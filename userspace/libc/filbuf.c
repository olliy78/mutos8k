/*
 * RECONSTRUCTED from the object of the shipped libc.a (V7 stdio/filbuf.c is the frame).
 * Differs from V7: a read/write stream (_IORW) is flushed and switched to reading,
 * stdin and stdout get the static buffers _sibuf/_sobuf (same names as in flsbuf.c).
 * Instruction order measured against the shipped member (doc/userspace/wk_w8.md).
 */
#include	<stdio.h>

char	*malloc();

int
_filbuf(iop)
	register FILE *iop;
{
	static char smallbuf[_NFILE];
	extern char _sibuf[], _sobuf[];

	if (iop->_flag & _IORW) {
		if (iop->_flag & _IOWRT) {
			fflush(iop);
			iop->_flag &= ~_IOWRT;
		}
		iop->_flag |= _IOREAD;
	}

	if ((iop->_flag & _IOREAD) == 0 || iop->_flag & _IOSTRG)
		return(EOF);

tryagain:
	if (iop->_base == NULL) {
		if (iop->_flag & _IONBF) {
			iop->_base = &smallbuf[fileno(iop)];
			goto tryagain;
		}
		if (iop == stdin) {
			iop->_base = _sibuf;
			goto tryagain;
		}
		if (iop == stdout) {
			iop->_base = _sobuf;
			goto tryagain;
		}
		if ((iop->_base = malloc(BUFSIZ)) == NULL) {
			iop->_flag |= _IONBF;
			goto tryagain;
		}
		iop->_flag |= _IOMYBUF;
	}
	iop->_ptr = iop->_base;
	iop->_cnt = read(fileno(iop), iop->_ptr, iop->_flag&_IONBF?1:BUFSIZ);
	if (--iop->_cnt < 0) {
		if (iop->_cnt == -1) {
			iop->_flag |= _IOEOF;
			if (iop->_flag & _IORW)
				iop->_flag &= ~_IOREAD;
		} else
			iop->_flag |= _IOERR;
		iop->_cnt = 0;
		return(EOF);
	}
	return(*iop->_ptr++ & 0377);
}
