#!/usr/bin/env python3
"""Builds minimal counterexamples: for every strict-checker failure reason,
take the smallest corpus file exhibiting it and delta-minimize while the
Python reference decoder still fails with the same reason.

Usage: min_counterexamples.py <report_dir>
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from ref_decode import decode, QoiError


def failure_reason(data):
    try:
        decode(data)
        return None
    except QoiError as e:
        return str(e)


def ddmin(data, reason):
    def fails_same(d):
        return bool(d) and failure_reason(d) == reason

    n = 2
    while len(data) >= 2:
        chunk = max(1, len(data) // n)
        reduced = False
        for start in range(0, len(data), chunk):
            cand = data[:start] + data[start + chunk:]
            if fails_same(cand):
                data, n = cand, max(2, n - 1)
                reduced = True
                break
        if not reduced:
            if n >= len(data):
                break
            n = min(len(data), n * 2)
    i = 0
    while i < len(data):
        cand = data[:i] + data[i + 1:]
        if fails_same(cand):
            data = cand
        else:
            i += 1
    return data


def main():
    report_dir = Path(sys.argv[1])
    mdir = report_dir / "corpus" / "malformed"
    outdir = report_dir / "counterexamples"
    outdir.mkdir(exist_ok=True)

    by_reason = defaultdict(list)
    for line in (report_dir / "malformed_results.jsonl").read_text().splitlines():
        r = json.loads(line)
        if not r["diag_ok"]:
            by_reason[r["diag_reason"]].append(r["id"])

    index = []
    for reason, ids in sorted(by_reason.items()):
        best_id, best_data = None, None
        for i in ids:
            data = (mdir / f"{i:05d}.qoi").read_bytes()
            if best_data is None or len(data) < len(best_data):
                best_id, best_data = i, data
        ref_reason = failure_reason(best_data)
        minimal = ddmin(best_data, ref_reason)
        slug = reason.replace(" ", "_").replace("(", "").replace(")", "")
        slug = slug.replace("<", "lt").replace("*", "x")[:48]
        path = outdir / f"{slug}.qoi"
        path.write_bytes(minimal)
        index.append({
            "reason": reason,
            "corpus_id": best_id,
            "original_size": len(best_data),
            "minimal_size": len(minimal),
            "file": path.name,
            "hex": minimal.hex(),
        })
        print(f"{reason}: {len(best_data)} -> {len(minimal)} bytes ({path.name})")

    (outdir / "index.json").write_text(json.dumps(index, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
