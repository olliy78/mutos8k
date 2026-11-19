/* as_code.c: reconstructed /usr/bin/as, original addresses 1C0C..31BA (function order measured, module boundaries *Annahme*).
   All functions are reconstructed (no stubs since doc/userspace/wk_w7o.md). */
#include "as.h"

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* write pointers of the code and relocation word buffers and the start of the current instruction in them
   (original data 69A8..69AE, initialized) */
int *cwp = g90e6;
int *rwp = g91ae;
int *cws = g90e6;
int *rws = g91ae;

/* encode (original 1C0C, W7j: FIRST HALF = prologue, pass 0 length switch, pass 1/2 code switch up to class 108/103/104
   and the common tail, W7k: second half 22BE..29DA, see doc/userspace/wk_w7j.md):
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
	int msk;			/* displacement mask (original FFEC) */
	int iv;
	long lv;
	long lt;
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
			if (n == 1) {
				/* W7q: class 21 (LD, PUSH, XOR ...): the first operand (a store to a direct address or an
				   indexed cell) takes its words too */
				n = 2;
				g90e2 = g90b0[0];
				goto len1;
			}
			if (cls == 51 || cls == 97) {
				g9046 += 2;
				if (g9278)
					g9046 += 2;
			}
			break;
		case 11:
			/* W7q: CALL, CLR: the only operand (call csv = 4 bytes) was not counted in pass 0 */
			goto len1;
		case 21:
			g90e2 = g90b0[1];
			n = 1;
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
		case 21:
		case 73:
			*cws |= opmask(15);
			g90e2 = g90b0[1];
			goto L29DA;
		case 22:
		case 74:
			g90e2 = g90b0[1];
			*cws |= opmask(15);
			g90e2 = g90b0[0];
			goto L29DA;
		case 71:
			*cws |= opmask(15) << 4;
			k = 0;
			g90e2 = g90b0[1];
			goto L29DA;
		case 72:
			g90e2 = g90b0[1];
			*cws |= opmask(15) << 4;
			g90e2 = g90b0[0];
			k = 0;
			goto L29DA;
		case 91:
			*cws |= opmask(240);
			break;
		case 92:
			*cws &= ~opmask(3);
			break;
		case 94:
			if (g90de == 1)
				*cws |= opmask(15);
			break;
		case 93:
			break;
		case 31:
			*cws |= opmask(15) << 8;
			msk = 255;
L23F0:
			/* relative displacement: lt = address of the next instruction */
			lt = g9046 + 2;
			lt &= 0xFFFFL;
			lv = opmask(-1);
			lv = lv - lt;
			k = msk >> 1;
			if (cls != 33 && cls != 96)
				lv = -lv;
			lv >>= 1;
			if (-k >= lv || k < lv || (cls == 31 && lv <= 0))
				if (pass == 1)
					error("ILLEGAL VALUE");
			*cws |= msk & lv;
			break;
		case 32:
			*cws |= opmask(15) << 8;
			*cws |= opmask(255);
			break;
		case 96:
			*cws |= opmask(15) << 8;
		case 33:
			msk = 255;
			goto L23F0;
		case 34:
			msk = 4095;
			goto L23F0;
		case 41:
			*rwp++ = 0;
			*cwp++ = (15 & (((struct obj *)g90e2)->o_val >> 16)) << 8;
			*cws |= opmask(15) << 4;
			*cws |= opmask(15);
			break;
		case 43:
			*cws |= opmask(15);
			*rwp++ = 0;
			*cwp++ = (15 & (((struct obj *)g90e2)->o_val >> 16)) << 8;
			*cws |= opmask(15) << 4;
			break;
		case 42:
		case 44:
			while (g90de--) {
				g90c4++;
				g90c4 &= 1;
				g90c4--;
				if (*g90e2 == 32) {
					*rwp++ = opreg();
					*cwp++ = opmask(-1);
					continue;
				}
				if (*g90e2 == 1024) {
					*cws |= (15 & (((struct obj *)g90e2)->o_val >> 16)) << 4;
					*rwp++ = opreg();
					*cwp++ = opmask(-1);
					continue;
				}
				if (*g90e2 == 8)
					*cws |= opmask(15);
			}
			break;
		case 51:
		case 97:
			goto L29DA;
L2700:
			/* the same operand format dispatch as case 16 below, for the second operand */
			g90e2 = g90b0[1];
			if (g9278) {
				*rwp++ = 0;
				*cwp++ = ((struct obj *)g90e2)->o_val >> 16;
				*rwp++ = 0;
				*cwp++ = opmask(-1);
			} else if (g9276) {
				*rwp++ = 0;
				*cwp++ = opmask(255);
				*(cwp - 1) |= *(cwp - 1) << 8;
			} else {
				*rwp++ = opreg();
				iv = opmask(-1);
				if (cls == 97)
					iv = -iv;
				*cwp++ = iv;
			}
			break;
		case 61:
		case 62:
			*cwp |= opmask(15) << 8;
			g90e2 = g90b0[2];
			((struct obj *)g90e2)->o_val--;
			*rwp++ = 0;
			*cwp++ |= opmask(15);
			g90e2 = g90b0[1];
			if (cls == 62)
				g90e2 = g90b0[0];
			goto L29DA;
		case 63:
			*rwp++ = 0;
			*cwp++ = opmask(15) << 8;
			*(cwp - 2) |= opmask(15);
			break;
		case 67:
			g90c4++;
			g90c4 &= 1;
			g90c4--;
		case 64:
		case 65:
			*cwp |= (*cws & 0xE0) >> 4;
			*cws &= 0xFF0F;
			*rwp++ = 0;
			*cwp++ |= opmask(15) << 4;
			*cws |= opmask(15) << 4;
			g90e2 = g90b0[2];
			*(cws + 1) |= opmask(15) << 8;
			if (g90de == 4)
				*(cws + 1) |= opmask(15);
			break;
		case 66:
			*cws |= opmask(15) << 4;
			*rwp++ = 0;
			*cwp++ = opmask(15) << 8;
			break;
		case 95:
			*cws |= opmask(255);
			break;
		/* The dead code at original 2C48 (error("no code")) is not reproduced: no case reaches it and its
		   source form is unknown. */
		default:
L29DA:
			/* dispatch on the type word of the operand cell g90e2 (original 29DA..2BEA) */
			switch (*g90e2) {
			case 4:
			case 8:
			case 64:
			case 256:
			case 2048:
				*cws |= opmask(15) << k;
				break;
			case 1:
				lv = ((struct obj *)g90e2)->o_val >> 16;
				if (lv & 0x000FFFF0 && (lv & 0x000FFFF0) != 0x000FFFF0 && pass == 1)
					error("illegal value");
				lv = 15 & lv;
				*cws |= lv << k;
			case 2:
				*rwp++ = opreg();
				*cwp++ = opmask(-1);
				break;
			case 16:
				if (g9278) {
					*rwp++ = 0;
					*cwp++ = ((struct obj *)g90e2)->o_val >> 16;
					*rwp++ = 0;
					*cwp++ = opmask(-1);
				} else if (g9276) {
					*rwp++ = 0;
					*cwp++ = opmask(255);
					*(cwp - 1) |= *(cwp - 1) << 8;
				} else {
					*rwp++ = opreg();
					iv = opmask(-1);
					if (cls == 97)
						iv = -iv;
					*cwp++ = iv;
				}
				break;
			default:
				error(" illegal operation format");
			}
			if (cls == 51 || cls == 97)
				goto L2700;
			if (*mn->mc_name == 'P') {
				/* swap the two register nibbles of the first word */
				k = *cws & 15;
				cls = *cws & 0xF0;
				*cws &= 0xFF00;
				*cws |= k << 4;
				*cws |= cls >> 4;
			}
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

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* setcon (original 2DAC): the cell A becomes a constant (type 0x128); in pass 1 the high word of its value is B.  Returns 0 */
setcon(a, b)
register int *a;
register int b;
{
	if (pass == 0)
		a[1] = b;
	*a = 296;
	return (0);
}

/* symdef (original 2DCC): definition of the cell A (size B) by the directive class g8d06: 5 = type 0x12B; 32 = bit 5;
   6, 7 = (6: bit 5 and) the type bits g90d0 and the value g9046, which advances by B (pass 1 only); else message */
symdef(a, b)
register int *a;
register int b;
{
	if (pass == 0) {
		a[2] = b;
		switch (g8d06) {
		case 5:
			*a = 299;
			break;
		case 6:
			*a |= 32;
		case 7:
			*a |= g90d0;
			a[1] = g9046;
			g9046 += b;
			break;
		case 32:
			*a |= 32;
			break;
		default:
			error("error in typdf");
		}
	}
	return ((int)a);
}

/* passini (original 2E38): start of a module with the header record P.  Common: local area stack empty, symbol limits =
   gc79e, scanner cells free.  Pass 1: constant pool at gc79e + 16, module name = the 8 bytes at P + 8 copied to curname
   (area D0F0), *P = 0x40.  Pass 2: section sizes rounded up to even and summed into the section bases (se_d),
   the output files are positioned at the section starts and the header words gca70..gca76 set (magic 0xE807, sizes).
   Finally the section counters 1..4 are cleared. */
passini(p)
int *p;
{
	long a, b, c, e, d;	/* e: unused, the original frame has 5 longs */
	register int i;
	register char *r;
	register char *q;

	g90c6 = 0;
	symend = symlim = gc79e;
	iniobj();
	if (pass == 0) {
		gca06 = gc79e + 16;
		curname = r = (char *)0xD0F0;
		q = (char *)p + 8;
		*p = 64;
		for (i = 0; i < 8; i++)
			*r++ = *q++;
	} else {
		for (i = 1; i < 8; i++) {
			sectab[i].se_pc++;
			sectab[i].se_pc &= ~1;
		}
		for (i = 3; i < 8; i++)
			sectab[i].se_d = sectab[i - 1].se_pc + sectab[i - 1].se_d;
		a = 16;
		b = sectab[2].se_pc;
		c = sectab[3].se_pc;
		d = sectab[4].se_pc;
		lseek(fd_o, a, 0);
		lseek(fd_p, a + b, 0);
		lseek(fd_q, a + b + c, 0);
		lseek(fd_r, a + c + (b << 1), 0);
		lseek(fd_s, a + ((b + c) << 1), 0);
		gca70 = -6137;
		gca72 = b;
		gca74 = c;
		gca76 = d;
		gca78 = 0;
	}
	g90e2 = (int *)objtab;
	g9046 = 0;
	for (i = 1; i <= 4; i++)
		sectab[i].se_pc = 0;
	gca80 = 1;
	g90d0 = 3;
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
