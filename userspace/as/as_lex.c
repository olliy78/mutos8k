/* as_lex.c: reconstructed /usr/bin/as, original addresses 09D4..1626 (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
#include "as.h"

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

/* TEMPORARY STUB: the scanner (called `plzlex` in the doc; the generated parser calls it yylex) */
yylex()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1330 (original 1330) */
f1330()
{
	return (0);
}

/* TEMPORARY STUB for the function at 13A2 (original 13A2) */
f13a2()
{
	return (0);
}

/* TEMPORARY STUB for the function at 13C8 (original 13C8) */
f13c8()
{
	return (0);
}

/* TEMPORARY STUB for the function at 14A6 (original 14A6) */
f14a6()
{
	return (0);
}

/* TEMPORARY STUB for the function at 14B0 (original 14B0) */
f14b0()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1502 (original 1502) */
f1502()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1540 (original 1540) */
f1540()
{
	return (0);
}

/* TEMPORARY STUB for the function at 1626 (original 1626) */
f1626()
{
	return (0);
}
