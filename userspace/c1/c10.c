#
/*

	    	C compiler, part 2


*/

#include "c1.h"

#define	dbprint(op)	/* */
#ifdef	DEBUG
#define	dbprint(op)	printf("	/ %s", opntab[op])
#endif

char	maprel[] {	EQUAL, NEQUAL, GREATEQ, GREAT, LESSEQ,
			LESS, GREATQP, GREATP, LESSEQP, LESSP
};

char	notrel[] {	NEQUAL, EQUAL, GREAT, GREATEQ, LESS,
			LESSEQ, GREATP, GREATQP, LESSP, LESSEQP
};

struct tconst czero { CON, INT, 0};
struct tconst cone  { CON, INT, 1};

struct tname sfuncr { NAME, STRUCT, STATIC, 0, 0, 0 };

/*
 * Not V7: zero-initialised int flags/counters in the DATA segment of the
 * original (760C..7622).  Names are *Annahme* (see doc wk_w6.md, Teil 5);
 * only count and order are measured.
 */
struct	table	*cregtab;
struct	ftconst	fptab[50];	/* Not V7: 8BD8, 50 * 14 bytes */
int	nfloat;			/* 8E94: BSS order cregtab, fptab, nfloat */

int	nfpool	0;	/* 760C: next free fptab entry */
int	zf1	0;	/* 760E */
int	zf2	0;	/* 7610 */
/* Differs from V7: nreg is 5 (Z8000 register set), V7 has 3 */
int	nreg	5;
int	rlused	0;	/* 7614 */
int	zf4	0;	/* 7616 */
int	isn	10000;
int	wregf	0;	/* 761A */
int	bregf	0;	/* 761C */
int	lregf	0;	/* 761E */
int	zf8	0;	/* 7620 */
int	zf9	0;	/* 7622 */

main(argc, argv)
char *argv[];
{

	if (argc<4) {
		error("Arg count");
		exit(1);
	}
	if (freopen(argv[1], "r", stdin)==NULL) {
		error("Missing temp file");
		exit(1);
	}
	if ((freopen(argv[3], "w", stdout)) == NULL) {
		error("Can't create %s", argv[3]);
		exit(1);
	}
	/* Differs from V7: Z8000 as module header instead of the PDP-11 ".globl" lines; no fltused reference.
	   modname is a 3-byte array in the original (address 7B3E, "c_"); only the first printf uses it; the c2 then reuses the pushed slot. */
	printf("%s module\n$NONSEGMENTED\nconstant\n\tFP\t:= r14\n", modname);
	printf("\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n");
	printf("\tI\t:= internal\n\tA\t:= array\n\tPR\t:= procedure\n");
	printf("\tE\t:= entry\n\tB\t:= byte\n\tW\t:= word\n");
	printf("\tBV\t:= bval\n\tWV\t:= wval\n\tLV\t:= lval\n");
	printf("\tL\t:= label\nX\tcsv\tPR\nX\tcret\tPR;\n");
	funcbase = curbase = coremax = sbrk(0);
	getree();
	if (*argv[2] != '-') {
		if (freopen(argv[2], "r", stdin)==NULL) {
			error("Missing temp file");
			exit(1);
		}
		getree();
	}
	if (totspace >= (unsigned)56000) {
		error("Warning: possibly too much data");
		nerror--;
	}
	printf("end %s\n", modname);
	exit(nerror!=0);
}

/*
 * Given a tree, a code table, and a
 * count of available registers, find the code table
 * for the appropriate operator such that the operands
 * are of the right type and the number of registers
 * required is not too large.
 * Return a ptr to the table entry or 0 if none found.
 */
char *
match(atree, table, nrleft, nocvt)
struct tnode *atree;
struct table *table;
{
#define	NOCVL	1
#define	NOCVR	2
	int d2, dope;
	register op, d1;
	register struct tnode *p2, *p1, *tree;
	register struct optab *opt;

	/*
	 * Differs from V7: no lsptab test; 'op' and 'd1' are register
	 * variables (order of the register variables is Annahme: it is
	 * the only one that reproduces r13..r8).
	 */
	if ((tree=atree)==0)
		return(0);
	if ((op = tree->op)==0)
		return(0);
	dope = opdope[op];
	if ((dope&LEAF) == 0)
		p1 = tree->tr1;
	else
		p1 = tree;
	d1 = dcalc(p1, nrleft);
	if ((dope&BINARY)!=0) {
		p2 = tree->tr2;
		/*
		 * Differs from V7 (Z8000): long operands of the library
		 * operators and (unsigned)->long conversions keep their
		 * conversion (no match with the conversion eliminated).
		 */
		if (tree->type==LONG && (op==DIVIDE || op==TIMES || op==MOD
		 || op==ASDIV || op==ASTIMES || op==ASMOD || op==LSHIFT
		 || op==ASLSH || op==RSHIFT || op==ASRSH))
			;
		else if (p2->op==ITOL && p2->tr1->type==UNSIGN)
			;
		/*
		 * If a subtree starts off with a conversion operator,
		 * try for a match with the conversion eliminated.
		 * E.g. int = double can be done without generating
		 * the converted int in a register by
		 * movf double,fr0; movfi fr0,int .
		 */
		else if (opdope[p2->op]&CNVRT && (nocvt&NOCVR)==0
			 && (opdope[p2->tr1->op]&CNVRT)==0) {
			tree->tr2 = p2->tr1;
			if (opt = match(tree, table, nrleft, NOCVL))
				return(opt);
			tree->tr2 = p2;
		} else if (opdope[p1->op]&CNVRT && (nocvt&NOCVL)==0
		 && (opdope[p1->tr1->op]&CNVRT)==0) {
			tree->tr1 = p1->tr1;
			if (opt = match(tree, table, nrleft, NOCVR))
				return(opt);
			tree->tr1 = p1;
		}
		d2 = dcalc(p2, nrleft);
	}
	for (; table->op!=op; table++)
		if (table->op==0)
			return(0);
	for (opt = table->tabp; opt->tabdeg1!=0; opt++) {
		if (d1 > (opt->tabdeg1&077)
		 || (opt->tabdeg1 >= 0100 && (p1->op != STAR)))
			continue;
		/* Differs from V7: notcompat has two arguments here */
		if (notcompat(p1, opt->tabtyp1)) {
			continue;
		}
		if ((opdope[op]&BINARY)!=0 && p2!=0) {
			if (d2 > (opt->tabdeg2&077)
			 || (opt->tabdeg2 >= 0100) && (p2->op != STAR) )
				continue;
			if (notcompat(p2,opt->tabtyp2))
				continue;
		}
		return(opt);
	}
	return(0);
}

/*
 * Given a tree, a code table, and a register,
 * produce code to evaluate the tree with the appropriate table.
 * Registers reg and upcan be used.
 * If there is a value, it is desired that it appear in reg.
 * The routine returns the register in which the value actually appears.
 *
 * Differs from V7 (Z8000 original at 039E, reconstructed from the binary):
 * no RELAT/cctab shortcut, no ANDN, no lsptab; CALL saves and restores the
 * live registers around the call and moves the result to reg; long shifts
 * keep their op; unsigned / and % and the bit operations OR/AND with a
 * single-bit constant are rewritten; STAR operands are loaded into a register
 * first; the cctab and sptab output is Z8000 test/push.  nsav, p, q, rr, bit
 * are names of the reconstruction (*Annahme*).
 */
rcexpr(atree, atable, reg)
struct tnode *atree;
struct table *atable;
{
	register r, nsav;
	register struct tnode *tree, *p, *q;
	register struct table *table;
	int modf, nargs, recurf, bit, rr, dope;

	nsav = 0;
	table = atable;
	recurf = 0;
	if (reg<0) {
		recurf++;
		reg = ~reg;
		if (reg>=020) {
			reg =- 020;
			recurf++;
		}
	}
again:
	if((tree=atree)==0)
		return(0);
	/*
	 * fieldselect(...) : in efftab mode,
	 * ignore the select, otherwise
	 * do the shift and mask.
	 */
	if (tree->op == FSELT) {
		if (table==efftab)
			atree = tree = tree->tr1;
		else {
			tree->op = FSEL;
			atree = tree = optim(tree);
		}
	}
	switch (tree->op)  {

	/*
	 * Structure assignments
	 */
	case STRASG:
		strasg(tree);
		return(0);

	/*
	 * An initializing expression
	 */
	case INIT:
		tree = optim(tree);
		doinit(tree->type, tree->tr1);
		return(0);

	/*
	 * Put the value of an expression in r0,
	 * for a switch or a return
	 */
	case RFORCE:
		if ((r = tree->type) != tree->tr1->type && (r==FLOAT || r==DOUBLE)) {
			printf("fclr\tf0\n");
			return(0);
		}
		tree = tree->tr1;
		if((r=rcexpr(tree, regtab, reg)) != 0)
			movreg(r, 0, tree);
		return(0);

	/*
	 * sequential execution
	 */
	case SEQNC:
		rcexpr(tree->tr1, efftab, reg);
		atree = tree = tree->tr2;
		goto again;

	/*
	 * Handle a subroutine call. It has to be done
	 * here because if cexpr got called twice, the
	 * arguments might be compiled twice.
	 * Differs from V7: the live registers 0..reg-1 are pushed first
	 * (and floating registers, if any) and popped after the call.
	 */
	case CALL:
		r = 0;
		if (tree->type==LONG && reg>1 || reg>0) {
			for (; r<reg; r++) {
				printf("push\t@SP,r%d\n", zreg(r));
				if (nfloat) {
					printf("dec\tSP,#8\nfldd\t@SP,f%d\n", r);
					nsav++;
				}
			}
			r = 0;
		}
		nargs = 0;
		modf = 0;
		if (tree->tr1->op!=NAME || tree->tr1->class!=EXTERN)
			nargs++;
		tree = tree->tr2;
		if(tree->op) {
			while (tree->op==COMMA) {
				r =+ comarg(tree->tr2, &modf);
				tree = tree->tr1;
				nargs++;
			}
			r =+ comarg(tree, &modf);
			nargs++;
		}
		tree = atree;
		tree->op = CALL2;
		tree->tr2 = 0;
		if (rcexpr(tree, regtab, 0)<0)
			error("compiler botch: call");
		popstk(r);
		if (tree->type==LONG && reg>1 || reg>0) {
			r = reg-1;
			if (tree->type==LONG || zf1) {
				reg = (reg+1) & ~1;
				zf1 = 0;
			} else if (zf2) {
				reg = (reg+1) | 1;
				zf2 = 0;
			}
			movreg(0, reg, tree);
			for (; r>=0; r--) {
				if (nsav)
					printf("fldd\tf%d,@SP\ninc\tSP,#8\n", r);
				printf("pop\tr%d,@SP\n", zreg(r));
			}
			nsav = 0;
		}
		if (table==efftab || table==regtab)
			return(reg);
		r = reg;
		goto fixup;

	/*
	 * Longs need special treatment.
	 * Differs from V7: also RSHIFT/ASRSH; the op stays.
	 */
	case ASLSH:
	case LSHIFT:
	case RSHIFT:
	case ASRSH:
		if (tree->type==LONG) {
			if (tree->tr2->op==ITOL)
				tree->tr2 = tree->tr2->tr1;
			else
				tree->tr2 = optim(tnode(LTOI,INT,tree->tr2));
		}
		break;

	/*
	 * Differs from V7: unsigned division and modulus are done like
	 * the multiplication: try to change to shift/and.
	 */
	case DIVIDE:
	case MOD:
	case ASDIV:
	case ASMOD:
		if (tree->type!=UNSIGN)
			break;
	case TIMES:
	case ASTIMES:
		dope = tree->op;
		tree = pow2(tree);
		if (tree->op!=dope)
			goto again;
		break;

	/*
	 * Not V7: x | single-bit constant (x &~ bit) is turned into a
	 * bit set / reset operation.
	 */
	case OR:
	case ASOR:
		if (tree->tr2->op==CON && tree->type!=LONG) {
			bit = bitnum(tree->tr2->value);
			if (bit>=0) {
	setbit:
				tree = bitop(tree, bit);
			}
		}
		break;

	case AND:
	case ASAND:
		if (tree->tr2->op==CON && tree->type!=LONG) {
			bit = bitnum(~tree->tr2->value);
			if (bit<0)
				break;
			goto setbit;
		}
		break;
	}
	/*
	 * Not V7: STAR operands that are not register names are
	 * evaluated into a register first, and replaced by a STAR of
	 * that register.
	 */
	p = tree;
	dope = opdope[tree->op];
	if ((dope&LEAF)==0) {
		if (p->tr1->op==STAR) {
			if (!(opdope[p->tr1->tr1->op]&LEAF) || p->tr1->tr1->class!=REG) {
				rr = rcexpr(tnode(LOAD, p->tr1->tr1->type, p->tr1->tr1), regtab, reg);
				p->tr1->tr1 = regnode(REG, p->tr1->type+PTR, rr);
				reg = rr+1;
			}
		}
		if (dope&BINARY) {
			q = tree->tr2;
			if (q->op==STAR) {
				if (!(opdope[q->tr1->op]&LEAF) || q->tr1->class!=REG) {
					rr = rcexpr(tnode(LOAD, q->tr1->type, q->tr1), regtab, reg);
					q->tr1 = regnode(REG, q->type+PTR, rr);
					reg = rr+1;
				}
			}
		}
	}
	atree = tree = p;
	/*
	 * Try to find postfix ++ and -- operators that can be
	 * pulled out and done after the rest of the expression
	 * (not when zf9 is set, a Z8000 addition).
	 */
	if (table!=cctab && table!=cregtab && recurf<2 && !zf9
	 && (opdope[tree->op]&LEAF)==0) {
		if (r=delay(&atree, table, reg)) {
			tree = atree;
			table = efftab;
			reg = r-1;
		}
	}
	/*
	 * Basically, try to reorder the computation
	 * so  reg = x+y  is done as  reg = x; reg =+ y
	 */
	if (recurf==0 && reorder(&atree, table, reg)) {
		if (table==cctab && atree->op==NAME)
			return(reg);
	}
	tree = atree;
	if (table==efftab && tree->op==NAME)
		return(reg);
	if ((r=cexpr(tree, table, reg))>=-2)
		return(r);
	if (table!=regtab && (table!=cctab||(opdope[tree->op]&RELAT)==0)) {
		if((r=cexpr(tree, regtab, reg))>=-2) {
	fixup:
			modf = isfloat(tree);
			if (table==sptab) {
				if (modf=='f') {
					printf("dec\tSP,#8\nfldd\t@SP,f%d\n", r);
					nfloat++;
				} else {
					printf("push%c\t@SP,", modf);
					preg(tree, r);
					printf("\n");
				}
			}
			if (table==cctab) {
				if (rlused) {
					modf = 'b';
					bregf = 1;
				}
				if ((tree->op==ASPLUS || tree->op==ASMINUS
				 || tree->op==ASRSH || tree->op==ASLSH
				 || tree->op==ASAND || tree->op==ASOR
				 || tree->op==ASXOR || tree->op==ASDIV
				 || tree->op==ASTIMES)
				 && tree->type!=LONG && tree->tr1->type!=CHAR)
					;
				else if ((opdope[tree->op]&ASSGOP)
				 && tree->op!=ASMOD && tree->op!=ASSIGN
				 && tree->op!=ASAND && tree->op!=ASOR
				 && tree->op!=ASXOR && tree->type==LONG)
					;
				else {
					if (modf=='f') {
						printf("fcpzx\tf%d\n", r);
						nfloat++;
					} else {
						printf("test%c\t", modf);
						preg(tree, r);
						printf("\n");
					}
					zf4 = 1;
				}
				bregf = 0;
			}
			return(r);
		}
	}
	/*
	 * There's a last chance for this operator
	 */
	if (tree->op==LTOI) {
		r = rcexpr(tree->tr1, regtab, reg);
		if (r >= 0) {
			r++;
			goto fixup;
		}
	}
	if (tree->type == STRUCT)
		error("Illegal operation on structure");
	else if (tree->op>0 && tree->op<RFORCE && opntab[tree->op])
		error("No code table for op: %s", opntab[tree->op]);
	else
		error("No code table for op %d", tree->op);
	return(reg);
}

/* Differs from V7: lsptab is not in c1.h (it would take BSS in front of nstack); it is no longer used by any
   reconstructed function but its BSS slot (original: before cexpr) is kept */
struct	table	lsptab[1];

/*
 * Try to compile the tree with the code table using
 * registers areg and up.  If successful,
 * return the register where the value actually ended up.
 * If unsuccessful, return -3 (Differs from V7: -1).
 *
 * Most of the work is the macro-expansion of the
 * code table.
 *
 * Differs from V7 (reconstructed from the binary at 0B9E, doc wk_w6.md part 6):
 * Z8000 rewrite of the macro expansion.  The register variables are
 * p, p1, tree (r13..r11), r, k (r10, r9) and ctable (r8); r13 and r11 hold
 * the same tree up to the loop.  The names fl, unused, k and the flags zf*,
 * wregf, bregf, lregf are *Annahme*, only the use is measured.
 */
cexpr(atree, table, areg)
struct tnode *atree;
struct table *table;
{
	register struct tnode *p, *p1, *tree;
	register r, k;
	register struct table *ctable;
	int fl;
	int c;
	int unused;
	struct tnode *p2;
	char *string;
	int reg, reg1, rreg, flag, opd;
	char *opt;

	zf9 = 1;
	lregf = 0;
	wregf = 0;
	tree = atree;
	p = tree;
	c = p->op;
	reg = areg;
	if (!(c&0400))
		p1 = tree->tr2;
	opd = opdope[c];
	/*
	 * When the value of a relational or a logical expression is
	 * desired, more work must be done.
	 */
	if ((opd&RELAT||c==LOGAND||c==LOGOR||c==EXCLA) && table!=cctab) {
		cbranch(tree, c=isn++, 1, reg);
		rcexpr(&czero, table, reg);
		branch(isn, 0);
		label(c);
		rcexpr(&cone, table, reg);
		label(isn++);
		return(reg);
	}
	if(c==QUEST) {
		if (table==cctab)
			return(-3);
		cbranch(tree->tr1, c=isn++, 0, reg);
		rreg = rcexpr(p1->tr1, table, reg);
		branch(r=isn++, 0);
		label(c);
		reg = rcexpr(p1->tr2, table, rreg);
		if (rreg!=reg && p1->tr2->op!=CALL)
			movreg(reg, rreg, tree->tr2);
		label(r);
		return(rreg);
	}
	/*
	 * Not V7: char register variables in assignment operators
	 * are treated as int.
	 */
	if (opd&ASSGOP && p->tr1->type==CHAR && p->tr1->op==NAME
	 && p->tr1->class==REG) {
		p->tr1->type = INT;
		if (p1->op==NAME && p1->class==REG && p1->type==CHAR)
			p1->type = INT;
	}
	tree = p;
	if (!(p->op&0400))
		tree->tr2 = p1;
	areg = reg;
	reg = oddreg(tree, reg);
	reg1 = reg+1;
	/*
	 * long values take 2 registers.
	 */
	if ((p->type==LONG||opd&RELAT&&p->tr1->type==LONG) && p->op!=ITOL)
		reg1++;
	/*
	 * Leaves of the expression tree
	 */
	if ((r = chkleaf(p, table, reg)) >= 0)
		return(r);
	/*
	 * x + (-n) is better done as x-n.
	 */
	if ((c==PLUS||c==ASPLUS) && p1->op==CON
	 && p1->value<=-1 && p1->value>=-16) {
		p1->value = -p1->value;
		c = ++p->op;
	}
	if (table==cregtab)
		table = regtab;
	/*
	 * Account for longs and oddregs; below is really
	 * r = nreg - reg - (reg-areg) - (reg1-reg-1);
	 */
	r = nreg - reg + areg - reg1 + 1;
	if (table!=cctab || c==INCAFT || c==DECAFT || c==MOD
	 || p->type==LONG && (c==AND || c==OR || c==EXOR)
	 || c==ASSIGN || c==CALL || c==LOAD || c==89 || c==CALL2
	 || (opt = match(p, efftab, r, 0)) == 0)
		if ((opt=match(p, table, r, 0))==0)
			return(-3);
	string = opt->tabstring;
	p1 = p->tr1;
	if (p1->op==FCON && p1->value>0) {
		if (k = fpfind(p1))
			p1->value = k;
		else
			outfp(p1, 1);
	}
	p2 = 0;
	if (opdope[tree->op]&BINARY) {
		p2 = p->tr2;
		if (p2->op==FCON && p2->value>0) {
			if (k = fpfind(p2))
				p2->value = k;
			else
				outfp(p2, 1);
		}
	}
loop:
	/*
	 * The 0200 bit asks for a tab.
	 */
	if ((c = *string++) & 0200) {
		c =& 0177;
		putchar('\t');
	}
	switch (c) {

	case '\n':
		bregf = 0;
		break;

	case '\0':
		if (isfloat(tree)!='f')
			if (tree->op==MOD||tree->op==ASMOD) {
				reg--;
				if (tree->type==LONG)
					reg--;
			}
		return(reg);

	case '@':
		printf("@SP");
		goto loop;

	case '#':
		printf("#%%");
		goto loop;

	case '"':
		printf("@");
		goto loop;

	/* A1 */
	case 'A':
		p = p1;
	adr:
		c = 0;
		if (*string=='+') {
			c = 1;
			string++;
		}
		if (*string=='\'') {
			wregf = 1;
			string++;
		}
		if ((tree->op==INCAFT||tree->op==DECAFT) && p->op==STAR
		 && p->tr1->nloc<8)
			zf8 = 1;
		pname(p, c);
		wregf = 0;
		goto loop;

	/* A2 */
	case 'B':
		p = p2;
		goto adr;

	/* I */
	case 'M':
		if ((c = *string)=='\'')
			string++;
		else
			c = 0;
		if (tree->type==FLOAT || tree->type==DOUBLE)
			fl = 1;
		else
			fl = 0;
		prins(tree->op, fl, c, instab);
		goto loop;

	case 'T':
		if (!(opd&LEAF) && dcalc(p1, 0)<6) {
			putchar('k');
			goto loop;
		}

	/* B1 */
	case 'C':
		if ((opd&LEAF) != 0)
			p = tree;
		else
			p = p1;
		goto pbyte;

	case 'P':
		if (dcalc(p2, 0)<6) {
			putchar('k');
			goto loop;
		}

	/* B2 */
	case 'D':
		p = p2;
	pbyte:
		if (p->type==CHAR) {
			putchar('b');
			bregf = 1;
		}
		if (isfloat(p)) {
			if (p->type==DOUBLE)
				putchar('d');
			else if (p->type==FLOAT)
				putchar('s');
			else
				putchar('l');
		}
		goto loop;

	/* BE */
	case 'L':
		if ((opd&LEAF) != 0)
			p = tree;
		else
			p = p1;
		if (isfloat(p)=='l')
			putchar('l');
		goto loop;

	case 'V':
		if (isfloat(p)=='f')
			putchar('f');
		goto loop;

	/* F */
	case 'G':
		p = p1;
		flag = 01;
		goto subtre;

	/* S */
	case 'K':
		p = p2;
		flag = 02;
		goto subtre;

	/* H */
	case 'H':
		p = tree;
		flag = 04;

	subtre:
		ctable = regtab;
		if (flag&04)
			ctable = cregtab;
		c = *string++ - 'A';
		r = 0;
		k = 0;
		if (*string=='!') {
			string++;
			r = 1;
			k = 1;
		}
		if ((c&02)!=0)
			ctable = sptab;
		if ((c&04)!=0)
			ctable = cctab;
		if ((flag&01) && ctable==regtab && (c&01)==0
		  && (tree->op==TIMES||tree->op==DIVIDE
		   || tree->op==ASTIMES||tree->op==ASDIV||tree->op==ITOL))
			ctable = cregtab;
		if (p->type==LONG || opdope[p->op]&RELAT && p->tr1->type==LONG)
			if (p->op!=ITOL) {
				reg = (reg+1) & ~01;
				reg1 = reg+2;
			}
		if (c&010)
			r =+ reg1;
		else
			if (opdope[p->op]&LEAF || p->degree < 2)
				r =+ reg;
			else
				r =+ areg;
		if (p->op==CALL) {
			if (tree->op==FTOL || tree->op==FTOI)
				zf1++;
			else if (tree->op==ITOF)
				zf2++;
		}
		rreg = rcexpr(p, ctable, r);
		if (p->op==CALL || p->op==CALL2)
			goto loop;
		if (ctable!=regtab && ctable!=cregtab)
			goto loop;
		if (c&010) {
			if (rreg!=r)
				movreg(rreg, r, p);
		} else if (rreg!=reg) {
			if (k==0)
				movreg(rreg, reg, p);
			else if (rreg!=reg+1)
				movreg(rreg, reg+1, p);
		}
		goto loop;

	case 'U':
		lregf = 1;

	/* R */
	case 'I':
		r = reg;
		if (*string=='-') {
			string++;
			r--;
			if (isfloat(tree)=='l')
				r--;
		}
		goto prg;

	case 'E':
		printf("r1");
		goto loop;

	case 'R':
		printf("f%d", reg);
		nfloat++;
		goto loop;

	case 'O':
		printf("rr0");
		goto loop;

	case 'Q':
		printf("rh0");
		goto loop;

	case 'F':
		printf("r0");
		goto loop;

	case 'S':
		printf("rh%d", zreg(reg));
		goto loop;

	case 'Y':
		if (reg>0)
			printf("rq4");
		else
			printf("rq0");
		goto loop;

	case 'N':
		r = 6;
		goto pregp;

	/* R1 */
	case 'J':
		r = reg1;
	prg:
		if (*string=='+') {
			string++;
			r++;
		}
		if (*string=='\'') {
			string++;
			wregf = 1;
		}
		if ((tree->type==FLOAT || tree->type==DOUBLE) && r>=7 || r>nreg)
			error("Register overflow: simplify expression");
	pregp:
		preg(tree, r);
		goto loop;

	case 'W':
		printf("SP");
		goto loop;

	/*
	 * Mask used in field assignments
	 */
	case 'Z':
		printf("#%%%x", ~tree->mask);
		goto loop;

	/*
	 * Sign/zero extension for / % and PTOI
	 */
	case 'X':
		if (tree->op==TIMES || tree->op==ASTIMES)
			goto loop;
		if (tree->type==LONG) {
			printf("extsl\trq%d\n", zreg(reg-2));
			goto loop;
		}
		if (tree->type==UNSIGN) {
			printf("xor\tr%d,r%d\n", zreg(reg-1), zreg(reg-1));
			goto loop;
		}
		printf("exts\trr%d\n", zreg(reg-1));
		goto loop;
	}
	putchar(c);
	goto loop;
}

/*
 * This routine just calls sreorder (below)
 * on the subtrees and then on the tree itself.
 * It returns non-zero if anything changed.
 */
reorder(treep, table, reg)
struct tnode **treep;
struct table *table;
{
	register r, o;
	register struct tnode *p;

	p = *treep;
	o = p->op;
	if (opdope[o]&LEAF || o==LOGOR || o==LOGAND)
		return(0);
	while(sreorder(&p->tr1, regtab, reg, 1))
		;
	if (opdope[o]&BINARY) 
		while(sreorder(&p->tr2, regtab, reg, 1))
			;
	r = 0;
	if (table!=cctab)
	while (sreorder(treep, table, reg, 0))
		r++;
	*treep = optim(*treep);
	return(r);
}

/*
 * Basically this routine carries out two kinds of optimization.
 * First, it observes that "x + (reg = y)" where actually
 * the = is any assignment op is better done as "reg=y; x+reg".
 * In this case rcexpr is called to do the first part and the
 * tree is modified so the name of the register
 * replaces the assignment.
 * Moreover, expressions like "reg = x+y" are best done as
 * "reg = x; reg =+ y" (so long as "reg" and "y" are not the same!).
 *
 * Differs from V7 (reconstructed from the binary at 16D0): no ANDN/ASANDN, shifts
 * and long operands are left alone, 107/108 are shift operators unknown to c1.h.
 */
sreorder(treep, table, reg, recurf)
struct tnode **treep;
struct table *table;
{
	register struct tnode *p, *p1;

	p = *treep;
	if (opdope[p->op]&LEAF)
		return(0);
	if (p->op==PLUS && recurf)
		if (reorder(&p->tr2, table, reg))
			*treep = p = optim(p);
	p1 = p->tr1;
	if (p->op==STAR || p->op==PLUS) {
		if (recurf && reorder(&p->tr1, table, reg))
			*treep = p = optim(p);
		p1 = p->tr1;
	}
	if (p1->op==NAME) switch(p->op) {
		case ASLSH:
		case ASRSH:
			if (p->type==LONG)
				return(0);
		case ASSIGN:
			if (p1->class != REG||p1->type==CHAR||isfloat(p->tr2)=='f')
				return(0);
			if (p->op==ASSIGN) switch (p->tr2->op) {
			case TIMES:
				if (!ispow2(p->tr2))
					break;
				p->tr2 = pow2(p->tr2);
				goto cm;
			case LSHIFT:
			case RSHIFT:
			case 107:	/* not in c1.h (Annahme: Z8000 shifts) */
			case 108:
				if (p->tr2->type==LONG)
					break;
			case PLUS:
			case MINUS:
			case AND:
			case OR:
			case EXOR:
			cm:
				p1 = p->tr2->tr2;
				if (xdcalc(p1, 16) > 12
				 || p1->op==NAME
				 &&(p->tr1->nloc==p1->nloc
				  || p1->regno==p->tr1->nloc))
					return(0);
				p1 = p->tr2;
				p->tr2 = p1->tr1;
				if (p1->tr1->op!=NAME
				 || p1->tr1->class!=REG
				 || p1->tr1->nloc!=p->tr1->nloc)
					rcexpr(p, efftab, reg);
				p->tr2 = p1->tr2;
				p->op = p1->op + ASPLUS - PLUS;
				*treep = p;
				return(1);
			}
			goto OK;

		case ASTIMES:
			if (!ispow2(p))
				return(0);
		case ASPLUS:
		case ASMINUS:
		case ASAND:
		case ASOR:
		case ASXOR:
		case INCBEF:
		case DECBEF:
		OK:
			if (table==cctab||table==cregtab)
				reg =+ 020;
			rcexpr(optim(p), efftab, ~reg);
			*treep = p1;
			return(1);
	}
	return(0);
}

/*
 * Delay handles postfix ++ and -- 
 * It observes that "x + y++" is better
 * treated as "x + y; y++".
 * If the operator is ++ or -- itself,
 * it calls rcexpr to load the operand, letting
 * the calling instance of rcexpr to do the
 * ++ using efftab.
 * Otherwise it uses sdelay to search for inc/dec
 * among the operands.
 */
delay(treep, table, reg)
struct tnode **treep;
{
	register struct tnode *p, *p1;
	register r;

	p = *treep;
	if ((p->op==INCAFT||p->op==DECAFT)
	 && p->tr1->op==NAME) {
		return(1+rcexpr(p->tr1, table, reg));
	}
	p1 = 0;
	if (opdope[p->op]&BINARY) {
		if (p->op==LOGAND || p->op==LOGOR)
			return(0);
		}
		p1 = sdelay(&p->tr2);
	if (p1==0)
		p1 = sdelay(&p->tr1);
	if (p1) {
		r = rcexpr(optim(p), table, reg);
		*treep = p1;
		return(r+1);
	}
	return(0);
}

sdelay(ap)
struct tnode **ap;
{
	register struct tnode *p, *p1;

	p = *ap;
	if ((p->op==INCAFT||p->op==DECAFT) && p->tr1->op==NAME) {
		*ap = ncopy(p->tr1);
		return(p);
	}
	/* Differs from V7: only PLUS is followed (listing 1A82: one comparison with 0x28), STAR is not. */
	if (p->op==PLUS) {
		if (p1=sdelay(&p->tr1))
			return(p1);
		return(sdelay(&p->tr2));
	}
	return(0);
}

/*
 * Copy a tree node for a register variable.
 * Used by sdelay because if *reg-- is turned
 * into *reg; reg-- the *reg will in turn
 * be changed to some offset class, accidentally
 * modifying the reg--.
 */
ncopy(ap)
struct tname *ap;
{
	register struct tname *p, *q;

	p = ap;
	if (p->class!=REG)
		return(p);
	q = getblk(sizeof(*p));
	q->op = p->op;
	q->type = p->type;
	q->class = p->class;
	q->offset = p->offset;
	q->nloc = p->nloc;
	return(q);
}

/*
 * If the tree can be immediately loaded into a register,
 * produce code to do so and return success.
 */
chkleaf(atree, table, reg)
struct tnode *atree;
{
	struct tnode lbuf;
	register struct tnode *tree;

	tree = atree;
	if (tree->op!=STAR && dcalc(tree, nreg-reg) > 12)
		return(-1);
	lbuf.op = LOAD;
	lbuf.type = tree->type;
	lbuf.degree = tree->degree;
	lbuf.tr1 = tree;
	return(rcexpr(&lbuf, table, reg));
}

/*
 * Compile a function argument.
 * If the stack is currently empty, put it in (sp)
 * rather than -(sp); this will save a pop.
 * Return the number of bytes pushed,
 * for future popping.
 */
comarg(atree, flagp)
int *flagp;
{
	register struct tnode *tree;
	register retval;
	register i;	/* unused: the original keeps r10 for size, i.e. one register variable before it (listing 1B4C) */
	register size;

	/* Differs from V7: the structure copy is Z8000 code (ld r0,#n / dec SP / dec rK / lddr), no
	   nstack bookkeeping, no lsptab path (flagp unused): every other argument goes through sptab. */
	tree = atree;
	if (tree->op==STRASG) {
		size = tree->mask;
		tree = tree->tr1;
		tree = strfunc(tree);
		if (size <= 2) {
			setype(tree, INT);
			goto normal;
		}
		if (size <= 4) {
			setype(tree, LONG);
			goto normal;
		}
		if (tree->op!=NAME && tree->op!=STAR) {
			error("Unimplemented structure assignment");
			return(0);
		}
		tree = tnode(AMPER, STRUCT+PTR, tree);
		tree = tnode(PLUS, STRUCT+PTR, tree, tconst(size, INT));
		tree = optim(tree);
		retval = rcexpr(tree, regtab, 0);
		size =>> 1;
		printf("ld\tr0,#%%%x\n", size);
		printf("dec\tSP\ndec\tr%d\n", zreg(retval));
		printf("lddr\t@SP,@r%d,r0\n", zreg(retval));
		return(size*2);
	}
normal:
	rcexpr(tree, sptab, 0);
	retval = arlength(tree->type);
	return(retval);
}

struct tnode *
strfunc(atp)
struct tnode *atp;
{
	register struct tnode *tp;

	tp = atp;
	if (tp->op != CALL)
		return(tp);
	setype(tp, STRUCT+PTR);
	return(tnode(STAR, STRUCT, tp));
}

extern int yf0;	/* defined in c11.c */

/*
 * Compile an initializing expression
 *
 * Differs from V7 (reconstructed from the binary at 1C74, doc wk_w6.md part 6):
 * Z8000 as syntax (BV/WV/LV), no SFCON, FLOAT and DOUBLE are output alike
 * (four words), floating constants can be pooled via yf0.  The suspicious
 * fcopy(tree->value, fval) in the yf0 branch is as in the binary (the
 * branch is probably never run: yf0 is never set).
 */
doinit(atype, atree)
struct tnode *atree;
{
	register struct tnode *tree;
	register int type;
	float sfval;
	int fval[4];
	long lval;
	int chrf;

	chrf = 0;
	tree = atree;
	type = atype;
	if (type==CHAR) {
		printf("BV");
		chrf = 1;
		if (tree->type&XTYPE)
			goto illinit;
		type = INT;
	}
	if (type&XTYPE)
		type = INT;
	switch (type) {
	case INT:
	case UNSIGN:
		if (tree->op==FTOI) {
			if (tree->tr1->op!=FCON)
				goto illinit;
			tree = tree->tr1;
			tree->value = ftol(&tree->fvalue);
			tree->op = CON;
		} else if (tree->op==LTOI) {
			if (tree->tr1->op!=LCON)
				goto illinit;
			tree = tree->tr1;
			lval = tree->lvalue;
			tree->op = CON;
			tree->value = lval;
		}
		if (tree->op == CON) {
			if (chrf)
				printf(" %%%x\n", tree->value);
			else
				printf("WV %%%x\n", tree->value);
		} else if (tree->op==AMPER) {
			printf("WV ");
			pname(tree->tr1, 0);
			putchar('\n');
		} else
			goto illinit;
		return;

	case DOUBLE:
	case FLOAT:
		if (tree->op==ITOF) {
			if (tree->tr1->op!=CON)
				goto illinit;
			ltod((long)tree->tr1->value, fval);
		} else if (tree->op==FCON)
			fcopy(fval, &tree->fvalue);
		else if (tree->op==LTOF) {
			if (tree->tr1->op!=LCON)
				goto illinit;
			ltod(tree->tr1->lvalue, fval);
		} else if (tree->op==CON || tree->op==LCON) {
			printf("WV %%0;WV %%0;WV %%0;WV %%0\n");
			return;
		} else
			goto illinit;
		if (yf0==0) {
			if (tree->op==FCON)
				printf("L%d:\n", tree->value);
			printf("WV %%%x;WV %%%x;WV %%%x;WV %%%x\n", fval[0], fval[1], fval[2], fval[3]);
			return;
		}
		if (tree->op!=FCON) {
			tree = getblk(sizeof(struct ftconst));
			tree->value = isn++;
			fcopy(tree->value, fval);
		}
		outfp(tree, 0);
		return;

	case LONG:
		if (tree->op==FTOL) {
			tree = tree->tr1;
			if (tree->op!=FCON)
				goto illinit;
			lval = ftol(&tree->fvalue);
		} else if (tree->op==ITOL) {
			if (tree->tr1->op != CON)
				goto illinit;
			lval = tree->tr1->value;
		} else if (tree->op==LCON)
			lval = tree->lvalue;
		else
			goto illinit;
		printf("LV %%%lx\n", lval);
		return;
	}
illinit:
	error("illegal initialization\n");
}

/*
 * Not V7 changes: this is V7 movreg for the Z8000 (original at 1EFC).  Register
 * numbers are mapped by zreg(); the output is "ld dst,src" (destination
 * first).  Reconstructed from the binary.
 */
movreg(r0, r1, tree)
struct tnode *tree;
{
	register d, s;

	if (r1==r0)
		return;
	d = zreg(r1);
	s = zreg(r0);
	if (tree->type==LONG) {
		printf("ldl\trr%d,rr%d\n", d, s);
		return;
	}
	if (isfloat(tree)!='f')
		printf("ld\tr%d,r%d\n", d, s);
	else
		printf("fld\tf%d,f%d\n", r1, r0);
}

/*
 * Not V7 (original at 1F66; name invented, *Annahme*): convert the long l
 * to the 4-word double format p[0..3] (sign, 11 bit exponent, bias 1023,
 * mantissa), used for LTOF of constants.
 */
ltod(l, p)
long l;
unsigned *p;
{
	register unsigned *lp;
	register e, sgn;

	lp = &l;
	p[3] = 0;
	if (l==0) {
		p[0] = p[1] = p[2] = 0;
		return;
	}
	e = 31;
	if (l<0) {
		l = -l;
		sgn = 1;
	} else
		sgn = 0;
	while ((*lp & 0100000) != 0100000) {
		l <<= 1;
		e--;
	}
	e += 1023;
	e <<= 4;
	p[2] = (lp[1] & 07767) << 5;
	l >>= 11;
	p[0] = (*lp & 017) | e;
	p[1] = lp[1];
	if (sgn)
		p[0] |= 0100000;
}

/*
 * Not V7 (original at 2028; name invented, *Annahme*): convert the 4-word
 * double p[0..3] to a long (inverse of ltod); the sign is not handled.
 */
long
ftol(p)
unsigned *p;
{
	register *mp, i, e, sgn;
	long m;

	mp = &m;
	if (p[3]==0 && p[2]==0 && p[1]==0 && (*p & 077777)==0)
		return(0);
	sgn = 0;
	e = ((*p & 077760) >> 4) - 1023;
	if (e > 31)
		error("floating to large for long");
	*p = (*p & 017) | 020;
	for (i=0; i<2; i++)
		mp[i] = (p[i+1] << 11) | (p[i+2] >> 5);
	m >>= 1;
	*mp &= 077777;
	m >>= 30 - e;
	return(m);
}

/*
 * Not V7 (original at 2104; name invented, *Annahme*): print the name of
 * register reg for the type of tree: FP, r%d, rr%d (long), f%d (float),
 * rl%d (byte).  The flags force a name format.
 */
preg(tree, reg)
struct tnode *tree;
{
	register struct tnode *t;
	register n;
	char c;

	rlused = 0;
	t = tree;
	if (reg==14) {
		printf("FP");
		return;
	}
	n = zreg(reg);
	if (wregf) {
		printf("r%d", n);
		wregf = 0;
		return;
	}
	if (lregf) {
		printf("rr%d", n);
		lregf = 0;
		return;
	}
	if ((c = isfloat(t))=='l')
		printf("rr%d", n);
	else if (c=='f') {
		printf("f%d", reg);
		nfloat++;
	} else if (bregf) {
		if (n < 9) {
			printf("rl%d", n);
			rlused = 1;
		} else
			error("byte-operation on register greater 8");
	} else
		printf("r%d", n);
}

/*
 * Not V7 (original at 21D6; name invented, *Annahme*): map a code
 * generator register number to the Z8000 register number used in the output.
 * 0..5 -> 2..7, 6..7 -> 0..1, others unchanged.
 */
zreg(r)
register r;
{
	if (r < 6)
		return(r+2);
	if (r > 7)
		return(r);
	return(r-6);
}

/* Not V7 (original at 21FC; name invented): copy 4 words (a double) */
fcopy(d, s)
int *d, *s;
{
	register i;

	for (i=0; i<4; i++)
		d[i] = s[i];
}

/*
 * Not V7 (original at 2228; name invented): output a floating constant:
 * label and four WV words (negated if neg), and remember it in fptab.
 */
outfp(p, neg)
register struct ftconst *p;
{
	if (neg)
		fphead();
	printf("L%d:\n", p->value);
	printf("WV %%%x;WV %%%x;WV %%%x;WV %%%x\n", p->fvalue);
	if (neg) {
		fptail();
		p->value = -p->value;
	}
	if (nfpool < 50)
		fptab[nfpool++] = *p;
}
