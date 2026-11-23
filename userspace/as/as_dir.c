/* as_dir.c: reconstructed /usr/bin/as, original addresses 3B78..43AE (function order measured, module boundaries *Annahme*).
   All functions are reconstructed (no stubs since doc/userspace/wk_w7o.md). */
#include "as.h"

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* secdir (original 3B78): section/directive switch.  A != 0: A is a cell (name in the cell at +8); K = 2: the section is named
   by the last letter of the name (b/B bss, d/D data, p/P text: section 4, 3, 2), 4: label-fixing directive (value from A+4),
   5: fill up to A+4 with bytes.  A == 0: K = 1 sets the flag gca80, 3 and 6 select section 3, 7 section 2, 4 and 5 clear
   or set the locality flag g90ce, 0x6F ("o": even the location counter). */
secdir(k, a)
int k;
register int *a;
{
	register char *p;
	register int i;
	register int *sp;

	sp = a;
	if (a) {
		secsave();
		switch (k) {
		case 2:
			i = 0;
			for (p = (char *)a + 8; i < 8; i++, p++)
				if (*p == 0)
					break;
			if (i == 8) {
				p = yytext + 8;
				if (*p)
					while (*++p)
						;
			}
			switch (p[-1]) {
			case 'P':
			case 'p':
				secsel(2);
				break;
			case 'D':
			case 'd':
				secsel(3);
				break;
			case 'B':
			case 'b':
				secsel(4);
				break;
			default:
				error("illegal section name");
			}
			if (*a == 0)
				*a = 30;
			break;
		case 4:
			secsave();
			g90ce = 1;
			g9046 = sp[2];
			*sp = -1;
			break;
		case 5:
			secsave();
			p = (char *)sp[2];
			*sp = -1;
			while ((char *)g9046 < p) {
				outbyte(0);
				g9046++;
			}
			g90ce = 0;
			break;
		default:
			error(" unimplmented ASSDIR");
		}
		return;
	}
	switch (k) {
	default:
		error(" unimplmented ASSDIR");
		break;
	case 1:
		gca80 = 1;
		break;
	case 0x6F:
		if (g9046 & 1) {
			g9046++;
			outbyte(0);
		}
		break;
	case 4:
		secsave();
		g90ce = 1;
		break;
	case 5:
		secsave();
		g90ce = 0;
		break;
	case 7:
		secsel(2);
		break;
	case 3:
	case 6:
		secsel(3);
		break;
	}
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* outbyte (original 3CEA): writes the byte C to the first file of the current section and a 0 byte to the second one
   (unless the section is 4 = bss) */
outbyte(c)
char c;
{
	if (g90d0 != 4) {
		owrite(sectab[g90d0].se_a, &c, 1);
		owrite(sectab[g90d0].se_b, "", 1);
	}
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* dirset (original 3D38): section 3 selected through secdir(6, 0); counts gcc36 up */
dirset()
{
	secdir(6, 0);
	gcc36++;
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* dirclr (original 3D52): gcc36 = 0, section 2 through secdir(7, 0) */
dirclr()
{
	gcc36 = 0;
	secdir(7, 0);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* stpush (original 3D6C): saves the parser state words on the two small stacks bufp3 (limit area3 + 94) and bufp4 */
stpush()
{
	if (bufp3 > area3 + 94) {
		error("nesting too deep");
		return;
	}
	*(int *)bufp3 = g90cc;
	bufp3 += 2;
	*(int *)bufp3 = g8d12;
	bufp3 += 2;
	*(int *)bufp4 = g8d22;
	bufp4 += 2;
	*(int *)bufp4 = g9042;
	bufp4 += 2;
	*(int *)bufp4 = g8d0e;
	bufp4 += 2;
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* stpop (original 3DD0): restores the state words saved by stpush (reverse order) */
stpop()
{
	bufp4 -= 2;
	g8d0e = *(int *)bufp4;
	bufp4 -= 2;
	g9042 = *(int *)bufp4;
	bufp4 -= 2;
	g8d22 = *(int *)bufp4;
	bufp3 -= 2;
	g8d12 = *(int *)bufp3;
	bufp3 -= 2;
	g90cc = *(int *)bufp3;
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text). */
/* getlab (original 3E1E): a new generic (numeric) label: yytext = the counter string numcls; then the counter byte behind the
   8 numerals (9286) is incremented with decimal carry through at most 8 places; the symbol is created (pass 1) or fetched (pass 2). */
getlab()
{
	register char *p;
	register char *q;
	register int i;
	register struct sym *sp;

	p = yytext;
	q = numcls;
	while (*p++ = *q++)
		;
	q = numcls + 8;
	(*q)++;
	for (i = 8; i; i--) {
		if (*q < '9')
			goto ok;
		*q-- = '0';
		(*q)++;
	}
	error(" too many generic labels");
ok:
	if (pass == 0)
		sp = (struct sym *)symadd(30);
	else {
		sp = (struct sym *)symget(30);
		if (sp == 0)
			error("getlab: label not found in PASS1");
	}
	return ((int)sp);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme*. */
/* labset (original 3E9E): pass 1: the cell A gets the location counter as value (+2) and the section in its type */
labset(a)
register int *a;
{
	if (pass == 0) {
		a[1] = g9046;
		*a |= g90d0;
	}
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* cpool (original 3EC0): reads the constant text of a directive up to the end of the line into the pool at gca06 (pass 1
   only; "!" starts/ends a comment, trailing blanks are cut off); returns the address of its last character, -1 at the end of
   the file, 0 on overflow (message "overflow of __constk__") */
cpool()
{
	register int c;

	if (pass == 0)
		*gca06++ = 0;
	do
		c = input();
	while (c == ' ' || c == '\t');
	if (c == -1)
		return (c);
	for (;;) {
		switch (c) {
		case '\n':
		case '\f':
		case '\r':
			do
				c = *--gca06 & 0377;
			while (c == ' ' || c == '\t');
			gca06++;
			return ((int)(gca06 - 1));
		case '!':
			do
				c = input();
			while (c != '!');
			break;
		default:
			if (gca06 >= (char *)&gca06) {
				prmsg(" overflow of __constk__ ");
				return (0);
			}
			if (pass == 0)
				*gca06++ = c;
		}
		c = input();
		if (c == -1)
			return (c);
	}
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* secsave (original 3F72): g90ce == 1: reloads the location counter g9046 from the current section and clears g90ce;
   otherwise stores g9046 into the current section g90d0 */
secsave()
{
	if (g90ce == 1) {
		g90ce = 0;
		g9046 = sectab[g90d0].se_pc;
	} else
		sectab[g90d0].se_pc = g9046;
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the name follows the message text or the use). */
/* secsel (original 3FB0): switches to section N (saves the location counter of the old one) */
secsel(n)
int n;
{
	secsave();
	g90d0 = n;
	g9046 = sectab[n].se_pc;
}

/* inifin (original 3FD6): end of an initialization list: the symbol cell gccb8 gets its size if it has none, the
   remaining items (gccba, counted in units of g9048 bytes) are filled with zero bytes; resets g8d0c/g8d0e */
inifin()
{
	if (gccb8) {
		if (gccb8[2] == 0)
			gccb8[2] = (gccba + 1) * g9048 * -1;
		if (gccba > 0) {
			gccba *= g9048;
			g9046 += gccba;
			while (gccba-- != 0)
				outbyte(0);
		}
		gccb8 = 0;
	}
	g8d0c = g8d0e = 0;
}

/* inibeg (original 404A): start of an initialization: cell A, unit size B, item count C (-1 = unknown).  Pass 1:
   location counter, size (C * B) and section into the cell; bit 5 with g8d06 == 6 */
inibeg(a, b, c)
register int *a;
int b, c;
{
	gccb8 = a;
	gccba = c;
	g9048 = b;
	if (pass == 0 && a) {
		a[1] = g9046;
		if (c != -1)
			a[2] = c * b;
		*a |= g90d0;
		if (g8d06 == 6)
			*a |= 32;
	}
}

/* zero block of the original (6F66): the data written to the relocation file of an initializer */
long zl1 = 0;

/* iniput (original 40A4): one initializer item from the operand cell A (value +2..+5, word +4): pass 2 writes it (1 byte,
   2/3 bytes as the word of opreg(), 4 bytes) to the file pair of the section (TEXT or DATA) and prints the listing
   line; the location counter advances by g9048.  The cell becomes -1 */
iniput(a)
register int *a;
{
	register int *p;
	register int fa;
	register int fb;
	int w;
	char cb;

	if (a == 0)
		error("'?' not supported");
	else {
		if (gccba-- != 0) {
			if (g9048 > 4)
				error("longer then long not supported");
			else {
				if (pass == 1) {
					switch (g90d0) {
					case 2:
						fa = fd_o;
						fb = fd_q;
						break;
					case 3:
						fa = fd_p;
						fb = fd_r;
						break;
					default:
						error("initialization only in TEXT or DATA!");
					}
					p = a + 1;
					if (g9048 < 4) {
						if (g9048 == 1) {
							cb = ((char *)a)[5];
							owrite(fa, &cb, 1);
							owrite(fb, &zl1, 1);
						} else {
							p++;
							g90e2 = a;
							w = opreg();
							swabw(g9048, &w);
							swabw(g9048, p);
							owrite(fa, p, g9048);
							owrite(fb, &w, g9048);
							swabw(g9048, &w);
							swabw(g9048, p);
						}
						if (lflag)
							fprintf(lstfile, "%04x%c %04x\n", g9046, "*ATDB"[g90d0], a[2]);
					} else {
						swabw(g9048, p);
						swabw(g9048, &zl1);
						owrite(fa, p, g9048);
						owrite(fb, &zl1, g9048);
						swabw(g9048, p);
						swabw(g9048, &zl1);
						if (lflag)
							fprintf(lstfile, "%04x%c %08lx\n", g9046, "*ATDB"[g90d0], *(long *)(a + 1));
					}
				}
				g9046 += g9048;
			}
		} else {
			gccba = 0;
			error("more initiators then expected");
		}
		*a = -1;
	}
}

/* zero block of the original (6F6E) */
long zl2 = 0;

/* inibyte (original 4298): one initializer item with the value C (a byte, from a character constant) in the data file
   pair of section 3: pass 2 writes it as word (units 1 and 2) or long (unit 4) */
inibyte(c)
char c;
{
	int w;
	long l;

	if (gccba-- != 0) {
		if (g9048 > 4)
			error("longer then 'long' not supported");
		else {
			if (pass == 1 && lflag)
				fprintf(lstfile, "%04x%c %04x\n", g9046, "*ATDB"[g90d0], c);
			w = c;
			l = c;
			switch (g9048) {
			case 1:
			case 2:
				owrite(fd_p, &w, g9048);
				break;
			case 4:
				owrite(fd_p, &l, g9048);
				break;
			default:
				error("type longer LVAL");
				return;
			}
			owrite(fd_r, &zl2, g9048);
			g9046 += g9048;
		}
	} else {
		gccba = 0;
		error("more initiators then expected");
	}
}

/* textsec (original 4372): selects section 2 (TEXT); the cell A is defined there in pass 1 (type 2, bit 5 with g8d06 == 6);
   returns A */
textsec(a)
register int *a;
{
	secsel(2);
	if (pass == 0) {
		a[1] = g9046;
		*a = 2;
		if (g8d06 == 6)
			*a |= 32;
	}
	g8d10 = 0;
	d831e = 0;
	return ((int)a);
}

/* labtyp (original 43AE): the symbol of the cell A with the token 0x1B (see labsym) */
labtyp(a)
register int a;
{
	labsym(a, 27);
}
