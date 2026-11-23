/*
 * Header for object code improver (MUTOS 8000 c2, Z8000)
 *
 * Differs from V7: the opcode numbers are the ones of the MUTOS optab (measured at
 * 0x4286 in the binary), registers are tracked in 38 slots, the jump
 * ops come in a short (jr) and a long (jp) form.  All names are Annahme except
 * those taken over from V7 c2.h.  Built with c20.c: every global below has the address of
 * the original (BSS from 0x4A10, checked), `ccpad` fills a 2-byte gap (Annahme).
 */

#include <stdio.h>

#define	CBRS	1		/* jr cc,L */
#define	CBR	2		/* jp cc,L */
#define	JBR	3		/* jr L */
#define	JMP	4		/* jp L */
#define	JSW	5		/* WV L (jump switch word) */
#define	LABEL	6
#define	DLABEL	7
#define	EROU	8		/* E (entry) */
#define	LDIL	9		/* ldil */
#define	MOV	10		/* ld */
#define	CLR	11
#define	COM	12
#define	INC	13
#define	DEC	14
#define	NEG	15
#define	TST	16		/* test */
#define	ASR	17		/* sra */
#define	ASL	18		/* sla */
#define	SXT	19		/* exts */
#define	CMP	20
#define	ADD	21
#define	SUB	22
#define	BIS	23		/* or */
#define	BIC	24		/* and */
#define	SDL	25
#define	MUL	26		/* mult */
#define	DIV	27
#define	ASH	28		/* sda */
#define	XOR	29
#define	TEXT	30
#define	CODE	31
#define	DSEC	32	/* $SECTION c_d */
#define	SDEF	33
#define	BSS	34
#define	EVEN	35
#define	DATA	36	/* no optab entry: pseudo segment id (lastseg, dead test in iterate) */
#define	CMT	37		/* ! */
#define	MULS	38		/* mul */
#define	CPZX	39
#define	CPFX	40
#define	SET	41
#define	RES	42
#define	BIT	43
#define	EX	44
#define	POP	45
#define	PUSH	46
#define	CALL	47
#define	END	48
#define	SETM	49
#define	SRL	50
#define	SLL	51
#define	SOB	52		/* djnz */
#define	LDIR	53
#define	LDDR	54
#define	LDK	55
#define	LDCTL	56
#define	RESM	57

#define	JEQ	0
#define	JNE	1
#define	JLE	2
#define	JGE	3
#define	JLT	4
#define	JGT	5
#define	JLO	6
#define	JHI	7
#define	JLOS	8
#define	JHIS	9
#define	JPL	10
#define	JMI	11

#define	BYTE	0x40
#define	LONG	0x20
#define	SINGLE	0x11
#define	DOUBLE	0x12
#define	FLTF	0x10
#define	LSIZE	512

struct node {
	char	op;
	char	subop;
	struct	node	*forw;
	struct	node	*back;
	struct	node	*ref;
	int	labno;
	char	*code;
	int	refc;
};

struct optab {
	char	*opstring;
	int	opcode;
};

char	line[LSIZE];
struct	node	first;
char	*curlp;
int	nbrbr;
char	regcl;
int	nsaddr;
int	redunm;
int	iaftbr;
int	njp1;
int	nrlab;
int	nxjump;
int	ncmot;
int	nrevbr;
int	loopiv;
int	nredunj;
int	nskip;
int	ncomj;
int	nsob;
int	nrtst;
int	nlit;

int	nchange;
int	isn;
int	debug;
int	lastseg;
char	*lasta;
char	*lastr;
char	*firstr;

#define	RT1	36
#define	RT2	37
#define	FREG	28
#define	NREG	36
#define	LABHS	127
#define	OPHS	79

char	regs[38][20];
char	rsz[38];
struct node *rnode[38];
char	cregs[8][20];
char	conloc[20];
char	conlsz;
char	conval[20];
char	convsz;
char	ccloc[20];
char	ccpad;		/* Annahme: unreferenced; fills the BSS gap 5096..5098 */
char	ccsz;
int	fflag;
struct optab *ophash[OPHS];

struct	node *nonlab();
char	*copy();
char	*sbrk();
char	*alloc();
struct	node *insertl();
struct	node *codemove();

#ifdef C2X
/* c2x run-time switches (W10o): one flag word `xfl`, one bit per rule of the older c2 (doc/userspace/wk_w10o.md).  Set by `-x<letters>` in main(). */
extern int xfl;
extern int xfl2;	/* second flag word (xfl is full): bits XR45.. */
#define	XR1	0x1	/* p  inc SP,#n+2 ; push stays unmerged */
#define	XR4	0x2	/* c  cp MEM,#k -> ld r0,MEM ; cp r0,#k */
#define	XR38	0x4	/* m  R0 reuse behind a short jr cc (needs c) */
#define	XR2	0x8	/* z  late deletion of a dead xorb before a byte store */
#define	XR30	0x10	/* k  exception to z: testb of the stored value */
#define	XR63	0x20	/* w  exception to z: word move + test of the register behind the store */
#define	XR43	0x40	/* s  exception to z: struct member array element copy */
#define	XR7	0x80	/* 7  xorb kept between ldb rlN,mem and cp rN,.. */
#define	XR3	0x100	/* 3  xorb kept before the final jr behind cp ; jr cc */
#define	XR10	0x200	/* t  xorb kept before add rN behind cp ; jr cc */
#define	XR32	0x400	/* r  xorb kept before the 2nd cp of a compare chain */
#define	XR5	0x800	/* 5  R5: ld rA,rB ; test rB -> test rA, ld rA,rB ; ld DST,rB -> ld DST,rA (W10t) */
#define	XR5T	0x1000	/* T  pseudo rule R5T: with 5 only the `ld DST` form (pr) */
#define	XR42	0x2000	/* 4  R42: ld rN,SRC ; ld MEM,rN ; test rN -> test MEM */
#define	XR64	0x4000	/* 6  R64: long compare chain works on the memory copy first (df) */
#define	XR63C	0x8000	/* W  R63 copy part: ld rK,rN ; ld rX,rN ; test rN behind the store -> ld rX,rK ; test rK (mv, W10v) */
#define	XR71	0x2	/* a  (xfl2) R71: ld rA,%k(FP) ; ld rB,rA ; jr L -> ld rB,%k(FP) (ar, W10w) */
#define	XR34	0x4	/* n  (xfl2) R34: ld MEM,rN ; test rN ; jr eq|ne ; jr mi|pl|lt|ge|gt|le -> test rN repeated after the first jump (cp, W10w) */
#define	XR6	0x8	/* d  (xfl2) R6: ld rA,M ; testb @rA ; jr cc ; ld rB,rA -> ld rB,M (date, W10w) */
#define	XR65	0x10	/* g  (xfl2) R65: ld rN,#k ; ldl rr2,X ; xor r0,r0 ; ld r1,rN ; cpl rr2,rr0 -> ld r1,#k (strip, W10w) */
#define	XR_SH	0x20	/* S  (xfl2) shared strings in copy() above a heap use of XTHR (as_code, W10z) */
#define	XR45	0x1	/* e  (in xfl2) R45: xor r2,r2 ; div rr2,#k -> exts rr2 ; div rr2,#k (ld, ncheck, nm; W10v) */
#endif
