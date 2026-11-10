#include	<stdio.h>
#include 	<a.out.h>

/*
	size -- determine object size

*/

/* Differs from V7: MUTOS a.out.h has no A_MAGIC2, so it is not in the list. */
int a_magic[] = {A_MAGIC1,A_MAGIC3,A_MAGIC4,0};

main(argc, argv)
char **argv;
{
	struct exec buf;
	long sum;
	int gorp,i;
	FILE *f;

	if (argc==1) {
		*argv = "a.out";
		argc++;
		--argv;
	}
	gorp = argc;
	while(--argc) {
		++argv;
		if ((f = fopen(*argv, "r"))==NULL) {
			printf("size: %s not found\n", *argv);
			continue;
		}
		fread((char *)&buf, sizeof(buf), 1, f);
		for(i=0;a_magic[i];i++)
			if(a_magic[i] == buf.a_magic) break;
		if(a_magic[i] == 0) {
			printf("size: %s not an object file\n", *argv);
			fclose(f);
			continue;
		}
		if (gorp>2)
			printf("%s: ", *argv);
		/* Differs from V7 (%u): the original binary prints the three sizes in hex. */
		printf("%x+%x+%x = ", buf.a_text,buf.a_data,buf.a_bss);
		sum = (long) buf.a_text + (long) buf.a_data + (long) buf.a_bss;
		/* Differs from V7 (%Ob): the original binary prints the sum in hex. */
		printf("%Db = 0%Xb\n", sum, sum);
		fclose(f);
	}
}
