/*

Strict, spec-based QOI stream validator with error offsets.

Written independently from the format documentation (not derived from qoi.h)
so it can act as a diagnostic oracle: for every input it either accepts and
decodes, or reports the exact byte offset and reason of the first spec
violation.

*/

#ifndef QOI_DIAG_H
#define QOI_DIAG_H

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define DIAG_PIXELS_MAX 400000000u

typedef struct {
	int ok;             /* 1 = valid stream, 0 = spec violation */
	size_t offset;      /* byte offset of the first violation */
	char reason[96];    /* human readable cause */
} diag_result;

typedef struct {
	diag_result res;
	unsigned width, height, channels, colorspace;
	unsigned char *pixels;  /* malloc'd, w*h*channels, only when res.ok */
} diag_decode_result;

static void diag_fail(diag_result *r, size_t off, const char *reason) {
	r->ok = 0;
	r->offset = off;
	snprintf(r->reason, sizeof(r->reason), "%s", reason);
}

static uint32_t diag_be32(const unsigned char *b) {
	return ((uint32_t)b[0] << 24) | ((uint32_t)b[1] << 16) |
	       ((uint32_t)b[2] << 8) | (uint32_t)b[3];
}

/* Strictly validate and decode. Forced channels: 0 = header, 3 or 4. */
static diag_decode_result diag_decode(const unsigned char *d, size_t n, int forced_channels) {
	static const unsigned char end_marker[8] = {0,0,0,0,0,0,0,1};
	diag_decode_result out;
	unsigned char index[64][4];
	unsigned char pr = 0, pg = 0, pb = 0, pa = 255;
	uint64_t px_done = 0, px_total;
	size_t pos = 14, out_pos = 0;
	int run = 0, channels;

	memset(&out, 0, sizeof(out));
	out.res.ok = 0;
	out.res.offset = 0;
	out.res.reason[0] = '\0';

	if (n < 14) {
		diag_fail(&out.res, n, "truncated header (< 14 bytes)");
		return out;
	}
	if (memcmp(d, "qoif", 4) != 0) {
		size_t i = 0;
		while (i < 4 && d[i] == "qoif"[i]) { i++; }
		diag_fail(&out.res, i, "bad magic bytes");
		return out;
	}
	out.width = diag_be32(d + 4);
	out.height = diag_be32(d + 8);
	out.channels = d[12];
	out.colorspace = d[13];

	if (out.width == 0) {
		diag_fail(&out.res, 4, "width is zero");
		return out;
	}
	if (out.height == 0) {
		diag_fail(&out.res, 8, "height is zero");
		return out;
	}
	if (out.channels != 3 && out.channels != 4) {
		diag_fail(&out.res, 12, "illegal channel count (must be 3 or 4)");
		return out;
	}
	if (out.colorspace > 1) {
		diag_fail(&out.res, 13, "illegal colorspace (must be 0 or 1)");
		return out;
	}
	if ((uint64_t)out.width * out.height > DIAG_PIXELS_MAX) {
		diag_fail(&out.res, 4, "width*height exceeds 400M pixel limit");
		return out;
	}
	if (n < 14 + 8) {
		diag_fail(&out.res, n, "truncated stream (no room for end marker)");
		return out;
	}

	channels = forced_channels ? forced_channels : (int)out.channels;
	px_total = (uint64_t)out.width * out.height;
	out.pixels = malloc(px_total * (unsigned)channels);
	if (!out.pixels) {
		diag_fail(&out.res, 0, "out of memory");
		return out;
	}
	memset(index, 0, sizeof(index));

	while (px_done < px_total) {
		unsigned char b1;
		if (run > 0) {
			run--;
		}
		else {
			if (pos >= n - 8) {
				diag_fail(&out.res, pos, "stream exhausted before all pixels decoded");
				free(out.pixels); out.pixels = NULL;
				return out;
			}
			b1 = d[pos];
			if (b1 == 0xfe) {           /* QOI_OP_RGB */
				if (pos + 4 > n - 8) {
					diag_fail(&out.res, pos, "truncated QOI_OP_RGB chunk");
					free(out.pixels); out.pixels = NULL;
					return out;
				}
				pr = d[pos+1]; pg = d[pos+2]; pb = d[pos+3];
				pos += 4;
			}
			else if (b1 == 0xff) {      /* QOI_OP_RGBA */
				if (pos + 5 > n - 8) {
					diag_fail(&out.res, pos, "truncated QOI_OP_RGBA chunk");
					free(out.pixels); out.pixels = NULL;
					return out;
				}
				pr = d[pos+1]; pg = d[pos+2]; pb = d[pos+3]; pa = d[pos+4];
				pos += 5;
			}
			else if ((b1 & 0xc0) == 0x00) {  /* QOI_OP_INDEX */
				pr = index[b1][0]; pg = index[b1][1];
				pb = index[b1][2]; pa = index[b1][3];
				pos += 1;
			}
			else if ((b1 & 0xc0) == 0x40) {  /* QOI_OP_DIFF */
				pr = (unsigned char)(pr + ((b1 >> 4 & 3) - 2));
				pg = (unsigned char)(pg + ((b1 >> 2 & 3) - 2));
				pb = (unsigned char)(pb + ((b1      & 3) - 2));
				pos += 1;
			}
			else if ((b1 & 0xc0) == 0x80) {  /* QOI_OP_LUMA */
				int b2, vg;
				if (pos + 2 > n - 8) {
					diag_fail(&out.res, pos, "truncated QOI_OP_LUMA chunk");
					free(out.pixels); out.pixels = NULL;
					return out;
				}
				b2 = d[pos+1];
				vg = (b1 & 0x3f) - 32;
				pr = (unsigned char)(pr + vg - 8 + (b2 >> 4));
				pg = (unsigned char)(pg + vg);
				pb = (unsigned char)(pb + vg - 8 + (b2 & 0x0f));
				pos += 2;
			}
			else {                          /* QOI_OP_RUN */
				run = b1 & 0x3f;
				pos += 1;
			}
			{
				unsigned h = (unsigned)(pr*3 + pg*5 + pb*7 + pa*11) % 64;
				index[h][0] = pr; index[h][1] = pg;
				index[h][2] = pb; index[h][3] = pa;
			}
		}
		out.pixels[out_pos++] = pr;
		out.pixels[out_pos++] = pg;
		out.pixels[out_pos++] = pb;
		if (channels == 4) { out.pixels[out_pos++] = pa; }
		px_done++;
	}

	if (pos + 8 > n || memcmp(d + pos, end_marker, 8) != 0) {
		diag_fail(&out.res, pos, "missing or corrupt 8-byte end marker");
		free(out.pixels); out.pixels = NULL;
		return out;
	}

	out.res.ok = 1;
	out.res.offset = pos + 8;
	snprintf(out.res.reason, sizeof(out.res.reason), "ok");
	return out;
}

#endif /* QOI_DIAG_H */
