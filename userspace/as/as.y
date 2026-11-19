/* as.y: yacc grammar of /usr/bin/as, RECOVERED from the parser tables (tools/userspace/as_grammatik.py).
   Rules in yyr1 order, so rule N here = rule N of the original tables = `case N` of yyparse.  Names of
   nonterminals (ntN = yacc number N) and of unnamed tokens (TOKn) are invented; actions 1..60 filled in (W7l), 61.. are placeholders. */
%{
#define IN_AS_Y 1
#include "as.h"
/* value of a cell at byte offset 4 (low word of the long value of a struct obj, or s_x of a struct sym; Annahme) */
#define CELL4(p) (*(int *)((char *)(p) + 4))
%}
%union { int u; }

%token MODULE 3
%token TYPE 5
%token GLOBAL 6
%token INTERNAL 7
%token EXTERNAL 14
%token SIZEOF 15
%token SEG 16
%token OFFSET 17
%token BYTE 18
%token WORD 19
%token LONG 20
%token ARRAY 24
%token RECORD 25
%token PROCEDURE 26
%token LABEL 27
%token ENTRY 28
%token END 29
%token LOCAL 30
%token CONSTANT 258
%token DO 276
%token OD 277
%token EXIT 278
%token FROM 279
%token REPEAT 280
%token IF 281
%token THEN 282
%token ELSE 283
%token FI 284
%token CASE 285
%token NUMBER 293
%token TOK294 294
%token TOK296 296
%token TOK297 297
%token IDENT 298
%token TOK299 299
%token TOK300 300
%token TOK302 302
%token INITKW 304
%token TOK305 305
%token CCODE 306
%token CCODE2 307
%token SPV 308
%token CTLREG 309
%token FPFLAG 310
%token TOK311 311
%token VIFLAG 312
%token SECDIR 313
%token TOK314 314
%token TOK315 315
%token DATADIR 316
%token CODEDIR 317
%left '<' '>' '='
%left '+' '-' LOR 286 LXOR 287
%left '*' '/' MOD 289 SHL 290 SHR 291 LAND 288
%left LNOT 292

%type <u> nt1 nt2 nt3 nt4 nt5 nt6 nt7 nt8 nt9 nt10 nt11 nt12 nt13 nt14 nt15 nt16 nt17

%%
nt18	: nt5 nt19 END IDENT	{
	/* action 1 */
	if ($<u>1 != $<u>4)
		error("wrong end of module");
	f3844();
};
nt5	: IDENT MODULE	{
	/* action 2 */
	$<u>$ = $<u>1;
	f2e38($<u>1);
};
nt19	: 	{ /* action 3 */ };
nt19	: nt19 nt20	{ /* action 4 */ };
nt20	: nt21	{ /* action 5 */ };
nt20	: nt22	{ /* action 6 */ };
nt20	: nt23	{ /* action 7 */ };
nt20	: nt24	{ /* action 8 */ };
nt20	: nt25	{ /* action 9 */ };
nt20	: nt26	{ /* action 10 */ };
nt20	: error	{ /* action 11 */ };
nt21	: nt27 nt28	{ /* action 12 */ };
nt27	: CONSTANT	{
	/* action 13 */
	g8d06 = 258;
};
nt28	: 	{ /* action 14 */ };
nt28	: nt28 nt29	{ /* action 15 */ };
nt22	: nt30 nt31	{ /* action 16 */ };
nt30	: TYPE	{
	/* action 17 */
	g8d06 = 5;
};
nt31	: 	{ /* action 18 */ };
nt31	: nt31 nt32	{ /* action 19 */ };
nt23	: nt33 nt34	{ /* action 20 */ };
nt33	: GLOBAL	{
	/* action 21 */
	g8d06 = 6;
};
nt24	: nt35 nt34	{ /* action 22 */ };
nt35	: INTERNAL	{
	/* action 23 */
	g8d06 = 7;
};
nt25	: nt36 nt37	{ /* action 24 */ };
nt37	: 	{ /* action 25 */ };
nt37	: nt37 nt38	{ /* action 26 */ };
nt36	: EXTERNAL	{
	/* action 27 */
	g8d06 = 32;
};
nt29	: nt6 TOK296	{
	/* action 28 */
	f2dac($<u>1, $<u>2);
	g8d08 = 0;
};
nt6	: IDENT ':' '='	{
	/* action 29 */
	if (g8d06 == 258)
		g8d08 = 1;
	else
		error(" wrong: IDENT :=___");
};
nt26	: SECDIR TOK315	{
	/* action 30 */
	secdir($<u>1, 0);
};
nt26	: SECDIR nt1 TOK315	{
	/* action 31 */
	secdir($<u>1, $<u>2);
};
nt26	: SECDIR IDENT TOK315	{
	/* action 32 */
	secdir($<u>1, $<u>2);
};
nt26	: SECDIR error TOK315	{
	/* action 33 */
	error(" invalid ASSDIR construction");
	yyerrok;
};
nt32	: IDENT nt7	{
	/* action 34 */
	f2dcc($<u>1, $<u>2);
};
nt32	: nt26	{ /* action 35 */ };
nt7	: nt8	{
	/* action 36 */
	$<u>$ = $<u>1;
};
nt7	: nt10	{
	/* action 37 */
	$<u>$ = $<u>1;
};
nt8	: BYTE	{
	/* action 38 */
	$<u>$ = 1;
};
nt8	: WORD	{
	/* action 39 */
	$<u>$ = 2;
};
nt8	: LONG	{
	/* action 40 */
	$<u>$ = 4;
};
nt8	: TOK299	{
	/* action 41 */
	$<u>$ = CELL4($<u>1);
};
nt10	: nt9	{
	/* action 42 */
	$<u>$ = $<u>1;
};
nt9	: ARRAY nt39 nt2 nt7 ']'	{
	/* action 43 */
	$<u>$ = CELL4($<u>3) * $<u>4;
	((struct obj *)$<u>3)->o_t = -1;
};
nt9	: TOK300	{
	/* action 44 */
	$<u>$ = CELL4($<u>1);
};
nt39	: '['	{
	/* action 45 */
	g8d0a = 1;
};
nt34	: 	{ /* action 46 */ };
nt34	: nt34 nt40	{ /* action 47 */ };
nt40	: nt41	{ /* action 48 */ };
nt40	: nt42	{ /* action 49 */ };
nt40	: nt43	{ /* action 50 */ };
nt40	: nt44	{ /* action 51 */ };
nt40	: nt26	{ /* action 52 */ };
nt43	: IDENT ':'	{
	/* action 53 */
	labsym($<u>1, 58);
};
nt41	: nt45	{ /* action 54 */ };
nt41	: nt46	{ /* action 55 */ };
nt38	: nt32	{ /* action 56 */ };
nt38	: nt11	{ /* action 57 */ };
nt38	: nt46	{ /* action 58 */ };
nt47	: IDENT nt8	{
	/* action 59 */
	f404a($<u>1, $<u>2, 1);
};
nt48	: IDENT ARRAY '[' '*' nt8 ']'	{
	/* action 60 */
	f404a($<u>1, $<u>5, -1);
};
nt48	: IDENT ARRAY '[' nt1 nt8 ']'	{ /* action 61 */ };
nt49	: nt48 ':' '=' '['	{ /* action 62 */ };
nt50	: nt47 ':'	{ /* action 63 */ };
nt45	: nt50 '=' nt3	{ /* action 64 */ };
nt45	: nt47	{ /* action 65 */ };
nt45	: nt49 nt51 ']'	{ /* action 66 */ };
nt45	: nt48 ':' '=' TOK302	{ /* action 67 */ };
nt45	: nt48	{ /* action 68 */ };
nt51	: nt52 nt3	{ /* action 69 */ };
nt52	: nt52 nt3	{ /* action 70 */ };
nt52	: 	{ /* action 71 */ };
nt3	: nt1	{ /* action 72 */ };
nt3	: '?'	{ /* action 73 */ };
nt46	: IDENT LABEL	{ /* action 74 */ };
nt42	: nt12 nt53 END IDENT	{ /* action 75 */ };
nt12	: nt11 nt54 nt55 ENTRY	{ /* action 76 */ };
nt11	: IDENT PROCEDURE	{ /* action 77 */ };
nt55	: 	{ /* action 78 */ };
nt55	: nt55 nt56	{ /* action 79 */ };
nt54	: 	{ /* action 80 */ };
nt54	: nt54 nt57	{ /* action 81 */ };
nt57	: TOK297 ':'	{ /* action 82 */ };
nt56	: nt58 nt59	{ /* action 83 */ };
nt58	: LOCAL	{ /* action 84 */ };
nt59	: 	{ /* action 85 */ };
nt59	: nt59 nt41	{ /* action 86 */ };
nt53	: 	{ /* action 87 */ };
nt53	: nt53 nt60	{ /* action 88 */ };
nt53	: nt61 nt53	{ /* action 89 */ };
nt60	: nt62	{ /* action 90 */ };
nt60	: 	{ /* action 91 */ };
nt60	: nt61 nt60	{ /* action 92 */ };
nt60	: nt63	{ /* action 93 */ };
nt60	: nt64	{ /* action 94 */ };
nt60	: nt65	{ /* action 95 */ };
nt60	: nt66	{ /* action 96 */ };
nt60	: nt67	{ /* action 97 */ };
nt60	: nt68	{ /* action 98 */ };
nt60	: nt26	{ /* action 99 */ };
nt60	: nt56	{ /* action 100 */ };
nt60	: nt44	{ /* action 101 */ };
nt60	: nt69	{ /* action 102 */ };
nt60	: error	{ /* action 103 */ };
nt69	: TOK297 ':' '=' IDENT	{ /* action 104 */ };
nt69	: TOK297 ':' '=' nt1	{ /* action 105 */ };
nt69	: TOK297 ':' '=' TOK294	{ /* action 106 */ };
nt68	: nt70 nt19 CODEDIR TOK315	{ /* action 107 */ };
nt70	: DATADIR TOK315	{ /* action 108 */ };
nt44	: INITKW nt51 TOK315	{ /* action 109 */ };
nt62	: nt71 nt53 OD	{ /* action 110 */ };
nt71	: DO	{ /* action 111 */ };
nt61	: IDENT ':'	{ /* action 112 */ };
nt61	: '$' NUMBER ':'	{ /* action 113 */ };
nt63	: EXIT nt72	{ /* action 114 */ };
nt64	: REPEAT nt72	{ /* action 115 */ };
nt72	: 	{ /* action 116 */ };
nt72	: FROM IDENT	{ /* action 117 */ };
nt65	: IF nt73 THEN nt53 nt74 FI	{ /* action 118 */ };
nt73	: CCODE	{ /* action 119 */ };
nt73	: CCODE2	{ /* action 120 */ };
nt66	: IF nt75 CASE nt1 THEN nt53 nt74 FI	{ /* action 121 */ };
nt74	: 	{ /* action 122 */ };
nt74	: ELSE nt53	{ /* action 123 */ };
nt75	: TOK294	{ /* action 124 */ };
nt2	: nt2 nt1	{ /* action 125 */ };
nt2	: nt1	{ /* action 126 */ };
nt67	: TOK305 nt76 TOK315	{ /* action 127 */ };
nt67	: TOK305 error TOK315	{ /* action 128 */ };
nt76	: 	{ /* action 129 */ };
nt76	: nt76 nt4	{ /* action 130 */ };
nt4	: TOK294	{ /* action 131 */ };
nt4	: TOK311	{ /* action 132 */ };
nt4	: CTLREG	{ /* action 133 */ };
nt4	: FPFLAG	{ /* action 134 */ };
nt4	: '@' TOK294	{ /* action 135 */ };
nt4	: '#' nt1	{ /* action 136 */ };
nt4	: nt14	{ /* action 137 */ };
nt4	: nt15	{ /* action 138 */ };
nt4	: nt16	{ /* action 139 */ };
nt4	: nt1	{ /* action 140 */ };
nt4	: nt17	{ /* action 141 */ };
nt4	: VIFLAG	{ /* action 142 */ };
nt13	: '#' nt1	{ /* action 143 */ };
nt14	: nt1 '(' TOK294 ')'	{ /* action 144 */ };
nt15	: TOK294 '(' nt13 ')'	{ /* action 145 */ };
nt16	: TOK294 '(' TOK294 ')'	{ /* action 146 */ };
nt1	: nt1 '<' nt1	{ /* action 147 */ };
nt1	: nt1 '>' nt1	{ /* action 148 */ };
nt1	: nt1 '=' nt1	{ /* action 149 */ };
nt1	: nt1 '<' '=' nt1	{ /* action 150 */ };
nt1	: nt1 '>' '=' nt1	{ /* action 151 */ };
nt1	: nt1 '+' nt1	{ /* action 152 */ };
nt1	: nt1 '-' nt1	{ /* action 153 */ };
nt1	: nt1 LOR nt1	{ /* action 154 */ };
nt1	: nt1 LXOR nt1	{ /* action 155 */ };
nt1	: nt1 '*' nt1	{ /* action 156 */ };
nt1	: nt1 '/' nt1	{ /* action 157 */ };
nt1	: nt1 MOD nt1	{ /* action 158 */ };
nt1	: nt1 SHL nt1	{ /* action 159 */ };
nt1	: nt1 SHR nt1	{ /* action 160 */ };
nt1	: nt1 LAND nt1	{ /* action 161 */ };
nt1	: '+' nt1 %prec LNOT	{ /* action 162 */ };
nt1	: '-' nt1 %prec LNOT	{ /* action 163 */ };
nt1	: LNOT nt1	{ /* action 164 */ };
nt1	: '(' nt1 ')'	{ /* action 165 */ };
nt1	: SIZEOF '(' IDENT ')'	{ /* action 166 */ };
nt1	: NUMBER	{ /* action 167 */ };
nt1	: TOK314	{ /* action 168 */ };
nt17	: SPV	{ /* action 169 */ };
nt17	: CCODE	{ /* action 170 */ };
nt17	: CCODE2	{ /* action 171 */ };
