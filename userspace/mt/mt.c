/*
 * mt -- magtape manipulation program
 *
 * Not V7 text (V7 ships no mt command): reconstructed from the MUTOS binary
 * (strings, command table, ioctl code 'm'<<8|1); see doc/userspace/cmd_s5.md.
 */
#include <stdio.h>

#define	equal(s1,s2)	(strcmp(s1, s2) == 0)
#define	DEFTAPE	"/dev/nrmt0"
#define	MTIOCTOP	('m'<<8|1)

struct commands {
	char *c_name;
	int c_code;
	int c_ronly;
} com[] = {
	{ "eof",	0,	0 },
	{ "fsf",	1,	1 },
	{ "bsf",	2,	1 },
	{ "fsr",	3,	1 },
	{ "bsr",	4,	1 },
	{ "rewind",	5,	1 },
	{ "offline",	6,	1 },
	{ 0 }
};

struct mtop {
	int mt_op;
	int mt_count;
};

int mtfd;
struct mtop mt_com;
char *tape;

main(argc, argv)
char **argv;
{
	register char *cp;
	register struct commands *comp;

	if (argc < 2) {
		fprintf(stderr, "usage: mt [ -t tape ] command [ count ]\n");
		exit(1);
	}
	if (equal(argv[1], "-t") && argc > 2) {
		argc -= 2;
		tape = argv[2];
		argv += 2;
	} else
		tape = DEFTAPE;
	cp = argv[1];
	for (comp = com; comp->c_name != NULL; comp++)
		if (strncmp(cp, comp->c_name, strlen(cp)) == 0)
			break;
	if (comp->c_name == NULL) {
		fprintf(stderr, "mt: what's \"%s\" ?\n", cp);
		exit(1);
	}
	if ((mtfd = open(tape, comp->c_ronly ? 0 : 2)) < 0) {
		perror(tape);
		exit(1);
	}
	mt_com.mt_count = (argc > 2 ? atoi(argv[2]) : 1);
	mt_com.mt_op = comp->c_code;
	if (ioctl(mtfd, MTIOCTOP, &mt_com) < 0) {
		fprintf(stderr, "%s %d ", comp->c_name, mt_com.mt_count);
		perror("failed");
	}
}
