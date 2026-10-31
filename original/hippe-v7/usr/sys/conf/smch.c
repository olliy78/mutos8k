/ machine language assist
/ for 11/23, 34, 40, 60

#include "m.h"

/ non-UNIX instructions
mfpi	= 6500^tst
mtpi	= 6600^tst
halt	= 0
wait	= 1
reset	= 5
rtt	= 6

/ system dump
/ save registers in low core and
/ write all core onto dump device.
/ entry is thru 44 abs

.globl	dump
dump:

/ save regs r0,r1,r2,r3,r4,r5,r6,KIA6
/ starting at abs location 4

	mov	r0,4
	mov	$6,r0
	mov	r1,(r0)+
	mov	r2,(r0)+
	mov	r3,(r0)+
	mov	r4,(r0)+
	mov	r5,(r0)+
	mov	sp,(r0)+
	mov	KISA6,(r0)+

/ dump all of core (ie to first error)
/ to selected dump device
#ifdef TUDUMP
MTC = 172522
	mov	$MTC,r0
	mov	$[60004|[TUDUMP\<8.]],(r0)+
	clr	2(r0)
1:
	mov	$-512.,(r0)
	inc	-(r0)
2:
	tstb	(r0)
	bge	2b
	tst	(r0)+
	bge	1b
	reset

	mov	$60007,-(r0)
#endif TUDUMP

#ifdef RKDUMP
RKC = 177404
	mov	$RKC,r0
	mov	$2,(r0)+
	clr	2(r0)
	mov	$[RKDUMP\<13.],4(r0)
1:
	mov	$-256.,(r0)
	inc	-(r0)
2:
	tstb	(r0)
	bpl	2b
	tst	(r0)+
	bpl	1b
#endif RKDUMP

#ifdef RLDUMP
RLC = 174400
	mov	$RLC,r0
	clr	2(r0)
	clr	4(r0)
1:
	mov	$-256.,6(r0)
	mov	$[12|[RLDUMP\<8.]],(r0)
2:
	tstb	(r0)
	bpl	2b
	tst	(r0)
	bpl	1b
#endif RLDUMP

/ loop when dump complete (or failed)
	br	.

.globl	start, _end, _edata, _main
start:
	mov	$trap,34

/ Set location 0 and 2 to catch traps and jumps to 0
/
/	mov	$42,0		/ illegal instruction if jump
/	mov	$777,2		/ trace trap at high priority if trap
/

/
/ set loc. 0 to trap to system, in case of
/ hardware glitch
/
	mov	$trap,0		/ in case of bad trap through 0
	mov	$340+15.,2	/ high pri, trap type 15

/ initialize user segment

	mov	$_end+63.,r2
	ash	$-6,r2
	bic	$!1777,r2
	mov	r2,KISA6		/ ksr6 = sysu
	mov	$usize-1\<8|6,KISD6

/ get a sp
	mov	$_u+[usize*64.],sp

/ clear user block

	mov	$_u,r0
1:
	clr	(r0)+
	cmp	r0,sp
	blo	1b

#ifdef XBUF
/
/ initialise the saved u-area
/ address to current
/
	mov	KISA6,_curr_u
#endif XBUF

/ set up previous mode and call main
/ on return, enter user mode at 0R

	mov	$30000,PS
	jsr	pc,_main
	mov	$170000,-(sp)
	clr	-(sp)
	rtt

.globl	trap, call
.globl	_trap

/ all traps and interrupts are
/ vectored thru this routine.

trap:
	mov	PS,saveps
	tst	nofault
	bne	1f
	mov	SSR0,ssr
	mov	SSR2,ssr+4
	mov	$1,SSR0
	jsr	r0,call1; jmp _trap
	/ no return
1:
	mov	$1,SSR0
	mov	nofault,(sp)
	rtt
.text

.globl	_runrun
call1:
	mov	saveps,-(sp)
	bic	$HIPRI,PS
	br	1f

call:
	mov	PS,-(sp)
1:
	mov	r1,-(sp)
	mfpi	sp
	mov	4(sp),-(sp)
	bic	$!37,(sp)
	bit	$30000,PS
	beq	1f
	jsr	pc,(r0)+
	tstb	_runrun
	beq	2f
	mov	$12.,(sp)		/ trap 12 is give up cpu
	jsr	pc,_trap
2:
	tst	(sp)+
	mtpi	sp
	br	2f
1:
	bis	$30000,PS
	jsr	pc,(r0)+
	cmp	(sp)+,(sp)+
2:
	mov	(sp)+,r1
	tst	(sp)+
	mov	(sp)+,r0
	rtt
.globl	_savfp
_savfp:
#ifdef FPP
	mov	2(sp),r1
	stfps	(r1)+
	setd
	movf	fr0,(r1)+
	movf	fr1,(r1)+
	movf	fr2,(r1)+
	movf	fr3,(r1)+
	movf	fr4,fr0
	movf	fr0,(r1)+
	movf	fr5,fr0
	movf	fr0,(r1)+
#endif FPP
	rts	pc

.globl	_restfp
_restfp:
#ifdef FPP
	mov	2(sp),r1
	mov	r1,r0
	setd
	add	$8.+2.,r1
	movf	(r1)+,fr1
	movf	(r1)+,fr2
	movf	(r1)+,fr3
	movf	(r1)+,fr0
	movf	fr0,fr4
	movf	(r1)+,fr0
	movf	fr0,fr5
	movf	2(r0),fr0
	ldfps	(r0)
#endif FPP
	rts	pc

.globl	_addupc
_addupc:
	mov	r2,-(sp)
	mov	6(sp),r2		/ base of prof with base,leng,off,scale
	mov	4(sp),r0		/ pc
	sub	4(r2),r0		/ offset
	clc
	ror	r0
	mov	6(r2),r1
	clc
	ror	r1
	mul	r1,r0		/ scale
	ashc	$-14.,r0
	inc	r1
	bic	$1,r1
	cmp	r1,2(r2)		/ length
	bhis	1f
	add	(r2),r1		/ base
	mov	nofault,-(sp)
	mov	$2f,nofault
	mfpi	(r1)
	add	12.(sp),(sp)
	mtpi	(r1)
	br	3f
2:
	clr	6(r2)
3:
	mov	(sp)+,nofault
1:
	mov	(sp)+,r2
	rts	pc


.globl	_display
_display:
	rts	pc

.globl	_backup
.globl	_regloc
_backup:
	mov	2(sp),ssr+2
	mov	r2,-(sp)
	jsr	pc,backup
	mov	r2,ssr+2
	mov	(sp)+,r2
	movb	jflg,r0
	bne	2f
	mov	2(sp),r0
	movb	ssr+2,r1
	jsr	pc,1f
	movb	ssr+3,r1
	jsr	pc,1f
	movb	_regloc+7,r1
	asl	r1
	add	r0,r1
	mov	ssr+4,(r1)
	clr	r0
2:
	rts	pc
1:
	mov	r1,-(sp)
	asr	(sp)
	asr	(sp)
	asr	(sp)
	bic	$!7,r1
	movb	_regloc(r1),r1
	asl	r1
	add	r0,r1
	sub	(sp)+,(r1)
	rts	pc

/
/ Hard part - simulate the SSR1 register which DEC fail to
/ provide on the /23, /34, /40 and /60.
/		14 Sept. '80 David S. H. Rosenthal
/
/ The basic cases are as follows:-
/
/ 1.	op dd
/	The fault happened on the dd.
/
/ 2.	op ss,dd
/	The fault may have happened on either the ss or dd. "backup"
/	evaluates and fetches the ss. If this process faults, the
/	adjustment of the dd register [delta(dd)] is zeroed. Things
/	would be easier if the hardware recorded what it was fetching.
/
/ 3.	mfp[id]	ss
/	Handled like mov ss,-(sp).
/
/ 4.	mtp[id] dd
/	Handled like mov (sp)+,dd.
/
/ 5.	jsr r,dd
/	The hardware evaluates, but does not fetch, dd and then pushes
/	the initial value of r onto the stack. "backup" assumes that the
/	fault is in the stack push (you shouldn't be jsr-ing via non-
/	existent locations!) and adjusts both the dd register and the sp.
/
/ 6.	FP11 op
/	The operands may be 2, 4 or 8 bytes long, depending upon the
/	particular operation and the "floating double" and "long integer"
/	bits.
/
/ 7.	illegal stuff like "mark"
/
/ There are also various special cases which depend upon the
/ particular processor you're running, and how adventurous you feel.
/
/
/ #define BUP_RR = 0	/ op ss,dd
/
/ If both the ss and dd refer to the same register, and if delta(dd)
/ is non-zero, it is impossible to distinguish an ss from a dd fault.
/ Set BUP_RR to 1 (define) to assume:-
/	If delta(ss) == 0 then dd fault else failure.
/ This permits, for example, a push fault in mov (sp),-(sp) to be
/ backed-up correctly. However, a source fault would be backed-up
/ incorrectly, and without warning. Set BUP_RR to 0 unless you are
/ absolutely certain.
/
/ BUP_M2D 	/ for op (r)+ (defined in "m.h")
/
/ Set BUP_M2D to 0 on machines which fault an op (r)+ with the
/ register in its FINAL state. Set it 1 (define) on machines which
/ fault an op (r)+ with the register in its INITIAL state.
/
/ BUP_M2S 	/ for op (r)+,dd (defined in "m.h")
/
/ Set BUP_M2S to 0 on machines which fault an (r)+ source with the
/ registers in their FINAL state. Set it 1 (define) on machines which
/ fault an (r)+ source with the registers in their INITIAL state.
/ On these machines there are 4 cases:-
/
/	Case	Before		After	Faults
/			------
/	1.		//////	<- r
/			------		none
/		  r ->	/////
/			------
/
/			------
/	2.			<- r
/			------		r, not r-2
/		  r ->	/////
/			------
/
/			------
/	3.	  r ->		<- r
/			------		r, not r-2
/			/////
/			------
/
/			------
/	4.	  r ->		<- r
/			------		r and r-2
/
/			------
/
/ Cases 2 and 3 are indistinguishable after the fact, and so a backup
/ failure must be signalled if either is detected.
/
/ BUP_FPP 	/ for FP11 ops (defined in "m.h")
/
/ Set BUP_FPP to zero on machines which fault FP11 ops with the registers
/ in their INITIAL state if the operand was 4 or 8 bytes long. Set it 1
/ (define) on machines which fault these operations with the
/ register in their FINAL state.
/
/ BUP_SP	/ (defined in "m.h")
/
/ If any operations are aborted with the registers in their INITIAL
/ state, then BUP_SP must be set to 1 (defined) to include the code for
/ "fix"-ing the stack in these cases.
/
/ To the best of our knowledge, the settings should be:-
/
/	Machine	      BUP_FPP BUP_M2S BUP_M2D BUP_SP
/	/40		0	0	0	0
/	/34+FP11A	1	1	1	1
/	/60		0	0	0	1
/	/60+FP11E	0	0	0	1
/	/23+KEF11A	1	?	?	?
/


/
/ Enter here with address of register save area in ssr+2,
/ and FP11 status in ssr+6. First sort out op-code.
/
backup:
	clr	r2		/ r2 stands for SSR1
	clr	bflg		/ jflg = 0; bflg = 0 for byte op.
	mov	ssr+4,r0	/ r0 = virtual pc.
	jsr	pc,fetch	/ get instruction word.
	mov	r0,r1
	ash	$-11.,r0
	bic	$!36,r0
	mov	0f(r0),pc	/ switch on xx----
/
/ Note that DEC's frequency-driven micro-code design means that
/ mov is usually faster than jmp, but it zaps the condition codes!
/
0:	t00;	t01;	t02;	t03;	t04;	t05;	t06;	t07
	t10;	t11;	t12;	t13;	t14;	t15;	t16;	t17

t00:
	incb	bflg		/ bflg = 1 for 2 byte op.
t10:
	mov	r1,r0
	swab	r0
	bic	$!16,r0
	mov	0f(r0),pc	/ switch on 00x--- or 10x---

0:	u0;	u1;	u2;	u3;	u4;	u5;	u6;	u7

u6:
	mov	r1,r0
	ash	$-5,r0
	bic	$!16,r0
	mov	0f(r0),pc	/ switch on 006x-- or 106x--

u60 = u5	/ ror, rorb
u61 = u5	/ rol, rolb
u62 = u5	/ asr, asrb
u63 = u5	/ asl, aslb
u64 = u7	/ mark, mtps
u67 = u5	/ sxt, mfps

0:	u60;	u61;	u62;	u63;	u64;	u65;	u66;	u67

u66:	/ simulate mtp[id] with mov (sp)+,dd
	bic	$4000,r1	/ make mode (sp)+
	br	1f

u65:	/ simulate mfp[id] with mov ss,-(sp)
	ash	$6,r1		/ move dd to ss
	bis	$46,r1		/ make dd -(sp)
1:	clrb	bflg		/ 2 byte ops - bflg ends up 1.
	br	t01		/ treat as mov

u4:	/ jsr = x04---
	mov	r1,r0
	jsr	pc,setreg	/ set up dd adjust
	bis	$173000,r2	/ delta(sp) = 2
	rts	pc

t07:	/ EIS = 07----
	incb	bflg		/ bflg = 1 for 2 byte op

u0:	/ swab, jmp = x00---
u5:	/ single operand = x05-dd
#ifdef BUP_M2D
	mov	r1,r0		/ (r)+ faults to
	ash	$-3,r0		/ INITIAL state
	bic	$!7,r0
	cmp	r0,$2		/ mode 2?
	bne	u51
	mov	$fixstk,pc	/ yes - fix stack
#endif BUP_M2D
u51:
	mov	r1,r0

/
/ setreg - put reg + delta into low byte of r2
/
setreg:
	mov	r0,-(sp)	/ mode+reg in r0
	bic	$!7,r0
	bis	r0,r2		/ put reg in r2
	mov	(sp)+,r0
	ash	$-3,r0
	bic	$!7,r0		/ mode in r0
	movb	adj(r0),r0	/ adjust in r0
	movb	bflg,-(sp)	/ push shift count
	bne	1f		/ not byte operand - skip
	bit	$2,r2		/ byte operand with
	beq	3f		/ sp or pc
	bit	$4,r2		/ is really word op
	beq	3f		/ so drop thru
1:
	bit	$10,r0		/ length dependent?
	beq	3f		/ no - dont shift
2:
	asl	r0		/ delta = 2**bflg
	decb	(sp)
	bgt	2b
3:
	tst	(sp)+		/ clean stack
	bisb	r0,r2		/ put delta in r2
	rts	pc

adj:	.byte	0, 0, 10, 20, -10, -20, 0, 0

t01:	/ mov
t02:	/ cmp
t03:	/ bit
t04:	/ bic
t05:	/ bis
t06:	/ add
t16:	/ sub
	incb	bflg		/ bflg = 1 for 2 byte op
t11:	/ movb
t12:	/ cmpb
t13:	/ bitb
t14:	/ bicb
t15:	/ bisb
	mov	r1,r0		/ op ss,dd
	ash	$-6,r0
	jsr	pc,setreg	/ for ss
	swab	r2
	mov	r1,r0
	jsr	pc,setreg	/ for dd

/
/ r2 now has delta(ss) in hi byte and delta(dd) in low byte.
/ Evaluate and fetch ss, zeroing delta(dd) if a fault occurs.
/ See fetch for details of how this happens.
/ 1.	If delta(dd) == 0 dont bother.
/
	bit	$370,r2
	beq	1f
/
/ 2.	If mode(ss) is R, it can't have faulted.
/
	bit	$7000,r1
	beq	1f
/
/ 3.	register(ss) == register(dd)?
/
	mov	r2,-(sp)
	bic	$174370,(sp)
	cmpb	1(sp),(sp)+
	bne	3f
/
/ 4.	Yes, but if delta(ss) == 0 we may assume a dd fault
/
#ifdef BUP_RR
	bit	$174000,r2
	beq	1f
#endif BUP_RR
	mov	$u7,pc
1:
	rts	pc
3:

#ifdef BUP_M2S
/
/ Try to deal with problems caused by /34 etc. faulting op (r)+,dd
/ source to INITIAL state.
/
	mov	r1,r0
	bic	$!7000,r0	/ r0 = mode(ss)
	cmp	$2000,r0	/ (r)+?
	beq	4f		/ yes - problems
	jsr	pc,1f		/ no - get r
	jsr	pc,2f		/ adjust for increment
	jsr	pc,3f		/ fetch it
	rts	pc		/ and quit

/
/ Its an op (r)+,dd. If a fetch on r fails to fault, then it was
/ a destination fault.
/
4:
	mov	r2,-(sp)	/ save SSR1
	jsr	pc,1f		/ get r
				/ NB - no adjust
	jsr	pc,3f		/ fetch it
	tstb	r2		/ did it fault?
	beq	4f		/ yes - try r-2
	tst	(sp)+		/ no - clean up
	rts	pc		/ its a dd fault

/
/ Fetch on r faults. If fetch on r-2 also faults, then its an ss fault.
/
4:
	mov	(sp)+,r2	/ restore SSR1
	jsr	pc,1f		/ get r
	jsr	pc,2f		/ adjust for increment
	jsr	pc,3f		/ fetch it
	tstb	r2		/ did it fault?
	bne	u7		/ no - failure
	ash	$-6,r1		/ yes - place ss
	br	fixstk		/ and fix stack
1:
#endif BUP_M2S

/
/ Zero delta(dd) if the ss faults (see fetch).
/ Start ss cycle by picking up the register value.
/
	mov	r1,r0
	ash	$-6,r0
	bic	$!7,r0		/ r0 = reg no.
	movb	_regloc(r0),r0
	asl	r0
	add	ssr+2,r0
	mov	(r0),r0		/ r0 = contents reg(ss)
#ifdef BUP_M2S
	rts	pc
2:
#endif BUP_M2S

/
/ If register incremented, must decrement before fetch. If register
/ decremented, happened before fetch.
/
	bit	$174000,r2
	ble	4f
	dec	r0
	bit	$10000,r2
	beq	4f		/ delta = 1
	dec	r0		/ delta = 2
4:
#ifdef BUP_M2S
	rts	pc
3:
#endif BUP_M2S

/
/ If mode 6 or 7 fetch and add X(r)
/
	bit	$4000,r1
	beq	4f
	bit	$2000,r1
	beq	4f
	mov	r0,-(sp)	/ mode 6 or 7
	mov	ssr+4,r0	/ virtual pc
	add	$2,r0
	jsr	pc,fetch	/ get X
	add	(sp)+,r0	/ add it in
4:

/
/ Fetch operand
/
	jsr	pc,fetch
/
/ If mode 3, 5 or 7 fetch *.
/
	bit	$1000,r1
	beq	4f
	bit	$6000,r1
	bne	fetch
4:
	rts	pc

t17:	/ FP11 op
#ifdef FPP
	incb	bflg		/ assume 2 bytes
	mov	r1,r0
	ash	$-7,r0
	bic	$!36,r0
	mov	0f(r0),pc	/ switch on 17x(x..)--

fp50 = u51	/ stexp is 2 bytes
fp64 = u51	/ ldexp is 2 bytes (Check this sometime!)

0:	fp00;	fp04;	fp10;	fp14;	fp20;	fp24;	fp30;	fp34;
	fp40;	fp44;	fp50;	fp54;	fp60;	fp64;	fp70;	fp74;

fp00:	/ ldfps, stfps, stst + others which can't fault.
	cmp	r1,$170300	/ stst?
	bhi	1f		/ stst is 4 bytes (for this purpose)
	mov	$u51,pc		/ ldfps, stfps are 2 bytes.

fp54:	/ stcfi
fp70:	/ ldcif
	stfps	r0		/ if long integer mode
	bit	$100,r0
	bne	1f		/ its 4 bytes
	mov	$u51,pc		/ else its really 2 bytes

fp60:	/stcfd
fp74:	/ldcfd
	incb	bflg		/ assume 4 bytes
#ifdef BUP_23
/
/ If one of these 'length changers' fails - the floating
/ double bit in the FP status register is left in the
/ opposite state to that in which it started.
/
	stfps	-(sp)		/ bloody stupid XOR instruction
	mov	$0200,r0	/ floating double bit
	xor	r0,(sp)		/ change it back
	ldfps	(sp)
	tstb	(sp)+
#else
	stfps	r0
	tstb	r0
#endif BUP_23
	bmi	0f		/ its really is
	br	1f		/ else its 8 bytes

fp04:	/ clrf tstf, absf, negf
fp10:	/ mulf
fp14:	/ modf
fp20:	/ addf
fp24:	/ ldf
fp30:	/ subf
fp34:	/ cmpf
fp40:	/ stf
fp44:	/ divf
	incb	bflg		/ assume 4 bytes
	stfps	r0
	tstb	r0		/ if not floating double
	bpl	0f		/ it really is
1:	incb	bflg		/ else its 8 bytes
0:
#ifdef BUP_FPP
	jbr	u51
#else
	jbr	fixstk
#endif BUP_FPP
#endif FPP
u1:	/ br
u2:
u3:
u7:	/ illegal
	incb	jflg
	rts	pc

#ifdef BUP_SP
/ Operation was aborted with registers in INITIAL state, so
/ no backup is required (why don't they all work that way?).
/ However, "grow()" examines the sp, and grows the stack iff it
/ points outside the valid stack. If the sp is in its INITIAL
/ state, it will point to a valid stack address, and SIGSEG will
/ occur. To avoid this, the sp seen by "grow()" must be adjusted
/ to its FINAL state. The sp seen by "grow()" is local register
/ variable "a" in "trap()"; "_backup()" does not save the registers,
/ so this is r3.
/
fixstk:
	mov	r1,r0
	bic	$!7,r0
	cmp	$6,r0		/ affecting sp?
	bne	3f		/ no - quit
	mov	r1,r0
	ash	$-3,r0
	bic	$!7,r0		/ r0 = mode
	movb	adj(r0),r0	/ get adjust
	tstb	bflg		/ byte op?
	bne	0f		/ no - skip
	incb	bflg		/ yes - on sp is word op
0:	ash	$-3,r0		/ r0 = adjust proper
	bit	$1,r0		/1 or -1
	beq	2f		/ no - deferred or zero
1:	asl	r0		/ exponentiate
	decb	bflg		/ bflg times
	bgt	1b
2:	add	r0,r3		/ adjust "a"
3:	clr	r2		/ no register adjust
	rts	pc
#endif BUP_SP

fetch:
	bic	$1,r0
	mov	nofault,-(sp)
	mov	$1f,nofault
	mfpi	(r0)
	mov	(sp)+,r0
	mov	(sp)+,nofault
	rts	pc

1:
 	mov	(sp)+,nofault
	clrb	r2			/ clear out dest on fault
	mov	$-1,r0
	rts	pc

.bss
bflg:	.=.+1
jflg:	.=.+1
fflg:	.=.+1
.even
.text

.globl	_fubyte, _subyte
.globl	_fuibyte, _suibyte
.globl	_fuword, _suword
.globl	_fuiword, _suiword
_fuibyte:
_fubyte:
	mov	2(sp),r1
	bic	$1,r1
	jsr	pc,gword
	cmp	r1,2(sp)
	beq	1f
	swab	r0
1:
	bic	$!377,r0
	rts	pc

_suibyte:
_subyte:
	mov	2(sp),r1
	bic	$1,r1
	jsr	pc,gword
	mov	r0,-(sp)
	cmp	r1,4(sp)
	beq	1f
	movb	6(sp),1(sp)
	br	2f
1:
	movb	6(sp),(sp)
2:
	mov	(sp)+,r0
	jsr	pc,pword
	clr	r0
	rts	pc
_fuiword:
_fuword:
	mov	2(sp),r1
fuword:
	jsr	pc,gword
	rts	pc

gword:
	mov	PS,-(sp)
	bis	$HIPRI,PS
	mov	nofault,-(sp)
	mov	$err,nofault
	mfpi	(r1)
	mov	(sp)+,r0
	br	1f

_suiword:
_suword:
	mov	2(sp),r1
	mov	4(sp),r0
suword:
	jsr	pc,pword
	rts	pc

pword:
	mov	PS,-(sp)
	bis	$HIPRI,PS
	mov	nofault,-(sp)
	mov	$err,nofault
	mov	r0,-(sp)
	mtpi	(r1)
1:
	mov	(sp)+,nofault
	mov	(sp)+,PS
	rts	pc

err:
	mov	(sp)+,nofault
	mov	(sp)+,PS
	tst	(sp)+
	mov	$-1,r0
	rts	pc
	rts	pc
.globl	_copyin, _copyout
.globl	_copyiin, _copyiout
_copyiin:
_copyin:
	jsr	pc,copsu
1:
	mfpi	(r0)+
	mov	(sp)+,(r1)+
	sob	r2,1b
	br	2f

_copyiout:
_copyout:
	jsr	pc,copsu
1:
	mov	(r0)+,-(sp)
	mtpi	(r1)+
	sob	r2,1b
2:
	mov	(sp)+,nofault
	mov	(sp)+,r2
	clr	r0
	rts	pc

copsu:
	mov	(sp)+,r0
	mov	r2,-(sp)
	mov	nofault,-(sp)
	mov	r0,-(sp)
	mov	10(sp),r0
	mov	12(sp),r1
	mov	14(sp),r2
	asr	r2
	mov	$1f,nofault
	rts	pc

1:
	mov	(sp)+,nofault
	mov	(sp)+,r2
	mov	$-1,r0
	rts	pc

.globl	_idle, _waitloc
_idle:
	mov	PS,-(sp)
	bic	$HIPRI,PS
	wait
waitloc:
	mov	(sp)+,PS
	rts	pc
	.data
_waitloc:
	waitloc
	.text

.globl	_save
_save:
	mov	(sp)+,r1
	mov	(sp),r0
	mov	r2,(r0)+
	mov	r3,(r0)+
	mov	r4,(r0)+
	mov	r5,(r0)+
	mov	sp,(r0)+
	mov	r1,(r0)+
	clr	r0
	jmp	(r1)

.globl	_resume
_resume:
	mov	2(sp),r0		/ new process
	mov	4(sp),r1		/ new stack
	bis	$HIPRI,PS
#ifdef XBUF
	mov	r0,_curr_u
#endif XBUF
	mov	r0,KISA6		/ In new process
	mov	(r1)+,r2
	mov	(r1)+,r3
	mov	(r1)+,r4
	mov	(r1)+,r5
	mov	(r1)+,sp
	mov	$1,r0
	bic	$HIPRI,PS
	jmp	*(r1)+

.globl	_spl0, _spl1, _spl4, _spl5, _spl6, _spl7, _splx
_spl0:
	mov	PS,r0
	bic	$HIPRI,PS
	rts	pc

_spl1:
	mov	PS,r0
	bis	$HIPRI,PS
	bic	$300,PS
	rts	pc

_spl4:
	mov	PS,r0
	bis	$HIPRI,PS
	bic	$140,PS
	rts	pc

_spl5:
	mov	PS,r0
	bis	$HIPRI,PS
	bic	$100,PS
	rts	pc

_spl6:
	mov	PS,r0
	bis	$HIPRI,PS
	bic	$40,PS
	rts	pc

_spl7:
	mov	PS,r0
	bis	$HIPRI,PS
	rts	pc

_splx:
	mov	2(sp),PS
	rts	pc

.globl	_copyseg
_copyseg:
	mov	PS,-(sp)
	mov	UISA0,-(sp)
	mov	UISA1,-(sp)
	mov	$30340,PS
	mov	10(sp),UISA0
	mov	12(sp),UISA1
	mov	UISD0,-(sp)
	mov	UISD1,-(sp)
	mov	$6,UISD0
	mov	$6,UISD1
	mov	r2,-(sp)
	clr	r0
	mov	$8192.,r1
	mov	$32.,r2
1:
	mfpi	(r0)+
	mtpi	(r1)+
	sob	r2,1b
	mov	(sp)+,r2
	mov	(sp)+,UISD1
	mov	(sp)+,UISD0
	mov	(sp)+,UISA1
	mov	(sp)+,UISA0
	mov	(sp)+,PS
	rts	pc

.globl	_clearseg
_clearseg:
	mov	PS,-(sp)
	mov	UISA0,-(sp)
	mov	$30340,PS
	mov	6(sp),UISA0
	mov	UISD0,-(sp)
	mov	$6,UISD0
	clr	r0
	mov	$32.,r1
1:
	clr	-(sp)
	mtpi	(r0)+
	sob	r1,1b
	mov	(sp)+,UISD0
	mov	(sp)+,UISA0
	mov	(sp)+,PS
	rts	pc

/ Long quotient

	.globl	ldiv
ldiv:
	jsr	r5,csv
	mov	10.(r5),r3
	sxt	r4
	bpl	1f
	neg	r3
1:
	cmp	r4,8.(r5)
	bne	hardldiv
	mov	6.(r5),r2
	mov	4.(r5),r1
	bge	1f
	neg	r1
	neg	r2
	sbc	r1
	com	r4
1:
	mov	r4,-(sp)
	clr	r0
	div	r3,r0
	mov	r0,r4		/ high quotient
	mov	r1,r0
	mov	r2,r1
#ifdef DIV_FIX
	mov	r0,-(sp)
	div	r3,r0
	bvc	1f
	mov	(sp)+,r0
	mov	r2,r1
#else
	div	r3,r0
	bvc	1f
#endif DIV_FIX
	sub	r3,r0		/ this is the clever part
	div	r3,r0
	tst	r1
	sxt	r1
	add	r1,r0		/ cannot overflow!
#ifdef DIV_FIX
	br	2f
1:
	tst	(sp)+
2:
#else
1:
#endif DIV_FIX
	mov	r0,r1
	mov	r4,r0
	tst	(sp)+
	bpl	9f
	neg	r0
	neg	r1
	sbc	r0
9:
	jmp	cret

hardldiv:
	4

/ Long remainder

	.globl	lrem
lrem:
	jsr	r5,csv
	mov	10.(r5),r3
	sxt	r4
	bpl	1f
	neg	r3
1:
	cmp	r4,8.(r5)
	bne	hardlrem
	mov	6.(r5),r2
	mov	4.(r5),r1
	mov	r1,r4
	bge	1f
	neg	r1
	neg	r2
	sbc	r1
1:
	clr	r0
	div	r3,r0
	mov	r1,r0
	mov	r2,r1
#ifdef DIV_FIX
	mov	r0,(sp)
	div	r3,r0
	bvc	1f
	mov	(sp),r0
	mov	r2,r1
#else
	div	r3,r0
	bvc	1f
#endif DIV_FIX
	sub	r3,r0
	div	r3,r0
	tst	r1
	beq	9f
	add	r3,r1
1:
	tst	r4
	bpl	9f
	neg	r1
9:
	sxt	r0
	jmp	cret

/ The divisor is known to be >= 2^15.	Only 16 cycles are
/ needed to get a remainder.
hardlrem:
	4

/.globl	lmul
/lmul:
/	mov	r2,-(sp)
/	mov	r3,-(sp)
/	mov	8(sp),r2
/	sxt	r1
/	sub	6(sp),r1
/	mov	12.(sp),r0
/	sxt	r3
/	sub	10.(sp),r3
/	mul	r0,r1
/	mul	r2,r3
/	add	r1,r3
/	mul	r2,r0
/	sub	r3,r0
/	mov	(sp)+,r3
/	mov	(sp)+,r2
/	rts	pc

.globl	csv
csv:
	mov	r5,r0
	mov	sp,r5
	mov	r4,-(sp)
	mov	r3,-(sp)
	mov	r2,-(sp)
	jsr	pc,(r0)

.globl cret
cret:
	mov	r5,r2
	mov	-(r2),r4
	mov	-(r2),r3
	mov	-(r2),r2
	mov	r5,sp
	mov	(sp)+,r5
	rts	pc

.globl _stst
stst = 170300^tst
_stst:
#ifdef FPP
	stst	r0
	mov	r0,*2(sp)
#endif FPP
	rts	pc

.globl	_u
_u	= 140000
usize	= 16.

HIPRI	= 340

PS	= 177776
SSR0	= 177572
SSR2	= 177576
KISA0	= 172340
KISA6	= 172354
KISA7	= 172356
KISD0	= 172300
KISD6	= 172314
MTC	= 172522
TUC	= 172440
UISA0	= 177640
UISA1	= 177642
UISD0	= 177600
UISD1	= 177602
IO	= 7600

.data
.globl	_ka6
.globl	_cputype

_cputype: 40.
_ka6:	KISA6

.bss
nofault:.=.+2
ssr:	.=.+6
saveps: .=.+2

.text
#ifdef XBUF
/
/ These routines set/fetch data
/ in/from the buffers/inodes outside
/ the kernel address space.
/
/ fetch buffer word
/ w = fbword(addr, offset)
/
.globl	_fbword
_fbword:
	mov	PS,-(sp)
	mov	KISA6,r1
	mov	6(sp),r0	/ offset
	bis	$340,PS
	mov	4(sp),KISA6	/ base address
	mov	_u(r0),r0
	mov	r1,KISA6
	mov	(sp)+,PS
	rts	pc

/
/ fetch buffer byte
/ b = fbbyte(addr, offset)
/
.globl	_fbbyte
_fbbyte:
	mov	PS,-(sp)
	mov	KISA6,r1
	mov	6(sp),r0	/ offset
	bis	$340,PS
	mov	4(sp),KISA6	/ base address
	movb	_u(r0),r0
	mov	r1,KISA6
	mov	(sp)+,PS
	bic	$!377,r0
	rts	pc

/
/ fetch buffer long
/ l = fblong(addr, offset)
/
.globl	_fblong
_fblong:
	mov	r2,-(sp)
	mov	PS,-(sp)
	mov	KISA6,r2
	mov	8.(sp),r0	/ offset
	bis	$340,PS
	mov	6.(sp),KISA6	/ base address
	mov	_u+2(r0),r1	/ low word
	mov	_u(r0),r0	/ high word
	mov	r2,KISA6
	mov	(sp)+,PS
	mov	(sp)+,r2
	rts	pc

/
/ store buffer word
/ sbword(addr, offset, value)
/
.globl	_sbword
_sbword:
	mov	r2,-(sp)
	mov	PS,-(sp)
	mov	KISA6,r0
	mov	10.(sp),r1	/ value
	mov	8.(sp),r2	/ offset
	bis	$340,PS
	mov	6(sp),KISA6	/ base address
	mov	r1,_u(r2)
	mov	r0,KISA6
	mov	(sp)+,PS
	mov	(sp)+,r2
	rts	pc

/
/ store buffer byte
/ sbbyte(addr, offset, value)
/
.globl	_sbbyte
_sbbyte:
	mov	r2,-(sp)
	mov	PS,-(sp)
	mov	KISA6,r0
	mov	10.(sp),r1	/ value
	mov	8.(sp),r2	/ offset
	bis	$340,PS
	mov	6(sp),KISA6	/ base address
	movb	r1,_u(r2)
	mov	r0,KISA6
	mov	(sp)+,PS
	mov	(sp)+,r2
	rts	pc

/
/ store buffer long
/ sblong(addr, offset, long)
/
.globl	_sblong
_sblong:
	mov	r2,-(sp)
	mov	r3,-(sp)
	mov	PS,-(sp)
	mov	KISA6,r3
	mov	14.(sp),r1	/ low word
	mov	12.(sp),r0	/ high word
	mov	10.(sp),r2	/ offset
	bis	$340,PS
	mov	8.(sp),KISA6	/ base address
	mov	r0,_u(r2)
	mov	r1,_u+2(r2)
	mov	r3,KISA6
	mov	(sp)+,PS
	mov	(sp)+,r3
	mov	(sp)+,r2
	rts	pc

/
/ block move from user to buffer
/ utb(buffer address, offset, user address, word count)
/
.globl	_utb
_utb:
	jsr	pc,atb
	mov	nofault,-(sp)
	mov	$3f,nofault
1:
	mfpi	(r1)+
	mov	(sp)+,(r0)+
	sob	r2,1b
	br	2f

/
/ block move from buffer to user
/ btu(buffer address, offset, user address, word count)
/
.globl	_btu
_btu:
	jsr	pc,atb
	mov	nofault,-(sp)
	mov	$3f,nofault
1:
	mov	(r0)+,-(sp)
	mtpi	(r1)+
	sob	r2,1b
2:
	mov	(sp)+,nofault
	clr	r0
	rts	pc
3:
	mov	(sp)+,nofault
	mov	$-1,r0
	rts	pc

/
/ block move from kernel to buffer
/ ktb(buffer address, offset, kernel address, word count)
/
.globl	_ktb
_ktb:
	jsr	pc,atb
1:
	mov	(r1)+,(r0)+
	sob	r2,1b
	rts	pc

/
/ block move from buffer to kernel
/ btk(buffer address, offset, kernel address, word count)
/
.globl	_btk
_btk:
	jsr	pc,atb
1:
	mov	(r0)+,(r1)+
	sob	r2,1b
	rts	pc

/
/ initialization and completion for routines btu, utb, btk, ktb
/
atb:
	mov	$stack,r0
	mov	sp,-(r0)
	mov	KISA6,-(r0)
	mov	(sp),-(r0)
	mov	4(sp),-(r0)	/ buffer address (/64)
	mov	r2,(sp)
	mov	6(sp),r0	/ offset
	add	$_u,r0
	mov	8.(sp),r1	/ kernel or user address
	mov	10.(sp),r2	/ byte count
	asr	r2
	mov	$stack-8,sp
	mov	(sp)+,KISA6
	jsr	pc,*(sp)+	/ copy
	mov	(sp)+,KISA6
	mov	(sp)+,sp
	mov	(sp)+,r2
	rts	pc

/
/ clrclick(buffer address, nrbytes)
/
.globl	_clrclick
_clrclick:
	mov	4(sp),r1
	asr	r1
	mov	2(sp),r0
	mov	sp,stack-2	/ buffer address (/64)
	mov	$stack-2,sp
	mov	KISA6,-(sp)
	mov	r0,KISA6
	mov	$_u,r0
1:
	clr	(r0)+
	sob	r1,1b
	mov	(sp)+,KISA6
	mov	(sp)+,sp
	rts	pc

.bss
.globl _curr_u
_curr_u: .=.+2
/
/ temporary stack while accessing the out of kernel blocks
/ the size of this stack is rather arbitrary
/
bottom:	.=.+200.
stack:
.text
#endif XBUF
