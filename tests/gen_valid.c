/* Encodes a valid 4x4 RGBA reference image via qoi_encode. */
#define QOI_IMPLEMENTATION
#include "../qoi.h"
#include <stdio.h>
#include <stdlib.h>

int main(void) {
	const int w = 4, h = 4, ch = 4;
	unsigned char px[4 * 4 * 4];
	for (int y = 0; y < h; y++) {
		for (int x = 0; x < w; x++) {
			unsigned char *p = &px[(y * w + x) * 4];
			p[0] = (unsigned char)(x * 60);
			p[1] = (unsigned char)(y * 60);
			p[2] = (unsigned char)(x * 30 + y * 15);
			p[3] = (unsigned char)(128 + x * 30);
		}
	}
	qoi_desc desc = { w, h, ch, QOI_SRGB };
	int len = 0;
	void *qoi = qoi_encode(px, &desc, &len);
	if (!qoi) { fprintf(stderr, "encode failed\n"); return 1; }
	FILE *f = fopen("tests/samples/13_valid_4x4.qoi", "wb");
	fwrite(qoi, 1, (size_t)len, f);
	fclose(f);
	free(qoi);
	printf("wrote tests/samples/13_valid_4x4.qoi (%d bytes)\n", len);
	return 0;
}
