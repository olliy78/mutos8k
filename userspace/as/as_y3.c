/* as_y3.c: part 3 of as_y.c (yydebug, yyparse), see as_y1.c */
/* as_y.c: GENERATED from as.y (V7 text, unchanged) by the MUTOS V7-yacc (userspace/ergaenzung/yacc, size class SMALL)
   in the emulator guest: cd /tmp; yacc as.y; y.tab.c -> as_y.c.  Regenerate: tools/userspace/erg_yacc.py userspace/as/as.
   Not V7 source text, not edited by hand. */

# line 4 "as.y"
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
extern YYSTYPE yylval, yyval;
# define YYERRCODE 256
# define YYNPROD 172
# define YYLAST 737
extern short yyexca[];
extern short yyact[];
extern short yypact[];
extern short yypgo[];
extern short yyr1[];
extern short yyr2[];
extern short yychk[];
extern short yydef[];
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
# line 65 "as.y"
{ /* action 1 */ } break;
case 2:
# line 66 "as.y"
{ /* action 2 */ } break;
case 3:
# line 67 "as.y"
{ /* action 3 */ } break;
case 4:
# line 68 "as.y"
{ /* action 4 */ } break;
case 5:
# line 69 "as.y"
{ /* action 5 */ } break;
case 6:
# line 70 "as.y"
{ /* action 6 */ } break;
case 7:
# line 71 "as.y"
{ /* action 7 */ } break;
case 8:
# line 72 "as.y"
{ /* action 8 */ } break;
case 9:
# line 73 "as.y"
{ /* action 9 */ } break;
case 10:
# line 74 "as.y"
{ /* action 10 */ } break;
case 11:
# line 75 "as.y"
{ /* action 11 */ } break;
case 12:
# line 76 "as.y"
{ /* action 12 */ } break;
case 13:
# line 77 "as.y"
{ /* action 13 */ } break;
case 14:
# line 78 "as.y"
{ /* action 14 */ } break;
case 15:
# line 79 "as.y"
{ /* action 15 */ } break;
case 16:
# line 80 "as.y"
{ /* action 16 */ } break;
case 17:
# line 81 "as.y"
{ /* action 17 */ } break;
case 18:
# line 82 "as.y"
{ /* action 18 */ } break;
case 19:
# line 83 "as.y"
{ /* action 19 */ } break;
case 20:
# line 84 "as.y"
{ /* action 20 */ } break;
case 21:
# line 85 "as.y"
{ /* action 21 */ } break;
case 22:
# line 86 "as.y"
{ /* action 22 */ } break;
case 23:
# line 87 "as.y"
{ /* action 23 */ } break;
case 24:
# line 88 "as.y"
{ /* action 24 */ } break;
case 25:
# line 89 "as.y"
{ /* action 25 */ } break;
case 26:
# line 90 "as.y"
{ /* action 26 */ } break;
case 27:
# line 91 "as.y"
{ /* action 27 */ } break;
case 28:
# line 92 "as.y"
{ /* action 28 */ } break;
case 29:
# line 93 "as.y"
{ /* action 29 */ } break;
case 30:
# line 94 "as.y"
{ /* action 30 */ } break;
case 31:
# line 95 "as.y"
{ /* action 31 */ } break;
case 32:
# line 96 "as.y"
{ /* action 32 */ } break;
case 33:
# line 97 "as.y"
{ /* action 33 */ } break;
case 34:
# line 98 "as.y"
{ /* action 34 */ } break;
case 35:
# line 99 "as.y"
{ /* action 35 */ } break;
case 36:
# line 100 "as.y"
{ /* action 36 */ } break;
case 37:
# line 101 "as.y"
{ /* action 37 */ } break;
case 38:
# line 102 "as.y"
{ /* action 38 */ } break;
case 39:
# line 103 "as.y"
{ /* action 39 */ } break;
case 40:
# line 104 "as.y"
{ /* action 40 */ } break;
case 41:
# line 105 "as.y"
{ /* action 41 */ } break;
case 42:
# line 106 "as.y"
{ /* action 42 */ } break;
case 43:
# line 107 "as.y"
{ /* action 43 */ } break;
case 44:
# line 108 "as.y"
{ /* action 44 */ } break;
case 45:
# line 109 "as.y"
{ /* action 45 */ } break;
case 46:
# line 110 "as.y"
{ /* action 46 */ } break;
case 47:
# line 111 "as.y"
{ /* action 47 */ } break;
case 48:
# line 112 "as.y"
{ /* action 48 */ } break;
case 49:
# line 113 "as.y"
{ /* action 49 */ } break;
case 50:
# line 114 "as.y"
{ /* action 50 */ } break;
case 51:
# line 115 "as.y"
{ /* action 51 */ } break;
case 52:
# line 116 "as.y"
{ /* action 52 */ } break;
case 53:
# line 117 "as.y"
{ /* action 53 */ } break;
case 54:
# line 118 "as.y"
{ /* action 54 */ } break;
case 55:
# line 119 "as.y"
{ /* action 55 */ } break;
case 56:
# line 120 "as.y"
{ /* action 56 */ } break;
case 57:
# line 121 "as.y"
{ /* action 57 */ } break;
case 58:
# line 122 "as.y"
{ /* action 58 */ } break;
case 59:
# line 123 "as.y"
{ /* action 59 */ } break;
case 60:
# line 124 "as.y"
{ /* action 60 */ } break;
case 61:
# line 125 "as.y"
{ /* action 61 */ } break;
case 62:
# line 126 "as.y"
{ /* action 62 */ } break;
case 63:
# line 127 "as.y"
{ /* action 63 */ } break;
case 64:
# line 128 "as.y"
{ /* action 64 */ } break;
case 65:
# line 129 "as.y"
{ /* action 65 */ } break;
case 66:
# line 130 "as.y"
{ /* action 66 */ } break;
case 67:
# line 131 "as.y"
{ /* action 67 */ } break;
case 68:
# line 132 "as.y"
{ /* action 68 */ } break;
case 69:
# line 133 "as.y"
{ /* action 69 */ } break;
case 70:
# line 134 "as.y"
{ /* action 70 */ } break;
case 71:
# line 135 "as.y"
{ /* action 71 */ } break;
case 72:
# line 136 "as.y"
{ /* action 72 */ } break;
case 73:
# line 137 "as.y"
{ /* action 73 */ } break;
case 74:
# line 138 "as.y"
{ /* action 74 */ } break;
case 75:
# line 139 "as.y"
{ /* action 75 */ } break;
case 76:
# line 140 "as.y"
{ /* action 76 */ } break;
case 77:
# line 141 "as.y"
{ /* action 77 */ } break;
case 78:
# line 142 "as.y"
{ /* action 78 */ } break;
case 79:
# line 143 "as.y"
{ /* action 79 */ } break;
case 80:
# line 144 "as.y"
{ /* action 80 */ } break;
case 81:
# line 145 "as.y"
{ /* action 81 */ } break;
case 82:
# line 146 "as.y"
{ /* action 82 */ } break;
case 83:
# line 147 "as.y"
{ /* action 83 */ } break;
case 84:
# line 148 "as.y"
{ /* action 84 */ } break;
case 85:
# line 149 "as.y"
{ /* action 85 */ } break;
case 86:
# line 150 "as.y"
{ /* action 86 */ } break;
case 87:
# line 151 "as.y"
{ /* action 87 */ } break;
case 88:
# line 152 "as.y"
{ /* action 88 */ } break;
case 89:
# line 153 "as.y"
{ /* action 89 */ } break;
case 90:
# line 154 "as.y"
{ /* action 90 */ } break;
case 91:
# line 155 "as.y"
{ /* action 91 */ } break;
case 92:
# line 156 "as.y"
{ /* action 92 */ } break;
case 93:
# line 157 "as.y"
{ /* action 93 */ } break;
case 94:
# line 158 "as.y"
{ /* action 94 */ } break;
case 95:
# line 159 "as.y"
{ /* action 95 */ } break;
case 96:
# line 160 "as.y"
{ /* action 96 */ } break;
case 97:
# line 161 "as.y"
{ /* action 97 */ } break;
case 98:
# line 162 "as.y"
{ /* action 98 */ } break;
case 99:
# line 163 "as.y"
{ /* action 99 */ } break;
case 100:
# line 164 "as.y"
{ /* action 100 */ } break;
case 101:
# line 165 "as.y"
{ /* action 101 */ } break;
case 102:
# line 166 "as.y"
{ /* action 102 */ } break;
case 103:
# line 167 "as.y"
{ /* action 103 */ } break;
case 104:
# line 168 "as.y"
{ /* action 104 */ } break;
case 105:
# line 169 "as.y"
{ /* action 105 */ } break;
case 106:
# line 170 "as.y"
{ /* action 106 */ } break;
case 107:
# line 171 "as.y"
{ /* action 107 */ } break;
case 108:
# line 172 "as.y"
{ /* action 108 */ } break;
case 109:
# line 173 "as.y"
{ /* action 109 */ } break;
case 110:
# line 174 "as.y"
{ /* action 110 */ } break;
case 111:
# line 175 "as.y"
{ /* action 111 */ } break;
case 112:
# line 176 "as.y"
{ /* action 112 */ } break;
case 113:
# line 177 "as.y"
{ /* action 113 */ } break;
case 114:
# line 178 "as.y"
{ /* action 114 */ } break;
case 115:
# line 179 "as.y"
{ /* action 115 */ } break;
case 116:
# line 180 "as.y"
{ /* action 116 */ } break;
case 117:
# line 181 "as.y"
{ /* action 117 */ } break;
case 118:
# line 182 "as.y"
{ /* action 118 */ } break;
case 119:
# line 183 "as.y"
{ /* action 119 */ } break;
case 120:
# line 184 "as.y"
{ /* action 120 */ } break;
case 121:
# line 185 "as.y"
{ /* action 121 */ } break;
case 122:
# line 186 "as.y"
{ /* action 122 */ } break;
case 123:
# line 187 "as.y"
{ /* action 123 */ } break;
case 124:
# line 188 "as.y"
{ /* action 124 */ } break;
case 125:
# line 189 "as.y"
{ /* action 125 */ } break;
case 126:
# line 190 "as.y"
{ /* action 126 */ } break;
case 127:
# line 191 "as.y"
{ /* action 127 */ } break;
case 128:
# line 192 "as.y"
{ /* action 128 */ } break;
case 129:
# line 193 "as.y"
{ /* action 129 */ } break;
case 130:
# line 194 "as.y"
{ /* action 130 */ } break;
case 131:
# line 195 "as.y"
{ /* action 131 */ } break;
case 132:
# line 196 "as.y"
{ /* action 132 */ } break;
case 133:
# line 197 "as.y"
{ /* action 133 */ } break;
case 134:
# line 198 "as.y"
{ /* action 134 */ } break;
case 135:
# line 199 "as.y"
{ /* action 135 */ } break;
case 136:
# line 200 "as.y"
{ /* action 136 */ } break;
case 137:
# line 201 "as.y"
{ /* action 137 */ } break;
case 138:
# line 202 "as.y"
{ /* action 138 */ } break;
case 139:
# line 203 "as.y"
{ /* action 139 */ } break;
case 140:
# line 204 "as.y"
{ /* action 140 */ } break;
case 141:
# line 205 "as.y"
{ /* action 141 */ } break;
case 142:
# line 206 "as.y"
{ /* action 142 */ } break;
case 143:
# line 207 "as.y"
{ /* action 143 */ } break;
case 144:
# line 208 "as.y"
{ /* action 144 */ } break;
case 145:
# line 209 "as.y"
{ /* action 145 */ } break;
case 146:
# line 210 "as.y"
{ /* action 146 */ } break;
case 147:
# line 211 "as.y"
{ /* action 147 */ } break;
case 148:
# line 212 "as.y"
{ /* action 148 */ } break;
case 149:
# line 213 "as.y"
{ /* action 149 */ } break;
case 150:
# line 214 "as.y"
{ /* action 150 */ } break;
case 151:
# line 215 "as.y"
{ /* action 151 */ } break;
case 152:
# line 216 "as.y"
{ /* action 152 */ } break;
case 153:
# line 217 "as.y"
{ /* action 153 */ } break;
case 154:
# line 218 "as.y"
{ /* action 154 */ } break;
case 155:
# line 219 "as.y"
{ /* action 155 */ } break;
case 156:
# line 220 "as.y"
{ /* action 156 */ } break;
case 157:
# line 221 "as.y"
{ /* action 157 */ } break;
case 158:
# line 222 "as.y"
{ /* action 158 */ } break;
case 159:
# line 223 "as.y"
{ /* action 159 */ } break;
case 160:
# line 224 "as.y"
{ /* action 160 */ } break;
case 161:
# line 225 "as.y"
{ /* action 161 */ } break;
case 162:
# line 226 "as.y"
{ /* action 162 */ } break;
case 163:
# line 227 "as.y"
{ /* action 163 */ } break;
case 164:
# line 228 "as.y"
{ /* action 164 */ } break;
case 165:
# line 229 "as.y"
{ /* action 165 */ } break;
case 166:
# line 230 "as.y"
{ /* action 166 */ } break;
case 167:
# line 231 "as.y"
{ /* action 167 */ } break;
case 168:
# line 232 "as.y"
{ /* action 168 */ } break;
case 169:
# line 233 "as.y"
{ /* action 169 */ } break;
case 170:
# line 234 "as.y"
{ /* action 170 */ } break;
case 171:
# line 235 "as.y"
{ /* action 171 */ } break;
		}
		goto yystack;  /* stack new state and value */

	}
