#include	<stdio.h>

putw(i, iop)
register i;
register struct _iobuf *iop;
{
	putc(i>>8, iop);   /* Differs from V7: big-endian word, high byte first */
	putc(i, iop);
}
