/*
qoirowtest - correctness and memory tests for the row-by-row decoder
(qoi_decode_init / qoi_decode_row) against the one-shot qoi_decode.

Usage:
	qoirowtest            run the correctness test suite
	qoirowtest gen W H file.qoi   generate a test image
	qoirowtest dec file.qoi full|rows   measure peak RSS of a decode
*/

#define QOI_IMPLEMENTATION
#include "qoi.h"

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/resource.h>

static uint64_t rng_state = 0x9e3779b97f4a7c15ull;
static uint32_t rnd32(void) {
	uint64_t x = rng_state;
	x ^= x << 13;
	x ^= x >> 7;
	x ^= x << 17;
	rng_state = x;
	return (uint32_t)(x >> 32);
}

/* FNV-1a 64 bit */
static uint64_t hash_bytes(const unsigned char *data, size_t len, uint64_t h) {
	size_t i;
	for (i = 0; i < len; i++) {
		h ^= data[i];
		h *= 0x100000001b3ull;
	}
	return h;
}

/* Generate an image that exercises all chunk types: solid bands (long runs
spanning multiple rows), a small palette (INDEX), smooth gradients
(DIFF/LUMA) and white noise (RGB/RGBA chunks). */
static void gen_image(unsigned char *px, int w, int h, int channels) {
	int x, y;
	for (y = 0; y < h; y++) {
		unsigned char *row = px + (size_t)y * w * channels;
		int band = (y * 4) / (h > 4 ? h : 1);
		for (x = 0; x < w; x++) {
			unsigned char *p = row + (size_t)x * channels;
			switch (band) {
			case 0: /* solid color -> long QOI_OP_RUN chains */
				p[0] = 200; p[1] = 100; p[2] = 50;
				if (channels == 4) { p[3] = 255; }
				break;
			case 1: /* small palette -> QOI_OP_INDEX */
				p[0] = (unsigned char)((x & 3) * 60);
				p[1] = (unsigned char)((x & 1) * 200);
				p[2] = (unsigned char)((x & 7) * 30);
				if (channels == 4) { p[3] = (unsigned char)(128 + (x & 1) * 127); }
				break;
			case 2: /* smooth gradient -> QOI_OP_DIFF / QOI_OP_LUMA */
				p[0] = (unsigned char)(x + y);
				p[1] = (unsigned char)(x * 2 + y);
				p[2] = (unsigned char)(x + y * 3);
				if (channels == 4) { p[3] = 255; }
				break;
			default: /* noise -> QOI_OP_RGB / QOI_OP_RGBA */
				p[0] = (unsigned char)rnd32();
				p[1] = (unsigned char)rnd32();
				p[2] = (unsigned char)rnd32();
				if (channels == 4) { p[3] = (unsigned char)rnd32(); }
				break;
			}
		}
	}
}

/* Decode the whole image row by row and hash the output. */
static uint64_t hash_row_decode(const void *qoi_data, int qoi_size, int channels) {
	qoi_decoder dec;
	unsigned char *row;
	uint64_t h = 1469598103934665603ull;
	unsigned int rows = 0;

	if (!qoi_decode_init(&dec, qoi_data, qoi_size, channels)) {
		return 0;
	}
	row = (unsigned char *)malloc((size_t)dec.desc.width * dec.channels);
	while (qoi_decode_row(&dec, row)) {
		h = hash_bytes(row, (size_t)dec.desc.width * dec.channels, h);
		rows++;
	}
	free(row);
	if (rows != dec.desc.height) {
		fprintf(stderr, "FAIL: decoded %u rows, expected %u\n", rows, dec.desc.height);
		exit(1);
	}
	return h;
}

static uint64_t hash_full_decode(const void *qoi_data, int qoi_size, int channels) {
	qoi_desc desc;
	unsigned char *px;
	uint64_t h;
	px = (unsigned char *)qoi_decode(qoi_data, qoi_size, &desc, channels);
	if (!px) {
		return 0;
	}
	if (channels == 0) {
		channels = desc.channels;
	}
	h = hash_bytes(px, (size_t)desc.width * desc.height * channels, 1469598103934665603ull);
	free(px);
	return h;
}

static int g_failures = 0;

static void check_identical(const char *name, const void *qoi_data, int qoi_size, int channels) {
	uint64_t h_full = hash_full_decode(qoi_data, qoi_size, channels);
	uint64_t h_rows = hash_row_decode(qoi_data, qoi_size, channels);
	if (h_full != h_rows) {
		printf("FAIL %-40s full=%016llx rows=%016llx\n", name,
			(unsigned long long)h_full, (unsigned long long)h_rows);
		g_failures++;
	}
	else {
		printf("ok   %-40s hash=%016llx\n", name, (unsigned long long)h_full);
	}
}

static void test_image(int w, int h, int file_channels, int out_channels) {
	qoi_desc desc;
	void *enc;
	int enc_len;
	char name[64];
	unsigned char *px = (unsigned char *)malloc((size_t)w * h * file_channels);

	gen_image(px, w, h, file_channels);
	desc.width = w;
	desc.height = h;
	desc.channels = file_channels;
	desc.colorspace = QOI_SRGB;
	enc = qoi_encode(px, &desc, &enc_len);
	if (!enc) {
		printf("FAIL encode %dx%d\n", w, h);
		g_failures++;
		free(px);
		return;
	}

	snprintf(name, sizeof(name), "%dx%d ch%d->ch%d", w, h, file_channels,
		out_channels ? out_channels : file_channels);
	check_identical(name, enc, enc_len, out_channels);

	free(enc);
	free(px);
}

static void test_truncated(void) {
	qoi_desc desc = { 517, 239, 4, QOI_SRGB };
	unsigned char *px = malloc((size_t)desc.width * desc.height * 4);
	void *enc;
	int enc_len;
	int cut;
	char name[64];

	gen_image(px, desc.width, desc.height, 4);
	enc = qoi_encode(px, &desc, &enc_len);

	/* Cut the stream at various points; the decoder must repeat the last
	pixel for the missing tail - identically in both APIs. */
	for (cut = 22; cut < enc_len; cut += (enc_len - 22) / 7 + 1) {
		snprintf(name, sizeof(name), "truncated at %d/%d", cut, enc_len);
		check_identical(name, enc, cut, 0);
	}

	free(enc);
	free(px);
}

static void test_boundaries(void) {
	qoi_desc desc = { 33, 5, 4, QOI_SRGB };
	unsigned char px[33 * 5 * 4];
	unsigned char row[33 * 4];
	void *enc;
	int enc_len;
	qoi_decoder dec;
	unsigned int rows;

	gen_image(px, 33, 5, 4);
	enc = qoi_encode(px, &desc, &enc_len);

	/* qoi_decode_row() past the last row must return 0 */
	if (!qoi_decode_init(&dec, enc, enc_len, 0)) {
		printf("FAIL boundary: init\n");
		g_failures++;
	}
	rows = 0;
	while (qoi_decode_row(&dec, row)) { rows++; }
	if (rows != 5 || qoi_decode_row(&dec, row) != 0 || dec.rows_decoded != 5) {
		printf("FAIL boundary: rows past end (got %u rows)\n", rows);
		g_failures++;
	}
	else {
		printf("ok   rows-past-end returns 0\n");
	}

	/* NULL row buffer must return 0 without crashing */
	if (qoi_decode_init(&dec, enc, enc_len, 0)) {
		if (qoi_decode_row(&dec, NULL) != 0) {
			printf("FAIL boundary: NULL row buffer\n");
			g_failures++;
		}
		else {
			printf("ok   NULL row buffer returns 0\n");
		}
	}

	/* Invalid inputs must fail init */
	{
		unsigned char bad[64];
		int ok = 1;
		memset(bad, 0, sizeof(bad));
		ok &= !qoi_decode_init(&dec, NULL, enc_len, 0);
		ok &= !qoi_decode_init(NULL, enc, enc_len, 0);
		ok &= !qoi_decode_init(&dec, enc, 10, 0);          /* too small */
		ok &= !qoi_decode_init(&dec, enc, enc_len, 2);     /* bad channels */
		ok &= !qoi_decode_init(&dec, bad, sizeof(bad), 0); /* bad magic */
		memcpy(bad, enc, sizeof(bad) < (size_t)enc_len ? sizeof(bad) : (size_t)enc_len);
		bad[7] = 0; /* width = 0 */
		ok &= !qoi_decode_init(&dec, bad, sizeof(bad), 0);
		if (!ok) {
			printf("FAIL boundary: invalid input accepted\n");
			g_failures++;
		}
		else {
			printf("ok   invalid inputs rejected\n");
		}
	}

	free(enc);
}

static long peak_rss_kb(void) {
	struct rusage ru;
	getrusage(RUSAGE_SELF, &ru);
	return ru.ru_maxrss;
}

static int gen_file(int w, int h, const char *filename) {
	qoi_desc desc = { 0, 0, 4, QOI_SRGB };
	unsigned char *px;
	void *enc;
	int enc_len;
	FILE *f;

	desc.width = w;
	desc.height = h;
	px = malloc((size_t)w * h * 4);
	gen_image(px, w, h, 4);
	enc = qoi_encode(px, &desc, &enc_len);
	free(px);
	if (!enc) {
		fprintf(stderr, "encode failed\n");
		return 1;
	}
	f = fopen(filename, "wb");
	if (!f || fwrite(enc, 1, enc_len, f) != (size_t)enc_len) {
		fprintf(stderr, "cannot write %s\n", filename);
		return 1;
	}
	fclose(f);
	printf("wrote %s: %dx%d rgba, %d KB encoded\n", filename, w, h, enc_len / 1024);
	free(enc);
	return 0;
}

static int dec_file(const char *filename, int rows_mode) {
	FILE *f = fopen(filename, "rb");
	long fsize;
	unsigned char *enc;
	long base, peak;
	uint64_t hash;

	if (!f) {
		fprintf(stderr, "cannot open %s\n", filename);
		return 1;
	}
	fseek(f, 0, SEEK_END);
	fsize = ftell(f);
	fseek(f, 0, SEEK_SET);
	enc = malloc(fsize);
	if (fread(enc, 1, fsize, f) != (size_t)fsize) {
		fprintf(stderr, "cannot read %s\n", filename);
		return 1;
	}
	fclose(f);

	base = peak_rss_kb();
	if (rows_mode) {
		hash = hash_row_decode(enc, fsize, 0);
	}
	else {
		hash = hash_full_decode(enc, fsize, 0);
	}
	peak = peak_rss_kb();

	printf("%s %s: encoded=%ld KB, decode peak RSS delta=%ld KB, hash=%016llx\n",
		rows_mode ? "rows" : "full", filename, fsize / 1024, peak - base,
		(unsigned long long)hash);

	free(enc);
	return 0;
}

int main(int argc, char **argv) {
	if (argc >= 5 && strcmp(argv[1], "gen") == 0) {
		int w = atoi(argv[2]);
		int h = atoi(argv[3]);
		return gen_file(w, h, argv[4]);
	}
	if (argc >= 4 && strcmp(argv[1], "dec") == 0) {
		int rows_mode = strcmp(argv[3], "rows") == 0;
		return dec_file(argv[2], rows_mode);
	}

	test_image(1, 1, 4, 0);
	test_image(3, 1, 3, 0);
	test_image(1, 7, 4, 0);
	test_image(64, 64, 3, 0);
	test_image(641, 479, 4, 0);
	test_image(641, 479, 3, 0);
	test_image(2000, 3, 4, 0);   /* runs spanning rows */
	test_image(641, 479, 4, 3);  /* forced channels rgba -> rgb */
	test_image(641, 479, 3, 4);  /* forced channels rgb -> rgba */
	test_truncated();
	test_boundaries();

	if (g_failures) {
		printf("%d FAILURES\n", g_failures);
		return 1;
	}
	printf("all tests passed\n");
	return 0;
}
