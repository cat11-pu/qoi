#!/usr/bin/env python3
"""Independent QOI reference decoder, written directly from the format spec.

Used as the reference implementation for the pixel-identical verification of
the 500 valid files: it decodes every <valid_dir>/*.qoi and compares the
result against the .raw ground truth and (transitively) the C decoder.

Usage: ref_decode.py <valid_dir> > ref_valid_results.jsonl
"""

import json
import sys
from pathlib import Path

END_MARKER = b"\x00\x00\x00\x00\x00\x00\x00\x01"


class QoiError(Exception):
    def __init__(self, offset, msg):
        super().__init__(msg)
        self.offset = offset


def decode(data: bytes, forced_channels: int = 0):
    # check order and messages mirror fuzz/qoi_diag.h exactly
    if len(data) < 14:
        raise QoiError(len(data), "truncated header (< 14 bytes)")
    if data[:4] != b"qoif":
        i = next(k for k in range(4) if data[k] != b"qoif"[k])
        raise QoiError(i, "bad magic bytes")
    w = int.from_bytes(data[4:8], "big")
    h = int.from_bytes(data[8:12], "big")
    ch, cs = data[12], data[13]
    if w == 0:
        raise QoiError(4, "width is zero")
    if h == 0:
        raise QoiError(8, "height is zero")
    if ch not in (3, 4):
        raise QoiError(12, "illegal channel count (must be 3 or 4)")
    if cs > 1:
        raise QoiError(13, "illegal colorspace (must be 0 or 1)")
    if w * h > 400_000_000:
        raise QoiError(4, "width*height exceeds 400M pixel limit")
    if len(data) < 14 + 8:
        raise QoiError(len(data), "truncated stream (no room for end marker)")

    out_ch = forced_channels or ch
    index = [(0, 0, 0, 0)] * 64
    r, g, b, a = 0, 0, 0, 255
    px = bytearray()
    pos, run = 14, 0
    limit = len(data) - 8

    for _ in range(w * h):
        if run > 0:
            run -= 1
        else:
            if pos >= limit:
                raise QoiError(pos, "stream exhausted before all pixels decoded")
            b1 = data[pos]
            if b1 == 0xFE:
                if pos + 4 > limit:
                    raise QoiError(pos, "truncated QOI_OP_RGB chunk")
                r, g, b = data[pos + 1], data[pos + 2], data[pos + 3]
                pos += 4
            elif b1 == 0xFF:
                if pos + 5 > limit:
                    raise QoiError(pos, "truncated QOI_OP_RGBA chunk")
                r, g, b, a = data[pos + 1], data[pos + 2], data[pos + 3], data[pos + 4]
                pos += 5
            elif b1 & 0xC0 == 0x00:
                r, g, b, a = index[b1]
                pos += 1
            elif b1 & 0xC0 == 0x40:
                r = (r + ((b1 >> 4 & 3) - 2)) & 0xFF
                g = (g + ((b1 >> 2 & 3) - 2)) & 0xFF
                b = (b + ((b1 & 3) - 2)) & 0xFF
                pos += 1
            elif b1 & 0xC0 == 0x80:
                if pos + 2 > limit:
                    raise QoiError(pos, "truncated QOI_OP_LUMA chunk")
                b2 = data[pos + 1]
                vg = (b1 & 0x3F) - 32
                r = (r + vg - 8 + (b2 >> 4)) & 0xFF
                g = (g + vg) & 0xFF
                b = (b + vg - 8 + (b2 & 0x0F)) & 0xFF
                pos += 2
            else:
                run = b1 & 0x3F
                pos += 1
            index[(r * 3 + g * 5 + b * 7 + a * 11) % 64] = (r, g, b, a)
        px += bytes((r, g, b))
        if out_ch == 4:
            px.append(a)

    if pos + 8 > len(data) or data[pos:pos + 8] != END_MARKER:
        raise QoiError(pos, "missing or corrupt 8-byte end marker")
    return (w, h, ch, cs), bytes(px)


def main():
    valid_dir = Path(sys.argv[1])
    for line in (valid_dir / "manifest.txt").read_text().splitlines():
        name, w, h, ch, cs = line.split()
        w, h, ch, cs = int(w), int(h), int(ch), int(cs)
        raw = (valid_dir / f"{name}.raw").read_bytes()
        rec = {"id": name}
        try:
            desc, px = decode((valid_dir / f"{name}.qoi").read_bytes())
            rec["desc_ok"] = desc == (w, h, ch, cs)
            rec["pixel_match"] = px == raw
        except QoiError as e:
            rec["desc_ok"] = False
            rec["pixel_match"] = False
            rec["error"] = f"offset {e.offset}: {e}"
        print(json.dumps(rec), flush=True)


if __name__ == "__main__":
    main()
