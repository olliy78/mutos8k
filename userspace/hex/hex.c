/*
 * hex -- hexadecimal dump of files (MUTOS 8000 /bin/hex)
 *
 * NOT a V7 program: no source exists in the V7 trees of this repository.  Reconstructed from the
 * listing, the map and the strings of the original binary (doc/userspace/cmd_s3b5.md).
 * Output: "%06X" address, 8 groups of two bytes ("xxxx"), then the printable bytes; a run of equal
 * lines is replaced by a line "*" (like od).  File "-" means /dev/tty.
 */
#include <stdio.h>

char	fmt[] = "%06X %-40s  %s\n";

char	obuf[41];	/* hex text of the current line */
char	pbuf[41];	/* ... of the line kept for printing */
char	ascii[17];	/* printable bytes of the current line */
char	pascii[17];	/* ... of the kept line */
long	paddr;		/* address of the kept line */
long	addr;		/* address of the current line */

main(argc, argv)
register argc;
register char **argv;
{
	argc--;
	if (argc == 0)
		hex();
	else
		while (argv++, --argc >= 0) {
			if (strcmp(*argv, "-") == 0)
				freopen("/dev/tty", "r", stdin);
			else if (freopen(*argv, "r", stdin) == NULL) {
				fprintf(stderr, "hex: cannot open %s\n", *argv);
				continue;
			}
			hex();
		}
	exit(0);
}

hex()
{
	register j, c, i;
	long n;

	i = 0;
	n = 0;
	paddr = 0;
	for (;;) {
		if ((c = getc(stdin)) == EOF)
			break;
		if (i == 0)
			addr = n++ << 4;
		if (i % 2 == 0)
			sprintf(&obuf[i / 2 * 5], " %02x", c);
		else
			sprintf(&obuf[i / 2 * 5 + 3], "%02x", c);
		if ((unsigned)c > '~' || c < ' ')
			c = '.';
		ascii[i++] = c;
		if (i != 16)
			continue;
		i = 0;
		for (j = 0; j < 41; j++) {
			if (pbuf[j] != obuf[j]) {
				if (addr != 0) {
					printf(fmt, paddr, pbuf, pascii);
					if (addr - paddr > 16)
						printf("*\n");
				}
				paddr = addr;
				for (j = 0; j < 41; j++)
					pbuf[j] = obuf[j];
				for (j = 0; j < 16; j++)
					pascii[j] = ascii[j];
				break;
			}
		}
	}
	if (addr > 0) {
		printf(fmt, paddr, pbuf, pascii);
	}
	if (addr - paddr > 16)
		printf("*\n");
	if (i > 0 || addr > 0 && addr != paddr)
		if (i > 0)
			ascii[i] = 0;
	printf(fmt, addr, obuf, ascii);
	if (i != 0 || addr != 0)
		printf("%06X\n", (long)i + (i ? addr : addr + 16));
	return 0;
}
