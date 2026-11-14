#!/usr/bin/env python3
"""Generates 5000 malformed QOI files from the valid corpus.

Categories (deterministic, seeded):
  truncation       1000  valid stream cut at a random offset
  header_misalign   400  bytes inserted/deleted inside the 14-byte header
  header_corrupt    600  random byte flips in magic/width/height fields
  bad_channels      500  channels byte set to an illegal value
  bad_colorspace    250  colorspace byte set to an illegal value
  oversize_dims     750  zero / huge / boundary width-height combinations
  chunk_corrupt    1000  flips, insertions, deletions in the chunk stream
  random_garbage    500  pure random buffers (half with valid magic)

Writes <outdir>/<idx>.qoi plus <outdir>/manifest.jsonl describing each case.
"""

import json
import random
import struct
import sys
from pathlib import Path


def load_valid(valid_dir: Path):
    files = []
    for line in (valid_dir / "manifest.txt").read_text().splitlines():
        name = line.split()[0]
        files.append((valid_dir / f"{name}.qoi").read_bytes())
    return files


def main():
    valid_dir, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)
    rng = random.Random(0xC0FFEE)
    valid = load_valid(valid_dir)
    cases = []

    def emit(data, category, desc):
        cases.append((category, desc, bytes(data)))

    # 1. truncation
    for _ in range(1000):
        src = rng.choice(valid)
        cut = rng.randrange(0, len(src))
        emit(src[:cut], "truncation", f"cut at offset {cut}/{len(src)}")

    # 2. header field misalignment: insert or delete bytes inside the header
    for _ in range(400):
        src = bytearray(rng.choice(valid))
        pos = rng.randrange(0, 14)
        if rng.random() < 0.5:
            src[pos:pos] = bytes([rng.randrange(256)])
            desc = f"inserted 1 byte at header offset {pos}"
        else:
            del src[pos]
            desc = f"deleted byte at header offset {pos}"
        emit(src, "header_misalign", desc)

    # 3. header corruption: flip bytes in magic / width / height
    for _ in range(600):
        src = bytearray(rng.choice(valid))
        pos = rng.randrange(0, 12)
        src[pos] ^= 1 << rng.randrange(8)
        emit(src, "header_corrupt", f"bit flip at header offset {pos}")

    # 4. illegal channel counts
    for _ in range(500):
        src = bytearray(rng.choice(valid))
        ch = rng.choice([0, 1, 2, 5, 6, 7, 8, 16, 255, rng.randrange(256)])
        if ch in (3, 4):
            ch = 0
        src[12] = ch
        emit(src, "bad_channels", f"channels={ch}")

    # 5. illegal colorspace
    for _ in range(250):
        src = bytearray(rng.choice(valid))
        cs = rng.randrange(2, 256)
        src[13] = cs
        emit(src, "bad_colorspace", f"colorspace={cs}")

    # 6. oversized / zero / boundary dimensions
    dim_cases = [
        (0, 1), (1, 0), (0, 0),
        (0xFFFFFFFF, 0xFFFFFFFF), (0xFFFFFFFF, 1), (1, 0xFFFFFFFF),
        (400_000_000, 1), (400_000_001, 1), (200_000_000, 2),
        (20_000, 20_000), (20_001, 20_000), (65536, 65536),
        (0x10000, 0x10000), (0x7FFFFFFF, 2), (2, 0x7FFFFFFF),
    ]
    for i in range(750):
        src = bytearray(rng.choice(valid))
        if i < len(dim_cases):
            w, h = dim_cases[i]
        else:
            w = rng.choice([0, 1, rng.randrange(2**32), rng.randrange(10**6, 2**32)])
            h = rng.choice([0, 1, rng.randrange(2**32), rng.randrange(10**6, 2**32)])
        src[4:12] = struct.pack(">II", w, h)
        emit(src, "oversize_dims", f"width={w} height={h}")

    # 7. chunk stream corruption
    for _ in range(1000):
        src = bytearray(rng.choice(valid))
        op = rng.random()
        pos = 14
        if op < 0.4:  # flip random bytes after the header
            for _ in range(rng.randrange(1, 8)):
                pos = rng.randrange(14, len(src))
                src[pos] ^= 1 << rng.randrange(8)
            desc = f"bit flips in chunk stream, last at {pos}"
        elif op < 0.6:  # corrupt the end marker
            pos = rng.randrange(len(src) - 8, len(src))
            src[pos] ^= 0xFF
            desc = f"end marker corrupted at {pos}"
        elif op < 0.8:  # insert garbage into the chunk stream
            pos = rng.randrange(14, len(src))
            junk = bytes(rng.randrange(256) for _ in range(rng.randrange(1, 16)))
            src[pos:pos] = junk
            desc = f"inserted {len(junk)} garbage bytes at {pos}"
        else:  # delete a slice of the chunk stream
            pos = rng.randrange(14, len(src))
            end = min(len(src), pos + rng.randrange(1, 32))
            del src[pos:end]
            desc = f"deleted bytes [{pos},{end})"
        emit(src, "chunk_corrupt", desc)

    # 8. random garbage
    for i in range(500):
        n = rng.randrange(0, 256)
        buf = bytearray(rng.randrange(256) for _ in range(n))
        if i % 2 == 0 and n >= 14:
            buf[0:4] = b"qoif"
            buf[12] = rng.choice([3, 4])
            buf[13] = rng.randrange(2)
            desc = "random garbage with valid magic/channels"
        else:
            desc = "random garbage"
        emit(buf, "random_garbage", desc)

    assert len(cases) == 5000, len(cases)
    with (out_dir / "manifest.jsonl").open("w") as mf:
        for idx, (cat, desc, data) in enumerate(cases):
            (out_dir / f"{idx:05d}.qoi").write_bytes(data)
            mf.write(json.dumps({"id": idx, "file": f"{idx:05d}.qoi",
                                 "category": cat, "mutation": desc,
                                 "size": len(data)}) + "\n")
    print(f"generated {len(cases)} malformed files in {out_dir}")


if __name__ == "__main__":
    main()
