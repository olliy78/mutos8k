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
L04C2:
	ld	r10,r15
L04C4:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L04D8
	cpb	rl0,#%25
	jr	eq,L04D8
	ldb	@r10,rl0
	inc	r10,#1
	jr	L04C4
L04D8:
	cp	r10,r15
	jr	eq,L04F6
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
L04F6:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0518
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0518:
	cpb	@r12,#%30
	jr	ne,L0524
	ld	%FFEE(r14),#%0030
L0524:
	calr	L065C
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0536
	calr	L065C
	ld	r11,r1
L0536:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1168
L053E:
	pop	r4,@r7
	test	r4
	jr	ne,L054A
	ldb	@r10,rl2
	inc	r10,#1
	jr	L062E
L054A:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L053E
	jp	@r4
L0552:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0572
	cpb	rl1,#%78
	jr	eq,L0576
	cpb	rl1,#%64
	jr	eq,L0588
	cpb	rl1,#%75
	jr	eq,L05A0
	dec	r12,#1
	jr	L05A2
L0572:
	pop	r6,@r13
	jr	L057A
L0576:
	pop	r6,@r13
L0578:
	rl	r3,#1
L057A:
	pop	r7,@r13
	jr	L05A6
L057E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0590
	jr	L05A4
L0588:
	pop	r6,@r13
	test	r6
	jr	pl,L05A2
	pop	r7,@r13
L0590:
	neg	r6
	neg	r7
	jr	uge,L0598
	dec	r6,#1
L0598:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L05A4
L05A0:
	pop	r6,@r13
L05A2:
	pop	r7,@r13
L05A4:
	inc	r3,#2
L05A6:
	testl	rr6
	jr	eq,L05B4
	test	r11
	jr	eq,L05B4
	ldb	@r10,#%30
	inc	r10,#1
L05B4:
	xor	r2,r2
	calr	L05BA
	jr	L062E
L05BA:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L05C4
	calr	L05BA
L05C4:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L05D4
	add	r0,#%0007
L05D4:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L05DA:
	call	pscien
	jr	L062E
L05E0:
	call	pscien
	jr	L062E
L05E6:
	inc	r11,#1
	test	r9
	jr	ne,L05F0
	ldk	r11,#7
	ld	r9,r11
L05F0:
	call	pscien
	jr	L062E
L05F6:
	ld	r13,@r13
	pop	r12,@r13
	jp	L04C2
L05FE:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L062E
	ldb	@r10,rl0
	inc	r10,#1
	jr	L062E
L0610:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0620
	ld	r2,#D11AC
L0620:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0630
	dec	r10,#1
	jr	L0630
L062E:
	ld	r2,r15
L0630:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L063C
	xor	r1,r1
L063C:
	test	%FFF0(r14)
	jr	ne,L0644
	neg	r1
L0644:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L04C2
L065C:
	xor	r9,r9
	ld	r1,r9
L0660:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0674
	pop	r2,@r13
	jr	L0684
L0674:
	cp	r2,#%0009
	jr	ugt,L0684
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0660
L0684:
	add	r2,#%0030
	ret
end __doprnt
I
D1168:
WV L057E
BV %0;BV %64
WV L057A
BV %0;BV %6F
WV L0578
BV %0;BV %78
WV L05DA
BV %0;BV %66
WV L05E6
BV %0;BV %65
WV L05E0
BV %0;BV %67
WV L05FE
BV %0;BV %63
WV L0610
BV %0;BV %73
WV L0552
BV %0;BV %6C
WV L0552
BV %0;BV %4C
WV L05A2
BV %0;BV %75
WV L05F6
BV %0;BV %72
WV L0588
BV %0;BV %44
WV L0572
BV %0;BV %4F
WV L0576
BV %0;BV %58
WV L05A0
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D11AC:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
