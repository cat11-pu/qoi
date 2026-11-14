#!/bin/sh
# End-to-end fuzz + verification pipeline. Run from the repo root:
#   sh fuzz/run_all.sh
set -e

ROOT=$(cd "$(dirname "$0")/.." && pwd)
REPORT="$ROOT/artifacts/fuzz-report"
CORPUS="$REPORT/corpus"
SAN="-fsanitize=address,undefined,leak -fno-omit-frame-pointer"

mkdir -p "$CORPUS/valid" "$CORPUS/malformed" "$REPORT/counterexamples"

echo "== build =="
gcc -std=c99 -O2 -I"$ROOT" "$ROOT/fuzz/gen_valid.c" -o "$ROOT/fuzz/gen_valid"
gcc -std=c99 -O1 -g $SAN -I"$ROOT" -I"$ROOT/fuzz" "$ROOT/fuzz/harness.c" -o "$ROOT/fuzz/harness"
gcc -std=c99 -O1 -g $SAN -I"$ROOT" "$ROOT/fuzz/decode_one.c" -o "$ROOT/fuzz/decode_one"

echo "== generate corpus =="
"$ROOT/fuzz/gen_valid" "$CORPUS/valid"
python3 "$ROOT/fuzz/gen_malformed.py" "$CORPUS/valid" "$CORPUS/malformed"

echo "== fuzz 5000 malformed (ASan/UBSan/LSan) =="
if ! "$ROOT/fuzz/harness" malformed "$CORPUS/malformed" > "$REPORT/malformed_results.jsonl" 2> "$REPORT/malformed_stderr.log"; then
	echo "!! sanitizer abort during malformed run; see $REPORT/malformed_stderr.log"
fi

echo "== verify 500 valid (ASan/UBSan/LSan) =="
"$ROOT/fuzz/harness" valid "$CORPUS/valid" > "$REPORT/valid_results.jsonl" 2> "$REPORT/valid_stderr.log"

echo "== reference implementation cross-check =="
python3 "$ROOT/fuzz/ref_decode.py" "$CORPUS/valid" > "$REPORT/ref_valid_results.jsonl"

echo "== report =="
python3 "$ROOT/fuzz/make_report.py" "$REPORT"
