#include	<stdio.h>

getw(iop)
register struct _iobuf *iop;
{
	register i;

	i = getc(iop);
	if (iop->_flag&_IOEOF)
		return(-1);
	return((i<<8) | getc(iop));   /* Differs from V7: big-endian word */
}
