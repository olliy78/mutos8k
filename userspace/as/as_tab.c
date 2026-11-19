/* as_tab.c: reconstructed /usr/bin/as, original addresses 43C6..48A4 (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
#include "as.h"

#include "as_tabd.h"

/* Not V7: reconstructed from the MUTOS binary */

/* initialized scalar data, original 8310..8322 */
int pass = 0;
char *yysptr = yysbuf;
FILE *yyin = stdin;
FILE *yyout = stdout;
char *symend = symtab + 13584;
char *symcur = symtab;
char *symlim = symtab + 13584;
int d831e = 6;
char *lptr = lbuf;

/* BSS in the ORIGINAL address order (W7g).  The original BSS starts at 8BD6 with the yacc output's yylval, yyval, yyv (in as_y.c, = 8BD6..8D06);
   everything below follows from 8D06.  Addresses/sizes are measured from the listing (every referenced address and its access width; the
   gaps between two references are filled with gXXXX arrays, whose content is *Annahme* unknown).  Variables are named after their address
   unless the code shows the role.  End of own BSS = CCEE (libc follows)  */
int g8d06, g8d08, g8d0a, g8d0c, g8d0e, g8d10, g8d12;
char g8d14[14];
int g8d22;
int yycnt, yyskip;
char yysbuf[200];			/* 8D28 */
int yytchar, yylineno;			/* 8DF0, 8DF2 */
int lflag;				/* 8DF4 */
char lbuf[128];				/* 8DF6 */
char yytext[200];			/* 8E76 */
int yyleng;				/* 8F3E */
int g8f40;
int cls[128];				/* 8F42 */
int g9042, g9044;
unsigned g9046;
int g9048, g904a;
struct obj objtab[10];			/* 904C */
int g90b0, g90b2, g90b4;
char g90b6[14];
int g90c4, g90c6;
char *bufp2;				/* 90C8 */
int g90ca, g90cc, g90ce, g90d0, g90d2;
char g90d4[8];
int g90dc, g90de, g90e0, g90e2;
int uflag;				/* 90E4 */
char g90e6[200];
char g91ae[200];
int g9276, g9278;
int fd_o, fd_q;				/* 927A, 927C */
char numcls[8];				/* 927E */
int errcount, g9288, cflag;		/* 9286, 9288, 928A */
char *oname;				/* 928C */
char symtab[13584];			/* 928E..C79E */
char gc79e[616];			/* C79E..CA06 */
int gca06;
char *curname;				/* CA08 (error() pushes it as the module name) */
int gca0a, gca0c, gca0e, gca10;
char gca12[18];				/* CA12..CA24: start of a table of 12-byte records (Annahme) */
int cp_o, cp_q;				/* CA24, CA26 */
char gca28[8];
int cp_p, cp_r;				/* CA30, CA32 */
char gca34[54];
int fd_p, fd_r, fd_s;			/* CA6A, CA6C, CA6E */
int gca70, gca72, gca74, gca76, gca78;
char gca7a[6];
int gca80;
char gca82[40], gcaaa[80], gcafa[40];
char *bufp1;				/* CB22 */
char area3[100];			/* CB24 */
char *bufp3;				/* CB88 */
char area4[150];			/* CB8A */
char *bufp4;				/* CC20 */
char lname[20];				/* CC22 */
int gcc36;
char gcc38[128];
int gccb8, gccba;
char gccbc[50];
/* CCEE: the libc BSS starts here (measured: environ D0EE = CCEE + 400h as in the build; LD R2,#CCEE = a libc buffer) */

/* TEMPORARY STUB for the function at 43C6 (original 43C6) */
f43c6()
{
	return (0);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* hashfind (original 44F0): look up name S in the open-addressing hash table at *bufp1 (1601 words, filled by the
   pass-2 set-up); IND = 1: the entries point to {name pointer, ...} (keyword/mnemonic tables), IND = 0: the entries
   point to symbol table cells with the name at +8.  Hash = first three characters, 4 bits apart; step 32. */
hashfind(s, ind)
char *s;
int ind;
{
	register char *p;
	register int h;
	register int c;
	int *e;

	p = s;
	h = *p++;
	c = *p++;
	if (c) {
		h <<= 4;
		h = h + c;
		c = *p++;
		if (c) {
			h <<= 4;
			h = h + c;
		}
	}
	h = h % 1601;
	while (h < 0)
		h += 1601;
	while (e = ((int *)bufp1)[h]) {
		if (ind)
			p = (char *)*e;
		else
			p = (char *)e + 8;
		if (cmp8(s, p))
			return ((int)e);
		if ((h -= 32) < 0)
			h += 1601;
	}
	return (0);
}

/* TEMPORARY STUB for the function at 459C (original 459C) */
f459c()
{
	return (0);
}

/* TEMPORARY STUB for the function at 4628 (original 4628) */
f4628()
{
	return (0);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* kwlook (original 46DA): look the name S up in the table (hashfind(s, 1)) and return the token of an entry of the
   keyword (706E..), condition (7102..), flag (722E..) or mnemonic (729A..) table; sets yylval and the scanner state.
   The original performs the lookup twice (the first result is thrown away). */
kwlook(s)
char *s;
{
	register char *p;
	register char *r;
	register struct mnent *mp;
	register struct ctent *cp;
	register int *q;

	if ((p = hashfind(s, 1)) == 0)
		return (0);
	if ((p = hashfind(s, 1)) == 0)
		return (0);
	if (p < (char *)kwtab || p >= (char *)&pass)
		return (0);
	if (g9044)
		goto dollar;
	if (p >= (char *)ctab1) {
		if (p < (char *)ctab2)
			goto ct1;
		if (p >= (char *)mnem)
			goto mn;
		goto dollar;
	}
	yylval = (int)p;
	if (((struct kwent *)p)->k_tok == 15) {
		f3d6c();
		g8d0e = 0;
		g9042 = 0;
		g8d22 = 0;
	}
	return (((struct kwent *)p)->k_tok);
ct1:
	cp = (struct ctent *)p;
	yylval = cp->c_val;
	if (cp->c_tok == 0x130) {
		g8d22 = 1;
		gccba = -1;
		g9048 = cp->c_val;
	}
	return (cp->c_tok);
mn:
	mp = (struct mnent *)p;
	q = &mp->m_w[1];
	g90dc = 0;
	goto m1;
m0:
	q++;
m1:
	g90dc |= *q;
	if (*q)
		goto m0;
	g9042 = 1;
	g9278 = 0;
	g9276 = 0;
	if (mp - mnem > 16) {
		r = s;
		while (*r++)
			;
		r -= 2;
		if (*r == 'L')
			g9278++;
		if (*r == 'B')
			g9276++;
	}
	yylval = (int)mp;
	g90e0 = (int)mp;
	return (0x131);
dollar:
	if (yytext[0] != '$')
		return (0);
	cp = (struct ctent *)p;
	yylval = cp->c_val;
	return (cp->c_tok);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* symadd (original 4814): allocate a symbol table cell for yytext.  N = 6: from the low end (symcur, grows up),
   otherwise from the high end (symend, grows down) and d831e = 0.  The cell is 16 bytes: type at +0, value at +2,
   -1 at +6 (not yet numbered), the first 8 characters of the name at +8. */
symadd(n)
register int n;
{
	register char *p;
	register char *q;
	register struct sym *sp;

	if (pass == 1) {
		error("illegal --totab-- in PASS1 ");
		return;
	}
	if (n == 6) {
		sp = (struct sym *)symcur;
		symcur += 16;
	} else {
		sp = (struct sym *)symend;
		symend -= 16;
		d831e = 0;
	}
	if (symend < symcur) {
		prmsg(" fatal error: symbol table overflow");
		f31ba();
	}
	p = sp->s_name;
	q = yytext;
	while (q < yytext + 8 && (*p++ = *q++))
		;
	sp->s_w = -1;
	if (n == 6)
		f4628(sp, 0);
	return ((int)sp);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* symget (original 48A4): find the symbol named yytext.  N = 6: through the hash table, otherwise by a linear search of the
   cells from symend + 16 to symlim.  In pass 1 (pass == 1) an undefined symbol gets a running number (gca78); depending on its
   type bits it is declared (uflag) or reported, or its value is relocated by the table at gca12 (12-byte records). */
symget(n)
register int n;
{
	register struct sym *sp;
	register struct sym *lo;
	register struct sym *hi;

	if (n == 6) {
		sp = hashfind(yytext, 0);
		if (sp == 0)
			return (0);
	} else {
		lo = (struct sym *)(symend + 16);
		hi = (struct sym *)symlim;
		for (sp = lo; sp <= hi; sp++)
			if (cmp8(yytext, sp->s_name))
				goto found;
		return (0);
	}
found:
	d831e = 0;
	if (pass == 1 && sp->s_t != 0x102 && sp->s_t != 0x128 && sp->s_w == -1) {
		sp->s_w = gca78;
		gca78++;
		switch (sp->s_t & ~0x20) {
		case 0:
			if (uflag)
				sp->s_t = 0x20;
			else {
				error(sp->s_name);
				error("undefined symbol");
			}
			break;
		case 3:
		case 4:
			if (g9288 == 0)
				sp->s_v += *(int *)(gca12 + 12 * (sp->s_t & 7));
			break;
		}
		f3988(sp);
	}
	return ((int)sp);
}
