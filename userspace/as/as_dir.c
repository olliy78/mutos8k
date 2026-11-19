/* as_dir.c: reconstructed /usr/bin/as, original addresses 3B78..43AE (function order measured, module boundaries *Annahme*).
   Functions marked TEMPORARY STUB only make the program link; real code: doc/userspace/wk_w7c.md. */
#include "as.h"

/* TEMPORARY STUB for the function at 3B78 (original 3B78) */
f3b78()
{
	return (0);
}

/* TEMPORARY STUB for the function at 3CEA (original 3CEA) */
f3cea()
{
	return (0);
}

/* TEMPORARY STUB for the function at 3D38 (original 3D38) */
f3d38()
{
	return (0);
}

/* TEMPORARY STUB for the function at 3D52 (original 3D52) */
f3d52()
{
	return (0);
}

/* TEMPORARY STUB for the function at 3D6C (original 3D6C) */
f3d6c()
{
	return (0);
}

/* TEMPORARY STUB for the function at 3DD0 (original 3DD0) */
f3dd0()
{
	return (0);
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

/* TEMPORARY STUB for the function at 3EC0 (original 3EC0) */
f3ec0()
{
	return (0);
}

/* TEMPORARY STUB for the function at 3F72 (original 3F72) */
f3f72()
{
	return (0);
}

/* TEMPORARY STUB for the function at 3FB0 (original 3FB0) */
f3fb0()
{
	return (0);
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
