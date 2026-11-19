/* as.h: declarations shared by the reconstructed parts of /usr/bin/as (W7c skeleton).
   Not V7: reconstructed from the MUTOS binary.  All names are invented (Annahme, doc/userspace/wk_w7c.md);
   the original had no symbols.  Token numbers are in the yacc output as_y.c, not here. */
#include <stdio.h>

struct kwent { char *k_name; int k_tok; };		/* keyword table, 4 B */
struct ctent { char *c_name; int c_tok; int c_val; };	/* condition/flag/control register table, 6 B */
struct mnent { char *m_name; int m_w[6]; };		/* mnemonic table, 14 B */

extern struct kwent kwtab[];
extern struct ctent ctab1[], ctab2[];
extern struct mnent mnem[];	/* 301 entries, the last one is "" */

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
extern int fd_o, fd_p, fd_q, fd_r, fd_s;
/* 12-byte section record, original table CA0A (8 records; W7h, measured from secsave/secsel/outbyte) */
struct sect { unsigned se_pc; int se_a; int se_b; int se_c; int se_d; int se_e; };
extern struct sect sectab[];
#define cp_o sectab[2].se_a
#define cp_q sectab[2].se_b
#define cp_p sectab[3].se_a
#define cp_r sectab[3].se_b
extern char *gca06;
extern char ucbuf[];
extern char *bufp1, *bufp2, *bufp3, *bufp4;
extern char area3[], area4[], lname[];
extern char symtab[];		/* 13584 B = 849 entries of 16 B (Annahme: symbol table) */

/* scanner data (W7f, names by original address = Annahme) */
struct obj { int o_t; long o_val; int o_ref; int o_x; };	/* 10 B scanner value cell, original table 904C */
struct sym { int s_t; unsigned s_v; int s_x; unsigned s_w; char s_name[8]; };	/* 16-byte symbol cell (W7g: s_w at +6, name at +8, measured) */
extern struct obj objtab[10];
extern struct obj *getobj();
extern char yytext[];		/* 200 B, original 8E76 */
extern int yyleng;		/* original 8F3E */
extern int cls[];		/* character class table, 128 words, original 8F42 */
extern int g8d06, g8d08, g8d0a, g8d0c, g8d0e, g8d10, g8d22;	/* flags set by the parser actions (Annahme) */
extern unsigned g9046;
extern int g9042, g9044, g9048, g904a, g90dc, g90e0, g90ce, g90d0, g9276, g9278, g9288, gca78, gccba;
		/* scanner state words (Annahme) */
#ifndef IN_AS_Y		/* as_y.c declares yylval itself (as the union YYSTYPE) */
extern int yylval;		/* defined by the yacc output (union of one int) */
#endif

/* lex frame unput(c) with the pass-2 listing capture, as it is inlined in the binary */
#define UNPUT(c) { yytchar = (c); if (yytchar == '\n') yylineno--; *yysptr++ = yytchar; \
	if (pass == 1 && lflag) { if (yyskip || yycnt) yyskip++; else *--lptr = 0; } }
extern int g90cc, g8d12, gcc36, gca80;

/* object output (W7i): buffers of the output files 1, 3, 4, 5 (6-byte records, original table 6BCA, initialized) */
struct obf { int ob_n; char *ob_b; char *ob_p; };
extern struct obf obtab[];
extern char gca82[], gcaaa[], gcafa[];
extern int g90de, g90c4, g90c6;
extern int gca70, gca72, gca74, gca76;
/* W7p: gc79e (constant pool, 616 B) must directly follow symtab: symend = symlim = gc79e is the end of symtab (symtab + 13584).
   As a separate array the linker placed it BEFORE symtab (bss order) -> every symadd() hit 'symbol table overflow'. */
#define gc79e (symtab + 13584)
extern int *g90b0[];
extern int g90d2[];
extern int *g90e2;
extern int *gccb8;

/* encoder (W7j): the mnemonic entry as the encoder 1C0C sees it: class byte +2, operand count +3, template word +12 */
struct mncl { char *mc_name; char mc_cls; char mc_cnt; int mc_w[5]; };
extern char g90e6[], g91ae[];	/* 200-byte code and relocation word buffers of one instruction */
extern int *cwp, *rwp, *cws, *rws;
extern int g90ca;
