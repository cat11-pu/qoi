# qoi_decode hardening — samples and zero-crash tests

Everything in this directory targets the decoder in `../qoi.h`.
The goal: any illegal header or truncated stream returns `NULL`
(the library's error code), with no crash, no out-of-bounds read and no
oversized allocation, while valid files decode byte-identically.

## Samples (`samples/`)

All files are the on-disk byte sequences fed straight to `qoi_decode`.

| File | Class | Expected |
|------|-------|----------|
| `01_bad_magic.qoi` | magic bytes are not `qoif` | NULL |
| `02_zero_width.qoi` | header width == 0 | NULL |
| `03_zero_height.qoi` | header height == 0 | NULL |
| `04_channels_2.qoi` | channels == 2 (only 3/4 legal) | NULL |
| `05_channels_5.qoi` | channels == 5 | NULL |
| `06_colorspace_2.qoi` | colorspace == 2 (only 0/1 legal) | NULL |
| `07_pixels_too_large.qoi` | width*height = 5e8 > `QOI_PIXELS_MAX` | NULL |
| `08_dim_overflow.qoi` | 0xffffffff x 2, 32-bit product overflow | NULL |
| `09_truncated_rgb.qoi` | `QOI_OP_RGB` with only 2 of 3 payload bytes | NULL |
| `10_truncated_rgba.qoi` | `QOI_OP_RGBA` with only 3 of 4 payload bytes | NULL |
| `11_truncated_luma.qoi` | `QOI_OP_LUMA` missing its second byte | NULL |
| `12_truncated_stream.qoi` | header asks for 4 pixels, stream has 1 | NULL |
| `13_valid_4x4.qoi` | well-formed 4x4 RGBA image | pixels |

Regenerate the binary samples deterministically:

```sh
gcc -std=c99 -O1 gen_samples.c -o gen_samples && ./gen_samples
gcc -std=c99 -O1 gen_valid.c   -o gen_valid   && ./gen_valid
```

## Test programs

- `run_samples.c` — decodes every file named on argv and reports
  `decoded` / `rejected`. Use it to sweep the sample directory.
- `decode_test.c` — the full zero-crash suite: illegal-header matrix,
  truncated chunks, truncated pixel stream, a hostile length/buffer
  geometry (allocation shorter than the claimed `size`, which is what
  makes the original code read out of bounds), and valid roundtrips
  including forced 3/4-channel output.

## Build and run

```sh
# sample sweep under ASan + UBSan
gcc -std=c99 -O1 -g -fsanitize=address,undefined run_samples.c -o run_samples
./run_samples samples/*.qoi

# full hardening suite (prints an aggregate; non-zero exit on any failure)
gcc -std=c99 -O1 -g -fsanitize=address,undefined decode_test.c -o decode_test
./decode_test
```

A clean run ends with `0 failures, 0 sanitizer crashes`.
