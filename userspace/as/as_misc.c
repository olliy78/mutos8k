/* as_misc.c: reconstructed /usr/bin/as, original addresses 167A..1BDA (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
#include "as.h"

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* mklabs (original 167A): saves the parser state (stpush) and opens two generic labels: g90cc = first, g8d12 = second
   (labset gets the first one) */
mklabs()
{
	stpush();
	g90cc = getlab();
	g8d12 = getlab();
	labset(g90cc);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* labsym (original 16A0): symbol for token T of the cell A.  T = 0x125 (numeric label reference): the symbol "#%6d" of the
   number is allocated (pass 1) or looked up (pass 2).  Otherwise, in pass 1 only: T = 0x1B marks the cell (bit 5) while
   g8d06 is 14 or 6; T = ':' sets the value to g9046 and the type bits (bit 0 if g90ce, else g90d0).  Returns the cell. */
labsym(a, t)
register struct sym *a;
register int t;
{
	register struct sym *sp;
	char buf[8];

	sp = a;
	if (t == 0x125) {
		t = a->s_x;
		sprintf(buf, "#%6d", t);
		if (pass == 0) {
			sp = (struct sym *)symadd(30);
			sp->s_v = g9046;
			sp->s_t = 2;
		} else {
			sp = (struct sym *)symget(30);
			iniobj();
		}
		return ((int)sp);
	}
	if (pass)
		return ((int)sp);
	if (t == 0x1B) {
		if (g8d06 == 14 || g8d06 == 6)
			a->s_t |= 32;
		return ((int)sp);
	}
	if (t != ':')
		return ((int)sp);
	sp->s_v = g9046;
	if (g90ce)
		sp->s_t |= 1;
	else
		sp->s_t |= g90d0;
	return ((int)sp);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* opmatch (original 174A): find the entry of the mnemonic table (starting at MP, going on over the entries named "#")
   whose operand count (byte +3) is g90de and whose operand masks (words 1..) all overlap the operand types g90b0[i];
   the masks are narrowed in the operands, g90dc collects them, and the entry goes to the encoder 1C0C.
   No entry fits: message (pass 2), operand cells freed, g90de = 0, result 1. */
opmatch(mp)
register struct mnent *mp;
{
	char frame[46];			/* unused: the original has a 0x2E byte frame here */
	register int *unused;		/* unused: the original skips R12 here (register order of i, r) */
	register int i;
	register int *r;

	for (;;) {
		if (*((char *)mp + 3) != g90de) {
next:
			mp++;
			if (*mp->m_name == '#')
				continue;
			if (pass == 1)
				error("illegal number or type of operands");
			iniobj();
			g90de = 0;
			return (1);
		}
		g90dc = 0;
		for (i = 0; i < g90de; i++) {
			r = g90b0[i];
			g90d2[i] = mp->m_w[1 + i];
			if ((g90d2[i] &= *r) == 0)
				goto next;
			g90dc |= g90d2[i];
		}
		for (i = 0; i < g90de; i++) {
			r = g90b0[i];
			*r = g90d2[i];
		}
		encode(mp);
		return;
	}
}

/* opclass (original 181A): from the class byte at Q + 2 of a mnemonic entry (hash switch, 21 values) and the type of the
   first (K = 0) or second (K = 1) operand: sets bit 14 (types 1, 2) or bit 15 (types 8, 0x4000) in *R.
   Meaning of the class values: *Annahme*. */
opclass(r, q)
register int *r;
char *q;
{
	register int k;
	register int fl;
	register int *t;

	k = 0;
	fl = 0;
	switch (*(q + 2)) {
	case 14:
	case 21:
	case 61:
	case 101:
	case 105:
	case 106:
	case 109:
		k = 1;
	case 11:
	case 12:
	case 13:
	case 22:
	case 23:
	case 51:
	case 62:
	case 66:
	case 97:
	case 98:
	case 102:
	case 115:
	case 116:
	case 119:
again:
		t = g90b0[k];
		switch (*t) {
		case 1:
		case 2:
			fl = 0x4000;
			break;
		case 8:
		case 0x4000:
			fl = 0100000;
			break;
		case 0x40:
			k = 1;
			if (g90de > 1)
				goto again;
			break;
		}
		*r |= fl;
	}
}

/* oppush (original 191A): append the operand cell P to the operand list g90b0 */
oppush(p)
int *p;
{
	g90b0[g90de] = p;
	g90de++;
}

/* mkopnd (original 1938): operand cell for the value A with the type mask M.  M = 16 or 34: A already is a cell, only its type
   is set.  Else a new cell (value A, type M); for M = 2112 with an operand of the kind 0x800 A becomes 1 << A, and for M = 256
   or such a 2112 an open operand of the same type on the operand stack (g90b0) is merged: its value gets A or-ed in. */
mkopnd(a, m)
register int a;
register int m;
{
	register struct obj *r11;
	register struct obj *r10;

	if (m == 16 || m == 34) {
		r10 = (struct obj *)a;
		r10->o_t = m;
		return (a);
	}
	r10 = getobj();
	r10->o_val = a;
	r10->o_t = m;
	switch (m) {
	case 2112:
		if (((int *)g90e0)[2] != 2048 && ((int *)g90e0)[3] != 2048)
			break;
		a = 1 << a;
		r10->o_val = a;
	case 256:
		if (g90de != 0) {
			r11 = (struct obj *)g90b0[g90de - 1];
			if (r11->o_t == m) {
				r11->o_val |= a;
				g90de--;
				return ((int)r11);
			}
		}
	}
	return ((int)r10);
}

/* endproc (original 19DA): end of a procedure: the names A and B must agree; in pass 1 the local area stack gets the
   symbol table end (lapush) and the low area limit is set to it; then section 3 */
endproc(a, b)
int a, b;
{
	int t1, t2;	/* unused: the original frame has 4 bytes of locals */

	if (a != b)
		error("wrong END of procedure");
	if (pass == 0) {
		lapush(symend);
		symlim = symend;
	}
	secsel(3);
	g8d10 = 0;
}

/* procnam (original 1A1E): after a procedure heading: d831e = g8d0e = 0; type 32 marks the cell A (bit 5);
   otherwise in pass 2 the symbol table end comes back from the local area stack.  Returns A */
procnam(a)
int *a;
{
	g8d0e = d831e = 0;
	if (g8d06 == 32) {
		*a |= 32;
		return ((int)a);
	}
	if (pass == 1)
		symend = (char *)lapop();
	return ((int)a);
}

/* lapush (original 1A54): push the word V on the local area stack bufp2 (limit 100 entries) */
lapush(v)
int v;
{
	if (g90c6 > 100) {
		error("too many local areas");
		return;
	}
	((int *)bufp2)[g90c6++] = v;
}

/* lapop (original 1A86): the counterpart of lapush.  The original advances the index here too (g90c6++, not --) and so
   reads the entry above; kept as measured */
lapop()
{
	if (g90c6 > 100) {
		error("too many local areas");
		return;
	}
	return (((int *)bufp2)[g90c6++]);
}

/* mkpair (original 1AB6): operand cell with a base A and an index B.  M = 1: A is the cell, B the index; 1024: B is the
   cell, A the index; 512: new cell with the value A, B the index.  The cell gets the type M and the value
   (low word of the old value) | (index << 16).  Other M: fatal error. */
mkpair(a, b, m)
register int a;
register int b;
register int m;
{
	register int r10;
	register struct obj *r9;

	switch (m) {
	case 1:
		r9 = (struct obj *)a;
		r10 = b;
		break;
	case 512:
		r9 = getobj();
		r9->o_val = a;
		r10 = b;
		break;
	case 1024:
		r9 = (struct obj *)b;
		r10 = a;
		break;
	default:
		prmsg("fatal error: opxba: wrong =Q= ");
		fatal();
	}
	r9->o_t = m;
	r9->o_val = r9->o_val & 65535L;
	r9->o_val |= (long)r10 << 16;
	return ((int)r9);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* opreg (original 1B2A): code of the symbol of the current operand g90e2 (word +6 = symbol cell).  Pass 2 only (else 0).
   Type 0x20 (and an undefined symbol with uflag): (number << 4) | 8; otherwise (type - 1) * 2; undefined symbol: message. */
opreg()
{
	register int t;
	register struct sym *sp;

	if (pass == 0)
		return (0);
	t = 0;
	sp = (struct sym *)g90e2[3];
	if (sp == 0)
		return (0);
	t = sp->s_t;
	if (t == 32) {
num:
		return ((sp->s_w << 4) | 8);
	}
	t &= ~32;
	if (--t < 0) {
		if (uflag)
			goto num;
		if (pass == 1)
			error("reloc:\tundefined symbol");
	}
	return (t << 1);
}

/* opmask (original 1B82): restrict the type mask of the current operand g90e2 (word +4) to M; bits of the mask that are
   not in M while M is not contained are an error (pass 2); the next operand becomes current; result = the narrowed mask */
opmask(m)
register int m;
{
	register int w;
	register int t;

	w = g90e2[2];
	t = ~m & w;
	if (~m != t && t != 0 && pass == 1)
		error("illegal value");
	w = m & w;
	g90c4++;
	g90e2 = g90b0[g90c4];
	return (w);
}

/* lstflush (original 1BDA): pass 2 listing: when the line buffer holds text, terminate it and write it with the line
   number to the listing file */
lstflush()
{
	if (lptr != lbuf) {
		*lptr = 0;
		lptr = lbuf;
		fprintf(lstfile, "\t\t%05d  %s\n", yylineno, lbuf);
	}
}
