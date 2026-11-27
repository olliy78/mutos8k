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
#ifdef C2X
/* c2x run-time switches, see c2.h.  Must be initialized (data, not BSS):
 * opsetup() can store one entry past ophash[OPHS] (V7 test `ophp > &ophash[OPHS]`),
 * harmless in the original layout, but it would hit a BSS variable placed right
 * after ophash. */
int	xfl = 0;
/* W10z: shared strings in copy() are run-time optional: flag S (XR_SH in xfl2), off by default.  They change the heap layout, and the heap
 * layout is not neutral: addsob() reads p->refc of a DEC node that nothing ever initialised (known bug F6), so the djnz decision
 * depends on leftover heap content of the previous function.  With sharing everywhere, dd/ed/tar lost their djnz (W10w/W10x).
 * Hence only the part of a function's heap above XTHR bytes is shared; functions that stay below XTHR are heap-identical to c2.
 * The tables are initialised data (F1), not BSS. */
#define	XTBSZ	120	/* longest string that copy() shares */
#define	XIHS	32	/* hash chains of the shared strings */
#define	XTHR	6144	/* heap use of the current function above which copy() starts to share */
char	xtb[XTBSZ + 8] = {0};
char	*xih[XIHS] = {0};
int	xfl2 = 0;	/* initialized data, not BSS (W10q: BSS neighbours of ophash get overwritten) */
int	xfl3 = 0;	/* W10ah: third flag word, initialized data likewise */

/* c2x (W10ad): insert a word MOV node with code s behind node p (R70) */
xins(p, s)
register struct node *p;
char *s;
{
	register struct node *np;

	np = (struct node *)alloc(sizeof first);
	np->op = MOV;
	np->subop = 0;
	np->labno = 0;
	np->ref = 0;
	np->refc = 0;
	np->code = s;
	np->forw = p->forw;
	np->back = p;
	p->forw->back = np;
	p->forw = np;
}

/* c2x pattern engine (W10ai).  The fixed instruction patterns of the rules R77, R92, R97-R100, R131-R133, R45, R64 and R93 are tables, not written-out
 * comparisons (about 60 % smaller).  A pattern is: flag mask, anchor index k, then pairs (op word, code text) up to an op word 0.  The window is the k nodes
 * in front of the anchor node p and the nodes behind it; node i of the window is stored in xw[i].  Op word = XP(op, sub): XSA = any sub-opcode, XCB = CBR or
 * CBRS, XBR = JMP or JBR, XNL = any node but a label.  Code text: 0 = any; `*` stands for the text up to the next comma (or the end),
 * a final `~` for any rest; otherwise it must be equal (none of the texts starts with `#`, so equstr() is plain equality).  No allocation happens here. */
struct node *xw[10] = {0};

xg(s, c)
register char *s, *c;
{
	for (;;) {
		if (*c == '~')
			return(1);
		if (*c == '*') {
			c++;
			while (*s && *s != ',')
				s++;
		} else if (*c != *s)
			return(0);
		else if (*c == 0)
			return(1);
		else {
			c++;
			s++;
		}
	}
}

xmn(q, w, c)
register struct node *q;
char *c;
{
	register o;

	o = w & 255;
	if (o == XCB ? q->op != CBR && q->op != CBRS : o == XBR ? q->op != JMP && q->op != JBR
	    : o == XNL ? q->op == LABEL || q->op == DLABEL : q->op != o)
		return(0);
	o = (w >> 8) & 255;
	return((o == XSA || q->subop == o) && (c == 0 || xg(q->code, c)));
}

xm(p, t)
struct node *p;
register int *t;
{
	register struct node *q;
	register i;

	q = p;
	for (i = *t++; i > 0; i--)
		if ((q = q->back) == 0)
			return(0);
	for (i = 0; *t; t += 2, i++) {
		if (q == 0 || !xmn(q, t[0], t[1]))
			return(0);
		xw[i] = q;
		q = q->forw;
	}
	return(1);
}

/* first pattern of the table at t whose mask is in fl and that matches at p: its number (1 ...), else 0 */
xmt(p, t, fl)
struct node *p;
register int *t;
{
	register i;

	for (i = 1; *t; i++) {
		if ((fl & *t) && xm(p, t + 1))
			return(i);
		for (t += 2; *t; t += 2)
			;
		t++;
	}
	return(0);
}

/* c2x (W10ae/W10ag): the single sites where the older c2 keeps a jp cc short that toofar() calls far.  p is the last node of each pattern.
   R132 (l): `cp r2,#%3 ; jp eq ; cp r2,#%7 ; jp eq ; jp Lc` -> the jp Lc is short, too (c0 tree);  R131 (l): `cp r9,#%8 ; jp ne ; cp @r13,#%5A ; jp eq`;
   the `jp eq` behind `cp r2,#%7` (see R132) followed by a jp;  R133: `cp r2,#%16 ; jp eq ; cp r2,#%17 ; jp eq ; cp r2,#%19`;  R77 (ps);  R92 (tar) */
int	xst[] = {
#ifdef C2X_C0
	XR131, 4, XP(CMP, XSA), "r2,#%3", XP(XCB, JEQ), 0, XP(CMP, XSA), "r2,#%7", XP(XCB, JEQ), 0, XP(JMP, XSA), 0, 0,
	XR131, 3, XP(CMP, XSA), "r9,#%8", XP(XCB, JNE), 0, XP(CMP, XSA), "@r13,#%5A", XP(CBR, JEQ), 0, 0,
	XR131, 3, XP(CMP, XSA), "r2,#%3", XP(XCB, JEQ), 0, XP(CMP, XSA), "r2,#%7", XP(CBR, JEQ), 0, XP(JMP, XSA), 0, 0,
	XR131, 3, XP(CMP, XSA), "r2,#%16", XP(XCB, JEQ), 0, XP(CMP, XSA), "r2,#%17", XP(CBR, JEQ), 0, XP(CMP, XSA), "r2,#%19", 0,
#endif
	XR77, 3, XP(MOV, BYTE), "rl2,@r13", XP(XOR, BYTE), "rh2,rh2", XP(CMP, XSA), "r2,#%1", XP(CBR, JNE), 0, 0,
	XR92, 1, XP(TST, XSA), "_rflag", XP(CBR, JEQ), 0, XP(TST, XSA), "_cflag", XP(CBRS, JEQ), 0, XP(XBR, XSA), 0, 0,
	0};

/* table entry number of R92 in xst (the four R131 entries exist only in the C0 variant) */
#ifdef C2X_C0
#define	XSI92	6
#else
#define	XSI92	2
#endif

xsite(p)
struct node *p;
{
	register i;

	i = xmt(p, xst, xfl2);
	return(i && (i != XSI92 || xw[4]->labno == p->labno));	/* R92: the final jump goes to the same label */
}

/* c2x (W10af): R97-R100, the four single-site forms of ld (c2gegen FLAGBUCHSTABE f h i j), and R45 (e).  Returns 1 when it rewrote at p (the caller goes on with p->forw). */
char	*xhead(), *xcomma();

int	xlt[] = {
#ifdef C2X_LD
	/* R97 `sub r2,r12 ; ld MEM,r2 ; jr mi L` -> `test r2` kept before the jr (mget) */
	XR97, 1, XP(SUB, 0), "r2,r12", XP(MOV, 0), "*,r2", XP(CBRS, JMI), 0, 0,
	/* R98 `xorb rh3,rh3 ; xor r2,r2 ; div rr2,#%3` -> `ld r2,r3 ; ld r3,r2` before the xor, R45 does not apply (main hash switch) */
	XR98, 1, XP(XOR, BYTE), "rh3,rh3", XP(XOR, 0), "r2,r2", XP(DIV, 0), "rr2,#%3", 0,
	/* R99 `mult rr4,#%C ; ld r13,r5 ; add r13,#X ; ld MEM,r13 ; ld @r2,r13` goes through r3 (enter) */
	XR99, 0, XP(MUL, 0), "rr4,#%C", XP(MOV, 0), "r13,r5", XP(ADD, 0), "r13,#~", XP(MOV, 0), "*,r13", XP(MOV, 0), "@r2,r13", 0,
	/* R100 `ld r3,@r2 ; ld -%X(FP),r3 ; ld r2,r3` -> `ld r2,-%X(FP)` (ldrand: the local is reloaded) */
	XR100, 1, XP(MOV, 0), "r3,@r2", XP(MOV, 0), "-*,r3", XP(MOV, 0), "r2,r3", 0,
#endif
	/* R45 (W10v): `xor r2,r2 ; div rr2,#k` -> `exts rr2 ; div rr2,#k` (the original divides as signed) */
	XR45, 0, XP(XOR, 0), "r2,r2", XP(DIV, 0), "rr2,#~", 0,
	0};

/* case number of R45 in xlt (R97-R100 come first, in the LD variant only) */
#ifdef C2X_LD
#define	XCASE45	5
#else
#define	XCASE45	1
#endif

xldrules(p)
register struct node *p;
{
	register struct node *w;

	switch (xmt(p, xlt, xfl2)) {
#ifdef C2X_LD
	case 1:
		xins(p, "r2");
		p->forw->op = TST;
		return(1);
	case 2:
		w = xw[0];
		xins(w, "r2,r3");
		xins(w->forw, "r3,r2");
		return(1);
	case 3:
		if (xw[3]->code[0] == 'r' || xw[3]->code[0] == '@')
			return(0);
		w = xw[2];
		xins(p, "r3,r5");
		xw[1]->code = copy(1, "r13,r3");
		xins(w, "r3,r13");
		w = w->forw->forw;
		w->code = copy(2, xhead(w->code, 1), "r3");
		w->forw->code = copy(1, "@r2,r3");
		return(1);
	case 4:
		xw[2]->code = copy(2, "r2,", xhead(xw[1]->code, 0));
		return(1);
#endif
	case XCASE45:
		p->op = SXT;
		p->code = copy(1, "rr2");
		return(1);
	}
	return(0);
}

/* strings a and b agree up to the first comma (or the end) */
xhdeq(a, b)
register char *a, *b;
{
	while (*a && *a != ',' && *a == *b) {
		a++;
		b++;
	}
	return((*a == 0 || *a == ',') && (*b == 0 || *b == ','));
}

/* s is a frame variable `[-]%HEX(FP)` or (rv) a register variable r8..r13; the text must end there (no comma) */
xccvar(s, rv)
register char *s;
{
	if (*s == '-')
		s++;
	if (*s == '%')
		return(xisfp(s));
	return(rv && s[0] == 'r' && (s[1] == '8' || s[1] == '9' ? s[2] == 0 : s[1] == '1' && s[2] >= '0' && s[2] <= '3' && s[3] == 0));
}

#ifdef C2X_CC
/* R93 window: `ld r3,@r2 ; ld MEM,r3 ; push @SP,r3` (anchor = the middle node) */
int	xr93[] = {1, XP(MOV, 0), "r3,@r2", XP(MOV, 0), "*,r3", XP(PUSH, 0), "@SP,r3", 0};

/* node n is a word `ld M,r2` with M a memory operand (not a register, not @) */
xld2m(n)
register struct node *n;
{
	register char *c;

	return(XN(n, MOV, 0) && xg(c = n->code, "*,r2") && c[0] != '@' && c[0] != ',' && !(c[0] == 'r' && c[1] >= '0' && c[1] <= '9'));
}

/* c2x (W10ah) flag y: R93-R96, node-level form of uspace.c2_cc_s (same conditions, same order): last pass before output.  r2 "mirrors" the memory
 * operand `mir` after `ld MEM,r2` / `ld r2,VAR`; a word cp/test and every jump keep it, anything else (and every label) drops it. */
xccpass()
{
	register struct node *p;
	register char *b, *c;
	char *mir, *stale;

	mir = stale = 0;
	for (p = first.forw; p != 0; p = p->forw) {
		/* R93 `ld r3,@r2 ; ld MEM,r3 ; push @SP,r3` -> `push @SP,MEM` */
		if (xm(p, xr93) && (b = xhead(p->code, 0)) && (b[0] == '_' ? b[1] != 0 : xccvar(b, 0)))
			p->forw->code = copy(2, "@SP,", b);
		if (XN(p, CMP, 0) && (c = xcomma(p->code)) && c[0] == '#' && c[1] && !equstr(c + 1, "-%1") && xccvar(b = xhead(p->code, 0), 1)) {
			if (mir && xhdeq(mir, b))
				p->code = copy(2, "r2,", c);		/* R95 */
			else {						/* R94 */
				if (stale == 0 && mir)
					stale = mir;
				xins(p->back, copy(2, "r2,", b));
				p->code = copy(2, "r2,", c);
				mir = b;
			}
			continue;
		}
		if (XN(p, TST, 0) && equstr(p->code, "r2")) {
			if (stale) {					/* R96 (b) */
				p->code = xhead(stale, 0);
				continue;
			}
			if (p->back && p->back->back && xld2m(p->back) && xld2m(p->back->back)) {	/* R96 (a) */
				p->code = xhead(p->back->code, 0);
				continue;
			}
		}
		if (xld2m(p)) {
			mir = p->code;
			stale = 0;
		} else if (XN(p, CMP, 0) || XN(p, TST, 0))
			;
		else if (p->op == CBRS || p->op == CBR || p->op == JBR || p->op == JMP)
			;
		else if (XN(p, MOV, 0) && xeq2(p->code, "r2,", p->code + 3) && xccvar(p->code + 3, 1)) {
			mir = p->code + 3;
			stale = 0;
		} else
			mir = stale = 0;
	}
}

#endif

#ifdef C2X_CV
/* c2x flag V (W10ak): R72-R76, the five single sites of convert (uspace.c2_convert_s), a last pass before output.  Window tables as above (xmt, xfl3).
   R72 `call _lseek ; inc SP,#%8 ; test r2 ; jr pl|mi` -> `testl rr2`;  R73 `sra rN,#%1` -> `ld r2,#-%1 ; sda rN,r2`;
   R75 `inc rK ; ld r2,rK ; inc rK ; ld r3,rM ; ldb @r2,rl3` -> the second inc moves behind the byte store;  R76 `ldb rl2,%1(r13) ; ldb @r13,rl2` -> `xorb rh2,rh2` between */
int	xcvt[] = {
	XRCV, 2, XP(CALL, XSA), "_lseek", XP(INC, XSA), "SP,#%8", XP(TST, 0), "r2", XP(CBRS, XSA), 0, 0,
	XRCV, 0, XP(ASR, 0), "r*,#%1", 0,
	XRCV, 0, XP(INC, 0), "r*,#%1", XP(MOV, 0), "r2,r*", XP(INC, 0), "r*,#%1", XP(MOV, 0), "r3,r*", XP(MOV, BYTE), "@r2,rl3", 0,
	XRCV, 0, XP(MOV, BYTE), "rl2,%1(r13)", XP(MOV, BYTE), "@r13,rl2", 0,
	0};

/* R74: loop inversion of the shipped c2 undone for the free-list loop of main.  p is `jr Lh` followed by the label Lb of the inverted loop (labno >= 9000):
   `jr Lh ; Lb: BODY ; Lh: HEAD ; jr ne Lb ; jr Lx`  ->  `Lh: HEAD ; jr eq Lx ; BODY ; jr Lh`.  Only the loop whose head has `testl _curr` and `call _blk`.
   The nodes are relinked (nothing is allocated); the label Lb and the second jump disappear, the `jr ne Lb` node becomes `jr eq Lx`. */
xcvinv(p)
register struct node *p;
{
	register struct node *b, *h, *k;
	struct node *bl, *k1, *last;
	int t1, t2;

	b = p->forw;
	if (b->op != LABEL || b->labno < 9000)
		return(0);
	for (h = b->forw; h != 0 && !(h->op == LABEL && h->labno == p->labno); h = h->forw)
		;
	if (h == 0)
		return(0);
	t1 = t2 = 0;
	for (k = h->forw; k != 0 && !(k->op == CBRS && k->subop == JNE && k->labno == b->labno); k = k->forw) {
		if (XN(k, TST, LONG) && equstr(k->code, "_curr"))
			t1 = 1;
		if (k->op == CALL && equstr(k->code, "_blk"))
			t2 = 1;
	}
	if (k == 0 || !t1 || !t2 || (k1 = k->forw) == 0 || k1->op != JBR || k1->forw == 0)
		return(0);
	k->subop = JEQ;
	k->labno = k1->labno;
	k->ref = k1->ref;
	k->code = k1->code;
	bl = h->back;
	last = k;
	p->back->forw = h;
	h->back = p->back;
	if (b->forw != h) {
		k->forw = b->forw;
		b->forw->back = k;
		last = bl;
	}
	last->forw = p;
	p->back = last;
	p->forw = k1->forw;
	k1->forw->back = p;
	return(1);
}

xcvpass()
{
	register struct node *p;
	register char *c;

	for (p = first.forw; p != 0; p = p->forw)
		if (p->op == JBR && p->forw != 0)
			xcvinv(p);
	for (p = first.forw; p != 0; p = p->forw)
		switch (xmt(p, xcvt, xfl3)) {
		case 1:
			if (xw[3]->subop == JPL || xw[3]->subop == JMI) {
				p->subop = LONG;
				p->code = "rr2";
			}
			break;
		case 2:
			if (p->code[1] >= '0' && p->code[1] <= '9') {
				c = xcomma(p->code);
				c[0] = 'r';
				c[1] = '2';
				c[2] = 0;
				xins(p, p->code);
				p->forw->op = ASH;
				p->op = MOV;
				p->code = "r2,#-%1";
			}
			break;
		case 3:
			if (xw[0]->code[1] >= '0' && xw[0]->code[1] <= '9' && equstr(xw[0]->code, xw[2]->code) && xhdeq(xw[0]->code, xw[1]->code + 3)
			    && xw[3]->code[4] >= '0' && xw[3]->code[4] <= '9') {
				/* unlink the second inc, put it behind the byte store */
				xw[2]->back->forw = xw[2]->forw;
				xw[2]->forw->back = xw[2]->back;
				xw[2]->forw = xw[4]->forw;
				xw[2]->back = xw[4];
				xw[4]->forw->back = xw[2];
				xw[4]->forw = xw[2];
			}
			break;
		case 4:
			xins(p, "rh2,rh2");
			p->forw->op = XOR;
			p->forw->subop = BYTE;
			break;
		}
}
#endif

/* c2x: parse the letters of one `-x<letters>` argument (or a group name) into xfl */
/* the letters of the flag bits: bit i of xfl / xfl2 is letter i of the string (c2.h order); `y` is bit 0 of xfl3 */
char	xl1[] = "pcmzkws73tr5T46W";
char	xl2[] = "eandgSoquvfhijbl";

#if !defined(C2X_LD) || !defined(C2X_CC) || !defined(C2X_C0) || !defined(C2X_CV)
/* W10aj: refuse a switch whose rule group is not built into this c2x variant (exit 1) */
xdeny(c)
{
	char t[2];

	t[0] = c;	/* xfm has no %c */
	t[1] = 0;
	fprintf(stderr, "c2x: switch -x%s needs a c2x variant with its rule group\n", t);
	exit(1);
}
#endif

xparse(s)
register char *s;
{
	register c, i;

	if (equstr(s, "push")) {
		xfl |= XR1;
		return;
	}
	if (equstr(s, "cmpmem")) {
		xfl |= XR4 | XR38;
		return;
	}
	if (equstr(s, "hzero")) {
		xfl |= XR2 | XR30 | XR63 | XR43 | XR7 | XR3 | XR10 | XR32;
		return;
	}
	while (c = *s++) {
		if (c == 'A') {
			xfl = 0x7FF | XR5 | XR42 | XR64 | XR63C;
			xfl2 |= XR45 | XR71 | XR34 | XR6 | XR65 | XR60 | XR70 | XR77 | XR92;
#ifdef C2X_LD
			xfl2 |= XR97 | XR98 | XR99 | XR100;
#endif
#ifdef C2X_C0
			xfl2 |= XR130 | XR131;
#endif
			continue;
		}
		/* W10aj: a letter of a rule group that this variant does not contain must not be accepted silently (wrong build) */
#ifndef C2X_LD
		if (c == 'f' || c == 'h' || c == 'i' || c == 'j')
			xdeny(c);
#endif
#ifndef C2X_CC
		if (c == 'y')
			xdeny(c);
#endif
#ifndef C2X_C0
		if (c == 'b' || c == 'l')
			xdeny(c);
#endif
#ifndef C2X_CV
		if (c == 'V')
			xdeny(c);
#endif
		for (i = 0; i < 16; i++) {
			if (xl1[i] == c)
				xfl |= 1 << i;
			if (xl2[i] == c)
				xfl2 |= 1 << i;
		}
#ifdef C2X_CC
		if (c == 'y')
			xfl3 |= XR93;
#endif
#ifdef C2X_CV
		if (c == 'V')
			xfl3 |= XRCV;
#endif
	}
}
#endif
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
#ifdef C2X
	xfl2 = 0;
	xfl3 = 0;
	xfl = 0;	/* explicit: flag-less guest runs showed stray bits in the BSS word (W10o) */
	while (argc>1 && argv[1][0]=='-' && argv[1][1]=='x') {
		xparse(argv[1]+2);	/* -x<letters>, -xpush, -xcmpmem, -xhzero, -xA (all) */
		argc--;
		argv++;
	}
#endif
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
#ifdef C2X
		if (xfl & XR38)
			cmppass();	/* c2x -xcmpmem: R0 reuse behind a short jr cc (R38) */
#endif
#ifdef C2X
		if (xfl & XR2)
			hzpass();	/* c2x -xhzero: late deletion of dead xorb (rule R2) */
#endif
#ifdef C2X
		if ((xfl & (XR5 | XR42 | XR64 | XR63C)) || (xfl2 & ~XR_SH))
			r5pass();	/* c2x -x5/-x4/-x6: R5, R42, R64 (W10t) */
#endif
#ifdef C2X
#ifdef C2X_CC
		if (xfl3 & XR93)
			xccpass();	/* c2x -xy: R93-R96 (cc, W10ah) */
#endif
#ifdef C2X_CV
		if (xfl3 & XRCV)
			xcvpass();	/* c2x -xV: R72-R76 (convert, W10ak) */
#endif
#endif
		output();
		if (niter > maxiter)
			maxiter = niter;
		lasta = firstr;
#ifdef C2X
		for (c = 0; c < XIHS; c++)
			xih[c] = 0;	/* the shared strings lived in the heap that was just released */
#endif
	} while (isend);
	if (nflag) {
#ifdef C2X
		/* W10aa: only the heap figure (the statistics strings cost ~400 bytes of the 64 KB image) */
#else
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
#endif
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
#ifdef C2X
	int h, k;
#endif

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
#ifdef C2X
	/* W10w: equal strings are stored once.  c2x is 6.7 KB bigger than c2 and the process has no more than 64 KB for text, data, heap and
	   stack (sbrk does not check): the biggest function of `as` (encode, 61K core with plain c2) did not fit any more.  The code strings
	   are never written after copy() (all writers work on regs[]) and nobody compares the pointers, so sharing is invisible.
	   Chains of the interned strings hang off xih[]; the link word sits in front of each string. */
	if ((xfl2 & XR_SH) && n <= XTBSZ && (int)lasta - (int)firstr > XTHR) {
		np = xtb;
		p = ap;
		while (*np++ = *p++)
			;
		if (na>1) {
			p = (&ap)[1];
			np--;
			while (*np++ = *p++);
		}
		h = 0;
		for (p = xtb; *p; p++)
			h = h*3 + *p;
		h = (h & 077777) % XIHS;
		/* exact comparison: equstr() treats `#%5` and `#5` as equal, which must not merge two different strings */
		for (onp = xih[h]; onp; onp = *(char **)(onp - 2)) {
			for (p = onp, np = xtb; *p == *np; p++, np++)
				if (*p == 0)
					return(onp);
		}
		k = n;
		np = alloc(k + 2);
		*(char **)np = xih[h];
		onp = np + 2;
		xih[h] = onp;
		for (np = xtb; *onp++ = *np++; )
			;
		return(xih[h]);
	}
#endif
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
#ifdef C2X
shortjmp()
{
	register struct node *p;

	nchange = 0;
	for (p = first.forw; p!=0; p = p->forw)
		if ((p->op==JMP || p->op==CBR) && p->labno && (!toofar(p, 0) || ((xfl2 & (XR77 | XR92 | XR131)) && xsite(p)))) {
			p->op--;
			nchange++;
		}
}
#else
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
#endif

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

#ifdef C2X
/* W10aa: minimal formatted output, replaces printf/fprintf/sprintf (see c2.h; lives in c20.c: c21.o is near the symbol table limit of `as`).  Conversions: %d %s %x %%; ONE argument at most.
 * to = FILE * (fp != 0) or a buffer (fp == 0, NUL terminated). */
xfm(fp, to, f, a)
register char *f;
char *to;
{
	register int c, n, k;
	register char *s;
	char t[8];

	while (c = *f++) {
		s = 0;
		if (c == '%' && *f) {
			c = *f++;
			if (c == 's')
				s = (char *)a;
			else if (c == 'd' || c == 'x') {
				n = a;
				k = c == 'd' ? 10 : 16;
				if (c == 'd' && n < 0) {
					xout(fp, &to, '-');
					n = -n;
				}
				s = t + 7;
				*s = 0;
				do {
					*--s = "0123456789ABCDEF"[n % k];
					n = n / k;
				} while (n);
			}
		}
		if (s == 0)
			xout(fp, &to, c);
		else while (*s)
			xout(fp, &to, *s++);
	}
	if (fp == 0)
		*to = 0;
}

xout(fp, top, c)
register char **top;
{
	char ch;

	if (fp == 0)
		*(*top)++ = c;
	else if (fp == 1)
		xputc(c);
	else {
		ch = c;
		write(fp, &ch, 1);
	}
}

xpf(fp, f, a)
{
	xfm(fp, 0, f, a);
}

xpo(f, a)
{
	xfm(1, 0, f, a);
}

xsp(b, f, a)
{
	xfm(0, b, f, a);
}

/* buffered stdin/stdout.  Initialised data, not BSS (F1). */
#define	XBS	32	/* W10ai: was 256 (initialised data, 2 buffers) */
char	xib[XBS] = {0};
char	xob[XBS] = {0};
int	xin = 0, xip = 0, xon = 0, xifd = 0, xofd = 1;

xputc(c)
{
	if (xon >= XBS)
		xflush();
	xob[xon++] = c;
	return(c);
}

xgetc()
{
	if (xip >= xin) {
		xip = 0;
		if ((xin = read(xifd, xib, XBS)) <= 0) {
			xin = 0;
			return(-1);
		}
	}
	return(xib[xip++] & 0377);
}

xflush()
{
	if (xon > 0)
		write(xofd, xob, xon);
	xon = 0;
}

/* freopen(name, mode, stdin|stdout): returns 0 on failure */
xfro(name, mode, fp)
char *name;
{
	register fd;

	if (fp == 0)
		fd = xifd = open(name, 0);
	else
		fd = xofd = creat(name, 0666);
	return(fd >= 0);
}

xexit(s)
{
	xflush();
	_exit(s);
}

/* libc's _exit calls _cleanup (fflush of all streams); defining it here keeps _flsbuf out of the image */
_cleanup()
{
}
#endif
