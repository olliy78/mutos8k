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
L05E0:
	ld	r10,r15
L05E2:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L05F6
	cpb	rl0,#%25
	jr	eq,L05F6
	ldb	@r10,rl0
	inc	r10,#1
	jr	L05E2
L05F6:
	cp	r10,r15
	jr	eq,L0614
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
L0614:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0636
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0636:
	cpb	@r12,#%30
	jr	ne,L0642
	ld	%FFEE(r14),#%0030
L0642:
	calr	L077A
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0654
	calr	L077A
	ld	r11,r1
L0654:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D151A
L065C:
	pop	r4,@r7
	test	r4
	jr	ne,L0668
	ldb	@r10,rl2
	inc	r10,#1
	jr	L074C
L0668:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L065C
	jp	@r4
L0670:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0690
	cpb	rl1,#%78
	jr	eq,L0694
	cpb	rl1,#%64
	jr	eq,L06A6
	cpb	rl1,#%75
	jr	eq,L06BE
	dec	r12,#1
	jr	L06C0
L0690:
	pop	r6,@r13
	jr	L0698
L0694:
	pop	r6,@r13
L0696:
	rl	r3,#1
L0698:
	pop	r7,@r13
	jr	L06C4
L069C:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L06AE
	jr	L06C2
L06A6:
	pop	r6,@r13
	test	r6
	jr	pl,L06C0
	pop	r7,@r13
L06AE:
	neg	r6
	neg	r7
	jr	uge,L06B6
	dec	r6,#1
L06B6:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L06C2
L06BE:
	pop	r6,@r13
L06C0:
	pop	r7,@r13
L06C2:
	inc	r3,#2
L06C4:
	testl	rr6
	jr	eq,L06D2
	test	r11
	jr	eq,L06D2
	ldb	@r10,#%30
	inc	r10,#1
L06D2:
	xor	r2,r2
	calr	L06D8
	jr	L074C
L06D8:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L06E2
	calr	L06D8
L06E2:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L06F2
	add	r0,#%0007
L06F2:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L06F8:
	call	pscien
	jr	L074C
L06FE:
	call	pscien
	jr	L074C
L0704:
	inc	r11,#1
	test	r9
	jr	ne,L070E
	ldk	r11,#7
	ld	r9,r11
L070E:
	call	pscien
	jr	L074C
L0714:
	ld	r13,@r13
	pop	r12,@r13
	jp	L05E0
L071C:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L074C
	ldb	@r10,rl0
	inc	r10,#1
	jr	L074C
L072E:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L073E
	ld	r2,#D155E
L073E:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L074E
	dec	r10,#1
	jr	L074E
L074C:
	ld	r2,r15
L074E:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L075A
	xor	r1,r1
L075A:
	test	%FFF0(r14)
	jr	ne,L0762
	neg	r1
L0762:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L05E0
L077A:
	xor	r9,r9
	ld	r1,r9
L077E:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0792
	pop	r2,@r13
	jr	L07A2
L0792:
	cp	r2,#%0009
	jr	ugt,L07A2
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L077E
L07A2:
	add	r2,#%0030
	ret
end __doprnt
I
D151A:
WV L069C
BV %0;BV %64
WV L0698
BV %0;BV %6F
WV L0696
BV %0;BV %78
WV L06F8
BV %0;BV %66
WV L0704
BV %0;BV %65
WV L06FE
BV %0;BV %67
WV L071C
BV %0;BV %63
WV L072E
BV %0;BV %73
WV L0670
BV %0;BV %6C
WV L0670
BV %0;BV %4C
WV L06C0
BV %0;BV %75
WV L0714
BV %0;BV %72
WV L06A6
BV %0;BV %44
WV L0690
BV %0;BV %4F
WV L0694
BV %0;BV %58
WV L06BE
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D155E:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
