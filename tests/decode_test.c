/* Zero-crash / hardening test suite for qoi_decode.

   Covers:
     A. Every illegal-header class must return NULL.
     B. Truncated multi-byte chunks (RGB/RGBA/LUMA) must return NULL.
     C. Truncated pixel stream must return NULL.
     D. Hostile length/buffer geometry must never read out of bounds.
     E. Valid images must decode byte-identically to the source pixels,
        including forced 3/4 channel output.

   Build (sanitizers):
     gcc -std=c99 -O1 -g -fsanitize=address,undefined decode_test.c \
         -o decode_test
   The program prints a PASS/FAIL line per case and a final aggregate.
   Exit status is non-zero if any expectation is violated. */
#define QOI_IMPLEMENTATION
#include "../qoi.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static int cases = 0, failures = 0, crashes = 0;

static void w32(unsigned char *b, uint32_t v) {
	b[0] = (unsigned char)(v >> 24); b[1] = (unsigned char)(v >> 16);
	b[2] = (unsigned char)(v >> 8);  b[3] = (unsigned char)v;
}

/* Build a 14-byte header + 8-byte end marker (22 bytes minimum). */
static size_t build_header(unsigned char *buf, uint32_t w, uint32_t h,
                           uint8_t ch, uint8_t cs, const char *magic) {
	memcpy(buf, magic, 4);
	w32(buf + 4, w);
	w32(buf + 8, h);
	buf[12] = ch;
	buf[13] = cs;
	static const unsigned char pad[8] = {0,0,0,0,0,0,0,1};
	memcpy(buf + 14, pad, 8);
	return 22;
}

static void expect_null(const char *tag, const unsigned char *buf, int size,
                        int force_channels) {
	cases++;
	qoi_desc desc;
	void *px = qoi_decode(buf, size, &desc, force_channels);
	if (px != NULL) {
		failures++;
		printf("[FAIL] %-28s expected NULL, got pixels\n", tag);
		free(px);
	}
	else {
		printf("[ OK ] %-28s rejected (NULL)\n", tag);
	}
}

int main(void) {
	unsigned char buf[128];
	int n;

	/* ---- A. illegal headers ------------------------------------------------ */
	n = (int)build_header(buf, 1, 1, 4, 0, "qoix");
	expect_null("bad magic", buf, n, 0);

	n = (int)build_header(buf, 0, 1, 4, 0, "qoif");
	expect_null("zero width", buf, n, 0);

	n = (int)build_header(buf, 1, 0, 4, 0, "qoif");
	expect_null("zero height", buf, n, 0);

	n = (int)build_header(buf, 1, 1, 2, 0, "qoif");
	expect_null("channels=2", buf, n, 0);

	n = (int)build_header(buf, 1, 1, 5, 0, "qoif");
	expect_null("channels=5", buf, n, 0);

	n = (int)build_header(buf, 1, 1, 0, 0, "qoif");
	expect_null("channels=0", buf, n, 0);

	n = (int)build_header(buf, 1, 1, 255, 0, "qoif");
	expect_null("channels=255", buf, n, 0);

	n = (int)build_header(buf, 1, 1, 4, 2, "qoif");
	expect_null("colorspace=2", buf, n, 0);

	n = (int)build_header(buf, 1, 1, 4, 255, "qoif");
	expect_null("colorspace=255", buf, n, 0);

	/* pixel count over QOI_PIXELS_MAX */
	n = (int)build_header(buf, 50000u, 10000u, 4, 0, "qoif");
	expect_null("pixels > 400M", buf, n, 0);

	/* dimensions whose product overflows 32-bit math */
	n = (int)build_header(buf, 0xffffffffu, 2u, 4, 0, "qoif");
	expect_null("w*h 32-bit overflow", buf, n, 0);

	n = (int)build_header(buf, 0xffff0000u, 0xffff0000u, 4, 0, "qoif");
	expect_null("huge w and h", buf, n, 0);

	/* argument validation */
	{
		qoi_desc desc;
		cases++;
		if (qoi_decode(NULL, n, &desc, 0) != NULL) {
			failures++; printf("[FAIL] null data\n");
		} else { printf("[ OK ] null data rejected\n"); }

		cases++;
		if (qoi_decode(buf, n, NULL, 0) != NULL) {
			failures++; printf("[FAIL] null desc\n");
		} else { printf("[ OK ] null desc rejected\n"); }

		cases++;
		if (qoi_decode(buf, 10, &desc, 0) != NULL) {
			failures++; printf("[FAIL] size below minimum\n");
		} else { printf("[ OK ] size below minimum rejected\n"); }

		cases++;
		if (qoi_decode(buf, n, &desc, 7) != NULL) {
			failures++; printf("[FAIL] force channels=7\n");
		} else { printf("[ OK ] force channels=7 rejected\n"); }
	}

	/* ---- B. truncated multi-byte chunks ------------------------------------ */
	{
		static const unsigned char pad[8] = {0,0,0,0,0,0,0,1};

		/* RGB tag with only 2 of 3 payload bytes */
		n = (int)build_header(buf, 1, 1, 4, 0, "qoif");
		buf[14] = 0xfe; buf[15] = 1; buf[16] = 2;
		memcpy(buf + 17, pad, 8);
		expect_null("truncated RGB chunk", buf, 25, 0);

		/* RGBA tag with only 3 of 4 payload bytes */
		n = (int)build_header(buf, 1, 1, 4, 0, "qoif");
		buf[14] = 0xff; buf[15] = 1; buf[16] = 2; buf[17] = 3;
		memcpy(buf + 18, pad, 8);
		expect_null("truncated RGBA chunk", buf, 26, 0);

		/* LUMA tag missing its second byte */
		n = (int)build_header(buf, 1, 1, 4, 0, "qoif");
		buf[14] = 0x80;
		memcpy(buf + 15, pad, 8);
		expect_null("truncated LUMA chunk", buf, 23, 0);
	}

	/* ---- C. truncated pixel stream (header asks for more pixels) ----------- */
	{
		n = (int)build_header(buf, 2, 2, 4, 0, "qoif");
		unsigned char rgba[5] = {0xff, 10, 20, 30, 40};
		memcpy(buf + 14, rgba, 5);
		static const unsigned char pad[8] = {0,0,0,0,0,0,0,1};
		memcpy(buf + 19, pad, 8);
		expect_null("stream ends after 1 of 4 px", buf, 27, 0);
	}

	/* ---- D. hostile length/buffer geometry (ASan must stay silent) --------- */
	{
		/* Real allocation shorter than the claimed size: a truncated RGB
		   chunk sits where its payload crosses the allocation. */
		size_t real = 16;
		unsigned char *tight = calloc(real, 1);
		memcpy(tight, "qoif", 4);
		w32(tight + 4, 1); w32(tight + 8, 1);
		tight[12] = 4; tight[13] = 0;
		tight[14] = 0xfe; /* QOI_OP_RGB: payload would read past byte 15 */
		cases++;
		qoi_desc desc;
		void *px = qoi_decode(tight, 24, &desc, 0);
		if (px != NULL) { failures++; printf("[FAIL] tight-buffer OOB\n"); free(px); }
		else { printf("[ OK ] tight-buffer OOB rejected\n"); }
		free(tight);
	}

	/* ---- E. valid images decode identically -------------------------------- */
	{
		const int w = 8, h = 8;
		int variants[2] = {3, 4};
		for (int vi = 0; vi < 2; vi++) {
			int ch = variants[vi];
			size_t npx = (size_t)w * h * ch;
			unsigned char *src = malloc(npx);
			for (int y = 0; y < h; y++) {
				for (int x = 0; x < w; x++) {
					unsigned char *p = &src[((size_t)y * w + x) * ch];
					p[0] = (unsigned char)(x * 31 + 1);
					p[1] = (unsigned char)(y * 29 + 7);
					p[2] = (unsigned char)(x * 13 + y * 11);
					if (ch == 4) p[3] = (unsigned char)(x + y * 17);
				}
			}
			qoi_desc ed = { (unsigned)w, (unsigned)h, (unsigned char)ch, QOI_SRGB };
			int qlen = 0;
			void *qoi = qoi_encode(src, &ed, &qlen);
			if (!qoi) { failures++; printf("[FAIL] encode ch=%d\n", ch); free(src); continue; }

			/* native channels */
			qoi_desc dd;
			unsigned char *out = qoi_decode(qoi, qlen, &dd, 0);
			cases++;
			if (!out || dd.width != (unsigned)w || dd.height != (unsigned)h ||
			    dd.channels != (unsigned char)ch || memcmp(src, out, npx) != 0) {
				failures++;
				printf("[FAIL] roundtrip ch=%d native\n", ch);
			} else {
				printf("[ OK ] roundtrip ch=%d native (%d bytes)\n", ch, qlen);
			}
			free(out);

			/* forced channel output: 3->4 and 4->3 */
			int forced = (ch == 3) ? 4 : 3;
			out = qoi_decode(qoi, qlen, &dd, forced);
			cases++;
			if (!out || dd.channels != (unsigned char)ch) {
				failures++;
				printf("[FAIL] roundtrip ch=%d forced=%d\n", ch, forced);
			} else {
				int ok = 1;
				for (int i = 0; i < w * h && ok; i++) {
					const unsigned char *s = src + (size_t)i * ch;
					const unsigned char *o = out + (size_t)i * forced;
					if (o[0] != s[0] || o[1] != s[1] || o[2] != s[2]) ok = 0;
					if (forced == 4 && o[3] != 255) ok = 0;
					if (ch == 4 && forced == 3) { /* alpha dropped, fine */ }
					if (ch == 4 && forced == 4 && o[3] != s[3]) ok = 0;
				}
				if (!ok) { failures++; printf("[FAIL] forced pixel mismatch\n"); }
				else { printf("[ OK ] roundtrip ch=%d forced=%d\n", ch, forced); }
			}
			free(out);
			free(qoi);
			free(src);
		}
	}

	printf("\n==== %d cases, %d failures, %d sanitizer crashes ====\n",
	       cases, failures, crashes);
	return failures == 0 ? 0 : 1;
}
