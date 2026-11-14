/*

Fuzz/verification harness for the qoi.h decoder.

Modes:
  ./harness malformed <dir>   decode 00000.qoi.. with qoi_decode (channels
                              0, 3 and 4) and with the strict diagnostic
                              parser; emit one JSON line per file.
  ./harness valid <dir>       decode every valid file with qoi_decode and
                              the diagnostic decoder; compare pixel-by-pixel
                              against the .raw ground truth.

Build with sanitizers so any crash / OOB / leak aborts the process; the
progress line printed to stderr before each decode identifies the
responsible input file, which is already stored on disk.

*/

#define QOI_IMPLEMENTATION
#include "qoi.h"
#include "qoi_diag.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned char *read_file(const char *path, long *size_out) {
	FILE *f = fopen(path, "rb");
	unsigned char *buf;
	long size;
	if (!f) { return NULL; }
	fseek(f, 0, SEEK_END);
	size = ftell(f);
	fseek(f, 0, SEEK_SET);
	buf = malloc(size > 0 ? size : 1);
	if (!buf) { fclose(f); return NULL; }
	if (size > 0 && fread(buf, 1, size, f) != (size_t)size) {
		free(buf); fclose(f); return NULL;
	}
	fclose(f);
	*size_out = size;
	return buf;
}

static void json_escape(FILE *out, const char *s) {
	for (; *s; s++) {
		if (*s == '"' || *s == '\\') { fprintf(out, "\\%c", *s); }
		else if ((unsigned char)*s < 0x20) { fprintf(out, "\\u%04x", *s); }
		else { fputc(*s, out); }
	}
}

static int run_malformed(const char *dir, int count) {
	char path[4096];
	int i;

	for (i = 0; i < count; i++) {
		unsigned char *data;
		long size;
		qoi_desc desc;
		void *px0, *px3, *px4;
		diag_decode_result dd;

		snprintf(path, sizeof(path), "%s/%05d.qoi", dir, i);
		fprintf(stderr, "malformed %05d\r", i);
		fflush(stderr);

		data = read_file(path, &size);
		if (!data) {
			printf("{\"id\":%d,\"error\":\"unreadable\"}\n", i);
			continue;
		}

		px0 = qoi_decode(data, (int)size, &desc, 0);
		px3 = qoi_decode(data, (int)size, &desc, 3);
		px4 = qoi_decode(data, (int)size, &desc, 4);

		dd = diag_decode(data, (size_t)size, 0);

		printf("{\"id\":%d,\"lib_ch0\":%s,\"lib_ch3\":%s,\"lib_ch4\":%s,"
		       "\"diag_ok\":%d,\"diag_off\":%zu,\"diag_reason\":\"",
		       i,
		       px0 ? "true" : "false",
		       px3 ? "true" : "false",
		       px4 ? "true" : "false",
		       dd.res.ok, dd.res.offset);
		json_escape(stdout, dd.res.reason);
		printf("\"}\n");
		fflush(stdout);

		free(px0);
		free(px3);
		free(px4);
		free(dd.pixels);
		free(data);
	}
	fprintf(stderr, "\n");
	return 0;
}

/* Compare decoded pixels against ground truth, converting channels. */
static int pixels_match(const unsigned char *got, const unsigned char *ref,
                        long npix, int ref_ch, int got_ch) {
	long i;
	for (i = 0; i < npix; i++) {
		const unsigned char *r = ref + i * ref_ch;
		const unsigned char *g = got + i * got_ch;
		if (g[0] != r[0] || g[1] != r[1] || g[2] != r[2]) { return 0; }
		if (got_ch == 4) {
			unsigned char ref_a = ref_ch == 4 ? r[3] : 255;
			if (g[3] != ref_a) { return 0; }
		}
	}
	return 1;
}

static int run_valid(const char *dir) {
	char path[4096];
	char line[256];
	FILE *manifest;
	int total = 0, failures = 0;

	snprintf(path, sizeof(path), "%s/manifest.txt", dir);
	manifest = fopen(path, "r");
	if (!manifest) { perror(path); return 1; }

	while (fgets(line, sizeof(line), manifest)) {
		char name[16];
		unsigned w, h;
		int ch, cs;
		unsigned char *qoi_data, *raw;
		long qoi_size, raw_size, npix;
		qoi_desc desc;
		void *px0, *px3, *px4;
		diag_decode_result dd;
		int m0, m3, m4, dm, desc_ok;

		if (sscanf(line, "%15s %u %u %d %d", name, &w, &h, &ch, &cs) != 5) {
			continue;
		}
		fprintf(stderr, "valid %s\r", name);
		fflush(stderr);

		snprintf(path, sizeof(path), "%s/%s.qoi", dir, name);
		qoi_data = read_file(path, &qoi_size);
		snprintf(path, sizeof(path), "%s/%s.raw", dir, name);
		raw = read_file(path, &raw_size);
		if (!qoi_data || !raw) {
			printf("{\"id\":\"%s\",\"error\":\"unreadable\"}\n", name);
			failures++;
			continue;
		}
		npix = (long)w * h;

		memset(&desc, 0, sizeof(desc));
		px0 = qoi_decode(qoi_data, (int)qoi_size, &desc, 0);
		px3 = qoi_decode(qoi_data, (int)qoi_size, &desc, 3);
		px4 = qoi_decode(qoi_data, (int)qoi_size, &desc, 4);
		dd = diag_decode(qoi_data, (size_t)qoi_size, 0);

		desc_ok = px0 && desc.width == w && desc.height == h &&
		          desc.channels == ch && desc.colorspace == cs;
		m0 = px0 && pixels_match(px0, raw, npix, ch, ch);
		m3 = px3 && pixels_match(px3, raw, npix, ch, 3);
		m4 = px4 && pixels_match(px4, raw, npix, ch, 4);
		dm = dd.res.ok && dd.pixels &&
		     pixels_match(dd.pixels, raw, npix, ch, ch);

		printf("{\"id\":\"%s\",\"w\":%u,\"h\":%u,\"ch\":%d,\"cs\":%d,"
		       "\"desc_ok\":%d,\"ch0_match\":%d,\"ch3_match\":%d,"
		       "\"ch4_match\":%d,\"diag_match\":%d}\n",
		       name, w, h, ch, cs, desc_ok, m0, m3, m4, dm);
		fflush(stdout);

		if (!desc_ok || !m0 || !m3 || !m4 || !dm) { failures++; }
		total++;

		free(px0); free(px3); free(px4);
		free(dd.pixels);
		free(qoi_data); free(raw);
	}
	fclose(manifest);
	fprintf(stderr, "\nvalid: %d files, %d failures\n", total, failures);
	return failures ? 2 : 0;
}

int main(int argc, char **argv) {
	if (argc == 3 && strcmp(argv[1], "malformed") == 0) {
		return run_malformed(argv[2], 5000);
	}
	if (argc == 3 && strcmp(argv[1], "valid") == 0) {
		return run_valid(argv[2]);
	}
	fprintf(stderr, "usage: %s malformed|valid <dir>\n", argv[0]);
	return 1;
}
