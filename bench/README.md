# qoi_encode optimization benchmark

Compares the original reference encoder (`qoi_baseline.h`, an unmodified
copy of the upstream `qoi.h`) against the optimized `qoi_encode()` in
`../qoi.h`.

## What is measured

Both encoders are compiled into the same binary and fed the exact same
deterministically generated RGBA/RGB pixel buffers. For every image the
benchmark asserts:

- identical encoded length,
- byte-for-byte identical output (`memcmp` over the whole stream),
- successful decode roundtrip of the optimized output.

The image generator mixes gradients (DIFF/LUMA), flat regions (RUN),
a small palette (INDEX) and random noise (RGB/RGBA) so every chunk type
is exercised.

## Build and run

```sh
gcc -std=gnu99 -O3 -Wall -Wextra baseline.c optimized.c bench.c -o bench
./bench

# differential fuzzing (20k adversarial images)
gcc -std=gnu99 -O2 baseline.c optimized.c fuzz_diff.c -o fuzz_diff
./fuzz_diff

# memory / UB validation
gcc -std=gnu99 -O1 -g -fsanitize=address,undefined \
    baseline.c optimized.c bench.c -o bench_san
./bench_san
```

Pin to one core for less scheduling jitter, e.g. `taskset -c 2 ./bench`.
Timing uses interleaved ref/opt runs and reports the median and minimum
wall time of the encode call (including its `malloc`/`free`).

## Files

- `qoi_baseline.h` - pristine upstream encoder used as the reference.
- `baseline.c` / `optimized.c` - compile each header with renamed symbols.
- `bench.c` - correctness suite (3000 random images + boundary sizes) and
  the three-size timing table.
- `fuzz_diff.c` - 20k adversarial differential tests.
- `variant_branchy.c`, `probe.c` - notes from discarded experiments
  (branchless entropy stage; static index table), not part of the build.
- `pure.c` - focused 10 MP RGBA timing with median/min reporting.

The three reported sizes are 1920x1080 (2.07 MP), 3840x2160 (8.29 MP)
and 4000x2500 (10.00 MP), each encoded as both RGBA and RGB.
