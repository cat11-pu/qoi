/*
 * Experiment artifact, not part of the build.
 *
 * This file held a temporary encoder used during benchmarking: original
 * (predictable) DIFF/LUMA/RGB entropy branches + channel-split loops +
 * u32 pixel load + bulk 32-bit RGB store. The measurements showed it was
 * consistently faster than a cmov-based branchless entropy stage, so its
 * approach was merged into qoi_encode() in ../qoi.h. Kept for reference;
 * not compiled by the benchmark (bench.c / baseline.c / optimized.c only).
 */
