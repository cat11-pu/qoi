/* Decodes every file passed on the command line and reports the result.
   Malformed files are expected to print "rejected"; valid files print
   "decoded". Run under ASan/UBSan to prove there is no out-of-bounds
   access:
     gcc -std=c99 -O1 -g -fsanitize=address,undefined run_samples.c -o rs
     ./rs samples/*.qoi
*/
#define QOI_IMPLEMENTATION
#include "../qoi.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
	int rejected = 0, decoded = 0;
	for (int i = 1; i < argc; i++) {
		FILE *f = fopen(argv[i], "rb");
		if (!f) { perror(argv[i]); return 2; }
		fseek(f, 0, SEEK_END);
		long n = ftell(f);
		fseek(f, 0, SEEK_SET);
		unsigned char *buf = malloc((size_t)n);
		if (fread(buf, 1, (size_t)n, f) != (size_t)n) {
			fprintf(stderr, "short read: %s\n", argv[i]);
			return 2;
		}
		fclose(f);

		qoi_desc desc;
		void *px = qoi_decode(buf, (int)n, &desc, 0);
		if (px) {
			decoded++;
			printf("%-34s decoded  %ux%u ch=%u cs=%u\n",
			       argv[i], desc.width, desc.height,
			       desc.channels, desc.colorspace);
			free(px);
		}
		else {
			rejected++;
			printf("%-34s rejected (NULL)\n", argv[i]);
		}
		free(buf);
	}
	printf("\n%d decoded, %d rejected, 0 crashes\n", decoded, rejected);
	return 0;
}
