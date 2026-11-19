/* as_code.c: reconstructed /usr/bin/as, original addresses 1C0C..31BA (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
#include "as.h"

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* write pointers of the code and relocation word buffers and the start of the current instruction in them
   (original data 69A8..69AE, initialized) */
int *cwp = g90e6;
int *rwp = g91ae;
int *cws = g90e6;
int *rws = g91ae;

/* encode (original 1C0C, W7j: FIRST HALF = prologue, pass 0 length switch, pass 1/2 code switch up to class 108/103/104
   and the common tail; the cases of the second half 22BE..29DA are TEMPORARY, see doc/userspace/wk_w7j.md):
   builds the code words of the instruction of the mnemonic entry MN in g90e6 (relocation words in g91ae) from the
   operand cells g90b0[] and writes them; pass 0 only counts the length into g9046. */
encode(mn)
register struct mncl *mn;
{
	register int u1, u2;		/* unused in the original (R12, R11) */
	register int cls;
	register int k;
	register int ty;
	int *xp;
	int *yp;
	int n;
	int pad1, pad2;
	long lv;
	int pad3, pad4;
	char *endp;
	char *begp;

	begp = g90e6;
	cwp = g90e6;
	rwp = g91ae;
	begp = g90e6;
	cws = cwp;
	rws = rwp;
	cls = mn->mc_cls;
	if (cls > 100) {
		*cwp++ = 0;
		xp = cwp;
		*cwp++ = mn->mc_w[4];
	} else {
		*cwp++ = mn->mc_w[4];
		*cwp = 0;
	}
	*rwp++ = 0;
	*rwp = 0;
	opclass(cws, mn);
	n = 0;
	g90c4 = 0;
	switch (cls) {
	case 44:
	case 62:
	case 72:
	case 106:
	case 67:
	case 101:
	case 105:
	case 109:
		g90c4 = 1;
		break;
	case 51:
	case 97:
		if (*mn->mc_name == 'S')
			g9276 = g9278 = 0;
		break;
	}
	g90e2 = g90b0[g90c4];
	ty = *g90e2;
	k = 4;
	if (pass == 0) {
		/* pass 0: only the length */
		g9046 += 2;
		switch (cls) {
		case 13:
		case 14:
		case 81:
			if (ty == 64)
				g90e2 = g90b0[1];
len1:
			ty = *g90e2;
			if (ty == 1 || ty == 2)
				g9046 += 2;
			else if (ty == 16) {
				if (g9278)
					g9046 += 2;
				g9046 += 2;
			}
			if (cls == 51 || cls == 97) {
				g9046 += 2;
				if (g9278)
					g9046 += 2;
			}
			break;
		case 21:
			g90e2 = g90b0[1];
			goto len1;
		case 41: case 42: case 43: case 44:
		case 63: case 64: case 65: case 66: case 67:
		case 71: case 72: case 103: case 104: case 107: case 108: case 118:
			g9046 += 2;
			break;
		case 61:
			g90e2 = g90b0[1];
		case 62:
		case 101: case 102: case 105: case 106: case 109:
		case 115: case 116: case 119:
			g9046 += 2;
			goto len1;
		}
		iniobj();
		g90de = 0;
		return;
	} else {
		switch (cls) {
		case 11:
			if (g90de == 2) {
				g90e2 = g90b0[1];
				*cws |= opmask(3) & 2;
				g90e2 = g90b0[0];
			}
			goto L29DA;
		case 12:
		case 98:
			g90e2 = g90b0[1];
			if (*mn->mc_name == 'I' || *mn->mc_name == 'D')
				((struct obj *)g90e2)->o_val--;
			if (cls == 98)
				*cws |= opmask(7);
			else
				*cws |= opmask(15);
			g90e2 = g90b0[0];
			goto L29DA;
		case 13:
			if (ty == 64) {
				*cws |= opmask(15);
				g90e2 = g90b0[1];
			} else
				*cws |= 8;
			goto L29DA;
		case 81:
			*cws |= opmask(15);
			*cws |= opmask(15) << 4;
			break;
		case 82:
			*cws |= opmask(15) << 4;
			*cws |= opmask(15);
			break;
		case 14:
			*cws |= opmask(15);
			g90e2 = g90b0[1];
			goto L29DA;
		case 102:
		case 115:
		case 116:
		case 119:
			k = 1;
			goto L1FC2;
		case 101:
		case 105:
		case 106:
		case 109:
			k = 0;
L1FC2:
			g90e2 = g90b0[k];
			ty = opmask(15);
			g90e2 = g90b0[k ? 0 : 1];
			switch (*g90e2) {
			case 0x4000:
				*cws |= 0x0E04;
				*xp &= 0xFFF0;
				goto L2044;
			case 8:
				if (k)
					*cws |= 0x0F00;
				else
					*cws |= 0x0F08;
L2044:
				*cws |= ty << 4;
				*xp |= opmask(15) << 8;
				break;
			case 4:
				*cws |= opmask(15) << 4 | 0x0F04;
				if (k)
					*cws |= 8;
				goto L215E;
			case 1:
				lv = ((struct obj *)g90e2)->o_val >> 16;
				if (lv & 0x000FFFF0 && (lv & 0x000FFFF0) != 0x000FFFF0 && pass == 1)
					error("illegal value");
				*cws |= (15 & lv) << 4;
			case 2:
				*cws |= 0x0F04;
				rwp++;
				*rwp++ = opreg();
				*cwp++ = opmask(-1);
				if (k)
					*cws |= 8;
L215E:
				*xp |= ty << 8;
				break;
			}
			if (cls == 106 || cls == 116) {
				g90e2 = g90b0[2];
				if (((struct obj *)g90e2)->o_val == 1)
					*xp |= 4;
				else
					*xp |= 9;
			}
			break;
		case 118:
			*cws |= 4;
			goto L2216;
		case 107:
			g90e2 = g90b0[1];
			*xp |= opmask(15) << 8;
			g90e2 = g90b0[0];
L2216:
		case 108:
			*cws |= opmask(15) << 4 | 0x8E00;
			break;
		case 103:
			*cws = 0x8E24;
			lv = opmask(31);
			if (lv > 8)
				*xp |= (lv - 8) << 8;
			else
				*xp |= lv;
			break;
		case 104:
			*cws |= 0x8E04;
			*xp |= opmask(15);
			break;
		/* TEMPORARY: the cases of the second half (original 22BE..29BE) and the type switch 29DA..2BA6 are not
		   written yet; they all end here without code (the instruction gets no operand words) */
		default:
L29DA:
			break;
		}
	}
	/* common tail (original 2C6A) */
	endp = (char *)cwp;
	n = endp - begp;
	if (pass == 1 && lflag) {
		xp = cws;
		yp = rws;
		while (xp < cwp) {
			fprintf(lstfile, "%04x %c %04x %04x\n", g9046, "*ATDB"[g90d0], *xp, *yp);
			xp++;
			yp++;
		}
	}
	g9046 += n;
	begp = endp;
	if (endp > g90e6) {
		if (pass == 1) {
			n = endp - g90e6;
			swabw(n, g90e6);
			swabw(n, g91ae);
			owrite(fd_o, g90e6, n);
			owrite(fd_q, g91ae, n);
		}
		cwp = g90e6;
		rwp = g91ae;
		for (g90ca = 0; g90ca < 4; g90ca++) {
			*cwp = 0;
			*rwp = 0;
			rwp++;
			cwp++;
		}
	}
	iniobj();
	g90de = 0;
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
