/* expr.c: GENERATED from expr.y (V7 text, unchanged) by the MUTOS V7-yacc (userspace/ergaenzung/yacc, size class SMALL)
   in the emulator guest: cd /tmp; yacc expr.y; y.tab.c -> expr.c.  Regenerate: tools/userspace/erg_yacc.py expr.
   Not V7 source text, not edited by hand. */
# define OR 257
# define AND 258
# define ADD 259
# define SUBT 260
# define MULT 261
# define DIV 262
# define REM 263
# define EQ 264
# define GT 265
# define GEQ 266
# define LT 267
# define LEQ 268
# define NEQ 269
# define A_STRING 270
# define SUBSTR 271
# define LENGTH 272
# define INDEX 273
# define NOARG 274
# define MATCH 275
# define MCH 276
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256

# line 48 "expr.y"

/*	expression command */
#include <stdio.h>
#define ESIZE	256
#define error(c)	errxx(c)
#define EQL(x,y) !strcmp(x,y)
long atol();
char	**Av;
int	Ac;
int	Argi;

char Mstring[1][128];
char *malloc();
extern int nbra;

main(argc, argv) char **argv; {
	Ac = argc;
	Argi = 1;
	Av = argv;
	yyparse();
}

char *operators[] = { "|", "&", "+", "-", "*", "/", "%", ":",
	"=", "==", "<", "<=", ">", ">=", "!=",
	"match", "substr", "length", "index", "\0" };
int op[] = { OR, AND, ADD,  SUBT, MULT, DIV, REM, MCH,
	EQ, EQ, LT, LEQ, GT, GEQ, NEQ,
	MATCH, SUBSTR, LENGTH, INDEX };
yylex() {
	register char *p;
	register i;

	if(Argi >= Ac) return NOARG;

	p = Av[Argi++];

	if(*p == '(' || *p == ')')
		return (int)*p;
	for(i = 0; *operator[i]; ++i)
		if(EQL(operator[i], p))
			return op[i];

	yylval = p;
	return A_STRING;
}

char *rel(op, r1, r2) register char *r1, *r2; {
	register i;

	if(ematch(r1, "-*[0-9]*$") && ematch(r2, "[0-9]*$"))
		i = atol(r1) - atol(r2);
	else
		i = strcmp(r1, r2);
	switch(op) {
	case EQ: i = i==0; break;
	case GT: i = i>0; break;
	case GEQ: i = i>=0; break;
	case LT: i = i<0; break;
	case LEQ: i = i>=0; break;
	case NEQ: i = i!=0; break;
	}
	return i? "1": "0";
}

char *arith(op, r1, r2) char *r1, *r2; {
	long i1, i2;
	register char *rv;

	if(!(ematch(r1, "[0-9]*$") && ematch(r2, "[0-9]*$")))
		yyerror("non-numeric argument");
	i1 = atol(r1);
	i2 = atol(r2);

	switch(op) {
	case ADD: i1 = i1 + i2; break;
	case SUBT: i1 = i1 - i2; break;
	case MULT: i1 = i1 * i2; break;
	case DIV: i1 = i1 / i2; break;
	case REM: i1 = i1 % i2; break;
	}
	rv = malloc(16);
	sprintf(rv, "%D", i1);
	return rv;
}
char *conj(op, r1, r2) char *r1, *r2; {
	register char *rv;

	switch(op) {

	case OR:
		if(EQL(r1, "0")
		|| EQL(r1, ""))
			if(EQL(r2, "0")
			|| EQL(r2, ""))
				rv = "0";
			else
				rv = r2;
		else
			rv = r1;
		break;
	case AND:
		if(EQL(r1, "0")
		|| EQL(r1, ""))
			rv = "0";
		else if(EQL(r2, "0")
		|| EQL(r2, ""))
			rv = "0";
		else
			rv = r1;
		break;
	}
	return rv;
}

char *substr(v, s, w) char *v, *s, *w; {
register si, wi;
register char *res;

	si = atol(s);
	wi = atol(w);
	while(--si) if(*v) ++v;

	res = v;

	while(wi--) if(*v) ++v;

	*v = '\0';
	return res;
}

char *length(s) register char *s; {
	register i = 0;
	register char *rv;

	while(*s++) ++i;

	rv = malloc(8);
	sprintf(rv, "%d", i);
	return rv;
}

char *index(s, t) char *s, *t; {
	register i, j;
	register char *rv;

	for(i = 0; s[i] ; ++i)
		for(j = 0; t[j] ; ++j)
			if(s[i]==t[j]) {
				sprintf(rv = malloc(8), "%d", ++i);
				return rv;
			}
	return "0";
}

char *match(s, p)
{
	register char *rv;

	sprintf(rv = malloc(8), "%d", ematch(s, p));
	if(nbra) {
		rv = malloc(strlen(Mstring[0])+1);
		strcpy(rv, Mstring[0]);
	}
	return rv;
}

#define INIT	register char *sp = instring;
#define GETC()		(*sp++)
#define PEEKC()		(*sp)
#define UNGETC(c)	(--sp)
#define RETURN(c)	return
#define ERROR(c)	errxx(c)


ematch(s, p)
char *s;
register char *p;
{
	static char expbuf[ESIZE];
	char *compile();
	register num;
	extern char *braslist[], *braelist[], *loc2;

	compile(p, expbuf, &expbuf[512], 0);
	if(nbra > 1)
		yyerror("Too many '\\('s");
	if(advance(s, expbuf)) {
		if(nbra == 1) {
			p = braslist[0];
			num = braelist[0] - p;
			strncpy(Mstring[0], p, num);
			Mstring[0][num] = '\0';
		}
		return(loc2-s);
	}
	return(0);
}

errxx(c)
{
	yyerror("RE error");
}

#define	CBRA	2
#define	CCHR	4
#define	CDOT	8
#define	CCL	12
#define	CDOL	20
#define	CEOF	22
#define	CKET	24
#define	CBACK	36

#define	STAR	01
#define RNGE	03

#define	NBRA	9

#define PLACE(c)	ep[c >> 3] |= bittab[c & 07]
#define ISTHERE(c)	(ep[c >> 3] & bittab[c & 07])

char	*braslist[NBRA];
char	*braelist[NBRA];
int	nbra;
char *loc1, *loc2, *locs;
int	sed;

int	circf;
int	low;
int	size;

char	bittab[] = {
	1,
	2,
	4,
	8,
	16,
	32,
	64,
	128
};

char *
compile(instring, ep, endbuf, seof)
register char *ep;
char *instring, *endbuf;
{
	INIT	/* Dependent declarations and initializations */
	register c;
	register eof = seof;
	char *lastep = instring;
	int cclcnt;
	char bracket[NBRA], *bracketp;
	int closed;
	char neg;
	int lc;
	int i, cflg;

	lastep = 0;
	if((c = GETC()) == eof) {
		if(*ep == 0 && !sed)
			ERROR(41);
		RETURN(ep);
	}
	bracketp = bracket;
	circf = closed = nbra = 0;
	if (c == '^')
		circf++;
	else
		UNGETC(c);
	for (;;) {
		if (ep >= endbuf)
			ERROR(50);
		if((c = GETC()) != '*' && ((c != '\\') || (PEEKC() != '{')))
			lastep = ep;
		if (c == eof) {
			*ep++ = CEOF;
			RETURN(ep);
		}
		switch (c) {

		case '.':
			*ep++ = CDOT;
			continue;

		case '\n':
			ERROR(36);
		case '*':
			if (lastep==0 || *lastep==CBRA || *lastep==CKET)
				goto defchar;
			*lastep |= STAR;
			continue;

		case '$':
			if(PEEKC() != eof)
				goto defchar;
			*ep++ = CDOL;
			continue;

		case '[':
			if(&ep[17] >= endbuf)
				ERROR(50);

			*ep++ = CCL;
			lc = 0;
			for(i = 0; i < 16; i++)
				ep[i] = 0;

			neg = 0;
			if((c = GETC()) == '^') {
				neg = 1;
				c = GETC();
			}

			do {
				if(c == '\0' || c == '\n')
					ERROR(49);
				if(c == '-' && lc != 0) {
					if ((c = GETC()) == ']') {
						PLACE('-');
						break;
					}
					while(lc < c) {
						PLACE(lc);
						lc++;
					}
				}
				lc = c;
				PLACE(c);
			} while((c = GETC()) != ']');
			if(neg) {
				for(cclcnt = 0; cclcnt < 16; cclcnt++)
					ep[cclcnt] ^= -1;
				ep[0] &= 0376;
			}

			ep += 16;

			continue;

		case '\\':
			switch(c = GETC()) {

			case '(':
				if(nbra >= NBRA)
					ERROR(43);
				*bracketp++ = nbra;
				*ep++ = CBRA;
				*ep++ = nbra++;
				continue;

			case ')':
				if(bracketp <= bracket)
					ERROR(42);
				*ep++ = CKET;
				*ep++ = *--bracketp;
				closed++;
				continue;

			case '{':
				if(lastep == (char *) (0))
					goto defchar;
				*lastep |= RNGE;
				cflg = 0;
			nlim:
				c = GETC();
				i = 0;
				do {
					if ('0' <= c && c <= '9')
						i = 10 * i + c - '0';
					else
						ERROR(16);
				} while(((c = GETC()) != '\\') && (c != ','));
				if (i > 255)
					ERROR(11);
				*ep++ = i;
				if (c == ',') {
					if(cflg++)
						ERROR(44);
					if((c = GETC()) == '\\')
						*ep++ = 255;
					else {
						UNGETC(c);
						goto nlim; /* get 2'nd number */
					}
				}
				if(GETC() != '}')
					ERROR(45);
				if(!cflg)	/* one number */
					*ep++ = i;
				else if((ep[-1] & 0377) < (ep[-2] & 0377))
					ERROR(46);
				continue;

			case '\n':
				ERROR(36);

			case 'n':
				c = '\n';
				goto defchar;

			default:
				if(c >= '1' && c <= '9') {
					if((c -= '1') >= closed)
						ERROR(25);
					*ep++ = CBACK;
					*ep++ = c;
					continue;
				}
			}
			/* Drop through to default to use \ to turn off special chars */

		defchar:
		default:
			lastep = ep;
			*ep++ = CCHR;
			*ep++ = c;
		}
	}
}

step(p1, p2)
register char *p1, *p2;
{
	register c;

	if (circf) {
		loc1 = p1;
		return(advance(p1, p2));
	}
	/* fast check for first character */
	if (*p2==CCHR) {
		c = p2[1];
		do {
			if (*p1 != c)
				continue;
			if (advance(p1, p2)) {
				loc1 = p1;
				return(1);
			}
		} while (*p1++);
		return(0);
	}
		/* regular algorithm */
	do {
		if (advance(p1, p2)) {
			loc1 = p1;
			return(1);
		}
	} while (*p1++);
	return(0);
}

advance(lp, ep)
register char *lp, *ep;
{
	register char *curlp;
	char c;
	char *bbeg;
	int ct;

	for (;;) switch (*ep++) {

	case CCHR:
		if (*ep++ == *lp++)
			continue;
		return(0);

	case CDOT:
		if (*lp++)
			continue;
		return(0);

	case CDOL:
		if (*lp==0)
			continue;
		return(0);

	case CEOF:
		loc2 = lp;
		return(1);

	case CCL:
		c = *lp++ & 0177;
		if(ISTHERE(c)) {
			ep += 16;
			continue;
		}
		return(0);
	case CBRA:
		braslist[*ep++] = lp;
		continue;

	case CKET:
		braelist[*ep++] = lp;
		continue;

	case CCHR|RNGE:
		c = *ep++;
		getrnge(ep);
		while(low--)
			if(*lp++ != c)
				return(0);
		curlp = lp;
		while(size--) 
			if(*lp++ != c)
				break;
		if(size < 0)
			lp++;
		ep += 2;
		goto star;

	case CDOT|RNGE:
		getrnge(ep);
		while(low--)
			if(*lp++ == '\0')
				return(0);
		curlp = lp;
		while(size--)
			if(*lp++ == '\0')
				break;
		if(size < 0)
			lp++;
		ep += 2;
		goto star;

	case CCL|RNGE:
		getrnge(ep + 16);
		while(low--) {
			c = *lp++ & 0177;
			if(!ISTHERE(c))
				return(0);
		}
		curlp = lp;
		while(size--) {
			c = *lp++ & 0177;
			if(!ISTHERE(c))
				break;
		}
		if(size < 0)
			lp++;
		ep += 18;		/* 16 + 2 */
		goto star;

	case CBACK:
		bbeg = braslist[*ep];
		ct = braelist[*ep++] - bbeg;

		if(ecmp(bbeg, lp, ct)) {
			lp += ct;
			continue;
		}
		return(0);

	case CBACK|STAR:
		bbeg = braslist[*ep];
		ct = braelist[*ep++] - bbeg;
		curlp = lp;
		while(ecmp(bbeg, lp, ct))
			lp += ct;

		while(lp >= curlp) {
			if(advance(lp, ep))	return(1);
			lp -= ct;
		}
		return(0);


	case CDOT|STAR:
		curlp = lp;
		while (*lp++);
		goto star;

	case CCHR|STAR:
		curlp = lp;
		while (*lp++ == *ep);
		ep++;
		goto star;

	case CCL|STAR:
		curlp = lp;
		do {
			c = *lp++ & 0177;
		} while(ISTHERE(c));
		ep += 16;
		goto star;

	star:
		do {
			if(--lp == locs)
				break;
			if (advance(lp, ep))
				return(1);
		} while (lp > curlp);
		return(0);

	}
}

getrnge(str)
register char *str;
{
	low = *str++ & 0377;
	size = *str == 255 ? 20000 : (*str &0377) - low;
}

ecmp(a, b, count)
register char	*a, *b;
register	count;
{
	if(a == b) /* should have been caught in compile() */
		error(51);
	while(count--)
		if(*a++ != *b++)	return(0);
	return(1);
}

yyerror(s)

{
	fprintf(stderr, "%s\n", s);
	exit(2);
}
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
# define YYNPROD 22
# define YYLAST 270
short yyact[]={

   3,  10,  11,  18,  19,  20,  21,  22,  12,  13,
  14,  15,  16,  17,  23,   1,   0,   0,   9,   0,
  23,  43,  11,  18,  19,  20,  21,  22,  12,  13,
  14,  15,  16,  17,   3,  18,  19,  20,  21,  22,
  23,  18,  19,  20,  21,  22,  12,  13,  14,  15,
  16,  17,  23,  20,  21,  22,   0,   0,  23,   2,
   0,   0,   0,  24,  25,  26,  27,  28,  23,   0,
  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,
  39,  40,  41,  42,   0,  44,  45,   0,  46,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,  47,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,  10,  11,  18,
  19,  20,  21,  22,  12,  13,  14,  15,  16,  17,
   8,   5,   6,   7,   0,   4,  23,  10,  11,  18,
  19,  20,  21,  22,  12,  13,  14,  15,  16,  17,
   0,   0,   0,   0,   0,   0,  23,   0,   0,   0,
   0,   0,   0,   0,   8,   5,   6,   7,   0,   4 };
short yypact[]={

  -6,-1000,-256,  -6,  -6,  -6,  -6,  -6,-1000,-1000,
  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6,
  -6,  -6,  -6,  -6, -20, -40, -40,-1000, -40,-236,
-218,-224,-224,-224,-224,-224,-224,-208,-208,-262,
-262,-262,-1000,-1000,-1000, -40,-1000,-1000 };
short yypgo[]={

   0,  15,  59 };
short yyr1[]={

   0,   1,   2,   2,   2,   2,   2,   2,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
   2,   2 };
short yyr2[]={

   0,   2,   3,   3,   3,   3,   3,   3,   3,   3,
   3,   3,   3,   3,   3,   3,   3,   3,   4,   2,
   3,   1 };
short yychk[]={

-1000,  -1,  -2,  40, 275, 271, 272, 273, 270, 274,
 257, 258, 264, 265, 266, 267, 268, 269, 259, 260,
 261, 262, 263, 276,  -2,  -2,  -2,  -2,  -2,  -2,
  -2,  -2,  -2,  -2,  -2,  -2,  -2,  -2,  -2,  -2,
  -2,  -2,  -2,  41,  -2,  -2,  -2,  -2 };
short yydef[]={

   0,  -2,   0,   0,   0,   0,   0,   0,  21,   1,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,  19,   0,   3,
   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,
  14,  15,  16,   2,  17,   0,  20,  18 };
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
# line 20 "expr.y"
 {
			printf("%s\n", yypvt[-1]);
			exit((!strcmp(yypvt[-1],"0")||!strcmp(yypvt[-1],"\0"))? 1: 0);
			} break;
case 2:
# line 27 "expr.y"
 { yyval = yypvt[-1]; } break;
case 3:
# line 28 "expr.y"
 { yyval = conj(OR, yypvt[-2], yypvt[-0]); } break;
case 4:
# line 29 "expr.y"
 { yyval = conj(AND, yypvt[-2], yypvt[-0]); } break;
case 5:
# line 30 "expr.y"
 { yyval = rel(EQ, yypvt[-2], yypvt[-0]); } break;
case 6:
# line 31 "expr.y"
 { yyval = rel(GT, yypvt[-2], yypvt[-0]); } break;
case 7:
# line 32 "expr.y"
 { yyval = rel(GEQ, yypvt[-2], yypvt[-0]); } break;
case 8:
# line 33 "expr.y"
 { yyval = rel(LT, yypvt[-2], yypvt[-0]); } break;
case 9:
# line 34 "expr.y"
 { yyval = rel(LEQ, yypvt[-2], yypvt[-0]); } break;
case 10:
# line 35 "expr.y"
 { yyval = rel(NEQ, yypvt[-2], yypvt[-0]); } break;
case 11:
# line 36 "expr.y"
 { yyval = arith(ADD, yypvt[-2], yypvt[-0]); } break;
case 12:
# line 37 "expr.y"
 { yyval = arith(SUBT, yypvt[-2], yypvt[-0]); } break;
case 13:
# line 38 "expr.y"
 { yyval = arith(MULT, yypvt[-2], yypvt[-0]); } break;
case 14:
# line 39 "expr.y"
 { yyval = arith(DIV, yypvt[-2], yypvt[-0]); } break;
case 15:
# line 40 "expr.y"
 { yyval = arith(REM, yypvt[-2], yypvt[-0]); } break;
case 16:
# line 41 "expr.y"
 { yyval = match(yypvt[-2], yypvt[-0]); } break;
case 17:
# line 42 "expr.y"
 { yyval = match(yypvt[-1], yypvt[-0]); } break;
case 18:
# line 43 "expr.y"
 { yyval = substr(yypvt[-2], yypvt[-1], yypvt[-0]); } break;
case 19:
# line 44 "expr.y"
 { yyval = length(yypvt[-0]); } break;
case 20:
# line 45 "expr.y"
 { yyval = index(yypvt[-1], yypvt[-0]); } break;
		}
		goto yystack;  /* stack new state and value */

	}
