doprnt_ module
$NONSEGMENTED
constant
	FP	:= r14
	SP	:= r15
	X	:= external
	G	:= global
	I	:= internal
	A	:= array
	PR	:= procedure
	E	:= entry
	B	:= byte
	W	:= word
	BV	:= bval
	WV	:= wval
	LV	:= lval
	L	:= label
G	__doprnt	PR
E
__doprnt:
	call	csv
	sub	r15,#%0086
	ld	r12,%0004(r14)
	ld	r13,%0006(r14)
L0332:
	ld	r10,r15
L0334:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0348
	cpb	rl0,#%25
	jr	eq,L0348
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0334
L0348:
	cp	r10,r15
	jr	eq,L0366
	ld	r8,r0
	ld	r1,r15
	push	@r15,%0008(r14)
	push	@r15,#%0000
	sub	r10,r1
	push	@r15,r10
	push	@r15,r1
	call	__strout
	inc	r15,#8
	ld	r0,r8
L0366:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0388
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0388:
	cpb	@r12,#%30
	jr	ne,L0394
	ld	%FFEE(r14),#%0030
L0394:
	calr	L04CC
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L03A6
	calr	L04CC
	ld	r11,r1
L03A6:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0EBE
L03AE:
	pop	r4,@r7
	test	r4
	jr	ne,L03BA
	ldb	@r10,rl2
	inc	r10,#1
	jr	L049E
L03BA:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L03AE
	jp	@r4
L03C2:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L03E2
	cpb	rl1,#%78
	jr	eq,L03E6
	cpb	rl1,#%64
	jr	eq,L03F8
	cpb	rl1,#%75
	jr	eq,L0410
	dec	r12,#1
	jr	L0412
L03E2:
	pop	r6,@r13
	jr	L03EA
L03E6:
	pop	r6,@r13
L03E8:
	rl	r3,#1
L03EA:
	pop	r7,@r13
	jr	L0416
L03EE:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0400
	jr	L0414
L03F8:
	pop	r6,@r13
	test	r6
	jr	pl,L0412
	pop	r7,@r13
L0400:
	neg	r6
	neg	r7
	jr	uge,L0408
	dec	r6,#1
L0408:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0414
L0410:
	pop	r6,@r13
L0412:
	pop	r7,@r13
L0414:
	inc	r3,#2
L0416:
	testl	rr6
	jr	eq,L0424
	test	r11
	jr	eq,L0424
	ldb	@r10,#%30
	inc	r10,#1
L0424:
	xor	r2,r2
	calr	L042A
	jr	L049E
L042A:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0434
	calr	L042A
L0434:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0444
	add	r0,#%0007
L0444:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L044A:
	call	pscien
	jr	L049E
L0450:
	call	pscien
	jr	L049E
L0456:
	inc	r11,#1
	test	r9
	jr	ne,L0460
	ldk	r11,#7
	ld	r9,r11
L0460:
	call	pscien
	jr	L049E
L0466:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0332
L046E:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L049E
	ldb	@r10,rl0
	inc	r10,#1
	jr	L049E
L0480:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0490
	ld	r2,#D0F02
L0490:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L04A0
	dec	r10,#1
	jr	L04A0
L049E:
	ld	r2,r15
L04A0:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L04AC
	xor	r1,r1
L04AC:
	test	%FFF0(r14)
	jr	ne,L04B4
	neg	r1
L04B4:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0332
L04CC:
	xor	r9,r9
	ld	r1,r9
L04D0:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L04E4
	pop	r2,@r13
	jr	L04F4
L04E4:
	cp	r2,#%0009
	jr	ugt,L04F4
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L04D0
L04F4:
	add	r2,#%0030
	ret
end __doprnt
I
D0EBE:
WV L03EE
BV %0;BV %64
WV L03EA
BV %0;BV %6F
WV L03E8
BV %0;BV %78
WV L044A
BV %0;BV %66
WV L0456
BV %0;BV %65
WV L0450
BV %0;BV %67
WV L046E
BV %0;BV %63
WV L0480
BV %0;BV %73
WV L03C2
BV %0;BV %6C
WV L03C2
BV %0;BV %4C
WV L0412
BV %0;BV %75
WV L0466
BV %0;BV %72
WV L03F8
BV %0;BV %44
WV L03E2
BV %0;BV %4F
WV L03E6
BV %0;BV %58
WV L0410
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0F02:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
