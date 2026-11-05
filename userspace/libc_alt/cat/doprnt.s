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
L03C0:
	ld	r10,r15
L03C2:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L03D6
	cpb	rl0,#%25
	jr	eq,L03D6
	ldb	@r10,rl0
	inc	r10,#1
	jr	L03C2
L03D6:
	cp	r10,r15
	jr	eq,L03F4
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
L03F4:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0416
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0416:
	cpb	@r12,#%30
	jr	ne,L0422
	ld	%FFEE(r14),#%0030
L0422:
	calr	L055A
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0434
	calr	L055A
	ld	r11,r1
L0434:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0EFA
L043C:
	pop	r4,@r7
	test	r4
	jr	ne,L0448
	ldb	@r10,rl2
	inc	r10,#1
	jr	L052C
L0448:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L043C
	jp	@r4
L0450:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0470
	cpb	rl1,#%78
	jr	eq,L0474
	cpb	rl1,#%64
	jr	eq,L0486
	cpb	rl1,#%75
	jr	eq,L049E
	dec	r12,#1
	jr	L04A0
L0470:
	pop	r6,@r13
	jr	L0478
L0474:
	pop	r6,@r13
L0476:
	rl	r3,#1
L0478:
	pop	r7,@r13
	jr	L04A4
L047C:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L048E
	jr	L04A2
L0486:
	pop	r6,@r13
	test	r6
	jr	pl,L04A0
	pop	r7,@r13
L048E:
	neg	r6
	neg	r7
	jr	uge,L0496
	dec	r6,#1
L0496:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L04A2
L049E:
	pop	r6,@r13
L04A0:
	pop	r7,@r13
L04A2:
	inc	r3,#2
L04A4:
	testl	rr6
	jr	eq,L04B2
	test	r11
	jr	eq,L04B2
	ldb	@r10,#%30
	inc	r10,#1
L04B2:
	xor	r2,r2
	calr	L04B8
	jr	L052C
L04B8:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L04C2
	calr	L04B8
L04C2:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L04D2
	add	r0,#%0007
L04D2:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L04D8:
	call	pscien
	jr	L052C
L04DE:
	call	pscien
	jr	L052C
L04E4:
	inc	r11,#1
	test	r9
	jr	ne,L04EE
	ldk	r11,#7
	ld	r9,r11
L04EE:
	call	pscien
	jr	L052C
L04F4:
	ld	r13,@r13
	pop	r12,@r13
	jp	L03C0
L04FC:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L052C
	ldb	@r10,rl0
	inc	r10,#1
	jr	L052C
L050E:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L051E
	ld	r2,#D0F3E
L051E:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L052E
	dec	r10,#1
	jr	L052E
L052C:
	ld	r2,r15
L052E:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L053A
	xor	r1,r1
L053A:
	test	%FFF0(r14)
	jr	ne,L0542
	neg	r1
L0542:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L03C0
L055A:
	xor	r9,r9
	ld	r1,r9
L055E:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0572
	pop	r2,@r13
	jr	L0582
L0572:
	cp	r2,#%0009
	jr	ugt,L0582
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L055E
L0582:
	add	r2,#%0030
	ret
end __doprnt
I
D0EFA:
WV L047C
BV %0;BV %64
WV L0478
BV %0;BV %6F
WV L0476
BV %0;BV %78
WV L04D8
BV %0;BV %66
WV L04E4
BV %0;BV %65
WV L04DE
BV %0;BV %67
WV L04FC
BV %0;BV %63
WV L050E
BV %0;BV %73
WV L0450
BV %0;BV %6C
WV L0450
BV %0;BV %4C
WV L04A0
BV %0;BV %75
WV L04F4
BV %0;BV %72
WV L0486
BV %0;BV %44
WV L0470
BV %0;BV %4F
WV L0474
BV %0;BV %58
WV L049E
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0F3E:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
