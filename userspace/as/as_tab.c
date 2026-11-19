/* as_tab.c: reconstructed /usr/bin/as, original addresses 43C6..48A4 (function order measured, module boundaries *Annahme*).
   All functions are reconstructed (no stubs since doc/userspace/wk_w7o.md). */
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
/* 90B0..90C3: operand cells of the current instruction (oppush).  W7s: ONE array of 10 words as in the original (90B0 up to
   g90c4 at 90C4); before it was int[3] plus an unused char[14], and the 4th operand cell of CPIR/CPSIR/CPD... (cc as 4th
   operand: crt0, execle, mcrt0, doprnt) was stored beyond the array (*Annahme*: not where opmatch reads it) */
int *g90b0[10];
int g90c4, g90c6;
char *bufp2;				/* 90C8 */
int g90ca, g90cc, g90ce, g90d0;
int g90d2[5];				/* 90D2..90DB: operand type masks of the matched entry (opmatch) */
int g90dc, g90de, g90e0;
int *g90e2;				/* 90E2: current operand cell (opreg, opmask) */
int uflag;				/* 90E4 */
char g90e6[200];
char g91ae[200];
int g9276, g9278;
int fd_o, fd_q;				/* 927A, 927C */
char numcls[8];				/* 927E */
int errcount, g9288, cflag;		/* 9286, 9288, 928A */
char *oname;				/* 928C */
char symtab[13584 + 616];		/* 928E..CA06: symbol cells 928E..C79E, then the constant pool gc79e (C79E..CA06, see as.h) */
char *gca06;				/* CA06: fill pointer of the constant pool gc79e (cpool) */
char *curname;				/* CA08 (error() pushes it as the module name) */
struct sect sectab[8];			/* CA0A..CA6A: 12-byte section records (cp_o/cp_q/cp_p/cp_r are fields of it, see as.h) */
int fd_p, fd_r, fd_s;			/* CA6A, CA6C, CA6E */
/* W7q: the 16-byte object header (gca70..gca78 + 6 zero bytes gca7a) is ONE array: modend writes 16 bytes from &gca70, and
   the linker did not keep the declaration order (gca80 landed behind gca78 -> garbage in header words 5..7). */
int objhdr[8];
int gca80;
char gca82[40], gcaaa[80], gcafa[40];
char *bufp1;				/* CB22 */
char area3[100];			/* CB24 */
char *bufp3;				/* CB88 */
char area4[150];			/* CB8A */
char *bufp4;				/* CC20 */
char lname[20];				/* CC22 */
int gcc36;
char ucbuf[128];
int *gccb8;
int gccba;
char gccbc[50];
/* CCEE: the libc BSS starts here (measured: environ D0EE = CCEE + 400h as in the build; LD R2,#CCEE = a libc buffer) */

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* nodeset (original 43C6): fills the symbol/value cell A by the kind K (pass 2: only iniobj()): 0 = location counter
   (type 2), 1 = copy of the 8 bytes of cell B, 2 = value from B+4 (type 1), 3 = pointer B as value (type 20); the word at +4 is
   set to -1 first (measured: switch through the 4-entry table at 6F7A, not error) */
nodeset(a, k, b)
struct sym *a;
int k;
struct sym *b;
{
	char *p;
	char *q;
	int n;

	if (pass == 1) {
		iniobj();
		return;
	}
	a->s_x = -1;
	switch (k) {
	case 0:
		secsave();
		a->s_t = 2;
		a->s_v = g9046;
		break;
	case 1:
		p = (char *)a;
		q = (char *)b;
		n = 8;
		while (n > 0) {
			*p++ = *q++;
			n--;
		}
		a->s_x = -1;
		break;
	case 2:
		a->s_t = 1;
		a->s_v = b->s_x;
		iniobj();
		break;
	case 3:
		a->s_t = 20;
		a->s_v = (int)b;
		break;
	}
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

/* hashini (original 459C): enters the mnemonics (not the names starting with '#'), the keywords and both condition tables
   into the hash table (hashins, IND = 1) */
hashini()
{
	register struct kwent *kp;
	register struct mnent *mp;
	register struct ctent *cp;

	for (mp = mnem; *mp->m_name; mp++)
		if (*mp->m_name != '#')
			hashins(mp, 1);
	for (kp = kwtab; *kp->k_name; kp++)
		hashins(kp, 1);
	for (cp = ctab1; *cp->c_name; cp++)
		hashins(cp, 1);
	for (cp = ctab2; *cp->c_name; cp++)
		hashins(cp, 1);
}

/* hashins (original 4628): enters the entry P into the hash table (counterpart of hashfind; same hash, step 32 backwards
   on collisions; more than 1601 steps: message and fatal) */
hashins(p, ind)
int *p;
int ind;
{
	register int h;
	register char *s;
	register int c;
	register int n;

	n = 0;
	if (ind)
		s = (char *)*p;
	else
		s = (char *)p + 8;
	h = *s++;
	c = *s++;
	if (c) {
		h <<= 4;
		h = h + c;
		c = *s++;
		if (c) {
			h <<= 4;
			h = h + c;
		}
	}
	h = h % 1601;
	while (h < 0)
		h += 1601;
	while (((int *)bufp1)[h]) {
		if ((h -= 32) < 0)
			h += 1601;
		if (++n >= 1601) {
			prmsg("fatal error: HASHSZ too small \n");
			fatal();
		}
	}
	((int *)bufp1)[h] = (int)p;
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
		stpush();
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
		fatal();
	}
	p = sp->s_name;
	q = yytext;
	while (q < yytext + 8 && (*p++ = *q++))
		;
	sp->s_w = -1;
	if (n == 6)
		hashins(sp, 0);
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
				sp->s_v += sectab[sp->s_t & 7].se_d;
			break;
		}
		symout(sp);
	}
	return ((int)sp);
}
