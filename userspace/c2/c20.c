#
/*
 *	 C object code improver (MUTOS 8000 c2, Z8000), part one.
 *
 * Reconstructed from the MUTOS binary /usr/lib/c2 (functions 0030..151E), starting from
 * the V7 text original/unix-v7/usr/src/cmd/c/c20.c.  doc/userspace/wk_w5.md lists, per
 * function, what is V7 and what is not.  Names that V7 does not have are Annahme.
 */

#include "c2.h"

/* Not V7: condition names of the Z8000 'jp cc,L' form, (name, code) pairs (table at 0x4252) */
int conds[] {
	"eq",	JEQ,
	"ne",	JNE,
	"le",	JLE,
	"ge",	JGE,
	"lt",	JLT,
	"gt",	JGT,
	"c",	JLO,
	"ugt",	JHI,
	"ule",	JLOS,
	"uge",	JHIS,
	"pl",	JPL,
	"mi",	JMI,
	0,	0};

/* Differs from V7: Z8000 mnemonics (table at 0x4286, 76 entries) */
struct optab optab[] {
	"jr",	JBR,
	"jp\teq",	CBR | JEQ<<8,
	"jp\tne",	CBR | JNE<<8,
	"jp\tle",	CBR | JLE<<8,
	"jp\tge",	CBR | JGE<<8,
	"jp\tlt",	CBR | JLT<<8,
	"jp\tgt",	CBR | JGT<<8,
	"jp\tc",	CBR | JLO<<8,
	"jp\tugt",	CBR | JHI<<8,
	"jp\tule",	CBR | JLOS<<8,
	"jp\tuge",	CBR | JHIS<<8,
	"jp\tpl",	CBR | JPL<<8,
	"jp\tmi",	CBR | JMI<<8,
	"jr\teq",	CBRS | JEQ<<8,
	"jr\tne",	CBRS | JNE<<8,
	"jr\tle",	CBRS | JLE<<8,
	"jr\tge",	CBRS | JGE<<8,
	"jr\tlt",	CBRS | JLT<<8,
	"jr\tgt",	CBRS | JGT<<8,
	"jr\tc",	CBRS | JLO<<8,
	"jr\tugt",	CBRS | JHI<<8,
	"jr\tule",	CBRS | JLOS<<8,
	"jr\tuge",	CBRS | JHIS<<8,
	"jr\tpl",	CBRS | JPL<<8,
	"jr\tmi",	CBRS | JMI<<8,
	"jp",	JMP,
	"djnz",	SOB,
	"E",	EROU,
	"ld",	MOV,
	"ldk",	LDK,
	"ldir",	LDIR,
	"lddr",	LDDR,
	"clr",	CLR,
	"com",	COM,
	"inc",	INC,
	"dec",	DEC,
	"neg",	NEG,
	"test",	TST,
	"sra",	ASR,
	"sla",	ASL,
	"exts",	SXT,
	"cp",	CMP,
	"add",	ADD,
	"sub",	SUB,
	"or",	BIS,
	"and",	BIC,
	"set",	SET,
	"res",	RES,
	"bit",	BIT,
	"mult",	MUL,
	"mul",	MULS,
	"ldil",	LDIL,
	"cpfx",	CPFX,
	"cpzx",	CPZX,
	"setmode",	SETM,
	"resmode",	RESM,
	"ldctl",	LDCTL,
	"div",	DIV,
	"ex",	EX,
	"pop",	POP,
	"push",	PUSH,
	"srl",	SRL,
	"sll",	SLL,
	"sdl",	SDL,
	"sda",	ASH,
	"xor",	XOR,
	"$SECTION c_p",	TEXT,
	"$SECTION c_d",	DSEC,
	"$SECTION BSS_B",	BSS,
	"$CODE",	CODE,
	"!",	CMT,
	"$SDEFAULT",	SDEF,
	"$EVEN",	EVEN,
	"call",	CALL,
	"end c_",	END,
	0,	0};

char	revbr[] { JNE, JEQ, JGT, JLT, JGE, JLE, JHIS, JLOS, JHI, JLO, JMI, JPL };
int	isn	= 9000;
int	lastseg	= 32;

main(argc, argv)
char **argv;
{
	register int niter, maxiter, isend, c, nflag;
	extern end;

	if (argc>1 && argv[1][0]=='+') {
		argc--;
		argv++;
		debug++;
	}
	nflag = 0;
	if (argc>1 && argv[1][0]=='-') {
		argc--;
		argv++;
		nflag++;
	}
	if (argc>1) {
		if (freopen(argv[1], "r", stdin) == NULL) {
			fprintf(stderr, "C2: can't find %s\n", argv[1]);
			exit(1);
		}
	}
	if (argc>2) {
		if (freopen(argv[2], "w", stdout) == NULL) {
			fprintf(stderr, "C2: can't create %s\n", argv[2]);
			exit(1);
		}
	}
	lasta = firstr = lastr = sbrk(2);
	maxiter = 0;
	opsetup();
	/* Not V7: the first input line (up to ';') is passed through unchanged */
	do {
		c = getchar();
		putchar(c);
	} while (c != ';');
	getchar();
	putchar('\n');
	do {
		isend = input();
		niter = 0;
		/* Differs from V7: no movedat(), no jumpsw(); retopt(); shortjmp() loop */
		do {
			refcount();
			do {
				iterate();
				niter++;
			} while (nchange);
			clearreg();
			comjump();
			if (retopt())
				break;
			rmove();
		} while (nchange);
		addsob();
		do {
			shortjmp();
		} while (nchange);
#ifdef XCMPMEM
		cmppass();	/* c2x -xcmpmem: R0 reuse behind a short jr cc (R38) */
#endif
#ifdef XHZERO
		hzpass();	/* c2x -xhzero: late deletion of dead xorb (rule R2) */
#endif
		output();
		if (niter > maxiter)
			maxiter = niter;
		lasta = firstr;
	} while (isend);
	if (nflag) {
		fprintf(stderr, "%d iterations\n", maxiter);
		fprintf(stderr, "%d jumps to jumps\n", nbrbr);
		fprintf(stderr, "%d inst. after jumps\n", iaftbr);
		fprintf(stderr, "%d jumps to .+2\n", njp1);
		fprintf(stderr, "%d redundant labels\n", nrlab);
		fprintf(stderr, "%d cross-jumps\n", nxjump);
		fprintf(stderr, "%d code motions\n", ncmot);
		fprintf(stderr, "%d branches reversed\n", nrevbr);
		fprintf(stderr, "%d redundant moves\n", redunm);
		fprintf(stderr, "%d simplified addresses\n", nsaddr);
		fprintf(stderr, "%d loops inverted\n", loopiv);
		fprintf(stderr, "%d redundant jumps\n", nredunj);
		fprintf(stderr, "%d common seqs before jmp's\n", ncomj);
		fprintf(stderr, "%d skips over jumps\n", nskip);
		fprintf(stderr, "%d sob's added\n", nsob);
		fprintf(stderr, "%d redundant tst's\n", nrtst);
		fprintf(stderr, "%d literals eliminated\n", nlit);
		fprintf(stderr, "%dK core\n", (((int)lastr+01777)>>10)&077);
	}
	exit(0);
}

input()
{
	register struct node *p, *lastp;
	register int oper;
	register char *cp, *s, *np;
	int *cc;
	static char cbuf[10];

	lastp = &first;
	for (;;) {
		oper = getline();
		switch (oper&0377) {

		default:
			p = (struct node *)alloc(sizeof first);
			p->op = oper&0377;
			p->subop = oper>>8;
			if (fflag && (p->subop & FLTF) == 0)
				p->subop = FLTF;
			p->labno = 0;
			p->code = copy(1, curlp);
			break;

		case LABEL:
			p = (struct node *)alloc(sizeof first);
			if (line[0] == 'L') {
				p->op = LABEL;
				p->subop = 0;
				p->labno = getnum(line+1);
				p->code = 0;
			} else {
				p->op = DLABEL;
				p->subop = 0;
				p->labno = 0;
				p->code = copy(1, line);
			}
			break;

		/* Not V7: comment lines ('!' ...) are kept as op 0 nodes with their text */
		case CMT:
			p = (struct node *)alloc(sizeof first);
			p->op = 0;
			p->subop = 0;
			p->labno = 0;
			p->code = copy(1, line);
			break;

		/* Differs from V7: the condition is split off the 'jp cc,L' operand (conds[]) */
		case JBR:
		case JMP:
		case JSW:
			p = (struct node *)alloc(sizeof first);
			p->op = oper&0377;
			p->subop = 0;
			if (*curlp != 'L') {
				np = cbuf;
				for (cp = curlp; *cp; ) {
					if (*cp=='\t' || *cp==' ' || *cp==',' || *cp=='\n')
						break;
					*np++ = *cp++;
				}
				*np++ = 0;
				for (cc = conds; *cc != 0; cc += 2) {
					s = *cc;
					np = cbuf;
					while (*s++ == *np)
						if (*np++ == 0) {
							p->subop = cc[1];
							p->op -= 2;
							curlp = ++cp;
							goto done;
						}
				}
			}
		done:
			if (*curlp=='L' && (p->labno = getnum(curlp+1)))
				p->code = 0;
			else {
				p->labno = 0;
				p->code = copy(1, curlp);
			}
			break;

		}
		p->forw = 0;
		p->back = lastp;
		lastp->forw = p;
		lastp = p;
		p->ref = 0;
		if (oper==EROU)
			return(1);
		if (oper==END)
			return(0);
	}
}

getline()
{
	register char *lp;
	register c;

	fflag = 0;
	lp = line;
	while ((c = getchar())==' ' || c=='\t')
		;
	/* Not V7: a leading 'f' marks a floating-point instruction */
	if (c=='f') {
		fflag++;
		c = getchar();
	}
	do {
		/* Not V7: comment lines start with '!' or '~' and run to the end of the line */
		if (c=='!' || c=='~') {
			do {
				*lp++ = c;
				c = getchar();
			} while (c != '\n');
			*lp++ = 0;
			return(CMT);
		}
		if (c==':') {
			getchar();
			*lp++ = 0;
			return(LABEL);
		}
		if (c=='\n') {
			*lp++ = 0;
			return(oplook());
		}
		if (lp >= &line[LSIZE-2]) {
			fprintf(stderr, "C2: Sorry, input line too long\n");
			exit(1);
		}
		*lp++ = c;
	} while ((c = getchar()) != EOF);
	*lp++ = 0;
	return(END);
}

getnum(ap)
char *ap;
{
	register char *p;
	register n, c;

	p = ap;
	n = 0;
	while ((c = *p++) >= '0' && c <= '9')
		n = n*10 + c - '0';
	if (*--p != 0)
		return(0);
	return(n);
}

/* Differs from V7: labels and DLABELs end in a newline, the segment ids differ, no reducelit() */
output()
{
	register struct node *t;
	register struct optab *oper;
	register int byte;

	t = &first;
	while (t = t->forw) switch (t->op) {

	case END:
		return;

	case LABEL:
		printf("L%d:\n", t->labno);
		continue;

	case DLABEL:
		printf("%s:\n", t->code);
		continue;

	case SDEF:
	case DSEC:
		lastseg = DATA;
		goto dflt;

	case BSS:
		lastseg = BSS;
		goto dflt;

	case TEXT:
	case CODE:
	case EROU:
		lastseg = CODE;

	default:
	dflt:
		if ((byte = t->subop) == BYTE || byte == LONG || (byte & FLTF))
			t->subop = 0;
		if (byte & FLTF)
			putchar('f');
		for (oper = optab; oper->opstring!=0; oper++)
			if ((oper->opcode&0377) == t->op
			 && (oper->opcode>>8) == t->subop) {
				printf("%s", oper->opstring);
				if (byte==BYTE)
					putchar('b');
				else if (byte==LONG)
					putchar('l');
				else if (byte==SINGLE)
					putchar('s');
				else if (byte==DOUBLE)
					putchar('d');
				break;
			}
		if (t->code) {
			printf("\t%s\n", t->code);
		} else if (t->op<=JMP)
			printf("\tL%d\n", t->labno);
		else
			printf("\n");
		continue;

	case JSW:
		printf("WV L%d\n", t->labno);
		continue;

	case SOB:
		printf("djnz\t%s", t->code);
		if (t->labno)
			printf(",L%d\n", t->labno);
		continue;

	case 0:
		if (t->code)
			printf("%s", t->code);
		printf("\n");
		continue;
	}
}

char *
copy(na, ap)
char *ap;
{
	register char *p, *np, *onp;
	register n;

	p = ap;
	n = 0;
	if (*p==0)
		return(0);
	do
		n++;
	while (*p++);
	if (na>1) {
		p = (&ap)[1];
		while (*p++)
			n++;
	}
	onp = np = alloc(n);
	p = ap;
	while (*np++ = *p++)
		;
	if (na>1) {
		p = (&ap)[1];
		np--;
		while (*np++ = *p++);
	}
	return(onp);
}

opsetup()
{
	register struct optab *optp, **ophp;
	register char *p;

	for (optp = optab; p = optp->opstring; optp++) {
		ophp = &ophash[(((p[0]<<3)+(p[1]<<1)+p[2])&077777) % OPHS];
		while (*ophp++)
			if (ophp > &ophash[OPHS])
				ophp = ophash;
		*--ophp = optp;
	}
}

/* Differs from V7: suffixes b/l/s/d of ld, cp, or, ex; 'WV Ln' is the jump switch word */
oplook()
{
	register struct optab *optp;
	register char *lp, *np;
	static char tmpop[32];
	register struct optab **ophp;
	char c;

	if (line[0]=='\0') {
		curlp = line;
		return(0);
	}
	np = tmpop;
	for (lp = line; *lp && *lp!=' ' && *lp!='\t';)
		*np++ = *lp++;
	*np++ = 0;
	while (*lp=='\t' || *lp==' ')
		lp++;
	curlp = lp;
	if ((c = tmpop[2])=='b' || c=='l' || c=='s' || c=='d') {
		if ((tmpop[0]=='l' && tmpop[1]=='d')
		 || (tmpop[0]=='c' && tmpop[1]=='p')
		 || (tmpop[0]=='o' && tmpop[1]=='r')
		 || (tmpop[0]=='e' && tmpop[1]=='x'))
			tmpop[2] = 0;
	}
	ophp = &ophash[(((tmpop[0]<<3)+(tmpop[1]<<1)+tmpop[2])&077777) % OPHS];
	tmpop[2] = c;
	while (optp = *ophp) {
		np = optp->opstring;
		lp = tmpop;
		while (*np++ == *lp)
			if (*lp++ == 0)
				return(optp->opcode);
		c = *lp++;
		if ((c=='b' || c=='l' || c=='s' || c=='d') && *lp++==0 && *--np==0) {
			if (c=='b')
				return(optp->opcode + (BYTE<<8));
			else if (c=='l')
				return(optp->opcode + (LONG<<8));
			else if (c=='s')
				return(optp->opcode + (SINGLE<<8));
			else
				return(optp->opcode + (DOUBLE<<8));
		}
		ophp++;
		if (ophp >= &ophash[OPHS])
			ophp = ophash;
	}
	if (line[0]=='W' && line[3]=='L') {
		lp = &line[4];
		while (*lp)
			if (*lp<'0' || *lp++>'9')
				return(0);
		curlp = &line[3];
		return(JSW);
	}
	curlp = line;
	return(0);
}

/* Differs from V7: also deletes 'I'/'G' declaration pseudo lines (delnode) */
refcount()
{
	register struct node *p, *lp;
	static struct node *labhash[LABHS];
	register struct node **hp, *tp;

	for (hp = labhash; hp < &labhash[LABHS];)
		*hp++ = 0;
	for (p = first.forw; p!=0; p = p->forw)
		if (p->op==0 && p->code && *p->code=='I'
		 && (p->forw->op==END
		  || (p->forw->op==0 && p->forw->code
		   && (*p->forw->code=='G' || *p->forw->code=='I')))) {
			delnode(p);
			p = p->forw;
		} else if (p->op==LABEL) {
			labhash[p->labno % LABHS] = p;
			p->refc = 0;
		}
	for (p = first.forw; p!=0; p = p->forw) {
		if (p->op<=JSW) {
			p->ref = 0;
			lp = labhash[p->labno % LABHS];
			if (lp==0 || p->labno!=lp->labno)
			for (lp = first.forw; lp!=0; lp = lp->forw) {
				if (lp->op==LABEL && p->labno==lp->labno)
					break;
			}
			if (lp) {
				tp = nonlab(lp)->back;
				if (tp!=lp) {
					p->labno = tp->labno;
					lp = tp;
				}
				p->ref = lp;
				lp->refc++;
			}
		}
	}
	for (p = first.forw; p!=0; p = p->forw)
		if (p->op==LABEL && p->refc==0
		 && (lp = nonlab(p))->op && lp->op!=JSW)
			decref(p);
}

/* Differs from V7: jr/jp pairs (JBR/JMP, CBRS/CBR), delnode(), jump-to-next removal */
iterate()
{
	register struct node *p, *rp, *p1;

	nchange = 0;
	for (p = first.forw; p!=0; p = p->forw) {
		if (p->op<=JSW) {
			rp = nonlab(p->ref);
			if ((rp->op==JBR || rp->op==JMP) && rp->labno && p->labno!=rp->labno) {
				nbrbr++;
				p->labno = rp->labno;
				decref(p->ref);
				rp->ref->refc++;
				p->ref = rp->ref;
				nchange++;
			}
		}
		if (p->op<=CBR && ((p1 = p->forw)->op==JBR || p1->op==JMP) && p1->labno) {
			rp = p->ref;
			do
				rp = rp->back;
			while (rp->op==LABEL);
			if (rp==p1) {
				decref(p->ref);
				p->ref = p1->ref;
				p->labno = p1->labno;
				p1->forw->back = p;
				p->forw = p1->forw;
				p->subop = revbr[p->subop];
				nchange++;
				nskip++;
			}
		}
		if (p->op<=CBR && (p1 = p->forw)->op<=CBR && p->labno==p1->labno
		 && revbr[p1->subop]==p->subop) {
			delnode(p1);
			p->subop = 0;
			p->op += 2;
			nchange++;
		}
		if (p->op==JBR || p->op==JMP) {
			while (p->forw && p->forw->op!=LABEL
				&& p->forw->op!=DLABEL
				&& p->forw->op!=EROU && p->forw->op!=END
				&& p->forw->op!=0 && p->forw->op!=DATA) {
				nchange++;
				iaftbr++;
				if (p->forw->ref)
					decref(p->forw->ref);
				p->forw = p->forw->forw;
				p->forw->back = p;
			}
			rp = p->forw;
			while (rp && rp->op==LABEL) {
				if (p->ref == rp) {
					delnode(p);
					p = p->back;
					decref(rp);
					nchange++;
					njp1++;
					break;
				}
				rp = rp->forw;
			}
		}
		if (p->op==JBR || p->op==JMP) {
			xjump(p);
			p = codemove(p);
		}
		if (p->op<JSW && p->ref == p->forw) {
			decref(p->forw);
			delnode(p);
			p = p->back;
			nchange++;
		}
	}
}

xjump(p1)
register struct node *p1;
{
	register struct node *p2, *p3;

	if ((p2 = p1->ref)==0)
		return;
	for (;;) {
		while ((p1 = p1->back) && p1->op==LABEL);
		while ((p2 = p2->back) && p2->op==LABEL);
		if (!equop(p1, p2) || p1==p2)
			return;
		if (p1->op>=CODE && p1->op<=CMT)
			return;
		p3 = insertl(p2);
		p1->op = JMP;
		p1->subop = 0;
		p1->ref = p3;
		p1->labno = p3->labno;
		p1->code = 0;
		nxjump++;
		nchange++;
	}
}

struct node *
insertl(oldp)
register struct node *oldp;
{
	register struct node *lp;

	if (oldp->op == LABEL) {
		oldp->refc++;
		return(oldp);
	}
	if (oldp->back->op == LABEL) {
		oldp = oldp->back;
		oldp->refc++;
		return(oldp);
	}
	lp = (struct node *)alloc(sizeof first);
	lp->op = LABEL;
	lp->subop = 0;
	lp->labno = isn++;
	lp->ref = 0;
	lp->code = 0;
	lp->refc = 1;
	lp->back = oldp->back;
	lp->forw = oldp;
	oldp->back->forw = lp;
	oldp->back = lp;
	return(lp);
}

struct node *
codemove(p)
struct node *p;
{
	register struct node *p1, *p2, *p3, *t, *tl;
	register n;

	p1 = p;
	if ((p1->op!=JMP && p1->op!=JBR) || (p2 = p1->ref)==0)
		return(p1);
	while (p2->op == LABEL)
		if ((p2 = p2->back) == 0)
			return(p1);
	if (p2->op!=JBR && p2->op!=JMP)
		goto ivloop;
	p2 = p2->forw;
	p3 = p1->ref;
	while (p3) {
		if (p3->op==JBR || p3->op==JMP) {
			if (p1==p3)
				return(p1);
			ncmot++;
			nchange++;
			p1->back->forw = p2;
			p1->forw->back = p3;
			p2->back->forw = p3->forw;
			p3->forw->back = p2->back;
			p2->back = p1->back;
			p3->forw = p1->forw;
			decref(p1->ref);
			return(p2);
		} else
			p3 = p3->forw;
	}
	return(p1);
ivloop:
	if (p1->forw->op!=LABEL)
		return(p1);
	p3 = p2 = p2->forw;
	n = 16;
	do {
		if ((p3 = p3->forw) == 0 || p3==p1 || --n==0)
			return(p1);
	} while ((p3->op && p3->op>CBR) || p3->labno!=p1->forw->labno);
	do
		if ((p1 = p1->back) == 0)
			return(p);
	while (p1!=p3);
	p1 = p;
	tl = insertl(p1);
	p3->subop = revbr[p3->subop];
	decref(p3->ref);
	p2->back->forw = p1;
	p3->forw->back = p1;
	p1->back->forw = p2;
	p1->forw->back = p3;
	t = p1->back;
	p1->back = p2->back;
	p2->back = t;
	t = p1->forw;
	p1->forw = p3->forw;
	p3->forw = t;
	p2 = insertl(p1->forw);
	p3->labno = p2->labno;
	p3->ref = p2;
	decref(tl);
	if (tl->refc<=0)
		nrlab--;
	loopiv++;
	nchange++;
	return(p3);
}

comjump()
{
	register struct node *p1, *p2, *p3;

	for (p1 = first.forw; p1!=0; p1 = p1->forw)
		if ((p1->op==JBR || p1->op==JMP) && (p2 = p1->ref) && p2->refc > 1)
			for (p3 = p1->forw; p3!=0; p3 = p3->forw)
				if (p3->op>=JBR && p3->op<=JMP && p3->ref == p2)
					backjmp(p1, p3);
}

/* Not V7: 'jp' becomes 'jr' when the target is near enough (toofar) */
shortjmp()
{
	register struct node *p;

	nchange = 0;
	for (p = first.forw; p!=0; p = p->forw)
		if ((p->op==JMP || p->op==CBR) && p->labno && !toofar(p, 0)) {
			p->op--;
			nchange++;
		}
}

backjmp(ap1, ap2)
struct node *ap1, *ap2;
{
	register struct node *p1, *p2, *p3;

	p1 = ap1;
	p2 = ap2;
	for(;;) {
		while ((p1 = p1->back) && p1->op==LABEL);
		p2 = p2->back;
		if (equop(p1, p2)) {
			p3 = insertl(p1);
			delnode(p2);
			p2 = p2->forw;
			decref(p2->ref);
			p2->labno = p3->labno;
			p2->ref = p3;
			nchange++;
			ncomj++;
		} else
			return;
	}
}

/* Not V7: 'call csv ; ... ; jp cret' is replaced by 'ret' (returns 1 on success) */
retopt()
{
	register struct node *p, *q;

	for (p = first.forw; p!=0; p = p->forw)
		if (p->op==CALL && equstr(p->code, "csv"))
			break;
	for (q = p->forw; q->op==0 && *q->code=='!'; q = q->forw)
		;
	if (q->op==JMP && equstr(q->code, "cret")) {
		delnode(p);
		q->op = 0;
		q->code = "ret";
		return(1);
	}
	return(0);
}
