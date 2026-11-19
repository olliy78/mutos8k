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

/* BSS: sizes of the objects the framework functions use; all other BSS of the original (17744 B) is still missing */
char yysbuf[200];
int yytchar, yylineno, yycnt, yyskip, lflag, uflag, cflag, errcount;
char lbuf[128];
char *oname, *curname;
char numcls[8];
int fd_o, fd_p, fd_q, fd_r, fd_s, cp_o, cp_q, cp_p, cp_r;
char *bufp1, *bufp2, *bufp3, *bufp4;
char area3[100], area4[150], lname[64];
char symtab[13584];
char yytext[200];
int yyleng;
int cls[128];
int g8d06, g8d08, g8d0c, g8d0e, g8d10, g8d22;
unsigned g9046;
int g9042, g9044, g9048, g904a;
struct obj objtab[10];

/* TEMPORARY STUB for the function at 43C6 (original 43C6) */
f43c6()
{
	return (0);
}

/* TEMPORARY STUB for the function at 44F0 (original 44F0) */
f44f0()
{
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

/* TEMPORARY STUB for the function at 46DA (original 46DA) */
f46da()
{
	return (0);
}

/* TEMPORARY STUB for the function at 4814 (original 4814) */
f4814()
{
	return (0);
}

/* TEMPORARY STUB for the function at 48A4 (original 48A4) */
f48a4()
{
	return (0);
}
