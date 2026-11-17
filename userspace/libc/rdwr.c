#include	<stdio.h>

fread(ptr, size, count, iop)
unsigned size, count;
register char *ptr;
register FILE *iop;
{
	/* Differs from V7: ndone and s are register variables */
	register c;
	register unsigned ndone, s;

	ndone = 0;
	if (size)
	for (; ndone<count; ndone++) {
		s = size;
		do {
			if ((c = getc(iop)) >= 0)
				*ptr++ = c;
			else
				return(ndone);
		} while (--s);
	}
	return(ndone);
}

fwrite(ptr, size, count, iop)
unsigned size, count;
register char *ptr;
register FILE *iop;
{
	/* Differs from V7: ndone is a register variable too */
	register unsigned s;
	register unsigned ndone;

	ndone = 0;
	if (size)
	for (; ndone<count; ndone++) {
		s = size;
		do {
			putc(*ptr++, iop);
		} while (--s);
		if (ferror(iop))
			break;
	}
	return(ndone);
}
