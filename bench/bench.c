#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>

#include "qoi_baseline.h"

void *qoi_encode_ref(const void *data, const qoi_desc *desc, int *out_len);
void *qoi_encode_opt(const void *data, const qoi_desc *desc, int *out_len);
void *qoi_decode_ref(const void *data, int size, qoi_desc *desc, int channels);
void *qoi_decode_opt(const void *data, int size, qoi_desc *desc, int channels);

static uint64_t now_ns(void) {
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return (uint64_t)ts.tv_sec * 1000000000ull + ts.tv_nsec;
}

static uint32_t lcg_state = 0x12345678u;
static uint32_t lcg(void) {
	lcg_state = lcg_state * 1664525u + 1013904223u;
	return lcg_state;
}

/* Deterministic mixed-content generator: gradients (DIFF/LUMA), flat
   regions (RUN), a small palette (INDEX) and noise (RGB/RGBA). */
static unsigned char *gen_image(int w, int h, int channels) {
	size_t n = (size_t)w * h * channels;
	unsigned char *px = malloc(n);
	if (!px) { exit(1); }

	for (int y = 0; y < h; y++) {
		for (int x = 0; x < w; x++) {
			unsigned char *p = px + ((size_t)y * w + x) * channels;
			int mode = (x / 64 + y / 64) & 3;
			unsigned r, g, b, a = 255;

			switch (mode) {
			case 0:
				r = (unsigned)(x * 3 + y);
				g = (unsigned)(y * 2);
				b = (unsigned)(x + y * 5);
				break;
			case 1:
				r = g = b = 40;
				break;
			case 2: {
				static const unsigned char pal[6][3] = {
					{10, 200, 30}, {200, 10, 90}, {0, 0, 0},
					{255, 255, 255}, {77, 77, 77}, {12, 34, 200}
				};
				int k = (x + y * 3) % 6;
				r = pal[k][0]; g = pal[k][1]; b = pal[k][2];
				break;
			}
			default:
				r = lcg() & 0xff;
				g = lcg() & 0xff;
				b = lcg() & 0xff;
				break;
			}

			if (channels == 4 && (y % 17) == 0) {
				a = (unsigned char)(lcg() & 0xff);
			}

			p[0] = (unsigned char)r;
			p[1] = (unsigned char)g;
			p[2] = (unsigned char)b;
			if (channels == 4) {
				p[3] = (unsigned char)a;
			}
		}
	}
	return px;
}

static int verify_identical(const unsigned char *a, int na,
                            const unsigned char *b, int nb,
                            const char *tag) {
	if (na != nb) {
		printf("  [FAIL] %s: length mismatch %d != %d\n", tag, na, nb);
		return 0;
	}
	int first_bad = -1;
	for (int i = 0; i < na; i++) {
		if (a[i] != b[i]) { first_bad = i; break; }
	}
	if (first_bad >= 0) {
		printf("  [FAIL] %s: byte %d differs (0x%02x != 0x%02x) of %d bytes\n",
		       tag, first_bad, a[first_bad], b[first_bad], na);
		return 0;
	}
	return 1;
}

static int verify_roundtrip(const unsigned char *in, size_t px_bytes,
                            const unsigned char *qoi, int qoi_len,
                            int channels, const char *which,
                            void *(*decode)(const void *, int, qoi_desc *, int)) {
	qoi_desc d;
	unsigned char *out = decode(qoi, qoi_len, &d, channels);
	if (!out) {
		printf("  [FAIL] %s decode returned NULL\n", which);
		return 0;
	}
	if (memcmp(in, out, px_bytes) != 0) {
		printf("  [FAIL] %s roundtrip pixels differ\n", which);
		free(out);
		return 0;
	}
	free(out);
	return 1;
}

static int cmp_double(const void *a, const void *b) {
	double x = *(const double *)a, y = *(const double *)b;
	return (x > y) - (x < y);
}

static void bench3_pair(const unsigned char *px, qoi_desc *desc, int rounds,
                        double *r_ref, double *r_opt, double *mn_ref, double *mn_opt,
                        int *lr, int *lo,
                        unsigned char **br, unsigned char **bo) {
	double *tr = malloc(sizeof(double) * rounds);
	double *to = malloc(sizeof(double) * rounds);

	for (int r = 0; r < rounds; r++) {
		uint64_t t0, t1;

		t0 = now_ns();
		*br = qoi_encode_ref(px, desc, lr);
		t1 = now_ns();
		tr[r] = (double)(t1 - t0) / 1.0e6;

		t0 = now_ns();
		*bo = qoi_encode_opt(px, desc, lo);
		t1 = now_ns();
		to[r] = (double)(t1 - t0) / 1.0e6;

		if (r + 1 < rounds) { free(*br); free(*bo); }
	}

	qsort(tr, rounds, sizeof(double), cmp_double);
	qsort(to, rounds, sizeof(double), cmp_double);
	*r_ref = tr[rounds / 2];
	*r_opt = to[rounds / 2];
	*mn_ref = tr[0];
	*mn_opt = to[0];
	free(tr); free(to);
}
static int random_correctness(void) {
	int fails = 0;
	for (int t = 0; t < 3000; t++) {
		int w = 1 + (int)(lcg() % 70);
		int h = 1 + (int)(lcg() % 70);
		int channels = (lcg() & 1) ? 4 : 3;
		size_t n = (size_t)w * h * channels;
		unsigned char *px = malloc(n);
		for (size_t i = 0; i < n; i++) { px[i] = (unsigned char)lcg(); }

		qoi_desc d = { w, h, (unsigned char)channels, QOI_SRGB };
		int lr, lo;
		unsigned char *r = qoi_encode_ref(px, &d, &lr);
		unsigned char *o = qoi_encode_opt(px, &d, &lo);

		char tag[64];
		snprintf(tag, sizeof(tag), "random %dx%d c%d #%d", w, h, channels, t);
		if (!verify_identical(r, lr, o, lo, tag)) { fails++; }
		if (!verify_roundtrip(px, n, o, lo, channels, "opt", qoi_decode_opt)) { fails++; }

		free(r); free(o); free(px);
	}

	/* Boundary sizes: run flush at 62, 1-wide rows, tiny images. */
	int dims[][2] = {{1,1}, {1,2}, {2,1}, {1,62}, {1,63}, {1,124},
	                 {62,1}, {63,1}, {7,1}, {1,7}, {257,3}};
	for (unsigned k = 0; k < sizeof(dims)/sizeof(dims[0]); k++) {
		for (int channels = 3; channels <= 4; channels++) {
			int w = dims[k][0], h = dims[k][1];
			size_t n = (size_t)w * h * channels;
			unsigned char *px = malloc(n);
			memset(px, channels == 4 ? 0 : 0, n);
			for (size_t i = 0; i + channels <= n; i += channels) {
				px[i] = px[i+1] = px[i+2] = 9;
				if (channels == 4) { px[i+3] = 255; }
			}
			qoi_desc d = { w, h, (unsigned char)channels, QOI_SRGB };
			int lr, lo;
			unsigned char *r = qoi_encode_ref(px, &d, &lr);
			unsigned char *o = qoi_encode_opt(px, &d, &lo);
			char tag[64];
			snprintf(tag, sizeof(tag), "edge %dx%d c%d", w, h, channels);
			if (!verify_identical(r, lr, o, lo, tag)) { fails++; }
			free(r); free(o); free(px);
		}
	}
	return fails;
}

int main(void) {
	printf("== correctness: 3000 random images + boundary cases ==\n");
	int fails = random_correctness();
	printf(fails ? "== correctness: %d FAILURES ==\n"
	             : "== correctness: all byte-identical, roundtrips OK ==\n", fails);
	if (fails) { return 1; }

	struct { int w, h; const char *name; } sizes[] = {
		{ 1920, 1080, "1920x1080  (2.07 MP)" },
		{ 3840, 2160, "3840x2160  (8.29 MP)" },
		{ 4000, 2500, "4000x2500 (10.00 MP)" },
	};
	const int ROUNDS = 21;

	printf("\n%-26s %-3s %9s %9s %9s %9s %9s %s\n",
	       "size", "ch", "ref med", "opt med", "speedup",
	       "ref min", "opt min", "byte check");

	for (unsigned s = 0; s < sizeof(sizes)/sizeof(sizes[0]); s++) {
		int w = sizes[s].w, h = sizes[s].h;
		for (int channels = 4; channels >= 3; channels--) {
			unsigned char *px = gen_image(w, h, channels);
			size_t px_bytes = (size_t)w * h * channels;
			qoi_desc desc = { w, h, (unsigned char)channels, QOI_SRGB };

			int lr, lo;
			unsigned char *br, *bo;
			double ms_ref, ms_opt, ref_min, opt_min;
			bench3_pair(px, &desc, ROUNDS,
			            &ms_ref, &ms_opt, &ref_min, &opt_min,
			            &lr, &lo, &br, &bo);

			int ok = verify_identical(br, lr, bo, lo, sizes[s].name);
			ok &= verify_roundtrip(px, px_bytes, bo, lo, channels,
			                       "opt", qoi_decode_opt);

			printf("%-26s %-3d %9.2f %9.2f %8.2fx %9.2f %9.2f %s\n",
			       sizes[s].name, channels, ms_ref, ms_opt,
			       ms_ref / ms_opt, ref_min, opt_min,
			       ok ? "identical" : "DIFFER");

			free(br); free(bo); free(px);
		}
	}

	printf("\n(timing: %d interleaved ref/opt runs, median ms; malloc/free included)\n",
	       ROUNDS);
	return 0;
}
