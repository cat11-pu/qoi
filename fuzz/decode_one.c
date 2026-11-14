/*

Single-file reproducer: decodes one QOI file with qoi_decode (channels 0, 3
and 4). Built with sanitizers; any crash/OOB/leak aborts with a non-zero
exit code, which is what minimize.py keys on.

*/

#define QOI_IMPLEMENTATION
#include "qoi.h"

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
	FILE *f;
	long size;
	unsigned char *data;
	qoi_desc desc;
	void *px;
	int ch;

	if (argc != 2) {
		fprintf(stderr, "usage: %s <file.qoi>\n", argv[0]);
		return 2;
	}
	f = fopen(argv[1], "rb");
	if (!f) { perror(argv[1]); return 2; }
	fseek(f, 0, SEEK_END);
	size = ftell(f);
	fseek(f, 0, SEEK_SET);
	data = malloc(size > 0 ? size : 1);
	if (!data) { fclose(f); return 2; }
	if (size > 0 && fread(data, 1, size, f) != (size_t)size) {
		free(data); fclose(f); return 2;
	}
	fclose(f);

	for (ch = 0; ch <= 4; ch += ch == 0 ? 3 : 1) {
		px = qoi_decode(data, (int)size, &desc, ch);
		free(px);
	}
	free(data);
	return 0;
}
