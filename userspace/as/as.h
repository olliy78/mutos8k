/* as.h: declarations shared by the reconstructed parts of /usr/bin/as (W7c skeleton).
   Not V7: reconstructed from the MUTOS binary.  All names are invented (Annahme, doc/userspace/wk_w7c.md);
   the original had no symbols.  Token numbers are in the yacc output as_y.c, not here. */
#include <stdio.h>

struct kwent { char *k_name; int k_tok; };		/* keyword table, 4 B */
struct ctent { char *c_name; int c_tok; int c_val; };	/* condition/flag/control register table, 6 B */
struct mnent { char *m_name; int m_w[6]; };		/* mnemonic table, 14 B */

extern struct kwent kwtab[];
extern struct ctent ctab1[], ctab2[];
extern struct mnent mnem[];

/* scalar data (initialized, original data 8310..8320) */
extern int pass;		/* 0 during pass 1, 1 during pass 2 */
extern char *yysptr;		/* lex frame: unput stack pointer, = yysbuf */
extern FILE *yyin, *yyout;
extern char *symend, *symcur, *symlim;	/* pointers into symtab */
extern int d831e;		/* initialized word, value 6, use unknown */
extern char *lptr;		/* listing line buffer pointer, = lbuf */
extern FILE *lstfile, *errfile;	/* original data 6BC6, 6BC8; both stderr at start */

/* BSS (original addresses 8D24..CC22, laid out by ld, so only the sizes are meant) */
extern char yysbuf[];		/* 200 B */
extern int yytchar, yylineno, yycnt, yyskip, lflag, uflag, cflag, errcount, yydebug;
extern char lbuf[];		/* 128 B listing line buffer */
extern char *oname, *curname;
extern char numcls[];		/* 8 B */
extern int fd_o, fd_p, fd_q, fd_r, fd_s, cp_o, cp_q, cp_p, cp_r;
extern char *bufp1, *bufp2, *bufp3, *bufp4;
extern char area3[], area4[], lname[];
extern char symtab[];		/* 13584 B = 849 entries of 16 B (Annahme: symbol table) */
