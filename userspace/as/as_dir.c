/* as_dir.c: reconstructed /usr/bin/as, original addresses 3B78..43AE (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
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
		f3038(sectab[g90d0].se_a, &c, 1);
		f3038(sectab[g90d0].se_b, "", 1);
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

/* TEMPORARY STUB for the function at 3E9E (original 3E9E) */
f3e9e()
{
	return (0);
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

/* TEMPORARY STUB for the function at 3FD6 (original 3FD6) */
f3fd6()
{
	return (0);
}

/* TEMPORARY STUB for the function at 404A (original 404A) */
f404a()
{
	return (0);
}

/* TEMPORARY STUB for the function at 40A4 (original 40A4) */
f40a4()
{
	return (0);
}

/* TEMPORARY STUB for the function at 4298 (original 4298) */
f4298()
{
	return (0);
}

/* TEMPORARY STUB for the function at 4372 (original 4372) */
f4372()
{
	return (0);
}

/* TEMPORARY STUB for the function at 43AE (original 43AE) */
f43ae()
{
	return (0);
}
