#!/usr/bin/env python3
"""Delta-debugging minimizer for crashing QOI inputs.

Usage: minimize.py <decode_one_binary> <crashing.qoi> <out.qoi>

Repeatedly tries to delete chunks of the input while the sanitizer-instrumented
decoder still exits non-zero (crash/OOB/UB). Produces a minimal counterexample.
"""

import subprocess
import sys


def crashes(binary: str, data: bytes) -> bool:
    with open("/tmp/.qoi_min_candidate", "wb") as f:
        f.write(data)
    r = subprocess.run([binary, "/tmp/.qoi_min_candidate"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                       timeout=30)
    return r.returncode != 0


def ddmin(binary: str, data: bytes) -> bytes:
    n = 2
    while len(data) >= 2:
        chunk = max(1, len(data) // n)
        reduced = False
        for start in range(0, len(data), chunk):
            candidate = data[:start] + data[start + chunk:]
            if candidate and crashes(binary, candidate):
                data = candidate
                n = max(2, n - 1)
                reduced = True
                break
        if not reduced:
            if n >= len(data):
                break
            n = min(len(data), n * 2)
    # final byte-wise cleanup pass
    i = 0
    while i < len(data):
        candidate = data[:i] + data[i + 1:]
        if candidate and crashes(binary, candidate):
            data = candidate
        else:
            i += 1
    return data


def main():
    binary, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]
    data = open(src, "rb").read()
    if not crashes(binary, data):
        print("input does not reproduce the crash", file=sys.stderr)
        sys.exit(1)
    minimal = ddmin(binary, data)
    open(dst, "wb").write(minimal)
    print(f"minimized {len(data)} -> {len(minimal)} bytes: {dst}")
    print(minimal.hex())


if __name__ == "__main__":
    main()
