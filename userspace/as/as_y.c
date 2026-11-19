/* as.c: GENERATED from as.y (V7 text, unchanged) by the MUTOS V7-yacc (userspace/ergaenzung/yacc, size class SMALL)
   in the emulator guest: cd /tmp; yacc as.y; y.tab.c -> as.c.  Regenerate: tools/userspace/erg_yacc.py userspace/as/as.
   Not V7 source text, not edited by hand. */

# line 5 "as.y"
#define IN_AS_Y 1
#include "as.h"
/* value of a cell at byte offset 4 (low word of the long value of a struct obj, or s_x of a struct sym; Annahme) */
#define CELL4(p) (*(int *)((char *)(p) + 4))

# line 10 "as.y"
typedef union  { int u; } YYSTYPE;
# define MODULE 3
# define TYPE 5
# define GLOBAL 6
# define INTERNAL 7
# define EXTERNAL 14
# define SIZEOF 15
# define SEG 16
# define OFFSET 17
# define BYTE 18
# define WORD 19
# define LONG 20
# define ARRAY 24
# define RECORD 25
# define PROCEDURE 26
# define LABEL 27
# define ENTRY 28
# define END 29
# define LOCAL 30
# define CONSTANT 258
# define DO 276
# define OD 277
# define EXIT 278
# define FROM 279
# define REPEAT 280
# define IF 281
# define THEN 282
# define ELSE 283
# define FI 284
# define CASE 285
# define NUMBER 293
# define TOK294 294
# define TOK296 296
# define TOK297 297
# define IDENT 298
# define TOK299 299
# define TOK300 300
# define TOK302 302
# define INITKW 304
# define TOK305 305
# define CCODE 306
# define CCODE2 307
# define SPV 308
# define CTLREG 309
# define FPFLAG 310
# define TOK311 311
# define VIFLAG 312
# define SECDIR 313
# define TOK314 314
# define TOK315 315
# define DATADIR 316
# define CODEDIR 317
# define LOR 286
# define LXOR 287
# define MOD 289
# define SHL 290
# define SHR 291
# define LAND 288
# define LNOT 292
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 170,
	315, 69,
	93, 69,
	-2, 70,
	};
# define YYNPROD 172
# define YYLAST 737
short yyact[]={

  40, 164, 246, 232,  22,  23,  24, 106, 200,  22,
  23,  24,  40,  25, 169,  85,  84,  58,  25,  69,
 222,  47, 235,  59, 204,  39, 106, 212,  36, 184,
  37, 194,  20,   6,  20, 164,  20,  39, 135, 202,
  36, 106,  37, 192, 193,  40,  96,  97,  98, 221,
  45,  26,   3, 178,  91,  40, 257, 258, 243,  96,
  97,  98, 167, 214, 267, 101, 259, 111, 110, 213,
  39, 188, 196,  36,  50,  37,  93, 139, 164, 150,
  39, 252, 170,  36, 106,  37, 140, 251, 164, 250,
 112, 239, 168, 172, 106, 174, 187, 138,   4, 236,
  40, 122,  78,  96,  97,  98, 175,  79, 136, 101,
 114,  96,  97,  98, 208, 201,   5, 109,  40, 111,
 110,  78,  74, 199,  75,  39,  79,  40,  36, 166,
  37,  40, 117, 115,  92,  40, 265, 263, 262,  71,
  73,  72, 181,  39, 242,  90,  36, 195,  37,  56,
 191, 107,  39, 116,  46,  36,  39,  37, 151,  36,
  39,  37, 206,  36, 164,  37,  64,  96,  97,  98,
  96,  97,  98,  96,  97,  98, 101, 120, 190, 109,
  29,  68, 110, 154,  94, 159,  66, 152,  53,  53,
 148,  78,  74, 147,  75, 146,  79, 173,  67,  30,
 145, 144, 143, 141, 198, 160, 177, 176, 118,  71,
  73,  72, 113,  78,  74,  60,  75, 245,  79,  78,
  74,  62,  75,  63,  79,  78,  74, 153,  75, 185,
  79,  71,  73,  72,  61, 205,  55,  71,  73,  72,
  52,  51, 103, 108, 134,  78,  74, 162,  75, 155,
  79, 156, 157, 189, 253,  14, 207,  21, 197, 209,
  14, 153,  21,  71,  73,  72,  49, 142, 161, 105,
 137,  65,  31, 234,  19,  59, 158,  38,  41, 217,
  18, 162, 211, 155,  20, 156, 157, 163, 105,  38,
  41, 230, 231, 229, 219, 220, 218, 228,  17,  42,
 215,  28, 161, 105, 153,  16,  43,  27,  15,  59,
 158,  42,  20,  12, 153, 256, 233,  20,  20,  11,
  10, 163,  38,  41, 162, 104, 155,  99, 156, 157,
   9,   8,  38,  41, 162,   7, 155,   1, 156, 157,
  99, 102, 227, 266,  42, 161, 105, 165,  83,  80,
  81,  82,  59, 158,  42, 161, 105, 225, 224,  35,
 223,  20,  59, 158, 163,  76,  77,  83,  80,  81,
  82,  20, 104, 255, 163,  57,  95,  38,  41, 100,
  44,   2, 216, 182,  99, 102,   0, 237, 238,   0,
   0,   0,  99,   0,  70,  38,  41, 186,   0,  42,
   0,  34,   0,   0,  38,  41, 249,   0,  38,  41,
 247,   0,  38,  41,   0,   0,   0,  42,  32,   0,
 108,   0, 104,   0,  78,  74,  42,  75,   0,  79,
  42,   0,   0,   0,  42,  76,  77,  83,  80,  81,
  82,   0,  71,  73,  72,   0,   0,   0,  99,   0,
   0,  99, 102, 254,  99,   0, 240,  76,  77,  83,
  80,  81,  82,  76,  77,  83,  80,  81,  82,  76,
  77,  83,  80,  81,  82,   0,   0, 149, 171,   0,
   0, 104,  13,   0,   0,   0,   0,   0,   0,  76,
  77,  83,  80,  81,  82,   0, 260, 261,   0,  33,
   0,   0,   0,   0,   0,   0,  48,  54,  54,  48,
   0,   0,   0,   0,   0,  86,  87,  88,  89,   0,
   0, 104, 104,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
 119, 121, 123, 124, 125, 126, 127, 128, 129, 130,
 131, 132, 133,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0, 179,
   0, 180,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 183,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0, 203,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0, 210,   0,   0,   0,   0,   0,   0,  76,  77,
  83,  80,  81,  82, 226,  13,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0, 241,   0,   0,   0,   0,   0,   0,
   0, 244,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0, 248,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0, 264 };
short yypact[]={

-246,-1000,-1000, 113,   4,-1000,-247,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
 103,-1000,-1000,-1000,-1000,-1000,-1000,-248,-277,-281,
-281,-279,-1000,  79,-299,-300, 120, 120, 120, 120,
 105,-1000,-1000,-1000,-242,  76,-1000, 152,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000, -10,  93,-1000,
  49,  75,-1000,  74,-1000,-1000,-1000,-1000,-1000,  41,
-1000, 116,  40, 120, 120, 120, 120, 120, 120, 120,
 120, 120, 120, 120,-1000,-1000,-1000,-1000,-1000, 203,
-260,-1000,  47,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,   6,-1000,  48, -10,  71,-231,-1000,-1000,   1,
-1000,-1000,-301,  30,  30,-1000,   2,  45,-244, 183,
 120, 183, 120, 183,  60,  60,  60,  60,-1000,-1000,
-1000,-1000,-1000,-1000,-1000, 101,-1000, 120,-1000,-269,
-1000,-1000,  58,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
-1000,-1000,-1000,-1000, -10,-208,-208,-263,-184,-1000,
-1000,  65,-1000,-307,-1000,  58,-1000,  57,  -3,-1000,
-1000, 382,-1000,-1000,-1000, -67, 134,-1000,  56, 183,
 183,-1000,  85, 382,-1000,-1000,   5,-1000,-271,-1000,
-213,-222,-1000,-1000,-1000, -15,-312,  -1,-276,  38,
-1000,-1000,  28, 149,-1000,-1000,-1000,-1000,-1000,  -2,
 382,-1000,-1000, -10, 120,-1000,-1000, 104,-1000,-1000,
-1000,-236, 120,-1000,-1000,-1000, 177,-1000,-1000,-1000,
-1000,-1000,-1000,-313,-1000, 155, 112,  -4,  -6,-1000,
 -29, 171,  21,-1000, 382,-237,-1000,-1000, 382,-1000,
-1000,-1000,-218, -10, -10,  97,  96, 120,  95,-1000,
  58, -29,-1000,-1000, 382,-1000,-220,-1000 };
short yypgo[]={

   0, 478, 383,  82, 382, 381, 380,  76, 184, 379,
 376, 166, 375, 373, 360, 358, 357, 342, 337,  98,
 335, 331, 330, 320, 319, 313, 477, 308, 307, 306,
 305, 301, 154, 298, 180, 280, 274, 272, 271, 270,
 266,  74, 241, 240, 158, 236, 149, 234, 223, 221,
 215,  90, 212, 242, 208, 207,  79, 206, 205, 204,
  86, 267, 203, 202, 201, 200, 195, 193, 190, 187,
 185, 183,  96, 178,  81, 150, 147 };
short yyr1[]={

   0,  18,   5,  19,  19,  20,  20,  20,  20,  20,
  20,  20,  21,  27,  28,  28,  22,  30,  31,  31,
  23,  33,  24,  35,  25,  37,  37,  36,  29,   6,
  26,  26,  26,  26,  32,  32,   7,   7,   8,   8,
   8,   8,  10,   9,   9,  39,  34,  34,  40,  40,
  40,  40,  40,  43,  41,  41,  38,  38,  38,  47,
  48,  48,  49,  50,  45,  45,  45,  45,  45,  51,
  52,  52,   3,   3,  46,  42,  12,  11,  55,  55,
  54,  54,  57,  56,  58,  59,  59,  53,  53,  53,
  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,
  60,  60,  60,  60,  69,  69,  69,  68,  70,  44,
  62,  71,  61,  61,  63,  64,  72,  72,  65,  73,
  73,  66,  74,  74,  75,   2,   2,  67,  67,  76,
  76,   4,   4,   4,   4,   4,   4,   4,   4,   4,
   4,   4,   4,  13,  14,  15,  16,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   1,   1,   1,   1,   1,  17,
  17,  17 };
short yyr2[]={

   0,   4,   2,   0,   2,   1,   1,   1,   1,   1,
   1,   1,   2,   1,   0,   2,   2,   1,   0,   2,
   2,   1,   2,   1,   2,   0,   2,   1,   2,   3,
   2,   3,   3,   3,   2,   1,   1,   1,   1,   1,
   1,   1,   1,   5,   1,   1,   0,   2,   1,   1,
   1,   1,   1,   2,   1,   1,   1,   1,   1,   2,
   6,   6,   4,   2,   3,   1,   3,   4,   1,   2,
   2,   0,   1,   1,   2,   4,   4,   2,   0,   2,
   0,   2,   2,   2,   1,   0,   2,   0,   2,   2,
   1,   0,   2,   1,   1,   1,   1,   1,   1,   1,
   1,   1,   1,   1,   4,   4,   4,   4,   2,   3,
   3,   1,   2,   3,   2,   2,   0,   2,   6,   1,
   1,   8,   0,   2,   1,   2,   1,   3,   3,   0,
   2,   1,   1,   1,   1,   2,   2,   1,   1,   1,
   1,   1,   1,   2,   4,   4,   4,   3,   3,   3,
   4,   4,   3,   3,   3,   3,   3,   3,   3,   3,
   3,   3,   2,   2,   2,   3,   4,   1,   1,   1,
   1,   1 };
short yychk[]={

-1000, -18,  -5, 298, -19,   3,  29, -20, -21, -22,
 -23, -24, -25, -26, 256, -27, -30, -33, -35, -36,
 313, 258,   5,   6,   7,  14, 298, -28, -31, -34,
 -34, -37, 315,  -1, 298, 256,  43,  45, 292,  40,
  15, 293, 314, -29,  -6, 298, -32, 298, -26, -40,
 -41, -42, -43, -44, -26, -45, -46, -12, 298, 304,
 -50, -47, -49, -48, -11, -38, -32, -11, -46, 298,
 315,  60,  62,  61,  43,  45, 286, 287,  42,  47,
 289, 290, 291, 288, 315, 315,  -1,  -1,  -1,  -1,
  40, 296,  58,  -7,  -8, -10,  18,  19,  20, 299,
  -9,  24, 300, -53, -61, 298,  36,  58,  -8,  24,
  27,  26, -51, -52,  61,  58, -51,  58, -54,  -1,
  61,  -1,  61,  -1,  -1,  -1,  -1,  -1,  -1,  -1,
  -1,  -1,  -1,  -1,  41, 298,  61, -39,  91,  29,
 -60, -62, -61, -63, -64, -65, -66, -67, -68, -26,
 -56, -44, -69, 256, -71, 278, 280, 281, 305, -70,
 -58, 297, 276, 316,  30, -53,  58, 293,  91, 315,
  -3,  -1,  63,  -3,  93,  61, -55, -57, 297,  -1,
  -1,  41,  -2,  -1, 298, -60, -53, -72, 279, -72,
 -73, -75, 306, 307, 294, -76, 256, -19, -59,  58,
 315,  58,  42,  -1,  91, 302,  28, -56,  58,  -7,
  -1, 277, 298, 282, 285, 315,  -4, 294, 311, 309,
 310,  64,  35, -14, -15, -16,  -1, -17, 312, 308,
 306, 307, 315, 317, -41, 298,  61,  -8,  -8,  93,
 -53,  -1,  40, 294,  -1,  40, 315, 298,  -1, 294,
  93,  93, -74, 283, 282, -13, 294,  35, 294, 284,
 -53, -53,  41,  41,  -1,  41, -74, 284 };
short yydef[]={

   0,  -2,   3,   0,   0,   2,   0,   4,   5,   6,
   7,   8,   9,  10,  11,  14,  18,  46,  46,  25,
   0,  13,  17,  21,  23,  27,   1,  12,  16,  20,
  22,  24,  30,   0,   0,   0,   0,   0,   0,   0,
   0, 167, 168,  15,   0,   0,  19,   0,  35,  47,
  48,  49,  50,  51,  52,  54,  55,  87,   0,  71,
   0,  65,  71,  68,  80,  26,  56,  57,  58,   0,
  31,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,  32,  33, 162, 163, 164,   0,
   0,  28,   0,  34,  36,  37,  38,  39,  40,  41,
  42,   0,  44,   0,  87,   0,   0,  53,  59,   0,
  74,  77,   0,   0,   0,  63,   0,   0,  78, 147,
   0, 148,   0, 149, 152, 153, 154, 155, 156, 157,
 158, 159, 160, 161, 165,   0,  29,   0,  45,   0,
  88,  90,  91,  93,  94,  95,  96,  97,  98,  99,
 100, 101, 102, 103,  87, 116, 116,   0, 129,   3,
  85,   0, 111,   0,  84,  89, 112,   0,   0, 109,
  -2,  72,  73,  64,  66,   0,   0,  81,   0, 150,
 151, 166,   0, 126,  75,  92,   0, 114,   0, 115,
   0,   0, 119, 120, 124,   0,   0,   0,  83,   0,
 108, 113,   0,   0,  62,  67,  76,  79,  82,   0,
 125, 110, 117,  87,   0, 127, 130, 131, 132, 133,
 134,   0,   0, 137, 138, 139, 140, 141, 142, 169,
 170, 171, 128,   0,  86,   0,   0,   0,   0,  43,
  91,   0,   0, 135, 136,   0, 107, 104, 105, 106,
  60,  61,   0,  87,  87,   0,   0,   0,   0, 118,
  91,  91, 145, 146, 143, 144,   0, 121 };
#
# define YYFLAG -1000
# define YYERROR goto yyerrlab
# define YYACCEPT return(0)
# define YYABORT return(1)

/*	parser for yacc output	*/

int yydebug = 0; /* 1 for debugging */
YYSTYPE yyv[YYMAXDEPTH]; /* where the values are stored */
int yychar = -1; /* current input token number */
int yynerrs = 0;  /* number of errors */
short yyerrflag = 0;  /* error recovery flag */

yyparse() {

	short yys[YYMAXDEPTH];
	short yyj, yym;
	register YYSTYPE *yypvt;
	register short yystate, *yyps, yyn;
	register YYSTYPE *yypv;
	register short *yyxi;

	yystate = 0;
	yychar = -1;
	yynerrs = 0;
	yyerrflag = 0;
	yyps= &yys[-1];
	yypv= &yyv[-1];

 yystack:    /* put a state and value onto the stack */

	if( yydebug  ) printf( "state %d, char 0%o\n", yystate, yychar );
		if( ++yyps> &yys[YYMAXDEPTH] ) { yyerror( "yacc stack overflow" ); return(1); }
		*yyps = yystate;
		++yypv;
		*yypv = yyval;

 yynewstate:

	yyn = yypact[yystate];

	if( yyn<= YYFLAG ) goto yydefault; /* simple state */

	if( yychar<0 ) if( (yychar=yylex())<0 ) yychar=0;
	if( (yyn += yychar)<0 || yyn >= YYLAST ) goto yydefault;

	if( yychk[ yyn=yyact[ yyn ] ] == yychar ){ /* valid shift */
		yychar = -1;
		yyval = yylval;
		yystate = yyn;
		if( yyerrflag > 0 ) --yyerrflag;
		goto yystack;
		}

 yydefault:
	/* default state action */

	if( (yyn=yydef[yystate]) == -2 ) {
		if( yychar<0 ) if( (yychar=yylex())<0 ) yychar = 0;
		/* look through exception table */

		for( yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=yystate) ; yyxi += 2 ) ; /* VOID */

		while( *(yyxi+=2) >= 0 ){
			if( *yyxi == yychar ) break;
			}
		if( (yyn = yyxi[1]) < 0 ) return(0);   /* accept */
		}

	if( yyn == 0 ){ /* error */
		/* error ... attempt to resume parsing */

		switch( yyerrflag ){

		case 0:   /* brand new error */

			yyerror( "syntax error" );
		yyerrlab:
			++yynerrs;

		case 1:
		case 2: /* incompletely recovered error ... try again */

			yyerrflag = 3;

			/* find a state where "error" is a legal shift action */

			while ( yyps >= yys ) {
			   yyn = yypact[*yyps] + YYERRCODE;
			   if( yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE ){
			      yystate = yyact[yyn];  /* simulate a shift of "error" */
			      goto yystack;
			      }
			   yyn = yypact[*yyps];

			   /* the current yyps has no shift onn "error", pop stack */

			   if( yydebug ) printf( "error recovery pops state %d, uncovers %d\n", *yyps, yyps[-1] );
			   --yyps;
			   --yypv;
			   }

			/* there is no state on the stack with an error shift ... abort */

	yyabort:
			return(1);


		case 3:  /* no shift yet; clobber input char */

			if( yydebug ) printf( "error recovery discards char %d\n", yychar );

			if( yychar == 0 ) goto yyabort; /* don't discard EOF, quit */
			yychar = -1;
			goto yynewstate;   /* try again in the same state */

			}

		}

	/* reduction by production yyn */

		if( yydebug ) printf("reduce %d\n",yyn);
		yyps -= yyr2[yyn];
		yypvt = yypv;
		yypv -= yyr2[yyn];
		yyval = yypv[1];
		yym=yyn;
			/* consult goto table to find next state */
		yyn = yyr1[yyn];
		yyj = yypgo[yyn] + *yyps + 1;
		if( yyj>=YYLAST || yychk[ yystate = yyact[yyj] ] != -yyn ) yystate = yyact[yypgo[yyn]];
		switch(yym){
			
case 1:
# line 71 "as.y"
{
	/* action 1 */
	if (yypvt[-3].u != yypvt[-0].u)
		error("wrong end of module");
	f3844();
} break;
case 2:
# line 77 "as.y"
{
	/* action 2 */
	yyval.u = yypvt[-1].u;
	f2e38(yypvt[-1].u);
} break;
case 3:
# line 82 "as.y"
{ /* action 3 */ } break;
case 4:
# line 83 "as.y"
{ /* action 4 */ } break;
case 5:
# line 84 "as.y"
{ /* action 5 */ } break;
case 6:
# line 85 "as.y"
{ /* action 6 */ } break;
case 7:
# line 86 "as.y"
{ /* action 7 */ } break;
case 8:
# line 87 "as.y"
{ /* action 8 */ } break;
case 9:
# line 88 "as.y"
{ /* action 9 */ } break;
case 10:
# line 89 "as.y"
{ /* action 10 */ } break;
case 11:
# line 90 "as.y"
{ /* action 11 */ } break;
case 12:
# line 91 "as.y"
{ /* action 12 */ } break;
case 13:
# line 92 "as.y"
{
	/* action 13 */
	g8d06 = 258;
} break;
case 14:
# line 96 "as.y"
{ /* action 14 */ } break;
case 15:
# line 97 "as.y"
{ /* action 15 */ } break;
case 16:
# line 98 "as.y"
{ /* action 16 */ } break;
case 17:
# line 99 "as.y"
{
	/* action 17 */
	g8d06 = 5;
} break;
case 18:
# line 103 "as.y"
{ /* action 18 */ } break;
case 19:
# line 104 "as.y"
{ /* action 19 */ } break;
case 20:
# line 105 "as.y"
{ /* action 20 */ } break;
case 21:
# line 106 "as.y"
{
	/* action 21 */
	g8d06 = 6;
} break;
case 22:
# line 110 "as.y"
{ /* action 22 */ } break;
case 23:
# line 111 "as.y"
{
	/* action 23 */
	g8d06 = 7;
} break;
case 24:
# line 115 "as.y"
{ /* action 24 */ } break;
case 25:
# line 116 "as.y"
{ /* action 25 */ } break;
case 26:
# line 117 "as.y"
{ /* action 26 */ } break;
case 27:
# line 118 "as.y"
{
	/* action 27 */
	g8d06 = 32;
} break;
case 28:
# line 122 "as.y"
{
	/* action 28 */
	f2dac(yypvt[-1].u, yypvt[-0].u);
	g8d08 = 0;
} break;
case 29:
# line 127 "as.y"
{
	/* action 29 */
	if (g8d06 == 258)
		g8d08 = 1;
	else
		error(" wrong: IDENT :=___");
} break;
case 30:
# line 134 "as.y"
{
	/* action 30 */
	secdir(yypvt[-1].u, 0);
} break;
case 31:
# line 138 "as.y"
{
	/* action 31 */
	secdir(yypvt[-2].u, yypvt[-1].u);
} break;
case 32:
# line 142 "as.y"
{
	/* action 32 */
	secdir(yypvt[-2].u, yypvt[-1].u);
} break;
case 33:
# line 146 "as.y"
{
	/* action 33 */
	error(" invalid ASSDIR construction");
	yyerrok;
} break;
case 34:
# line 151 "as.y"
{
	/* action 34 */
	f2dcc(yypvt[-1].u, yypvt[-0].u);
} break;
case 35:
# line 155 "as.y"
{ /* action 35 */ } break;
case 36:
# line 156 "as.y"
{
	/* action 36 */
	yyval.u = yypvt[-0].u;
} break;
case 37:
# line 160 "as.y"
{
	/* action 37 */
	yyval.u = yypvt[-0].u;
} break;
case 38:
# line 164 "as.y"
{
	/* action 38 */
	yyval.u = 1;
} break;
case 39:
# line 168 "as.y"
{
	/* action 39 */
	yyval.u = 2;
} break;
case 40:
# line 172 "as.y"
{
	/* action 40 */
	yyval.u = 4;
} break;
case 41:
# line 176 "as.y"
{
	/* action 41 */
	yyval.u = CELL4(yypvt[-0].u);
} break;
case 42:
# line 180 "as.y"
{
	/* action 42 */
	yyval.u = yypvt[-0].u;
} break;
case 43:
# line 184 "as.y"
{
	/* action 43 */
	yyval.u = CELL4(yypvt[-2].u) * yypvt[-1].u;
	((struct obj *)yypvt[-2].u)->o_t = -1;
} break;
case 44:
# line 189 "as.y"
{
	/* action 44 */
	yyval.u = CELL4(yypvt[-0].u);
} break;
case 45:
# line 193 "as.y"
{
	/* action 45 */
	g8d0a = 1;
} break;
case 46:
# line 197 "as.y"
{ /* action 46 */ } break;
case 47:
# line 198 "as.y"
{ /* action 47 */ } break;
case 48:
# line 199 "as.y"
{ /* action 48 */ } break;
case 49:
# line 200 "as.y"
{ /* action 49 */ } break;
case 50:
# line 201 "as.y"
{ /* action 50 */ } break;
case 51:
# line 202 "as.y"
{ /* action 51 */ } break;
case 52:
# line 203 "as.y"
{ /* action 52 */ } break;
case 53:
# line 204 "as.y"
{
	/* action 53 */
	labsym(yypvt[-1].u, 58);
} break;
case 54:
# line 208 "as.y"
{ /* action 54 */ } break;
case 55:
# line 209 "as.y"
{ /* action 55 */ } break;
case 56:
# line 210 "as.y"
{ /* action 56 */ } break;
case 57:
# line 211 "as.y"
{ /* action 57 */ } break;
case 58:
# line 212 "as.y"
{ /* action 58 */ } break;
case 59:
# line 213 "as.y"
{
	/* action 59 */
	f404a(yypvt[-1].u, yypvt[-0].u, 1);
} break;
case 60:
# line 217 "as.y"
{
	/* action 60 */
	f404a(yypvt[-5].u, yypvt[-1].u, -1);
} break;
case 61:
# line 221 "as.y"
{
	/* action 61 */
	f404a(yypvt[-5].u, yypvt[-1].u, CELL4(yypvt[-2].u));
	((struct obj *)yypvt[-2].u)->o_t = -1;
} break;
case 62:
# line 226 "as.y"
{
	/* action 62 */
	g8d0c = 1;
	g8d0e = 1;
} break;
case 63:
# line 231 "as.y"
{
	/* action 63 */
	g8d0e = 1;
} break;
case 64:
# line 235 "as.y"
{
	/* action 64 */
	f3fd6();
} break;
case 65:
# line 239 "as.y"
{
	/* action 65 */
	g8d0e = 1;
	f3fd6();
} break;
case 66:
# line 244 "as.y"
{
	/* action 66 */
	f3fd6();
} break;
case 67:
# line 248 "as.y"
{
	/* action 67 */
	f3fd6();
} break;
case 68:
# line 252 "as.y"
{
	/* action 68 */
	f3fd6();
} break;
case 69:
# line 256 "as.y"
{ /* action 69 */ } break;
case 70:
# line 257 "as.y"
{ /* action 70 */ } break;
case 71:
# line 258 "as.y"
{ /* action 71 */ } break;
case 72:
# line 259 "as.y"
{
	/* action 72 */
	yyval.u = f40a4(yypvt[-0].u);
} break;
case 73:
# line 263 "as.y"
{
	/* action 73 */
	yyval.u = f40a4(0);
} break;
case 74:
# line 267 "as.y"
{
	/* action 74 */
	f43ae(yypvt[-1].u);
} break;
case 75:
# line 271 "as.y"
{
	/* action 75 */
	f19da(yypvt[-3].u, yypvt[-0].u);
} break;
case 76:
# line 275 "as.y"
{
	/* action 76 */
	yyval.u = f4372(yypvt[-3].u);
} break;
case 77:
# line 279 "as.y"
{
	/* action 77 */
	yyval.u = f1a1e(yypvt[-1].u);
} break;
case 78:
# line 283 "as.y"
{ /* action 78 */ } break;
case 79:
# line 284 "as.y"
{ /* action 79 */ } break;
case 80:
# line 285 "as.y"
{ /* action 80 */ } break;
case 81:
# line 286 "as.y"
{ /* action 81 */ } break;
case 82:
# line 287 "as.y"
{
	/* action 82 */
	nodeset(yypvt[-1].u, 0, 0);
} break;
case 83:
# line 291 "as.y"
{
	/* action 83 */
	g8d0e = 0;
} break;
case 84:
# line 295 "as.y"
{
	/* action 84 */
	g8d10 = 1;
	g8d0e = 1;
} break;
case 85:
# line 300 "as.y"
{ /* action 85 */ } break;
case 86:
# line 301 "as.y"
{ /* action 86 */ } break;
case 87:
# line 302 "as.y"
{ /* action 87 */ } break;
case 88:
# line 303 "as.y"
{ /* action 88 */ } break;
case 89:
# line 304 "as.y"
{ /* action 89 */ } break;
case 90:
# line 305 "as.y"
{ /* action 90 */ } break;
case 91:
# line 306 "as.y"
{ /* action 91 */ } break;
case 92:
# line 307 "as.y"
{ /* action 92 */ } break;
case 93:
# line 308 "as.y"
{ /* action 93 */ } break;
case 94:
# line 309 "as.y"
{ /* action 94 */ } break;
case 95:
# line 310 "as.y"
{ /* action 95 */ } break;
case 96:
# line 311 "as.y"
{ /* action 96 */ } break;
case 97:
# line 312 "as.y"
{ /* action 97 */ } break;
case 98:
# line 313 "as.y"
{ /* action 98 */ } break;
case 99:
# line 314 "as.y"
{ /* action 99 */ } break;
case 100:
# line 315 "as.y"
{ /* action 100 */ } break;
case 101:
# line 316 "as.y"
{ /* action 101 */ } break;
case 102:
# line 317 "as.y"
{ /* action 102 */ } break;
case 103:
# line 318 "as.y"
{ /* action 103 */ } break;
case 104:
# line 319 "as.y"
{
	/* action 104 */
	nodeset(yypvt[-3].u, 1, yypvt[-0].u);
} break;
case 105:
# line 323 "as.y"
{
	/* action 105 */
	nodeset(yypvt[-3].u, 2, yypvt[-0].u);
} break;
case 106:
# line 327 "as.y"
{
	/* action 106 */
	nodeset(yypvt[-3].u, 3, yypvt[-0].u);
} break;
case 107:
# line 331 "as.y"
{
	/* action 107 */
	dirclr();
} break;
case 108:
# line 335 "as.y"
{
	/* action 108 */
	dirset();
} break;
case 109:
# line 339 "as.y"
{
	/* action 109 */
	f3fd6();
} break;
case 110:
# line 343 "as.y"
{
	/* action 110 */
	f3e9e(g8d12);
	stpop();
} break;
case 111:
# line 348 "as.y"
{
	/* action 111 */
	f167a();
} break;
case 112:
# line 352 "as.y"
{
	/* action 112 */
	labsym(yypvt[-1].u, 58);
} break;
case 113:
# line 356 "as.y"
{
	/* action 113 */
	labsym(yypvt[-1].u, 293);
} break;
case 114:
# line 360 "as.y"
{ /* action 114 */ } break;
case 115:
# line 361 "as.y"
{ /* action 115 */ } break;
case 116:
# line 362 "as.y"
{ /* action 116 */ } break;
case 117:
# line 363 "as.y"
{ /* action 117 */ } break;
case 118:
# line 364 "as.y"
{ /* action 118 */ } break;
case 119:
# line 365 "as.y"
{ /* action 119 */ } break;
case 120:
# line 366 "as.y"
{ /* action 120 */ } break;
case 121:
# line 367 "as.y"
{ /* action 121 */ } break;
case 122:
# line 368 "as.y"
{ /* action 122 */ } break;
case 123:
# line 369 "as.y"
{ /* action 123 */ } break;
case 124:
# line 370 "as.y"
{ /* action 124 */ } break;
case 125:
# line 371 "as.y"
{
	/* action 125 */
	yyval.u = exprdo(yypvt[-1].u, 42, yypvt[-0].u);
} break;
case 126:
# line 375 "as.y"
{
	/* action 126 */
	yyval.u = yypvt[-0].u;
} break;
case 127:
# line 379 "as.y"
{
	/* action 127 */
	opmatch(yypvt[-2].u);
} break;
case 128:
# line 383 "as.y"
{
	/* action 128 */
	error(" error in operands ");
} break;
case 129:
# line 387 "as.y"
{ /* action 129 */ } break;
case 130:
# line 388 "as.y"
{
	/* action 130 */
	oppush(yypvt[-0].u);
} break;
case 131:
# line 392 "as.y"
{
	/* action 131 */
	yyval.u = f1938(yypvt[-0].u, 8);
} break;
case 132:
# line 396 "as.y"
{
	/* action 132 */
	yyval.u = f1938(yypvt[-0].u, 16384);
} break;
case 133:
# line 400 "as.y"
{
	/* action 133 */
	yyval.u = f1938(yypvt[-0].u, 8192);
} break;
case 134:
# line 404 "as.y"
{
	/* action 134 */
	yyval.u = f1938(yypvt[-0].u, 4096);
} break;
case 135:
# line 408 "as.y"
{
	/* action 135 */
	yyval.u = f1938(yypvt[-0].u, 4);
} break;
case 136:
# line 412 "as.y"
{
	/* action 136 */
	yyval.u = f1938(yypvt[-0].u, 16);
} break;
case 137:
# line 416 "as.y"
{ /* action 137 */ } break;
case 138:
# line 417 "as.y"
{ /* action 138 */ } break;
case 139:
# line 418 "as.y"
{ /* action 139 */ } break;
case 140:
# line 419 "as.y"
{
	/* action 140 */
	yyval.u = f1938(yypvt[-0].u, 34);
} break;
case 141:
# line 423 "as.y"
{
	/* action 141 */
	yyval.u = f1938(yypvt[-0].u, 2112);
} break;
case 142:
# line 427 "as.y"
{
	/* action 142 */
	yyval.u = f1938(yypvt[-0].u, 256);
} break;
case 143:
# line 431 "as.y"
{
	/* action 143 */
	yyval.u = yypvt[-0].u;
} break;
case 144:
# line 435 "as.y"
{
	/* action 144 */
	yyval.u = f1ab6(yypvt[-3].u, yypvt[-1].u, 1);
} break;
case 145:
# line 439 "as.y"
{
	/* action 145 */
	yyval.u = f1ab6(yypvt[-3].u, yypvt[-1].u, 1024);
} break;
case 146:
# line 443 "as.y"
{
	/* action 146 */
	yyval.u = f1ab6(yypvt[-3].u, yypvt[-1].u, 512);
} break;
case 147:
# line 447 "as.y"
{
	/* action 147 */
	yyval.u = exprdo(yypvt[-2].u, 60, yypvt[-0].u);
} break;
case 148:
# line 451 "as.y"
{
	/* action 148 */
	yyval.u = exprdo(yypvt[-2].u, 62, yypvt[-0].u);
} break;
case 149:
# line 455 "as.y"
{
	/* action 149 */
	yyval.u = exprdo(yypvt[-2].u, 61, yypvt[-0].u);
} break;
case 150:
# line 459 "as.y"
{
	/* action 150 */
	yyval.u = exprdo(yypvt[-3].u, 15676, yypvt[-0].u);
} break;
case 151:
# line 463 "as.y"
{
	/* action 151 */
	yyval.u = exprdo(yypvt[-3].u, 15678, yypvt[-0].u);
} break;
case 152:
# line 467 "as.y"
{
	/* action 152 */
	yyval.u = exprdo(yypvt[-2].u, 43, yypvt[-0].u);
} break;
case 153:
# line 471 "as.y"
{
	/* action 153 */
	yyval.u = exprdo(yypvt[-2].u, 45, yypvt[-0].u);
} break;
case 154:
# line 475 "as.y"
{
	/* action 154 */
	yyval.u = exprdo(yypvt[-2].u, 286, yypvt[-0].u);
} break;
case 155:
# line 479 "as.y"
{
	/* action 155 */
	yyval.u = exprdo(yypvt[-2].u, 287, yypvt[-0].u);
} break;
case 156:
# line 483 "as.y"
{
	/* action 156 */
	yyval.u = exprdo(yypvt[-2].u, 42, yypvt[-0].u);
} break;
case 157:
# line 487 "as.y"
{
	/* action 157 */
	yyval.u = exprdo(yypvt[-2].u, 47, yypvt[-0].u);
} break;
case 158:
# line 491 "as.y"
{
	/* action 158 */
	yyval.u = exprdo(yypvt[-2].u, 289, yypvt[-0].u);
} break;
case 159:
# line 495 "as.y"
{
	/* action 159 */
	yyval.u = exprdo(yypvt[-2].u, 290, yypvt[-0].u);
} break;
case 160:
# line 499 "as.y"
{
	/* action 160 */
	yyval.u = exprdo(yypvt[-2].u, 291, yypvt[-0].u);
} break;
case 161:
# line 503 "as.y"
{
	/* action 161 */
	yyval.u = exprdo(yypvt[-2].u, 288, yypvt[-0].u);
} break;
case 162:
# line 507 "as.y"
{
	/* action 162 */
	yyval.u = exprdo(yypvt[-0].u, 43, 0);
} break;
case 163:
# line 511 "as.y"
{
	/* action 163 */
	yyval.u = exprdo(yypvt[-0].u, 45, 0);
} break;
case 164:
# line 515 "as.y"
{
	/* action 164 */
	yyval.u = exprdo(yypvt[-0].u, 292, 0);
} break;
case 165:
# line 519 "as.y"
{
	/* action 165 */
	yyval.u = yypvt[-1].u;
} break;
case 166:
# line 523 "as.y"
{ /* action 166 */ } break;
case 167:
# line 524 "as.y"
{ /* action 167 */ } break;
case 168:
# line 525 "as.y"
{ /* action 168 */ } break;
case 169:
# line 526 "as.y"
{ /* action 169 */ } break;
case 170:
# line 527 "as.y"
{ /* action 170 */ } break;
case 171:
# line 528 "as.y"
{ /* action 171 */ } break;
		}
		goto yystack;  /* stack new state and value */

	}
