#
/*
 *	 C object code improver (MUTOS 8000 c2, Z8000), part two.
 *
 * Reconstructed from the MUTOS binary /usr/lib/c2 (functions 0x151E..0x3590), starting
 * from the V7 text original/unix-v7/usr/src/cmd/c/c21.c.  doc/userspace/wk_w5.md lists,
 * per function, what is V7 and what is not.  Names that V7 does not have are Annahme.
 *
 * rmove (0x151E) is still a STUB (part d): it only reproduces the string pool and the
 * jump table of the original so that data addresses line up.
 */

#include "c2.h"

extern char revbr[];

/*
 * Differs from V7: Z8000 operand order (destination first, so RT1 is the destination),
 * 38 register slots (two banks), the size of every operand is tracked in rsz[], flt is
 * 0 or FREG per bank.  Reconstructed from the binary (0x151E); case groups follow the
 * jump table at 0x4778.  Variable names are Annahme.  flt is the bank of the
 * destination, fl2 the bank of the source operand.
 */
#ifdef C2X
int	x4keep = 0;	/* regs[0] holds the MEM of an inserted `ld r0,MEM` (set in rmove, cleared by kill(0)) */
#define	X4MARK	-4	/* -xcmpmem: labno of the `ld r0,MEM` nodes inserted for a `cp MEM,#k`; they keep MEM (no register copy propagation; cat, od measured) */
#endif
rmove()
{
	register struct node *p;
	register char *cp;
	register r, r1, flt, i;
	int fl2;

	for (p = first.forw; p != 0; p = p->forw) {
	if (p->subop & FLTF)
		flt = FREG;
	else
		flt = 0;
	fl2 = flt;
	switch (p->op) {

	case LDIL:
		dualop(p);
		if (rsz[RT2] == 'r')
			fl2 = 0;
		else
			flt = 0;
		goto mv;

	case MOV:
	case LDK:
		dualop(p);
		if (!equstr(regs[RT1], regs[RT2]))
			goto mv;
		goto del;
	mv:
		if ((r = findrand(regs[RT2], rsz[RT2], fl2)) >= 0
		 && rsz[r+fl2] == rsz[RT2] && isreg(regs[RT1]) == r
#ifdef C2X
		 /* W10k: a repeated inserted `ld r0,MEM` goes only when R0 came from an inserted one (x4keep), not from an ordinary `ld r0,MEM` (tar) */
		 && (p->labno != X4MARK || x4keep)
#endif
		 && rsz[r+flt] == rsz[RT1]) {
		del:
			delnode(p);
			redunm++;
			continue;
		}
		if ((r = findrand(regs[RT1], rsz[RT1], flt)) >= 0
		 && rsz[r+flt] == rsz[RT1] && isreg(regs[RT2]) == r
		 && rsz[r+fl2] == rsz[RT2])
			goto del;
		if (flt == fl2) {
		l163a:
			r = isreg(regs[RT1]);
			if (r >= 0 && rnode[r+flt] != 0 && rsz[r+flt] == rsz[RT1]) {
				delnode(rnode[r+flt]);
				kill(r+flt, rsz[RT1]);
				if (isreg(ccloc) == r+flt)
					clrcc();
			}
			if (p->op == CLR || equstr(regs[RT2], "#0")) {
				if (p->subop != LONG && (p->subop & FLTF) == 0
				 && isreg(regs[RT1]) >= 0) {
					p->op = XOR;
					regs[RT2][0] = ',';
					i = 0;
					do
						regs[RT2][i+1] = regs[RT1][i];
					while (regs[RT1][i++]);
					p->code = copy(2, regs[RT1], regs[RT2]);
					nchange++;
					continue;
				}
			}
#ifdef C2X
			if (p->op != LDK && p->labno != X4MARK) {
#else
			if (p->op != LDK) {
#endif
				repladdr(p, 0, flt);
				dualop(p);
			}
		}
		r = isreg(ccloc);
		r1 = isreg(regs[RT1]);
		if ((r < 0 && r1 < 0) || (r == r1 && ccsz == rsz[RT1])
		 || (ccsz == 'r' && (r1 & ~1) == r)
		 || (rsz[RT1] == 'r' && (r & ~1) == r1))
			clrcc();
		r = isreg(regs[RT2]);
		dest(regs[RT1], rsz[RT1], flt);
		if (r1 < 0)
			clrptr(regs[RT1], rsz[RT1], flt);
		clrptr(regs[RT2], rsz[RT2], fl2);
		if (r >= 0) {
			if (r1 >= 0) {
				if (r1 < r)
					savereg(r1+flt, regs[RT2], rsz[RT2], p);
				else
					savereg(r1+flt, regs[r], rsz[r], p);
			} else if (regs[r+fl2][0] == 0)
				savereg(r+fl2, regs[RT1], rsz[RT1], 0);
			else {
				if (fl2)
					continue;
				savereg(r+14, regs[RT1], rsz[RT1], 0);
			}
		} else if (r1 >= 0)
#ifdef C2X
		{	/* braces only here: the default c2 stays token-identical (c2gegen.py tokcheck) */
			savereg(r1+flt, regs[RT2], rsz[RT2], p);
			if (p->labno == X4MARK && r1 == 0 && flt == 0)
				x4keep = 1;
		}
#else
			savereg(r1+flt, regs[RT2], rsz[RT2], p);
#endif
		else
			setcon(regs[RT2], regs[RT1], rsz[RT1]);
		continue;

	case INC:
	case DEC:
	case ASR:
	case ASL:
	case SET:
	case RES:
	case SRL:
	case SLL:
		dualop(p);
		if (p->op == INC && equstr(regs[RT1], "SP") && p->forw
		 && p->forw->op == PUSH && regs[RT2][0] == '#') {
			dualop(p->forw);
			if (regs[RT2][0] == 'r' || regs[RT2][0] == '#') {
				dualop(p);
				r1 = atoh(regs[RT2][1] == '%' ? &regs[RT2][2] : &regs[RT2][1]);
				if (p->forw->subop == LONG && r1 > 3)
					r1 -= 4;
				else if (r1 > 1 && p->forw->subop != LONG)
					r1 -= 2;
				else
					goto dflt;
/* c2x -xpush (W10f): with run-time flag p (XR1) keeps `inc SP,#n+2 ; push` unmerged unless the inc vanishes (r1 == 0); compiled only under C2X, off without the flag */
#ifdef C2X
				if ((xfl & XR1) && r1 != 0)
					goto dflt;
#endif
				if (r1 == 0)
					delnode(p);
				else
					sprintf(regs[RT2], ",#%%%x", r1);
				p->forw->op = MOV;
				p->code = copy(2, regs[RT1], regs[RT2]);
				redunm++;
				continue;
			}
		}
	dflt:
		dualop(p);
		dest(regs[RT1], rsz[RT1], flt);
		clrptr(regs[RT2], rsz[RT2], flt);
		clrptr(regs[RT1], rsz[RT1], flt);
		if (p->op == SET || p->op == RES || p->op == PUSH || p->op == POP) {
		clrc:
			clrcc();
			continue;
		}
		goto setc;

	case ADD:
	case SUB:
	case BIS:
	case SDL:
	case MUL:
	case DIV:
	case ASH:
	case XOR:
	case MULS:
	case POP:
	case PUSH:
	dble:
		dualop(p);
		if (p->op == POP && (r = isreg(regs[RT1])) >= 0 && rnode[r] != 0
		 && rsz[r] == rsz[RT1]) {
			delnode(rnode[r]);
			kill(r, rsz[RT1]);
			if (isreg(ccloc) == r)
				clrcc();
		}
		if (p->op == BIS && regs[RT2][0] == '#' && p->subop == 0) {
			cp = &regs[RT2][1];
			if (*cp == '%')
				cp++;
			if ((i = log2n(atoh(cp))) >= 0) {
				p->op = SET;
			shft:
				mkshift(p, i);
				clrcc();
				nchange++;
				continue;
			}
		}
		if (p->op == XOR && (r = isreg(regs[RT1])) >= 0
		 && equstr(regs[RT1], regs[RT2])) {
			if (rnode[r] && rsz[r] == rsz[RT1]) {
				delnode(rnode[r]);
				kill(r, rsz[RT1]);
				if (isreg(ccloc) == r)
					clrcc();
			}
#ifdef C2X
			/* c2x -xhzero (R3, R7, R10, R32): the older c2 does not drop this xorb as redundant (hzkeep) */
			if (rsz[RT1] == 'h' && (xfl & (XR7 | XR3 | XR10 | XR32)) && hzkeep(p, r))
				goto hzset;
#endif
			if (rsz[r] == rsz[RT1]) {
				if (rsz[r] != 'h' && equstr(regs[r], "#0"))
					goto del;
				if (rsz[r] == 'h' && equstr(cregs[r], "#0"))
					goto del;
			}
			if (rsz[r] == 'l' && rsz[RT1] == 'h' && equstr(cregs[r], "#0"))
				goto del;
			if (rsz[r] == 'h' && rsz[RT1] == 'l' && equstr(regs[r], "#0"))
				goto del;
#ifdef C2X
		hzset:
#endif
			if (rsz[RT1] == 'h') {
				if (rsz[r] != 'l')
					kill(r, 'h');
				cregs[r][0] = '#';
				cregs[r][1] = '0';
				cregs[r][2] = 0;
				rnode[r] = p;
			} else {
				savereg(r+flt, "#0", rsz[RT1], p);
				goto setc;
			}
		setc:
			setcc(regs[RT1], rsz[RT1]);
			continue;
		}
		repladdr(p, 0, flt);
		dualop(p);
		dest(regs[RT1], rsz[RT1], flt);
		clrptr(regs[RT2], rsz[RT2], flt);
		clrptr(regs[RT1], rsz[RT1], flt);
		goto setc;

	case NEG:
		if (p->subop & FLTF)
			goto dble;
	case CLR:
	case COM:
	case SXT:
		singop(p);
		if (p->op == CLR) {
			if ((r = isreg(regs[RT1])) >= 0)
				goto l163a;
			setcon("#0", regs[RT1], rsz[RT1]);
		}
		dest(regs[RT1], rsz[RT1], flt);
		clrptr(regs[RT1], rsz[RT1], flt);
		if (p->op == CLR)
			goto clrc;
		goto setc;

	case TST:
	case CPZX:
		singop(p);
	tst2:
		repladdr(p, 1, flt);
		singop(p);
		if ((ccsz == rsz[RT1] && equstr(regs[RT1], ccloc))
		 || (p->forw && p->forw->op > CBR)) {
			delnode(p);
			nrtst++;
		} else
			setcc(regs[RT1], rsz[RT1]);
		clrptr(regs[RT1], rsz[RT1], flt);
		continue;

	case CMP:
	case CPFX:
	case BIT:
		if (p->forw->op > CBR) {
			delnode(p);
			continue;
		}
/* c2x -xcmpmem (W10g): with run-time flag c (XR4) loads a memory operand of a word `cp MEM,#k` into R0 first (`ld r0,MEM ; cp r0,#k`), as the older c2 of the
   original programs did; the new MOV node then runs through the register tracking (a second `cp MEM,#k` behind a jr cc reuses R0).
   Only compiled under C2X, off unless -xc is given. */
#ifdef C2X
		if ((xfl & XR4) && p->op == CMP && (p->subop & (BYTE | LONG | FLTF)) == 0) {
			dualop(p);
			if (regs[RT2][0] == '#' && regs[RT1][0] != '@' && isreg(regs[RT1]) < 0) {
				struct node *np;

				np = (struct node *)alloc(sizeof first);
				np->op = MOV;
				np->subop = 0;
				np->labno = X4MARK;
				np->code = copy(2, "r0,", regs[RT1]);
				np->forw = p;
				np->back = p->back;
				p->back->forw = np;
				p->back = np;
				p->code = copy(2, "r0,", regs[RT2]);
				p = np->back;
				nchange++;
				continue;
			}
		}
#endif
	case BIC:
		dualop(p);
		if (p->op == BIC && regs[RT2][0] == '#' && p->subop == 0) {
			cp = &regs[RT2][1];
			if (*cp == '%')
				cp++;
			if ((i = log2n(~atoh(cp))) >= 0) {
				p->op = RES;
				goto shft;
			}
		}
		if (p->op == BIC) {
			if (equstr(regs[RT2], "#%ffff") || equstr(regs[RT2], "#-%1")) {
				p->op = TST;
				regs[RT2][0] = 0;
				rsz[RT2] = 0;
				p->code = copy(1, regs[RT1]);
				nchange++;
				nsaddr++;
				goto tst2;
			}
			if (equstr(regs[RT2], "#%0")) {
				p->op = CLR;
				regs[RT2][0] = 0;
				rsz[RT2] = 0;
				p->code = copy(1, regs[RT1]);
				nchange++;
				nsaddr++;
				goto l163a;
			}
			dest(regs[RT1], rsz[RT1], flt);
		}
		if (p->op != BIT && (p->op != CMP || regs[RT2][0] != '#')) {
			repladdr(p, 1, flt);
			dualop(p);
		}
		if (p->op != BIC)
			clrcc();
		else
			setcc(regs[RT1], rsz[RT1]);
		clrptr(regs[RT1], rsz[RT1], flt);
		clrptr(regs[RT2], rsz[RT2], flt);
		continue;

	case CBRS:
	case CBR:
		if (p->back->op == TST || p->back->op == CMP) {
			if (p->back->op == TST) {
				singop(p->back);
				savereg(RT2, "#0", rsz[RT1], p->back);
			} else
				dualop(p->back);
			r = compare(p->subop, findcon(RT1), findcon(RT2));
			if (r == 0) {
				if (p->forw->op <= CBR)
					delnode(p);
				else {
					p->back->back->forw = p->forw;
					p->forw->back = p->back->back;
				}
				clrcc();
				decref(p->ref);
				p = p->back->back;
				nchange++;
			} else if (r > 0) {
				p->op += 2;
				p->subop = 0;
				p->back->back->forw = p;
				p->back = p->back->back;
				p = p->back;
				nchange++;
			}
		}

	case JBR:
	case JMP:
		redunbr(p);
		clrptr30();
		continue;

	case EROU:
	case CALL:
	case END:
		for (r = 0; r < 8; r++)
			if (rnode[r] != 0 && regs[r][0] == 'r') {
				delnode(rnode[r]);
				if (isreg(ccloc) == r)
					clrcc();
			}

	default:
		clearreg();
	}
	}
}

/*
 * Not V7 in this form: V7 jumpsw is the same idea; the MUTOS binary still contains it
 * (0x20EC) but nothing calls it.  Differs from V7: ops are tested by range (CBR is 1/2,
 * JBR/JMP are 3/4), and branches without a label number are left alone.
 */
jumpsw()
{
	register struct node *p, *p1;
	register t;
	register struct node *tp;
	register nj;

	t = 0;
	nj = 0;
	for (p = first.forw; p != 0; p = p->forw)
		p->refc = ++t;
	for (p = first.forw; p != 0; p = p1) {
		p1 = p->forw;
		if (p->op <= CBR && p1->op >= JBR && p1->op <= JMP && p->ref && p1->ref
		 && abs(p->refc - p->ref->refc) > abs(p1->refc - p1->ref->refc)) {
			if (p->ref == p1->ref || !p->labno || !p1->labno)
				continue;
			p->subop = revbr[p->subop];
			tp = p1->ref;
			p1->ref = p->ref;
			p->ref = tp;
			t = p1->labno;
			p1->labno = p->labno;
			p->labno = t;
			nrevbr++;
			nj++;
		}
	}
	return(nj);
}

/*
 * Not V7: the MUTOS version does three things in one pass: it removes an instruction
 * that repeats the one before (same op, same operand), it removes a test that follows
 * an instruction that sets the condition codes itself (and folds the branch after
 * a clr), and it makes djnz from dec + jp ne (this part is V7 addsob).
 * The case values are measured from the hash switch (op*3 buckets); names Annahme.
 */
addsob()
{
	register struct node *p, *p1;

	for (p = &first; (p1 = p->forw) != 0; p = p1) {
		switch (p->op) {
		case MOV:
		case CLR:
		case TST:
		case CMP:
		case BIS:
		case BIC:
		case CPZX:
		case CPFX:
		case SET:
		case RES:
		case BIT:
		case LDK:
			p1 = nonlab(p->forw);
			if (p1->op == p->op && equstr(p->code, p1->code)) {
				delnode(p);
				p = p->back;
				if (!(p1 = p->forw))
					return;
			}
		}
		if (p1->op == TST || p1->op == CPZX) {
			switch (p->op) {
			case CLR:
				if (p1->forw > 2)
					break;
				if (!equstr(p->code, p1->code))
					break;
				switch (p1->subop) {
				case JNE:
				case JGT:
				case JHI:
					delnode(p1->forw);
					delnode(p1);
					if (!(p1 = p->forw))
						return;
				case JEQ:
				case JLE:
				case JLOS:
					p = p1->forw;
					delnode(p1);
					p->op += 2;
					p->subop = 0;
					if (p == 0)
						return;
				case JGE:
				case JLT:
				case JLO:
				default:
					;
				}
			case COM:
			case INC:
			case DEC:
			case NEG:
				if (equstr(p->code, p1->code)) {
					delnode(p1);
					nrtst++;
					if ((p1 = p1->forw) == 0)
						return;
				}
			}
		}
		if ((p->op == TST || p->op == CPZX) && p1->op > CBR) {
			delnode(p);
			nrtst++;
			continue;
		}
		if (p->op == DEC && isreg(p->code) >= 0
		 && p1->op == CBR && p1->subop == JNE) {
			if (p->refc < p1->ref->refc)
				continue;
			if (toofar(p1, 1))
				continue;
			dualop(p);
			p->code = copy(1, regs[RT1]);
			p->labno = p1->labno;
			p->op = SOB;
			p->subop = 0;
			p1->forw->back = p;
			p->forw = p1->forw;
			nsob++;
		}
	}
}

/*
 * V7 toofar with a flag: a forward jump (flag set) is always "too far"; the limit is
 * 254 bytes (jr range), measured over the instruction lengths of ilen.
 */
toofar(ap, flag)
struct node *ap;
{
	register struct node *p, *p1;
	register len;

	p = ap;
	for (p1 = first.forw; p1 != p; p1 = p1->forw)
		if (p1 == p->ref)
			break;
	if (p1 == p->ref) {
		p = p1;
		p1 = ap->forw;
	} else {
		if (flag)
			return(1);
		p1 = p->ref;
	}
	len = 0;
	for (;;) {
		p = p->forw;
		if (p == 0 || p == p1)
			return(len >= 254);
		len += ilen(p);
	}
}

/* Not V7: length in bytes of one instruction (Z8000 encoding) */
ilen(p)
register struct node *p;
{
	if (p->op == 0)
		return(0);
	switch (p->op) {
	case LABEL:
	case DLABEL:
	case EROU:
	case TEXT:
	case CODE:
	case DSEC:
	case SDEF:
	case BSS:
	case EVEN:
	case CMT:
		return(0);

	case ASR:
	case ASL:
	case ASH:
	case SRL:
	case SLL:
	case LDIR:
	case LDDR:
		return(4);

	case CBRS:
	case JBR:
	case SOB:
	case LDK:
		return(2);

	default:
		dualop(p);
		if (p->subop & FLTF)
			return(adrlen(regs[RT1]) + adrlen(regs[RT2]) + 4);
		switch (p->op) {
		case INC:
		case DEC:
		case SET:
		case RES:
		case BIT:
			return(adrlen(regs[RT1]) + 2);

		case MOV:
		case CMP:
		case ADD:
		case SUB:
		case MUL:
		case DIV:
			if (p->subop == LONG && regs[RT2][0] == '#')
				return(6);

		default:
			return(adrlen(regs[RT1]) + adrlen(regs[RT2]) + 2);
		}
	}
}

/* Not V7: extra bytes of an operand (register 0, immediate/address/indexed 2) */
adrlen(s)
register char *s;
{
	if (*s == 0)
		return(0);
	if (*s == 'r' || *s == 'f')
		return(0);
	if (*s == 'S' && s[1] == 'P')
		return(0);
	if (*s == '(' && (s[1] == 'r' || s[1] == 'F'))
		return(0);
	if (*s == '@')
		return(0);
	return(2);
}

/* Not V7: abs (V7 uses the library) */
abs(x)
{
	if (x < 0)
		return(-x);
	return(x);
}

equop(ap1, p2)
struct node *ap1;
register struct node *p2;
{
	register char *cp1, *cp2;
	register struct node *p1;

	p1 = ap1;
	if (p1->op!=p2->op || p1->subop!=p2->subop)
		return(0);
	if (p1->op>0 && p1->op<MOV)
		return(0);
	cp1 = p1->code;
	cp2 = p2->code;
	if (cp1==0 && cp2==0)
		return(1);
	if (cp1==0 || cp2==0)
		return(0);
	while (*cp1 == *cp2++)
		if (*cp1++ == 0)
			return(1);
	return(0);
}

decref(p)
register struct node *p;
{
	if (--p->refc <= 0) {
		nrlab++;
		delnode(p);
	}
}

struct node *
nonlab(p)
register struct node *p;
{
	while (p && p->op==LABEL)
		p = p->forw;
	return(p);
}

char *
alloc(n)
register n;
{
	register char *p;

	n++;
	n &= ~1;
	if (lasta+n >= lastr) {
		if (sbrk(2000) == -1) {
			fprintf(stderr, "C Optimizer: out of space\n");
			exit(1);
		}
		lastr += 2000;
	}
	p = lasta;
	lasta += n;
	return(p);
}

clearreg()
{
	register int i;

	for (i = 0; i < NREG; i++) {
		regs[i][0] = '\0';
		rsz[i] = 0;
		rnode[i] = 0;
	}
	conloc[0] = 0;
	conlsz = 0;
	conval[0] = 0;
	convsz = 0;
	clrcc();
	for (i = 0; i < 8; i++)
		cregs[i][0] = 0;
}

/*
 * Differs from V7: the register slot also records the size letter (sz) and the
 * node that loaded it (np); no check for a source operand.
 */
savereg(ai, as, sz, np)
register ai;
char *as;
char sz;
register struct node *np;
{
	register char *p, *s, *sp;

	sp = p = regs[ai];
	s = as;
	kill(ai, sz);
	rsz[ai] = sz;
	rnode[ai] = np;
	while (*p++ = *s) {
		if (*s == '(' && regno(s+1) != 14) {
			*sp = 0;
			return;
		}
		if (*s++ == ',')
			break;
	}
	*--p = '\0';
}

/* V7 dest with size (sz) bookkeeping; '@' instead of '*', '#' instead of '$' */
dest(as, sz, flt)
char *as;
char sz;
register flt;
{
	register char *s;
	register i, r;

	s = as;
	if ((r = isreg(s)) >= 0) {
		kill(r+flt, sz);
		if (flt == 0)
			kill(r+14, sz);
	}
	for (i = 0; i < NREG; i++)
		if ((r >= 0 && isreg(regs[i]) == r)
		 || (regs[i][0] == '@' && equstr(s, regs[i]+1)))
			kill(i, sz);
	while ((i = findrand(s, sz, flt)) >= 0) {
		if (rsz[i] == sz)
			kill(i, sz);
		else if (i+flt <= NREG && rsz[i+flt] == sz)
			kill(i+flt, sz);
	}
	while (*s) {
		if ((*s == '(' && (s[1] != 'F' || s[2] != 'P')) || *s++ == '@') {
			for (i = 0; i < FREG; i++) {
				if (regs[i][0] != '#' && regs[i][0] != 'r' && regs[i][0] != 'f')
					kill(i, sz);
				conloc[0] = 0;
				conlsz = 0;
			}
			return;
		}
	}
}

/*
 * Not V7: forget which node loaded a register (rnode) for the destination as; same
 * walk as dest.  Name Annahme.
 */
clrptr(as, sz, flt)
char *as;
char sz;
register flt;
{
	register char *s;
	register i;

	s = as;
	if ((i = isreg(s)) >= 0) {
		rnode[i+flt] = 0;
		if (flt == 0)
			rnode[i+14] = 0;
		if (sz == 'r' || sz == 'q') {
			rnode[i+1] = 0;
			rnode[i+15] = 0;
		}
		if (sz == 'q') {
			rnode[i+2] = 0;
			rnode[i+3] = 0;
			rnode[i+16] = 0;
			rnode[i+17] = 0;
		}
	} else {
		if (*s == '@') {
			s++;
			if ((i = isreg(s)) >= 0)
				goto clr;
		}
		for (; *s; s++)
			if (*s == '(')
				break;
		if (*s && *s == '(') {
			s++;
			if ((i = regno(s)) < 0)
				return;
		clr:
			rnode[i] = 0;
			rnode[i+14] = 0;
		}
	}
}

/* Differs from V7: the size letter is taken from the node (setrsz) */
singop(ap)
struct node *ap;
{
	register char *p1, *p2;

	p1 = ap->code;
	p2 = regs[RT1];
	while (*p2++ = *p1++);
	setrsz(RT1, ap);
	regs[RT2][0] = 0;
	rsz[RT2] = 0;
}

dualop(ap)
struct node *ap;
{
	register char *p1, *p2;
	register struct node *p;

	p = ap;
	p1 = p->code;
	p2 = regs[RT1];
	while (*p1 && *p1!=',')
		*p2++ = *p1++;
	setrsz(RT1, ap);
	*p2++ = 0;
	p2 = regs[RT2];
	*p2 = 0;
	if (*p1++ !=',') {
		rsz[RT2] = 0;
		return;
	}
	while (*p2++ = *p1++);
	setrsz(RT2, ap);
}

findrand(as, sz, flt)
char *as;
char sz;
register flt;
{
	register i, j;

	if (*as == 0)
		return(-1);
	if ((i = isreg(as)) >= 0) {
		if ((j = isreg(regs[i+flt])) >= 0) {
			if (j <= i)
				return(-1);
			if (rsz[j] != rsz[i])
				return(-1);
			return(j);
		}
	}
	for (i = flt; i < (flt ? 8 : 0) + FREG; i++) {
		if (equstr(regs[i], as)) {
			if (rsz[i & ~1] == 'r' && sz != 'r')
				continue;
			if (rsz[i & ~3] == 'q' && sz != 'q')
				continue;
			return(i);
		}
	}
	return(-1);
}

/* Differs from V7: register names are decoded by regno */
isreg(as)
register char *as;
{
	return(regno(as));
}

check()
{
	register struct node *p, *lp;

	lp = &first;
	for (p=first.forw; p!=0; p = p->forw) {
		if (p->back != lp)
			abort();
		lp = p;
	}
}

/*
 * Differs from V7: Z8000 register names r0..r14 with a size letter; replaces the
 * operand text by a register when a register holds the same value (findrand).
 */
repladdr(p, f, flt)
struct node *p;
register f;
register flt;
{
	register r1, n, r, t;
	char *p1, *p2;
	static char rt1[50], rt2[50];
#ifdef C2X
	char save0;

	save0 = 0;
#endif

#ifdef C2X
	/* c2x -xcmpmem (W10j): the R0 copy made by an inserted `ld r0,MEM` (X4MARK) serves only a repeated `cp MEM,#k` (see rmove, mv:); the older
	   c2 keeps MEM in `ld r2,MEM`, `test MEM`, `push MEM` or reuses another register (cpp, mkfs, sh/cmd, sh/xec, tar measured).  Hide it here. */
	/* W10l: no exception behind a conditional branch any more: the rule R38 reuse (`cp r0,#k ; jr cc ; ld rN,MEM` -> `ld rN,r0`) is done by
	   cmppass() after shortjmp, only for a branch that ended up short (the original does not reuse R0 behind a far `jp cc`). */
	if (x4keep) {
		save0 = regs[0][0];
		regs[0][0] = 0;
	}
#endif
	if (f)
		r1 = findrand(regs[RT1], rsz[RT1], flt);
	else
		r1 = -1;
	r = findrand(regs[RT2], rsz[RT2], flt);
#ifdef C2X
	if (save0)
		regs[0][0] = save0;
#endif
	if (r >= FREG)
		r -= FREG;
	if (r1 >= FREG)
		r1 -= FREG;
	if (r >= 14)
		r -= 14;
	if (r1 >= 14)
		r1 -= 14;
	if (r1 >= 0 || r >= 0) {
		p2 = regs[RT1];
		for (p1 = rt1; *p1++ = *p2++;);
		if (regs[RT2][0]) {
			p1 = rt2;
			*p1++ = ',';
			for (p2 = regs[RT2]; *p1++ = *p2++;);
		} else
			rt2[0] = 0;
		if (r1 >= 0
		 && (regs[r1][0] == 0 || rsz[r1] == rsz[RT1])
		 && ((t = isreg(regs[RT1])) < 0 || (t < r1 && rsz[t] == rsz[RT1]))) {
			if (flt)
				rt1[0] = 'f';
			else
				rt1[0] = 'r';
			n = 1;
			if (rsz[RT1] && rsz[RT1] != 'f')
				rt1[n++] = rsz[RT1];
			if (r1 > 9) {
				rt1[n++] = '1';
				rt1[n++] = r1 + '0' - 10;
			} else
				rt1[n++] = r1 + '0';
			rt1[n] = 0;
			nsaddr++;
			nchange++;
		}
		if (r >= 0
		 && (regs[r][0] == 0 || rsz[r] == rsz[RT2])
		 && ((t = isreg(regs[RT2])) < 0 || (t < r && rsz[t] == rsz[RT2]))) {
			if (flt)
				rt2[1] = 'f';
			else
				rt2[1] = 'r';
			n = 2;
			if (rsz[RT2] && rsz[RT2] != 'f')
				rt2[n++] = rsz[RT2];
			if (r > 9) {
				rt2[n++] = '1';
				rt2[n++] = r + '0' - 10;
			} else
				rt2[n++] = r + '0';
			rt2[n] = 0;
			nsaddr++;
			nchange++;
		}
		p->code = copy(2, rt1, rt2);
	}
}

redunbr(p)
register struct node *p;
{
	register struct node *p1;
	register char *ap1, *ap2;

	if ((p1 = p->ref) == 0)
		return;
	p1 = nonlab(p1);
	if (p1->op==TST) {
		singop(p1);
		savereg(RT2, "#0", rsz[RT1], p1);
	} else if (p1->op==CMP)
		dualop(p1);
	else
		return;
	if (p1->forw->op!=CBR)
		return;
	ap1 = findcon(RT1);
	ap2 = findcon(RT2);
	p1 = p1->forw;
	if (compare(p1->subop, ap1, ap2)>0 && p1->labno) {
		nredunj++;
		nchange++;
		decref(p->ref);
		p->ref = p1->ref;
		p->labno = p1->labno;
		p->ref->refc++;
	}
}

findcon(i)
register i;
{
	register char *p;
	register r;

	p = regs[i];
	if (*p=='#')
		return(p);
	if ((r = isreg(p)) >= 0 && rsz[r] == rsz[i])
		return(regs[r]);
	if (equstr(p, conloc) && conlsz == rsz[i])
		return(conval);
	return(p);
}

/* Differs from V7: numbers are hex (atoh), '#' marks an immediate, jp pl/mi are known */
compare(oper, cp1, cp2)
register oper;
char *cp1, *cp2;
{
	register unsigned n1, n2;

	if (*cp1++ != '#' || *cp2++ != '#')
		return(-1);
	n2 = atoh(cp2);
	n1 = atoh(cp1);
	do {
		if (*cp1++ != *cp2)
			return(-1);
	} while (*cp2++);
	switch(oper) {
	case JEQ:
		return(n1 == n2);
	case JNE:
		return(n1 != n2);
	case JLE:
		return((int)n1 <= (int)n2);
	case JGE:
		return((int)n1 >= (int)n2);
	case JLT:
		return((int)n1 < (int)n2);
	case JGT:
		return((int)n1 > (int)n2);
	case JLO:
		return(n1 < n2);
	case JHI:
		return(n1 > n2);
	case JLOS:
		return(n1 <= n2);
	case JHIS:
		return(n1 >= n2);
	case JPL:
		return((int)n1 >= 0);
	case JMI:
		return((int)n1 < 0);
	}
	return(-1);
}

setcon(ar1, ar2, sz)
char *ar1, *ar2;
char sz;
{
	register char *cl, *cv, *p;

	cl = ar2;
	cv = ar1;
	if (*cv != '#')
		return;
	if (!natural(cl))
		return;
	p = conloc;
	while (*p++ = *cl++);
	p = conval;
	while (*p++ = *cv++);
	conlsz = sz;
	convsz = sz;
}

/* Differs from V7: "#%x" and "#x" are the same constant */
equstr(ap1, ap2)
char *ap1, *ap2;
{
	register char *p1, *p2;

	p1 = ap1;
	p2 = ap2;
	if (*p1 == '#' && *p2 == '#') {
		if (*++p1 == '%')
			p1++;
		if (*++p2 == '%')
			p2++;
	}
	do {
		if (*p1++ != *p2)
			return(0);
	} while (*p2++);
	return(1);
}

setcc(ap, sz)
char *ap;
char sz;
{
	register char *p, *p1;

	p = ap;
	ccsz = sz;
	if (!natural(p)) {
		clrcc();
		return;
	}
	p1 = ccloc;
	while (*p1++ = *p++);
}

/* Not V7 */
clrcc()
{
	ccloc[0] = 0;
	ccsz = 0;
}

natural(ap)
char *ap;
{
	register char *p;

	p = ap;
	if (*p=='@' || *p=='(')
		return(0);
	while (*p++);
	p--;
	if (*--p == ')' && *--p != 'P')
		return(0);
	return(1);
}

/* Not V7: hex number at the start of s (no pointer advance for the caller) */
atoh(s)
char *s;
{
	register unsigned n;

	n = 0;
	while (*s >= '0' && *s <= '9' || *s >= 'a' && *s <= 'f') {
		n <<= 4;
		if (*s < 'a')
			n += *s++ - '0';
		else
			n += *s++ - 'a' + 10;
	}
	return(n);
}

/* Differs from V7: counts the change, does not touch refc (the callers do) */
delnode(p)
register struct node *p;
{
	p->back->forw = p->forw;
	p->forw->back = p->back;
	nchange++;
}

/* Not V7: register number of an operand name (r5 -> 5, r12 -> 12, FP -> 14), -1 if none */
regno(s)
char *s;
{
	if (*s != 'r' && *s != 'F' && *s != 'f')
		return(-1);
	regcl = 0;
	if (*s++ == 'F') {
		if (*s++ == 'P')
			return(14);
	}
	if (*s == 'l' || *s == 'r' || *s == 'h' || *s == 'q')
		regcl = *s++;
	if (s[1] >= '0' && s[1] <= '4') {
		s++;
		return(*s++ - '0' + 10);
	}
	return(*s++ - '0');
}

/* Not V7: size letter of register slot i from the node np */
setrsz(i, np)
register i;
register struct node *np;
{
	if (regs[i][0] == 'r' && regs[i][1] > '9')
		rsz[i] = regs[i][1];
	else if (np->subop & FLTF)
		rsz[i] = 'f';
	else if (np->subop == LONG)
		rsz[i] = 'r';
	else if (np->subop == BYTE)
		rsz[i] = 'l';
	else
		rsz[i] = 0;
}

/* Not V7: forget register slot ai (and the pair/quad it belongs to) */
kill(ai, sz)
register ai;
char sz;
{
	register i, j;

	j = ai & ~1;
	i = ai & ~3;
	if (ai < 8 && sz != 'l')
		cregs[ai][0] = 0;
#ifdef C2X
	if (ai == 0)
		x4keep = 0;
#endif
	if (rsz[i] == 'q' || sz == 'q') {
		regs[i][0] = 0;
		rsz[i] = 0;
		rnode[i] = 0;
		i++;
		regs[i][0] = 0;
		rsz[i] = 0;
		rnode[i] = 0;
		i++;
		regs[i][0] = 0;
		rsz[i] = 0;
		rnode[i] = 0;
		i++;
		regs[i][0] = 0;
		rsz[i] = 0;
		rnode[i] = 0;
	} else if (rsz[j] == 'r' || sz == 'r') {
		regs[j][0] = 0;
		rsz[j] = 0;
		rnode[j] = 0;
		j++;
		regs[j][0] = 0;
		rsz[j] = 0;
		rnode[j] = 0;
	} else {
		regs[ai][0] = 0;
		rsz[ai] = 0;
	}
	rnode[ai] = 0;
}

/* Not V7 */
#ifdef C2X
/* c2x -xcmpmem (W10l, R38): late pass after shortjmp: `ld r0,MEM [X4MARK] ; cp r0,.. ; jr cc ; ld rN,MEM` -> `ld rN,r0`, only when the branch is a
   short jr (CBRS).  A label or any other node in between breaks the pattern. */
char	rt0buf[8];

cmppass()
{
	register struct node *p, *q, *b, *m;
	register char *c1, *c2;

	for (p = first.forw; p != 0; p = p->forw) {
		if (p->op != MOV || p->labno != X4MARK || (q = p->forw) == 0 || q->op != CMP || (b = q->forw) == 0 || b->op != CBRS)
			continue;
		m = b->forw;
		if (m == 0 || m->op != MOV || m->subop != 0 || m->labno == X4MARK)
			continue;
		c1 = p->code + 3;	/* p->code is "r0,MEM" */
		c2 = m->code;
		if (c2[0] != 'r' || c2[1] < '1' || c2[1] > '9')	/* destination rN, N != 0 */
			continue;
		while (*c2 && *c2 != ',')
			c2++;
		if (*c2++ != ',' || !equstr(c1, c2))
			continue;
		c2 = m->code;
		for (c1 = rt0buf; (*c1 = *c2) != ','; c1++, c2++);
		c1[1] = 'r';
		c1[2] = '0';
		c1[3] = 0;
		m->code = copy(1, rt0buf);
	}
}
#endif

#ifdef C2X
/*
 * c2x -xhzero (R2 with its exceptions R30, R63): the xorb p (rhN) is dead when the next node is a byte store `ldb mem,rlN`
 * (mem not a register).  It stays when the node behind the store reads the register again: `testb rlN` (R30) or a word move
 * from rN (R63), or when the store copies a struct member array element (R43).  Returns 1 when p can go.
 */
char hzbuf[20];

hzdrop(p, r)
struct node *p;
register r;
{
	register struct node *q, *q2;
	register ok;
	register char *cp;

	ok = 0;
	q = p->forw;
	if (q && q->op == MOV && (q->subop & BYTE) && !(q->subop & (LONG | FLTF))) {
		dualop(q);
		if (regs[RT1][0] && isreg(regs[RT1]) < 0 && isreg(regs[RT2]) == r && rsz[RT2] == 'l') {
			ok = 1;
			/* R43: `inc rK,#n (n > 1) ; ldb rlN,@rK ; xorb ; ldb @rM,rlN` keeps the xorb */
			q2 = p->back;
			if ((xfl & XR43) && regs[RT1][0] == '@' && regs[RT1][1] == 'r' && q2->op == MOV && (q2->subop & BYTE) && q2->back->op == INC) {
				dualop(q2);
				cp = regs[RT2];
				if (isreg(regs[RT1]) == r && rsz[RT1] == 'l' && cp[0] == '@' && cp[1] == 'r') {
					strcpy(hzbuf, cp + 1);	/* dualop below overwrites regs[] */
					dualop(q2->back);
					if (equstr(regs[RT1], hzbuf) && regs[RT2][0] == '#') {
						cp = &regs[RT2][1];
						if (*cp == '%')
							cp++;
						if (atoh(cp) > 1)
							ok = 0;
					}
				}
			}
			q2 = q->forw;
			if ((xfl & XR30) && q2 && q2->op == TST && (q2->subop & BYTE)) {
				singop(q2);
				if (isreg(regs[RT1]) == r && rsz[RT1] == 'l')
					ok = 0;
			} else if ((xfl & XR63) && q2 && q2->op == MOV && (q2->subop & (BYTE | LONG | FLTF)) == 0) {
				/* R63: `ld rK,rN ; ld rX,rN ; test rN` behind the store keeps the xorb */
				dualop(q2);
				if (isreg(regs[RT2]) == r && rsz[RT2] == 0 && q2->forw && q2->forw->op == MOV
				 && (q2->forw->subop & (BYTE | LONG | FLTF)) == 0 && q2->forw->forw && q2->forw->forw->op == TST) {
					dualop(q2->forw);
					if (isreg(regs[RT2]) == r && rsz[RT2] == 0) {
						singop(q2->forw->forw);
						if (isreg(regs[RT1]) == r && rsz[RT1] == 0)
							ok = 0;
					}
				}
			}
		}
	}
	dualop(p);
	return(ok);
}

/*
 * c2x -xhzero: is p (xorb rhN) one the older c2 keeps although the high byte is known to be zero?
 *   R7:  `ldb rlN,mem ; xorb ; cp rN,..`  (each rule has its own run-time bit, see c2.h: R3 jr/jp, R10 add, R32 cp)
 *   R3, R10, R32 (first xorb behind a compare chain only): `xorb ; cp rN,.. ; jr cc ; xorb ; jr M | add rN,.. | cp rN,..`
 */
hzkeep(p, r)
struct node *p;
register r;
{
	register struct node *q, *f;
	register ok;

	ok = 0;
	q = p->back;
	f = p->forw;
	if (q->op == MOV && (q->subop & BYTE) && !(q->subop & (LONG | FLTF)) && f && f->op == CMP) {
		dualop(q);
		if (isreg(regs[RT1]) == r && rsz[RT1] == 'l' && regs[RT2][0] && regs[RT2][0] != 'r') {
			dualop(f);
			if (isreg(regs[RT1]) == r && rsz[RT1] == 0 && (xfl & XR7))
				ok = 1;
		}
	} else if ((q->op == CBR || q->op == CBRS) && f && q->back->op == CMP && q->back->back->op == XOR
	 && q->back->back->back->op != CBR && q->back->back->back->op != CBRS) {
		dualop(q->back);
		if (isreg(regs[RT1]) == r && rsz[RT1] == 0) {
			dualop(q->back->back);
			if (isreg(regs[RT1]) == r && rsz[RT1] == 'h') {
				if (f->op == JBR || f->op == JMP)
					ok = (xfl & XR3) != 0;
				else if (f->op == CMP || f->op == ADD) {
					dualop(f);
					if (isreg(regs[RT1]) == r && rsz[RT1] == 0 && (xfl & (f->op == ADD ? XR10 : XR32)))
						ok = 1;
				}
			}
		}
	}
	dualop(p);
	return(ok);
}

/* c2x -xhzero (R2): last pass before output: the xorb that hzdrop() condemns goes now (after jump optimisation and shortjmp, as in the originals) */
hzpass()
{
	register struct node *p;
	register r;

	for (p = first.forw; p != 0; p = p->forw)
		if (p->op == XOR) {
			dualop(p);
			if (rsz[RT1] == 'h' && (r = isreg(regs[RT1])) >= 0 && equstr(regs[RT1], regs[RT2]) && hzdrop(p, r))
				delnode(p);
		}
}

/*
 * c2x -x5 / -xT / -x4 / -x6 (W10t): last pass before output (after hzpass), peepholes of the older c2 that the shipped c2 does not make.  Each is the
 * node-level form of the host model rule of the same number (tools/userspace/uspace.py c2_emu_s), same conditions, same exceptions:
 *   R5  (5, T)  `ld rA,rB ; test rB` -> `test rA`;  `ld rA,rB ; ld DST,rB` -> `ld DST,rA`.  Exceptions R33 (`call ; ld rA,r2 ; test r2`) and R39
 *               (`xorb rhB,rhB ; ld rA,rB ; test rB`, A >= 8) keep the test; T = pseudo rule R5T: only the `ld DST` form (pr, 4 sites)
 *   R42 (4)     `ld rN,SRC ; ld MEM,rN ; test rN` -> `test MEM` (SRC, MEM memory operands; not when R37 takes the place: `jr cc ; ld r0,rN` follows)
 *   R64 (6)     `ldl MEM,rr4 ; testl rr4 ; jr eq ; ldl rr2,rr4 ; ld r5,X ; xor r4,r4 ; cpl rr2,rr4 ; jr lt ; ldl rr0,MEM ; cpl rr0,M` -> memory copy first,
 *               then the loaded pair (df)
 * A window is only nodes in a row: a label node in between breaks it, as the text model sees the label line.
 */

/* word register `rN` (N = 0..14), nothing else */
xisrw(s)
register char *s;
{
	if (s[0] != 'r' || s[1] < '0' || s[1] > '9')
		return(0);
	if (s[2] == 0)
		return(1);
	return(s[2] >= '0' && s[2] <= '9' && s[3] == 0);
}

/* the text behind the first comma of a node code, 0 if none */
char *
xcomma(s)
register char *s;
{
	while (*s && *s != ',')
		s++;
	return(*s ? s + 1 : 0);
}

/* copy of the code text up to the first comma (inc = 1: with the comma) */
char *
xhead(s, inc)
char *s;
{
	register char *p, *q, *r;
	register n;

	n = 0;
	for (p = s; *p && *p != ','; p++)
		n++;
	n += inc;
	r = q = alloc(n + 1);
	for (p = s; n-- > 0; )
		*q++ = *p++;
	*q = 0;
	return(r);
}

/* s is `pre` followed by `rest` */
xeq2(s, pre, rest)
register char *s, *pre, *rest;
{
	while (*pre)
		if (*s++ != *pre++)
			return(0);
	return(equstr(s, rest));
}

/* register name as the model's regex sees it: rN, rhN, rlN, rqN, rrN, sp, fp (any case) */
xisreg2(s)
register char *s;
{
	if (s[0] == 'r') {
		s++;
		if (*s == 'h' || *s == 'l' || *s == 'q' || *s == 'r')
			s++;
		if (*s < '0' || *s > '9')
			return(0);
		while (*s >= '0' && *s <= '9')
			s++;
		return(*s == 0);
	}
	return((s[0] == 's' || s[0] == 'S' || s[0] == 'f' || s[0] == 'F') && (s[1] == 'p' || s[1] == 'P') && s[2] == 0);
}

/* s is `rhN,rhN` for the word register rb (= "rN") */
xzerob(s, rb)
register char *s, *rb;
{
	register char *b;

	if (s[0] != 'r' || s[1] != 'h')
		return(0);
	s += 2;
	for (b = rb + 1; *b && *s == *b; b++)
		s++;
	if (*b || *s++ != ',' || s[0] != 'r' || s[1] != 'h')
		return(0);
	s += 2;
	for (b = rb + 1; *b && *s == *b; b++)
		s++;
	return(*b == 0 && *s == 0);
}

/* node n is a word `ld` whose code is `DST,rS` with rS a word register: returns the text behind the comma, else 0 */
char *
xldsrc(n)
register struct node *n;
{
	register char *c;

	if (n == 0 || n->op != MOV || n->subop != 0 || (c = xcomma(n->code)) == 0 || !xisrw(c))
		return(0);
	return(c);
}

/* node n has opcode op, sub-opcode sub and (when s != 0) code text s */
xnd(n, op, sub, s)
register struct node *n;
char *s;
{
	return(n->op == op && n->subop == sub && (s == 0 || equstr(n->code, s)));
}

/* s is `%HEX(FP)`: a frame operand with an upper-case hex offset */
xisfp(s)
register char *s;
{
	register n;

	if (*s++ != '%')
		return(0);
	for (n = 0; (*s >= '0' && *s <= '9') || (*s >= 'A' && *s <= 'F'); n++)
		s++;
	return(n > 0 && equstr(s, "(FP)"));
}

r5pass()
{
	register struct node *p, *q;
	register char *a, *b, *c;
	register char *d;
	struct node *w;
	struct node *n[10];
	register i;

	for (p = first.forw; p != 0; p = p->forw) {
		/* R64: ten nodes in a row */
		if ((xfl & XR64) && xnd(p, MOV, LONG, 0) && p->code[0] != 'r' && (b = xcomma(p->code)) && equstr(b, "rr4")) {
			n[0] = p;
			for (i = 1; i < 10 && n[i-1]->forw; i++)
				n[i] = n[i-1]->forw;
			if (i == 10 && xnd(n[1], TST, LONG, "rr4")
			 && xnd(n[2], CBRS, JEQ, 0)
			 && xnd(n[3], MOV, LONG, "rr2,rr4")
			 && n[4]->op != LABEL && n[4]->op != DLABEL
			 && xnd(n[5], XOR, 0, "r4,r4")
			 && xnd(n[6], CMP, LONG, "rr2,rr4")
			 && xnd(n[7], CBRS, JLT, 0)
			 && xnd(n[8], MOV, LONG, 0)
			 && xnd(n[9], CMP, LONG, 0) && xeq2(n[9]->code, "rr0,", n[9]->code + 4)) {
				a = xhead(p->code, 0);		/* MEM */
				if (xeq2(n[8]->code, "rr0,", a)) {
					n[1]->code = copy(1, a);
					n[3]->code = copy(2, "rr2,", a);
					n[8]->code = copy(1, "rr0,rr2");
					n[9]->code = copy(2, "rr2,", n[9]->code + 4);
					p = n[9];
					continue;
				}
			}
		}
		q = p->forw;
		if (q == 0)
			break;
		/* R45 (W10v): `xor r2,r2 ; div rr2,#k` -> `exts rr2 ; div rr2,#k` (the original divides as signed) */
		if ((xfl2 & XR45) && xnd(p, XOR, 0, "r2,r2") && xnd(q, DIV, 0, 0)
		 && q->code[0] == 'r' && q->code[1] == 'r' && q->code[2] == '2' && q->code[3] == ',' && q->code[4] == '#') {
			p->op = SXT;
			p->code = copy(1, "rr2");
			continue;
		}
		/* R71 (W10w): `ld rA,%k(FP) ; ld rB,rA ; jr L` -> `ld rA,%k(FP) ; ld rB,%k(FP) ; jr L` (ar trim()) */
		if ((xfl2 & XR71) && xnd(p, MOV, 0, 0) && (b = xcomma(p->code)) && xisfp(b) && xisrw(a = xhead(p->code, 0))
		 && xnd(q, MOV, 0, 0) && (c = xcomma(q->code)) && equstr(c, a) && xisrw(xhead(q->code, 0))
		 && q->forw && q->forw->op == JBR) {
			q->code = copy(2, xhead(q->code, 1), b);
			p = q;
			continue;
		}
		/* R6 (W10w): `ld rA,M ; testb @rA ; jr cc L ; ld rB,rA` -> `... ; ld rB,M` (date) */
		if ((xfl2 & XR6) && xnd(p, MOV, 0, 0) && (b = xcomma(p->code)) && b[0] != 'r' && b[0] != '@' && xcomma(b) == 0
		 && xisrw(a = xhead(p->code, 0)) && xnd(q, TST, BYTE, 0) && q->code[0] == '@' && equstr(q->code + 1, a)
		 && q->forw && (q->forw->op == CBRS || q->forw->op == JBR) && q->forw->forw
		 && (w = q->forw->forw)->op == MOV && w->subop == 0 && (d = xcomma(w->code)) && equstr(d, a) && xisrw(xhead(w->code, 0))) {
			w->code = copy(2, xhead(w->code, 1), b);
			p = w;
			continue;
		}
		/* R65 (W10w): `ld rN,#k ; ldl rr2,X ; xor r0,r0 ; ld r1,rN ; cpl rr2,rr0` -> `... ; ld r1,#k ; cpl rr2,rr0` (strip) */
		if ((xfl2 & XR65) && xnd(p, MOV, 0, 0) && (b = xcomma(p->code)) && b[0] == '#' && xcomma(b) == 0 && xisrw(a = xhead(p->code, 0))
		 && xnd(q, MOV, LONG, 0) && q->code[0] == 'r' && q->code[1] == 'r' && q->code[2] == '2' && q->code[3] == ','
		 && (w = q->forw) && xnd(w, XOR, 0, "r0,r0")
		 && w->forw && xnd(w->forw, MOV, 0, 0) && xeq2(w->forw->code, "r1,", a)
		 && w->forw->forw && xnd(w->forw->forw, CMP, LONG, "rr2,rr0")) {
			w->forw->code = copy(2, "r1,", b);
			p = w->forw->forw;
			continue;
		}
		/* R34 (W10w): `ld MEM,rN ; test rN ; jr eq|ne L ; jr mi|pl|lt|ge|gt|le L2` -> test rN repeated after the first jump (cp) */
		if ((xfl2 & XR34) && xnd(p, TST, 0, 0) && xisrw(p->code) && xnd(p->back, MOV, 0, 0)
		 && (c = xcomma(p->back->code)) && equstr(c, p->code) && p->back->code[0] != 'r' && q->op == CBRS && (q->subop == JEQ || q->subop == JNE)
		 && q->forw && q->forw->op == CBRS && (q->forw->subop == JMI || q->forw->subop == JPL || q->forw->subop == JLT
		 || q->forw->subop == JGE || q->forw->subop == JGT || q->forw->subop == JLE)) {
			struct node *np;

			np = (struct node *)alloc(sizeof first);
			np->op = TST;
			np->subop = 0;
			np->labno = 0;
			np->ref = 0;
			np->refc = 0;
			np->code = p->code;
			np->forw = q->forw;
			np->back = q;
			q->forw->back = np;
			q->forw = np;
			p = np;
			continue;
		}
		/* R63 copy part (W10v): `xorb rhN,rhN ; ldb @rM,rlN ; ld rK,rN ; ld rX,rN ; test rN` -> `... ; ld rK,rN ; ld rX,rK ; test rK`
		   (the original works on the copy; the xorb itself is kept by the hzpass exception, flag w) */
		if ((xfl & XR63C) && (b = xldsrc(p)) && xisrw(a = xhead(p->code, 0)) && q->forw && (c = xldsrc(q)) && equstr(c, b)
		 && xisrw(xhead(q->code, 0)) && xnd(q->forw, TST, 0, 0) && equstr(q->forw->code, b)
		 && xnd(p->back, MOV, BYTE, 0) && p->back->code[0] == '@' && p->back->code[1] == 'r'
		 && (c = xcomma(p->back->code)) && c[0] == 'r' && c[1] == 'l' && equstr(c + 2, b + 1)
		 && xnd(p->back->back, XOR, BYTE, 0) && xzerob(p->back->back->code, b)) {
			q->code = copy(2, xhead(q->code, 1), a);
			q->forw->code = copy(1, a);
			p = q->forw;
			continue;
		}
		/* R42: p = `ld MEM,rN`, behind `ld rN,SRC`, before `test rN` */
		if ((xfl & XR42) && xnd(p, MOV, 0, 0) && xnd(q, TST, 0, 0) && (b = xcomma(p->code)) && xisrw(b) && equstr(q->code, b)
		 && xnd(p->back, MOV, 0, 0) && (c = xcomma(p->back->code)) && c[0] != 'r' && c[0] != '#') {
			a = xhead(p->code, 0);		/* MEM */
			for (i = 0; a[i] && a[i] != '@' && a[i] != '#'; i++)
				;
			if (a[0] && a[i] == 0 && !xisreg2(a)
			 && equstr(xhead(p->back->code, 0), b)	/* destination of the previous `ld` is rN */
			 && !(q->forw && q->forw->op == CBRS && q->forw->forw && xnd(q->forw->forw, MOV, 0, 0)
			      && xeq2(q->forw->forw->code, "r0,", b))) {
				q->code = copy(1, a);
				p = q;
				continue;
			}
		}
		/* R5 */
		if ((xfl & XR5) && (b = xldsrc(p)) && xisrw(a = xhead(p->code, 0))) {
			if (xnd(q, TST, 0, 0) && equstr(q->code, b)) {
				if (equstr(b, "r2") && p->back->op == CALL) {		/* R33 */
					p = q;
					continue;
				}
				if ((a[2] || a[1] >= '8') && xnd(p->back, XOR, BYTE, 0) && xzerob(p->back->code, b)) {
					p = q;		/* R39: rA is r8..r14 */
					continue;
				}
				if (!(xfl & XR5T)) {
					q->code = copy(1, a);
					p = q;
				}
				continue;
			}
			if ((c = xldsrc(q)) && equstr(c, b) && !equstr(xhead(q->code, 0), a)) {
				q->code = copy(2, xhead(q->code, 1), a);
				p = q;
			}
		}
	}
}
#endif

clrptr30()
{
	register i;

	for (i = 0; i < 30; i++)
		rnode[i] = 0;
}

/* Not V7: n = 2**k -> k, else -1 */
log2n(n)
register unsigned n;
{
	register i;

	if (n != 0 && n <= 0x8000 && (n & (n-1)) == 0) {
		for (i = 0; n >>= 1; i++);
		return(i);
	}
	return(-1);
}

/* Not V7: make the operand ",#%k" (shift count) for the shift made from mult/and/or */
mkshift(np, n)
register struct node *np;
register n;
{
	static char buf[5];

	rsz[RT2] = 0;
	buf[0] = ',';
	buf[1] = '#';
	buf[2] = '%';
	buf[3] = n < 10 ? n + '0' : n + 'a' - 10;
	buf[4] = 0;
	np->code = copy(2, regs[RT1], buf);
}
