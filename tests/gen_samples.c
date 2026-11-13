/* Generates malformed-header and truncated-chunk QOI samples plus one
   valid reference image. All files are written to tests/samples/. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static void w32(FILE *f, uint32_t v) {
	unsigned char b[4] = {v >> 24, v >> 16, v >> 8, v};
	fwrite(b, 1, 4, f);
}

static void hdr(FILE *f, const char *magic, uint32_t w, uint32_t h,
                uint8_t ch, uint8_t cs) {
	fwrite(magic, 1, 4, f);
	w32(f, w); w32(f, h);
	unsigned char t[2] = {ch, cs};
	fwrite(t, 1, 2, f);
}

static void padding(FILE *f) {
	unsigned char pad[8] = {0,0,0,0,0,0,0,1};
	fwrite(pad, 1, 8, f);
}

static void mk(const char *name, const unsigned char *data, size_t n) {
	char path[256];
	snprintf(path, sizeof path, "tests/samples/%s", name);
	FILE *f = fopen(path, "wb");
	fwrite(data, 1, n, f);
	fclose(f);
	printf("wrote %s (%zu bytes)\n", path, n);
}

int main(void) {
	const char *magic = "qoif";
	unsigned char buf[64];
	FILE *f;

	/* 1. bad magic, otherwise plausible 1x1 RGBA header */
	f = tmpfile();
	hdr(f, "qoix", 1, 1, 4, 0);
	unsigned char rgba[5] = {0xff, 10, 20, 30, 40};
	fwrite(rgba, 1, 5, f);
	padding(f);
	rewind(f); size_t n = fread(buf, 1, sizeof buf, f);
	mk("01_bad_magic.qoi", buf, n); fclose(f);

	/* 2. width == 0 */
	f = tmpfile();
	hdr(f, magic, 0, 1, 4, 0); padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("02_zero_width.qoi", buf, n); fclose(f);

	/* 3. height == 0 */
	f = tmpfile();
	hdr(f, magic, 1, 0, 4, 0); padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("03_zero_height.qoi", buf, n); fclose(f);

	/* 4. channels == 2 (illegal) */
	f = tmpfile();
	hdr(f, magic, 1, 1, 2, 0); padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("04_channels_2.qoi", buf, n); fclose(f);

	/* 5. channels == 5 (illegal) */
	f = tmpfile();
	hdr(f, magic, 1, 1, 5, 0); padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("05_channels_5.qoi", buf, n); fclose(f);

	/* 6. colorspace == 2 (illegal) */
	f = tmpfile();
	hdr(f, magic, 1, 1, 4, 2); padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("06_colorspace_2.qoi", buf, n); fclose(f);

	/* 7. pixel count over QOI_PIXELS_MAX: 50000 * 10000 = 5e8 */
	f = tmpfile();
	hdr(f, magic, 50000u, 10000u, 4, 0); padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("07_pixels_too_large.qoi", buf, n); fclose(f);

	/* 8. huge dimensions that overflow 32-bit pixel math:
	   0xffffffff * 2 = 0x1fffffffe, truncated / channels multiply. */
	f = tmpfile();
	hdr(f, magic, 0xffffffffu, 2u, 4, 0); padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("08_dim_overflow.qoi", buf, n); fclose(f);

	/* 9. valid header but truncated QOI_OP_RGB (tag + 2 of 3 bytes) */
	f = tmpfile();
	hdr(f, magic, 1, 1, 4, 0);
	unsigned char trunc_rgb[3] = {0xfe, 1, 2};
	fwrite(trunc_rgb, 1, 3, f);
	padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("09_truncated_rgb.qoi", buf, n); fclose(f);

	/* 10. truncated QOI_OP_RGBA (tag + 3 of 4 bytes) */
	f = tmpfile();
	hdr(f, magic, 1, 1, 4, 0);
	unsigned char trunc_rgba[4] = {0xff, 1, 2, 3};
	fwrite(trunc_rgba, 1, 4, f);
	padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("10_truncated_rgba.qoi", buf, n); fclose(f);

	/* 11. truncated QOI_OP_LUMA (tag byte, missing second byte) */
	f = tmpfile();
	hdr(f, magic, 1, 1, 4, 0);
	unsigned char trunc_luma[1] = {0x80};
	fwrite(trunc_luma, 1, 1, f);
	padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("11_truncated_luma.qoi", buf, n); fclose(f);

	/* 12. header says 4 pixels but stream ends after 1 valid pixel */
	f = tmpfile();
	hdr(f, magic, 2, 2, 4, 0);
	fwrite(rgba, 1, 5, f);
	padding(f);
	rewind(f); n = fread(buf, 1, sizeof buf, f);
	mk("12_truncated_stream.qoi", buf, n); fclose(f);

	/* 13. valid reference: 2x2 RGBA, encoded with the encoder itself.
	   Done by a small helper below instead. */
	return 0;
}
