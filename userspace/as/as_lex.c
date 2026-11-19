/* as_lex.c: reconstructed /usr/bin/as, original addresses 09D4..1626 (function order measured, module boundaries *Annahme*).
   Scanner reconstructed in W7f (doc/userspace/wk_w7f.md). */
#include "as.h"

#define TOK_NUMBER 293
#define TOK_CTL 296
#define TOK_IDENT 298

/* Not V7: reconstructed from the MUTOS binary */
/* lex frame input(): V7 lex frame with the pass-2 listing capture (original 09D4, 212 B) */
input()
{
	char c;

	if ((yytchar = yysptr > yysbuf ? *--yysptr : getc(yyin)) == '\n')
		yylineno++;
	c = yytchar == EOF ? 0 : yytchar;
	if (yycnt + 1 > yysptr)		/* int against pointer, as in the binary (unsigned compare) */
		yycnt = 0;
	if (pass == 1 && lflag) {
		if (yyskip)
			yyskip--;
		else {
			*lptr++ = c;
			if (lptr >= &lbuf[127])
				f1bda();
		}
	}
	return (c);
}

/* Not V7: reconstructed from the MUTOS binary.  Names are *Annahme* (the original had no symbols). */
/* plzlex (0AA8, 2184 B): the scanner proper, the body of the lex-frame switch over the class mask returned by
   plzlook().  Written with gotos in binary order.  The case values are the quotient/remainder-decoded constants
   of the hash switch (doc/userspace/wk_w7f.md). */
yylex()
{
	char ch;
	int radix, e, flg, brk, c, ty, v, m;
	register struct sym *sp;
	register char *s;
	register char *t;
	register struct obj *p;

	brk = 0;
	for (;;) {
	lp:
		c = plzlook();
		if (c < 0)
			return (0);
		if (c & ~0x800)
			c &= ~0x800;
		if (yydebug)
			fprintf(stderr, " nstr =0%o yytext=%s  \n", c, yytext);
		flg = 0;
		s = yytext;
		if (brk)
			goto l0bb6;
		switch ((unsigned)c) {
		case 0:
			if (yywrap())
				return (0);
			break;
		case -1:
		case 512:
			break;
		l0b1e:
			yytext[yyleng++] = ch;
			flg = 1;
		l0b38:
			ch = input();
			if (cls[ch] & 4)
				goto l0b1e;
			UNPUT(ch);
			if (flg == 0)
				goto l0c0e;
			flg = 0;
			yytext[yyleng] = 0;
			d831e = 30;
		l0bb6:
			if (g8d06 == 258)
				goto l0e78;
			if (brk == 0)
				goto l0eb0;
			ty = 30;
			if (brk <= 1)
				goto l0eaa;
			yyleng++;
			s = yytext + (m = yyleng);
			t = s - 1;
		l0bf0:
			if (m-- == 0)
				goto l0ea6;
			*s-- = *t--;
			goto l0bf0;
		l0c0e:
			if (g9042 || g9044) {
				p = getobj();
				p->o_val = g9046;
				p->o_t = 34;
				yylval = (int)p;
				return (314);
			}
			return (36);
		case 296:
			return (296);
		case 2048:
			if (yyleng == 1)
				goto l0b38;
			g9044 = 1;
		case 321:
		case 257:
		case 259:
			s = (char *)f3a18();
		case 81:
		case 17:
		case 19:
			if (brk)
				goto l0bb6;
			e = f46da(s);
			if (e == 0)
				goto l0bb6;
			return (e);
		case 1024:
			if (lflag)
				f1bda();
			if (g9044 == 0)
				goto l0c94;
			g9044 = 0;
			goto l0c8e;
		l0c8a:
			g9042 = 0;
		l0c8e:
			return (315);
		l0c94:
			if (g9042)
				goto l0c8a;
			if (g8d22 == 0)
				goto lp;
			g8d22 = 0;
			goto l0c8e;
		case 128:
			if (yytext[0] == '~') {
				brk += yyleng;
				goto lp;
			}
			if (yytext[0] == '!') {
			l0cd0:
				ch = input();
				if (ch == '!')
					goto lp;
				goto l0cd0;
			}
			if (yytext[0] != '\'')
				goto lp;
			yyskip++;
			while (--yyleng)
				UNPUT(ch = yytext[yyleng]);
			yyskip--;
			if (g8d22 || g9042 || g8d0c) {
				p = getobj();
				v = 0;
				if (g9048 == 4) {
					s = (char *)p + 2;
					e = escchar();
					if (e == 512)
						goto l0dd4;
					*s++ = e;
					e = escchar();
					if (e == 512)
						goto l0dd4;
					*s++ = e;
				} else
					s = (char *)&v;
				e = escchar();
				if (e == 512)
					goto l0dd4;
				*s++ = e;
				*s = escchar();
			l0dd4:
				yylval = (int)p;
				if (g9048 == 4)
					return (314);
				p->o_val = v;
				return (314);
			}
			for (;;) {
				e = escchar();
				if (e == 512)
					break;
				f4298(e);
			}
			return (302);
		case 1:
		case 3:
		case 67:
			s = yytext;
			if (*s != 'f' && *s != 'F')
				goto l0bb6;
			s++;
			v = 0;
			if ((cls[ch = *s++] & 4) == 0)
				goto l0bb6;
			v = ch - '0';
			if (v > 7)
				error("illegal floating register");
			yylval = v;
			return (311);
		l0e78:
			yylval = (int)(sp = (struct sym *)f48a4(6));
			if (sp)
				goto l0f20;
			sp = (struct sym *)f4814(6);
			yylval = (int)sp;
		l0e9e:
			return (TOK_IDENT);
		l0ea6:
			*s = '~';
		l0eaa:
			if (pass == 0)
				goto l0f10;
		l0eb0:
			sp = (struct sym *)f48a4(30);
			yylval = (int)sp;
			if (sp && brk == 0 && sp->s_w == -1)
				sp = 0;
			if (sp)
				goto l0f20;
			yylval = (int)(sp = (struct sym *)f48a4(6));
			if (sp)
				goto l0f20;
			ty = 6;
			if (d831e)
				ty = d831e;
			if (g8d10)
				ty = 30;
		l0f10:
			sp = (struct sym *)f4814(ty);
			yylval = (int)sp;
		l0f20:
			if (sp->s_t != TOK_CTL)
				goto l0fa0;
			s = (char *)sp->s_v;
			yycnt = (int)yysptr;
			yyskip = 1;
			while (ch = *s--)
				UNPUT(ch);
			yyskip--;
			goto lp;
		l0fa0:
			if (g8d22 || g9042 || g8d0e) {
				p = getobj();
				yylval = (int)p;
				p->o_val = sp->s_v;
				p->o_ref = (int)sp;
				return (314);
			}
			if (brk == 0)
				goto l0e9e;
			brk = 0;
			return (297);
		case 65:
			s = yytext;
			v = 0;
			m = 0;
			switch (ch = *s++) {
			case 'R':
			case 'r':
				break;
			default:
				goto l0bb6;
			}
			switch (ch = *s++) {
			case 0:
				goto l0bb6;
			case 'R':
			case 'r':
				g904a = 2;
				goto l10b8;
			l1056:
				if ((cls[ch] & 4) == 0)
					goto l0bb6;
				v *= 10;
				v += ch - '0';
				goto l10b8;
			case 'L':
			case 'l':
				m = 8;
				goto l10b2;
			case 'Q':
			case 'q':
				g904a = 4;
				goto l10b8;
			default:
				if (ch < '0' || ch > '9')
					goto l0bb6;
				s--;
			case 'H':
			case 'h':
			l10b2:
				g904a = 1;
			}
		l10b8:
			if (ch = *s++)
				goto l1056;
			if (v % g904a)
				error("register type");
			yylval = v + m;
			return (294);
		case 71:
		case 79:
			radix = 10;
			yyskip++;
			while (yyleng--)
				UNPUT(ch = yytext[yyleng]);
			yyskip--;
			goto l117a;
		case 32:
			if (yytext[0] != '%')
				goto l1276;
			radix = 16;
		l117a:
			p = getobj();
			if (yytchar == '(') {
				ch = input();
				input();
				t = input();
				if (t != ')')
					prmsg("expecting '%(n)'-construct");
				radix = ch - '0';
			}
			while (cls[ch = input()] & 2) {
				p->o_val *= radix;
				p->o_val += ch <= '9' ? ch - '0' : ch <= 'F' ? ch - 55 : ch - 87;
			}
			UNPUT(ch);
			yylval = (int)p;
			p->o_t = 16;
			return (TOK_NUMBER);
		l1276:
			return (yytext[0]);
		default:
			error("bad switch in plzlex returning from yylook");
		}
	}
}

/* 1330: allocate a free scanner value cell (original 1330) */
struct obj *getobj()
{
	register int i;

	for (i = 0; i < 10; i++)
		if (objtab[i].o_t == -1) {
			objtab[i].o_t = 0;
			objtab[i].o_val = 0L;
			objtab[i].o_ref = 0;
			return (&objtab[i]);
		}
	prmsg("fatal error: overflow of expression/operands list");
	f31ba();
}

/* 13A2: mark all scanner value cells free (original 13A2) */
iniobj()
{
	register int i;

	for (i = 0; i < 10; i++)
		objtab[i].o_t = -1;
}

/* 13C8: yylook replacement; reads characters while some class bit stays common, returns the last non-empty mask */
plzlook()
{
	register int c;
	register char *p;
	register int mask, last;

	if (g8d08) {
		yylval = f3ec0();
		return (296);
	}
	p = yytext;
	last = 0;
	mask = -1;
	goto l13f6;
l13ee:
	last = mask;
	if (mask == 0x20)
		goto l145a;
l13f6:
	c = input() & 0x7f;
	*p++ = c;
	if (mask &= cls[c])
		goto l13ee;
	UNPUT(*--p);
l145a:
	*p = 0;
	yyleng = p - yytext;
	return (last);
}

/* 1476: is v in the zero-terminated int list p (original 1476, missing from the earlier stub list) */
inlist(p, v)
int *p;
int v;
{
	if (p)
		while (*p)
			if (*p++ == v)
				return (1);
	return (0);
}

/* 14A6: lex frame yywrap() */
yywrap()
{
	return (1);
}

/* 14B0: compare two 8-character names, 7-bit masked, up to the first NUL (original 14B0) */
cmp8(a, b)
register char *a, *b;
{
	register int c, n;
	char d;

	n = 8;
	while (n--) {
		c = *b++ & 0x7f;
		if ((d = *a++ & 0x7f) != c)
			return (0);
		if (d == 0)
			break;
	}
	return (1);
}

/* 1502: OR the class mask m into cls[] for every character of s (original 1502) */
setcls(s, m)
register char *s;
int m;
{
	register int i;
	char c;

	while (c = *s++) {
		i = c & 0x7f;
		cls[i] |= m;
	}
}

/* 1540: read one (possibly %-escaped) character of a character constant; 0x200 = closing quote */
escchar()
{
	char c;

	if ((c = input()) == '\'')
		return (0x200);
	if (c == '%') {
		switch (c = input()) {
		case '%':
			c = '%';
			break;
		case 'R':
		case 'r':
			c = '\r';
			break;
		case 'T':
		case 't':
			c = '\t';
			break;
		case 'L':
		case 'l':
			c = '\n';
			break;
		case 'P':
		case 'p':
			c = '\f';
			break;
		case 'Q':
		case 'q':
			c = '\'';
			break;
		default:
			c = (hexdig(c) << 4) + hexdig(input());
			break;
		}
	}
	return (c);
}

/* 1626: value of one hex digit, class masks: 2 hex digit, 4 decimal, 16 upper case (BIT n tests mask 1<<n) */
hexdig(c)
char c;
{
	register int t;

	t = cls[c];
	if (t & 2) {
		if (t & 4)
			return (c - '0');
		if (t & 16)
			return (c - 55);
		return (c - 87);
	}
	error("hex_digit expected");
	return (0);
}
