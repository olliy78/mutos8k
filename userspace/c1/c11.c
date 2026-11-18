#
/*
 *  C compiler
 */

#include "c1.h"

extern int nreg;
extern int isn;
extern int zf4, wregf, bregf, zf8, zf9;	/* defined in c10.c */

/* Not V7: original data at 7B3E (3 bytes + pad) */
char	modname[]	"c_";
int	nfloat;

/* Not V7: zero-initialised flags at 7B42..7B4A (names *Annahme*) */
int	yf0	0;	/* 7B42 */
int	yf1	0;	/* 7B44 */
int	yf2	0;	/* 7B46 */
int	yf3	0;	/* 7B48 */
int	yf4	0;	/* 7B4A */

/*
 * Not V7 (original at 229E, size 86; name *Annahme*): look up a floating
 * constant in the pool fptab (filled by outfp) by its four value words;
 * returns the label number kept there, 0 if absent.
 * The word view of struct ftconst is a local invention (members w0..w3).
 */
struct fpw { int fw_op; int fw_type; int fw_value; int w0, w1, w2, w3; };
extern struct fpw fptab[];
extern int nfpool;

fpfind(ap)
struct fpw *ap;
{
	register struct fpw *p, *q;
	register i;

	p = ap;
	for (i=0; i<nfpool; i++) {
		q = &fptab[i];
		if (p->w0==q->w0 && p->w1==q->w1 && p->w2==q->w2 && p->w3==q->w3)
			return(q->fw_value);
	}
	return(0);
}

max(a, b)
{
	if (a>b)
		return(a);
	return(b);
}

degree(at)
struct tnode *at;
{
	register struct tnode *t, *t1;

	if ((t=at)==0 || t->op==0)
		return(0);
	if (t->op == CON)
		return(-3);
	if (t->op == AMPER)
		return(-2);
	if (t->op==ITOL) {
		if ((t1 = isconstant(t)) && (t1->value>=0 || t1->type==UNSIGN))
			return(-2);
		if ((t1=t->tr1)->type==UNSIGN && opdope[t1->op]&LEAF)
			return(-1);
	}
	if ((opdope[t->op] & LEAF) != 0) {
		if (t->type==CHAR || t->type==FLOAT)
			return(1);
		return(0);
	}
	return(t->degree);
}

/*
 * Differs from V7 (original at 23AE): Z8000 operand syntax, no AUTOI/AUTOD/
 * SFCON cases, putchar('#') for AMPER, '@' for indirection (STAR) unless
 * zf8/OFFS, register-pair second half via flag.  yf3 (7B48): an offset was
 * printed (name *Annahme*).
 */
pname(ap, flag)
struct tnode *ap;
{
	register i;
	register struct tnode *p;
	struct { int intx[2]; };

	p = ap;
loop:
	switch(p->op) {

	case LCON:
		if (flag==0 && wregf==0) {
			printf("#%%%lx", p->lvalue);
			return;
		}
		if (flag==0 && wregf)
			printf("#%%%x", p->lvalue.intx[0]);
		else
			printf("#%%%x", p->lvalue.intx[1]);
		return;

	case CON:
		printf("#");
		if (bregf)
			p->value =& 0377;
		psoct(p->value);
		return;

	case FCON:
		printf("L%d", (p->value>0? p->value: -p->value));
		return;

	case NAME:
		yf3 = 0;
		if (flag && p->class==REG) {
			flag = 0;
			p->nloc++;
		}
		i = p->offset;
		if (flag)
			i =+ 2;
		if (i) {
			yf3 = 1;
			psoct(i);
			if (p->class!=OFFS)
				putchar('+');
			if (p->class==REG)
				regerr();
		}
		switch(p->class) {

		case SOFFS:
		case XOFFS:
			yf3 = 1;
			pbase(p);

		case OFFS:
			if (p->regno==14) {
				if (yf3)
					printf("(FP)");
				else
					printf("@FP");
				return;
			}
			if (yf3)
				printf("(r%d)", zreg(p->regno));
			else
				printf("@r%d", zreg(p->regno));
			return;

		case EXTERN:
		case STATIC:
			pbase(p);
			return;

		case REG:
			preg(p, p->nloc);
			return;

		}
		error("Compiler error: pname");
		return;

	case AMPER:
		putchar('#');
		p = p->tr1;
		if (p->op==NAME && p->class==REG)
			regerr();
		goto loop;

	case STAR:
		p = p->tr1;
		if (!zf8 && p->class!=OFFS) {
			putchar('@');
			wregf = 1;
		} else
			zf8 = 0;
		if (p->class==REG)
			goto loop;
		if (p->class==OFFS)
			goto loop;
		error("illegal indirection");
		goto loop;

	}
	error("pname called illegally");
}

regerr()
{
	error("Illegal use of register");
}

pbase(ap)
struct tnode *ap;
{
	register struct tnode *p;

	p = ap;
	if (p->class==SOFFS || p->class==STATIC)
		printf("L%d", p->nloc);
	else
		printf("%.8s", &(p->nloc));
}

xdcalc(ap, nrleft)
struct tnode *ap;
{
	register struct tnode *p;
	register d;

	p = ap;
	d = dcalc(p, nrleft);
	if (d<20 && p->type==CHAR) {
		if (nrleft>=1)
			d = 20;
		else
			d = 24;
	}
	return(d);
}

/*
 * Differs from V7 (original at 26D8): dense switch over NAME..STAR; FCON,
 * AMPER and a non-register NAME give 12, LCON 11 (no AUTOI/AUTOD/SFCON);
 * CON is graded 4/5/6/7/8 by value (12 if not positive); STAR of a register
 * name gives 9, of an OFFS name 12 (V7: NAME/CON/AUTOI/AUTOD operand, not
 * LONG).
 */
dcalc(ap, nrleft)
struct tnode *ap;
{
	register struct tnode *p, *p1;

	if ((p=ap)==0)
		return(0);
	switch (p->op) {

	case NAME:
		if (p->class==REG)
			return(9);

	case FCON:
	case AMPER:
		return(12);

	case LCON:
		return(11);

	case CON:
		if (p->value==0)
			return(4);
		if (p->value>0) {
			if (p->value<16)
				return(5);
			if (p->value==16)
				return(6);
			if (p->value<33)
				return(7);
			return(8);
		}
		return(12);

	case STAR:
		p1 = p->tr1;
		if (p1->op==NAME && p1->class==REG)
			return(9);
		if (p1->op==NAME && p1->class==OFFS)
			return(12);
	}
	if (p->type==LONG)
		nrleft--;
	return(p->degree <= nrleft? 20: 24);
}

/* Differs from V7: no register-char/ASSIGN exemption (op is unused) */
notcompat(ap, ast, op)
struct tnode *ap;
{
	register at, st;
	register struct tnode *p;

	p = ap;
	at = p->type;
	st = ast;
	if (st==0)		/* word, byte */
		return(at!=CHAR && at!=INT && at!=UNSIGN && at<PTR);
	if (st==1)		/* word */
		return(at!=INT && at!=UNSIGN && at<PTR);
	if (st==9 && (at&XTYPE))
		return(0);
	st =- 2;
	if ((at&(~(TYPE+XTYPE))) != 0)
		at = 020;
	if ((at&(~TYPE)) != 0)
		at = at&TYPE | 020;
	if (st==FLOAT && at==DOUBLE)
		at = FLOAT;
	return(st != at);
}

/*
 * Differs from V7 (original at 2826): extra argument fl (unused here; the
 * callers pass the float flag), entries are {iop, str1, str2}; a string
 * starting with '!' only counts up yf4; an operator string starting with
 * 'm' gets a 't' appended unless fl; t/x/o/an operators set zf4 (branch
 * code selection).  Reconstructed from the listing.
 */
prins(op, fl, c, itable)
struct instab *itable;
{
	register struct instab *insp;
	register char *ip;

	for (insp=itable; insp->iop != 0; insp++) {
		if (insp->iop == op) {
			ip = c? insp->str2: insp->str1;
			if (ip==0)
				break;
			if (*ip=='!') {
				yf4++;
				return;
			}
			printf("%s", ip);
			if (*ip=='m' && !fl)
				putchar('t');
			if (*ip=='t' || *ip=='x' || *ip=='o' || (*ip=='a' && ip[1]=='n'))
				zf4 = 1;
			return;
		}
	}
	error("No match' for op %d", op);
}

/*
 * Differs from V7: also returns 'l' for LONG (original at 28EE).
 */
isfloat(at)
struct tnode *at;
{
	register struct tnode *t;

	t = at;
	if ((opdope[t->op]&RELAT)!=0)
		t = t->tr1;
	if (t->type==FLOAT || t->type==DOUBLE) {
		nstack = 1;
		return('f');
	}
	if (t->type==LONG)
		return('l');
	return(0);
}

/*
 * Differs from V7 (original at 293C): different operator lists, Z8000
 * register pairs; the DIVIDE.. case returns (reg+1)|1 for non-longs.
 */
oddreg(t, areg)
struct tnode *t;
{
	register reg, c;

	reg = areg;
	if ((c = isfloat(t))!='f') {
		switch(t->op) {
		case PTOI:
		case TIMES:
		case DIVIDE:
		case MOD:
		case ASTIMES:
		case ASDIV:
		case ASMOD:
			if (t->type==LONG) {
				if (reg>2)
					error("Register overflow for longs: simplify expression");
				else {
					if (reg || t->op==MOD || t->op==ASMOD)
						return(4);
					return(0);
				}
			} else
				return((reg+1)|1);
		}
	}
	if (c=='l' || t->op==ITOF || t->op==FTOI)
		return((reg+1) & ~01);
	return(reg);
}

arlength(t)
{
	if (t>=PTR)
		return(2);
	switch(t) {

	case INT:
	case CHAR:
	case UNSIGN:
		return(2);

	case LONG:
		return(4);

	case FLOAT:
	case DOUBLE:
		return(8);
	}
	return(1024);
}

/*
 * Strings for switch code (Z8000 form, original at 7BB6/7C08: the table
 * goes to a data section named after modname).
 */

char	dirsw[] {"\
cp	r2,#%%%x\n\
jp	ugt,L%d\n\
add	r2,r2\n\
ld	r1,L%d(r2)\n\
jp	@r1\n\
$DATA\n\
$SECTION %s_d\n\
I\n\
L%d:\n\
" };

char	hashsw[] {"\
ld	r3,r2\n\
xor	r2,r2\n\
div	rr2,#%%%x\n\
ex	r2,r3\n\
add	r3,r3\n\
ld	r1,L%d(r3)\n\
jp	@r1\n\
$DATA\n\
$SECTION %s_d\n\
I\n\
L%d:\n\
"};

/*
 * If the unsigned casts below won't compile,
 * try using the calls to lrem and ldiv.
 * Differs from V7 (original at 2A1E): Z8000 output; the data section of the
 * tables is closed with fptail() (3CAA) instead of ".text".
 */

pswitch(afp, alp, deflab)
struct swtab *afp, *alp;
{
	int ncase, tabs, worst, best, range;
	register struct swtab *swp, *fp, *lp;
	register i, j;
	register int *poctab;

	fp = afp;
	lp = alp;
	if (fp==lp) {
		printf("jp	L%d\n", deflab);
		return;
	}
	isn++;
	if (sort(fp, lp))
		return;
	ncase = lp-fp;
	lp--;
	range = lp->swval - fp->swval;
	/* direct switch */
	if (range>0 && range <= 3*ncase) {
		if (fp->swval)
			printf("sub	r2,#%%%x\n", fp->swval);
		printf(dirsw, range, deflab, isn, modname, isn);
		isn++;
		for (i=fp->swval; ; i++) {
			if (i==fp->swval) {
				printf("WV L%d\n", fp->swlab);
				if (fp==lp)
					break;
				fp++;
			} else
				printf("WV L%d\n", deflab);
		}
		fptail();
		return;
	}
	/* simple switch */
	if (ncase<10) {
		for (fp = afp; fp<=lp; fp++)
			breq(fp->swval, fp->swlab);
		printf("jp	L%d\n", deflab);
		return;
	}
	/* hash switch */
	best = 077777;
	poctab = getblk(((ncase+2)/2) * sizeof(*poctab));
	for (i=ncase/4; i<=ncase/2; i++) {
		for (j=0; j<i; j++)
			poctab[j] = 0;
		for (swp=fp; swp<=lp; swp++)
			/* lrem(0, swp->swval, i) */
			poctab[(unsigned)swp->swval%i]++;
		worst = 0;
		for (j=0; j<i; j++)
			if (poctab[j]>worst)
				worst = poctab[j];
		if (i*worst < best) {
			tabs = i;
			best = i*worst;
		}
	}
	i = isn++;
	printf(hashsw, tabs, i, modname, i);
	isn++;
	for (i=0; i<tabs; i++)
		printf("WV L%d\n", isn+i);
	fptail();
	for (i=0; i<tabs; i++) {
		printf("L%d:\n", isn++);
		for (swp=fp; swp<=lp; swp++) {
			/* lrem(0, swp->swval, tabs) */
			if ((unsigned)swp->swval%tabs == i) {
				/* ldiv(0, swp->swval, tabs) */
				breq((unsigned)swp->swval/tabs, swp->swlab);
			}
		}
		printf("jp	L%d\n", deflab);
	}
}

breq(v, l)
{
	if (v==0)
		printf("test	r2\n");
	else
		printf("cp	r2,#%%%x\n", v);
	printf("jp	eq	L%d\n", l);
}

sort(afp, alp)
struct swtab *afp, *alp;
{
	register struct swtab *cp, *fp, *lp;
	int intch, t;

	fp = afp;
	lp = alp;
	while (fp < --lp) {
		intch = 0;
		for (cp=fp; cp<lp; cp++) {
			if (cp->swval == cp[1].swval) {
				error("Duplicate case (%d)", cp->swval);
				return(1);
			}
			if (cp->swval > cp[1].swval) {
				intch++;
				t = cp->swval;
				cp->swval = cp[1].swval;
				cp[1].swval = t;
				t = cp->swlab;
				cp->swlab = cp[1].swlab;
				cp[1].swlab = t;
			}
		}
		if (intch==0)
			break;
	}
	return(0);
}

ispow2(atree)
{
	register int d;
	register struct tnode *tree;

	tree = atree;
	if (!isfloat(tree) && tree->tr2->op==CON) {
		d = tree->tr2->value;
		if (d>1 && (d&(d-1))==0)
			return(d);
	}
	return(0);
}

/*
 * Not V7 (original at 2DAE, name *Annahme*): bit number of a single-bit
 * constant, else -1.  Placed between ispow2 and pow2 like in the binary.
 */
bitnum(v)
unsigned v;
{
	register n;

	if (v==0 || v>0100000 || (v&(v-1))!=0)
		return(-1);
	for (n=0; (v >>= 1)!=0; n++)
		;
	return(n);
}

pow2(atree)
struct tnode *atree;
{
	register int d, i;
	register struct tnode *tree;

	tree = atree;
	if (d = ispow2(tree)) {
		for (i=0; (d=>>1)!=0; i++);
		tree->tr2->value = i;
		switch (tree->op) {

		case TIMES:
			tree->op = LSHIFT;
			break;

		case ASTIMES:
			tree->op = ASLSH;
			break;

		case DIVIDE:
			tree->op = ULSH;
			tree->tr2->value = -i;
			break;

		case ASDIV:
			tree->op = ASULSH;
			tree->tr2->value = -i;
			break;

		case MOD:
			tree->op = AND;
			tree->tr2->value = (1<<i)-1;
			break;

		case ASMOD:
			tree->op = ASAND;
			tree->tr2->value = (1<<i)-1;
			break;

		default:
			error("pow2 botch");
		}
		tree = optim(tree);
	}
	return(tree);
}

/*
 * Not V7 (original at 2EE4, name *Annahme*): turn the AND/OR/ASAND/ASOR
 * with a single-bit constant into the bit reset/set operators 82/81/84/83
 * (op numbers measured; no names in c1.h yet) with the bit number as the
 * constant.  Placed after pow2 like in the binary.
 */
bitop(tree, n)
struct tnode *tree;
{
	struct tnode *p;

	p = tree;
	if (p->tr1->type==CHAR && n>7)
		return(p);
	p->tr2->value = n;
	switch (p->op) {
	case AND:
		p->op = 82;
		break;
	case OR:
		p->op = 81;
		break;
	case ASAND:
		p->op = 84;
		break;
	case ASOR:
		p->op = 83;
		break;
	}
	return(p);
}

/*
 * Differs from V7 (original at 2F6C): constant conditions, a bit-test form
 * for AND with a single-bit constant (op 85, bit number as constant), leaf
 * operands are compared with 0, no long compare (no longrel), unsigned
 * compare for char operands, no cfcc.
 */
cbranch(atree, albl, cond, areg)
struct tnode *atree;
{
	register l1, op, k, lbl, reg;
	register struct tnode *tree;

	zf4 = 0;
	lbl = albl;
	reg = areg;
again:
	if ((tree=atree)==0)
		return;
	if (tree->op==CON && tree->value==0 || tree->op==LCON && tree->lvalue==0) {
		if (!cond)
			branch(lbl, 0, 0);
		return;
	}
	if (tree->op==CON || tree->op==LCON) {
		if (cond)
			branch(lbl, 0, 0);
		return;
	}
	switch(tree->op) {

	case LOGAND:
		if (cond) {
			cbranch(tree->tr1, l1=isn++, 0, reg);
			cbranch(tree->tr2, lbl, 1, reg);
			label(l1);
		} else {
			cbranch(tree->tr1, lbl, 0, reg);
			cbranch(tree->tr2, lbl, 0, reg);
		}
		return;

	case LOGOR:
		if (cond) {
			cbranch(tree->tr1, lbl, 1, reg);
			cbranch(tree->tr2, lbl, 1, reg);
		} else {
			cbranch(tree->tr1, l1=isn++, 1, reg);
			cbranch(tree->tr2, lbl, 0, reg);
			label(l1);
		}
		return;

	case EXCLA:
		cbranch(tree->tr1, lbl, !cond, reg);
		return;

	case SEQNC:
		rcexpr(tree->tr1, efftab, reg);
		atree = tree->tr2;
		goto again;

	case ITOL:
		tree = tree->tr1;
		break;

	}
	if (tree->op==AND && tree->type!=LONG && tree->tr2->op==CON
	 && (k = bitnum(tree->tr2->value)) >= 0
	 && !(tree->type==CHAR && k>7)) {
		tree->op = 85;
		tree->tr2->value = k;
	}
	if (opdope[tree->op]&LEAF) {
		k = tree->type;
		if (k==FLOAT || k==DOUBLE)
			k = 0;
		tree = tnode(NEQUAL, tree->type, tree, tconst(0, k));
	}
	rcexpr(tree, cctab, reg);
	op = tree->op;
	if ((opdope[op]&RELAT)==0)
		op = NEQUAL;
	else {
		if (tree->tr1->type==CHAR && tree->tr2->type==CHAR && op>=LESSEQ)
			op =+ LESSEQP-LESSEQ;
		l1 = tree->tr2->op;
		if (l1==CON && tree->tr2->value==0)
			op =+ 200;		/* special for ptr tests */
	}
	branch(lbl, op, !cond);
}

/*
 * Differs from V7 (original at 31E8): zf4 (set by the cctab output, 7616)
 * selects the signed-compare fixups (jp pl / jp mi after the compare);
 * yf4 (7B4A) suppresses the label operand (name *Annahme*).
 */
branch(lbl, aop, c)
{
	register op;
	int k;

	if (op=aop) {
		if (zf4) {
			zf4 = 0;
			if (op>200)
				k = op-200;
			else
				k = op;
			if (k==GREAT && !c || k==LESSEQ && c) {
				printf("jp	eq	L%d\n", isn);
				printf("jp	pl	L%d\n", lbl);
				printf("L%d:\n", isn++);
				return;
			}
			if (k==LESSEQ && !c || k==GREAT && c) {
				printf("jp	mi	L%d\n", lbl);
				printf("jp	eq");
			} else if (k==GREATEQ && !c || k==LESS && c)
				printf("jp	pl");
			else if (k==LESS && !c || k==GREATEQ && c)
				printf("jp	mi");
			else
				prins(op, 0, c, branchtab);
		} else
			prins(op, 0, c, branchtab);
	} else
		printf("jp");
	if (yf4)
		yf4 = 0;
	else
		printf("\tL%d\n", lbl);
}

label(l)
{
	printf("L%d:\n", l);
}

popstk(a)
{
	if (a) {
		if (a<=16)
			printf("inc	SP,#%%%x\n", a);
		else
			printf("add	SP,#%%%x\n", a);
	}
}

error(s, p1, p2, p3, p4, p5, p6)
{

	nerror++;
	fprintf(stderr, "%d: ", line);
	fprintf(stderr, s, p1, p2, p3, p4, p5, p6);
	putc('\n', stderr);
}

psoct(an)
{
	register n;

	if ((n = an) < 0) {
		n = -n;
		putchar('-');
	}
	printf("%%%x", n);
}

/*
 * Read in an intermediate file.
 * Differs from V7 (original at 3416): Z8000 output (as dialect with
 * $-sections, BV/WV), no SETREG case, FCON always DOUBLE and atof(s, &d),
 * NAME other than EXTERN via regnode(), a second static name buffer (s1)
 * for RLABEL, long compare of the CBRANCH-less 3-way branch uses testl /
 * fcpzx.  globf: a global symbol name is pending in s (printed by NLABEL);
 * endf: print "end <name>" after the next BRANCH (names *Annahme*).
 */
#define	STKS	100
getree()
{
	struct tnode *expstack[STKS];
	register struct tnode **sp;
	register t, x, op;
	register struct swtab *swp;
	register struct xtname *np;
	static char s[9], s1[9];
	char numbuf[64];
	int unused1;	/* never used; the original frame has this word (FEEA) between numbuf and fp (*Annahme*) */
	struct ftconst *fp;
	struct lconst *lp;
	struct fasgn *sap;
	int lbl, cond, lbl2, lbl3, endf, globf;

	endf = 0;
	globf = 0;
	curbase = funcbase;
	sp = expstack;
	for (;;) {
		if (sp >= &expstack[STKS])
			error("Stack overflow botch");
		op = geti();
		if ((op&0177400) != 0177000) {
			error("Intermediate file error");
			exit(1);
		}
		lbl = 0;
		switch(op =& 0377) {

	case SINIT:
		printf("WV %%%x\n", geti());
		break;

	case EOFC:
		return;

	case BDATA:
		if (geti() == 1) {
			/* Differs from V7: one "BV" per value, so the ";" is
			   printed before the next "BV " (loop inverted by cc:
			   the test comes last in the original, at 34B0). */
			while (printf("BV "), printf("%%%x", geti()), geti() == 1)
				printf(";");
			printf("\n");
		}
		break;

	case PROG:
		if (yf0) {
			fptail();
			break;
		}
		globf = 0;
		yf0 = 1;
		break;

	case DATA:
		fphead();
		break;

	case BSS:
		secbss();
		break;

	case SYMDEF:
		fptail();
		outname(s);
		yf1 = 1;
		if (s[0])
			globf = 1;
		sfuncr.nloc = 0;
		break;

	case RETRN:
		printf("jp	cret\n");
		break;

	case CSPACE:
		t = outname(s);
		printf("X	%.8s	", t);
		t = geti();
		switch (t) {

		case 1:
			printf("B\n");
			break;

		case 2:
			printf("W\n");
			break;

		case 4:
			printf("long\n");
			break;

		default:
			printf("A[%%%x B]\n", t);
		}
		break;

	case SSPACE:
		t = geti();
		printf("$REL	$+%%%x\n", t);
		totspace =+ (unsigned)t;
		break;

	case EVEN:
		printf("$EVEN\n");
		break;

	case SAVE:
		printf("call	csv\n");
		break;

	case SETSTK:
		t = geti()-12;
		if (t!=0 && t<17)
			printf("dec	SP,#%%%x\n", t);
		else if (t != 0)
			printf("sub	SP,#%%%x\n", t);
		endf = 1;
		yf0 = 0;
		break;

	case PROFIL:
		t = geti();
		printf("ld	r2,#L%d\n,call	mcount\n", t);
		secbss();
		printf("L%d:\n$REL	$+2\n", t);
		fptail();
		break;

	case SNAME:
		t = outname(s);
		printf("~%s:=L%d\n", t+1, geti());
		break;

	case ANAME:
		t = outname(s);
		printf("~%s:=%%%x\n", t+1, geti());
		break;

	case RNAME:
		t = outname(s);
		printf("~%s:=r%d\n", t+1, geti());
		break;

	case SWIT:
		t = geti();
		line = geti();
		curbase = funcbase;
		while(swp=getblk(sizeof(*swp)), swp->swlab = geti())
			swp->swval = geti();
		pswitch(funcbase, swp, t);
		break;

	case C3BRANCH:		/* for fortran [sic] */
		lbl = geti();
		lbl2 = geti();
		lbl3 = geti();
		goto xpr;

	case CBRANCH:
		lbl = geti();
		cond = geti();

	case EXPR:
	xpr:
		nfloat = 0;
		zf9 = 0;
		line = geti();
		if (sp != &expstack[1]) {
			error("Expression input botch");
			exit(1);
		}
		*sp = optim(*--sp);
		if (op==CBRANCH)
			cbranch(*sp, lbl, cond, 0);
		else if (op==EXPR)
			rcexpr(*sp, efftab, 0);
		else {
			if ((*sp)->type==LONG) {
				rcexpr(tnode(RFORCE, (*sp)->type, *sp), efftab, 0);
				printf("testl	rr2\n");
			} else {
				rcexpr(*sp, cctab, 0);
				if (isfloat(*sp)=='f')
					printf("fcpzx	f0\n");
			}
			printf("jp	gt	L%d\n", lbl3);
			printf("jp	lt	L%d\njp	L%d\n", lbl, lbl2);
		}
		curbase = funcbase;
		break;

	case NAME:
		t = geti();
		x = geti();
		if (t==EXTERN) {
			np = getblk(sizeof(*np));
			np->type = x;
			outname(np->name);
			np->op = NAME;
			np->class = t;
			np->regno = 0;
			np->offset = 0;
			*sp++ = np;
		} else
			*sp++ = regnode(t, x, geti());
		break;

	case CON:
		t = geti();
		*sp++ = tconst(geti(), t);
		break;

	case LCON:
		geti();	/* ignore type, assume long */
		t = geti();
		op = geti();
		if (t==0 && op>=0 || t == -1 && op<0) {
			*sp++ = tnode(ITOL, LONG, tconst(op, INT));
			break;
		}
		lp = getblk(sizeof(*lp));
		lp->op = LCON;
		lp->type = LONG;
		lp->lvalue = ((long)t<<16) + (unsigned)op;	/* nonportable */
		*sp++ = lp;
		break;

	case FCON:
		t = geti();
		outname(numbuf);
		fp = getblk(sizeof(*fp));
		fp->op = FCON;
		fp->type = DOUBLE;
		fp->value = isn++;
		atof(numbuf, &fp->fvalue);
		*sp++ = fp;
		break;

	case FSEL:
		*sp = tnode(FSEL, geti(), *--sp, NULL);
		t = geti();
		(*sp++)->tr2 = tnode(COMMA, INT, tconst(geti(), INT), tconst(t, INT));
		break;

	case STRASG:
		sap = getblk(sizeof(*sap));
		sap->op = STRASG;
		sap->type = geti();
		sap->mask = geti();
		sap->tr1 = *--sp;
		sap->tr2 = NULL;
		*sp++ = sap;
		break;

	case NULLOP:
		*sp++ = tnode(0, 0, NULL, NULL);
		break;

	case LABEL:
		label(geti());
		break;

	case NLABEL:
		t = outname(s);
		if (globf) {
			printf("%.8s	L\n", s);
			globf = 0;
		}
		printf("%.8s:\n", t);
		break;

	case RLABEL:
		t = outname(s1);
		if (s[0]) {
			if (yf1) {
				printf("G");
				yf1 = 0;
			}
			printf("	%.8s	PR\n", s);
		} else
			printf("I	%s	PR\n", t);
		printf("~~%s:\nE\n", t+1);
		break;

	case BRANCH:
		branch(geti(), 0);
		if (endf) {
			endf = 0;
			printf("end %.8s\nI\n", s1);
		}
		break;

	default:
		if (opdope[op]&BINARY) {
			if (sp < &expstack[1]) {
				error("Binary expression botch");
				exit(1);
			}
			t = *--sp;
			*sp = tnode(op, geti(), *--sp, t);
			sp++;
		} else
			sp[-1] = tnode(op, geti(), sp[-1]);
		break;
	}
	}
}

/*
 * Not V7 (original at 3C2A, 3C58, 3CAA; names *Annahme*): output of the
 * assembler section directives.  yf0: section mode ($DATA/$SECTION/$CODE
 * instead of the plain directives), yf1: next data is global (G, else I),
 * yf2: a section is open.  Texts and flags measured, meaning guessed.
 */
secbss()
{
	if (yf0)
		printf("$DATA\n$SECTION BSS_B\nI\n");
	else {
		printf("$SECTION BSS_B\nI\n");
		yf1 = 0;
	}
	yf2 = 1;
}

fphead()
{
	if (yf0)
		printf("$DATA\n$SECTION %s_d\nI\n", modname);
	else if (yf2) {
		printf("$SDEFAULT\n");
		yf2 = 0;
	}
	if (!yf0) {
		if (yf1)
			printf("G\n");
		else
			printf("I\n");
	}
	yf1 = 0;
}

fptail()
{
	if (yf0)
		printf("$CODE\n");
	else if (yf2)
		printf("$SDEFAULT\n");
	yf2 = 0;
}

geti()
{
	register i;

	i = getchar();
	i += getchar()<<8;
	return(i);
}

outname(s)
{
	register char *p, c;
	register n;

	p = s;
	n = 0;
	while (c = getchar()) {
		*p++ = c;
		n++;
	}
	do {
		*p++ = 0;
	} while (n++ < 8);
	return(s);
}

/*
 * Differs from V7 (original at 3DAE): Z8000 output; the function-result
 * buffer goes to a BSS section (secbss/fptail), the block copy is one
 * ldir, a structure result address is loaded into r2.
 */
strasg(atp)
struct fasgn *atp;
{
	register struct tnode *tp;
	register nwords;

	nwords = atp->mask/sizeof(int);
	tp = atp->tr1;
	if (tp->op != ASSIGN) {
		if (tp->op==RFORCE) {	/* function return */
			if (sfuncr.nloc==0) {
				sfuncr.nloc = isn++;
				secbss();
				printf("L%d:\n$REL	$+%%%x\n", sfuncr.nloc, nwords*sizeof(int));
				fptail();
			}
			atp->tr1 = tnode(ASSIGN, STRUCT, &sfuncr, tp->tr1);
			strasg(atp);
			printf("ld	r2,#L%d\n", sfuncr.nloc);
			return;
		}
		if (tp->op==CALL) {
			rcexpr(tp, efftab, 0);
			return;
		}
		error("Illegal structure operation");
		return;
	}
	tp->tr2 = strfunc(tp->tr2);
	if (nwords==1)
		setype(tp, INT);
	else if (nwords==sizeof(int))
		setype(tp, LONG);
	else {
		if (tp->tr1->op!=NAME && tp->tr1->op!=STAR
		 || tp->tr2->op!=NAME && tp->tr2->op!=STAR) {
			error("unimplemented structure assignment");
			return;
		}
		tp->tr1 = tnode(AMPER, STRUCT+PTR, tp->tr1);
		tp->tr2 = tnode(AMPER, STRUCT+PTR, tp->tr2);
		tp->op = STRSET;
		tp->type = STRUCT+PTR;
		tp = optim(tp);
		rcexpr(tp, efftab, 0);
		printf("ld	r0,#%%%x\n", nwords);
		printf("ldir	@r2,@r3,r0\n");
		return;
	}
	rcexpr(tp, efftab, 0);
}

setype(p, t)
register struct tnode *p;
register t;
{

	for (;; p = p->tr1) {
		p->type = t;
		if (p->op==AMPER)
			t = decref(t);
		else if (p->op==STAR)
			t = incref(t);
		else if (p->op==ASSIGN)
			setype(p->tr2, t);
		else if (p->op!=PLUS)
			break;
	}
}

/*
 * Reduce the degree-of-reference by one.
 * e.g. turn "ptr-to-int" into "int".
 */
decref(at)
{
	register t;

	t = at;
	if ((t & ~TYPE) == 0) {
		error("Illegal indirection");
		return(t);
	}
	return((t>>TYLEN) & ~TYPE | t&TYPE);
}

/*
 * Increase the degree of reference by
 * one; e.g. turn "int" to "ptr-to-int".
 */
incref(t)
{
	return(((t&~TYPE)<<TYLEN) | (t&TYPE) | PTR);
}
