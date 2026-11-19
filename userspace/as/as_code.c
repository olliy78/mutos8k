/* as_code.c: reconstructed /usr/bin/as, original addresses 1C0C..31BA (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
#include "as.h"

/* TEMPORARY STUB for the function at 1C0C (original 1C0C) */
f1c0c()
{
	return (0);
}

/* TEMPORARY STUB for the function at 2DAC (original 2DAC) */
f2dac()
{
	return (0);
}

/* TEMPORARY STUB for the function at 2DCC (original 2DCC) */
f2dcc()
{
	return (0);
}

/* TEMPORARY STUB for the function at 2E38 (original 2E38) */
f2e38()
{
	return (0);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (invented; the original had no symbols). */
/* swabw (original 2FF4): with cflag set, swap the two bytes of each of the (N + 1) / 2 words at P, in place */
swabw(n, p)
register int n;
register unsigned *p;
{
	register unsigned *q;

	if (cflag) {
		if (n & 1)
			n++;
		n >>= 1;
		for (q = p; n; n--)
			*q++ = *p >> 8 | *p++ << 8;
	}
}

/* owrite (original 3038): output of N bytes at P to the file FD.  Pass 2 only.  Up to 20 bytes of the files 1, 3, 4, 5
   are collected in the 40-byte buffers of obtab (flushed when full); longer pieces and file 2 are written directly.
   A write error is fatal. */
owrite(fd, p, n)
int fd;
register char *p;
int n;
{
	register char *d;

	if (pass) {
		if (n > 20)
			goto big;
		switch (fd) {
		case 1:
		case 3:
		case 4:
		case 5:
			if (obtab[fd].ob_n + n >= 40)
				goto big;
			d = obtab[fd].ob_p;
			while (n--) {
				*d++ = *p++;
				obtab[fd].ob_n++;
			}
			obtab[fd].ob_p = d;
			return;
		default:
			goto direct;
		}
big:
		oflush(fd);
direct:
		if (write(fd, p, n) < 0) {
			error("fatal output error");
			fatal();
		}
	}
}

/* oflush (original 3100): write the collected bytes of the buffer N, then empty it */
oflush(n)
int n;
{
	if (obtab[n].ob_n > 0)
		if (write(n, obtab[n].ob_b, obtab[n].ob_n) < 0) {
			error("fatal output error");
			fatal();
		}
	obtab[n].ob_n = 0;
	obtab[n].ob_p = obtab[n].ob_b;
}

/* oflall (original 3188): flush all buffers (1, 3, 4, 5) */
oflall()
{
	int i;

	oflush(1);
	for (i = 3; i < 6; i++)
		oflush(i);
}

/* fatal (original 31BA): flush, truncate the object file (creat) and leave with exit status 4 */
fatal()
{
	oflall();
	creat(oname, 0666);
	fprintf(stderr, "error exit from assembler\n");
	exit(4);
}
