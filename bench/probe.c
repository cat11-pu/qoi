/*
 * Experiment artifact, not part of the build.
 *
 * This file held a temporary encoder identical to the branchy variant but
 * with a file-scope (static) 64-entry index table to skip stack clearing.
 * Measurements showed it was slightly slower due to worse cache locality,
 * so the stack-local index was retained in ../qoi.h.
 */
