/*

Prints the strict diagnostic verdict (and the library verdict) for one file.
Usage: diag_one <file.qoi>

*/

#define QOI_IMPLEMENTATION
#include "qoi.h"
#include "qoi_diag.h"

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
	FILE *f;
	long size;
	unsigned char *data;
	diag_decode_result dd;
	qoi_desc desc;
	void *px;

	if (argc != 2) { fprintf(stderr, "usage: %s <file>\n", argv[0]); return 2; }
	f = fopen(argv[1], "rb");
	if (!f) { perror(argv[1]); return 2; }
	fseek(f, 0, SEEK_END);
	size = ftell(f);
	fseek(f, 0, SEEK_SET);
	data = malloc(size > 0 ? size : 1);
	if (size > 0 && fread(data, 1, size, f) != (size_t)size) { return 2; }
	fclose(f);

	dd = diag_decode(data, (size_t)size, 0);
	px = qoi_decode(data, (int)size, &desc, 0);

	printf("size=%ld strict=%s", size, dd.res.ok ? "ok" : "fail");
	if (!dd.res.ok) { printf(" offset=%zu reason=\"%s\"", dd.res.offset, dd.res.reason); }
	printf(" lib=%s\n", px ? "accept" : "reject");

	free(px);
	free(dd.pixels);
	free(data);
	return 0;
}
