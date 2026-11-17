/*
 * Header for object code improver (MUTOS 8000 c2, Z8000)
 *
 * Differs from V7: the opcode numbers are the ones of the MUTOS optab (measured at
 * 0x4286 in the binary), registers are tracked in 38 slots, the jump
 * ops come in a short (jr) and a long (jp) form.  All names are Annahme except
 * those taken over from V7 c2.h.
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
char	ccsz;
int	fflag;
struct optab *ophash[OPHS];

struct	node *nonlab();
char	*copy();
char	*sbrk();
char	*alloc();
struct	node *insertl();
struct	node *codemove();
