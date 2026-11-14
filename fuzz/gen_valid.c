/*

Generates N_VALID valid QOI files plus their raw pixel dumps and a manifest.

The .raw files serve as the ground truth: both the decoder under test (qoi.h)
and the independent reference decoder (ref_decode.py) must reproduce them
pixel by pixel.

Build: gcc -std=c99 -O2 -I.. gen_valid.c -o gen_valid
Run:   ./gen_valid <outdir>

*/

#define QOI_IMPLEMENTATION
#include "qoi.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N_VALID 500

static unsigned long long rng_state = 0x9e3779b97f4a7c15ull;

static unsigned int rnd(void) {
	rng_state ^= rng_state << 13;
	rng_state ^= rng_state >> 7;
	rng_state ^= rng_state << 17;
	return (unsigned int)(rng_state >> 32);
}

/* Pixel patterns chosen to exercise all chunk types:
   0 = pure noise (RGB/RGBA chunks), 1 = solid color (RUN chunks),
   2 = smooth gradient (DIFF/LUMA chunks), 3 = repeats (INDEX chunks) */
static void gen_pixels(unsigned char *px, int w, int h, int channels, int pattern) {
	int i, n = w * h;
	switch (pattern) {
	case 0:
		for (i = 0; i < n * channels; i++) {
			px[i] = (unsigned char)rnd();
		}
		break;
	case 1: {
		unsigned char r = (unsigned char)rnd(), g = (unsigned char)rnd();
		unsigned char b = (unsigned char)rnd(), a = (unsigned char)rnd();
		for (i = 0; i < n; i++) {
			px[i * channels + 0] = r;
			px[i * channels + 1] = g;
			px[i * channels + 2] = b;
			if (channels == 4) { px[i * channels + 3] = a; }
		}
		break;
	}
	case 2:
		for (i = 0; i < n; i++) {
			px[i * channels + 0] = (unsigned char)(i % w);
			px[i * channels + 1] = (unsigned char)(i / w);
			px[i * channels + 2] = (unsigned char)(i * 3);
			if (channels == 4) { px[i * channels + 3] = 200; }
		}
		break;
	default: {
		unsigned char palette[8][4];
		int j;
		for (j = 0; j < 8; j++) {
			palette[j][0] = (unsigned char)rnd();
			palette[j][1] = (unsigned char)rnd();
			palette[j][2] = (unsigned char)rnd();
			palette[j][3] = (unsigned char)rnd();
		}
		for (i = 0; i < n; i++) {
			const unsigned char *c = palette[rnd() % 8];
			px[i * channels + 0] = c[0];
			px[i * channels + 1] = c[1];
			px[i * channels + 2] = c[2];
			if (channels == 4) { px[i * channels + 3] = c[3]; }
		}
		break;
	}
	}
}

int main(int argc, char **argv) {
	char path[4096];
	FILE *manifest;
	int i;

	if (argc != 2) {
		fprintf(stderr, "usage: %s <outdir>\n", argv[0]);
		return 1;
	}

	snprintf(path, sizeof(path), "%s/manifest.txt", argv[1]);
	manifest = fopen(path, "w");
	if (!manifest) { perror("manifest"); return 1; }

	for (i = 0; i < N_VALID; i++) {
		qoi_desc desc;
		unsigned char *pixels, *encoded;
		int enc_len, px_len;
		FILE *f;

		desc.width  = 1 + rnd() % 300;
		desc.height = 1 + rnd() % 300;
		desc.channels = 3 + (rnd() & 1);
		desc.colorspace = rnd() & 1;

		px_len = desc.width * desc.height * desc.channels;
		pixels = malloc(px_len);
		if (!pixels) { fprintf(stderr, "oom\n"); return 1; }
		gen_pixels(pixels, desc.width, desc.height, desc.channels, i % 4);

		encoded = qoi_encode(pixels, &desc, &enc_len);
		if (!encoded) { fprintf(stderr, "encode failed for %d\n", i); return 1; }

		snprintf(path, sizeof(path), "%s/%04d.qoi", argv[1], i);
		f = fopen(path, "wb");
		if (!f) { perror(path); return 1; }
		fwrite(encoded, 1, enc_len, f);
		fclose(f);

		snprintf(path, sizeof(path), "%s/%04d.raw", argv[1], i);
		f = fopen(path, "wb");
		if (!f) { perror(path); return 1; }
		fwrite(pixels, 1, px_len, f);
		fclose(f);

		fprintf(manifest, "%04d %u %u %d %d\n",
			i, desc.width, desc.height, desc.channels, desc.colorspace);

		free(pixels);
		free(encoded);
	}

	fclose(manifest);
	printf("generated %d valid files in %s\n", N_VALID, argv[1]);
	return 0;
}
