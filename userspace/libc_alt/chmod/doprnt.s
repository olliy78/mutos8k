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
L035E:
	ld	r10,r15
L0360:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0374
	cpb	rl0,#%25
	jr	eq,L0374
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0360
L0374:
	cp	r10,r15
	jr	eq,L0392
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
L0392:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L03B4
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L03B4:
	cpb	@r12,#%30
	jr	ne,L03C0
	ld	%FFEE(r14),#%0030
L03C0:
	calr	L04F8
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L03D2
	calr	L04F8
	ld	r11,r1
L03D2:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0D80
L03DA:
	pop	r4,@r7
	test	r4
	jr	ne,L03E6
	ldb	@r10,rl2
	inc	r10,#1
	jr	L04CA
L03E6:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L03DA
	jp	@r4
L03EE:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L040E
	cpb	rl1,#%78
	jr	eq,L0412
	cpb	rl1,#%64
	jr	eq,L0424
	cpb	rl1,#%75
	jr	eq,L043C
	dec	r12,#1
	jr	L043E
L040E:
	pop	r6,@r13
	jr	L0416
L0412:
	pop	r6,@r13
L0414:
	rl	r3,#1
L0416:
	pop	r7,@r13
	jr	L0442
L041A:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L042C
	jr	L0440
L0424:
	pop	r6,@r13
	test	r6
	jr	pl,L043E
	pop	r7,@r13
L042C:
	neg	r6
	neg	r7
	jr	uge,L0434
	dec	r6,#1
L0434:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0440
L043C:
	pop	r6,@r13
L043E:
	pop	r7,@r13
L0440:
	inc	r3,#2
L0442:
	testl	rr6
	jr	eq,L0450
	test	r11
	jr	eq,L0450
	ldb	@r10,#%30
	inc	r10,#1
L0450:
	xor	r2,r2
	calr	L0456
	jr	L04CA
L0456:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0460
	calr	L0456
L0460:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0470
	add	r0,#%0007
L0470:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0476:
	call	pscien
	jr	L04CA
L047C:
	call	pscien
	jr	L04CA
L0482:
	inc	r11,#1
	test	r9
	jr	ne,L048C
	ldk	r11,#7
	ld	r9,r11
L048C:
	call	pscien
	jr	L04CA
L0492:
	ld	r13,@r13
	pop	r12,@r13
	jp	L035E
L049A:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L04CA
	ldb	@r10,rl0
	inc	r10,#1
	jr	L04CA
L04AC:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L04BC
	ld	r2,#D0DC4
L04BC:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L04CC
	dec	r10,#1
	jr	L04CC
L04CA:
	ld	r2,r15
L04CC:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L04D8
	xor	r1,r1
L04D8:
	test	%FFF0(r14)
	jr	ne,L04E0
	neg	r1
L04E0:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L035E
L04F8:
	xor	r9,r9
	ld	r1,r9
L04FC:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0510
	pop	r2,@r13
	jr	L0520
L0510:
	cp	r2,#%0009
	jr	ugt,L0520
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L04FC
L0520:
	add	r2,#%0030
	ret
end __doprnt
I
D0D80:
WV L041A
BV %0;BV %64
WV L0416
BV %0;BV %6F
WV L0414
BV %0;BV %78
WV L0476
BV %0;BV %66
WV L0482
BV %0;BV %65
WV L047C
BV %0;BV %67
WV L049A
BV %0;BV %63
WV L04AC
BV %0;BV %73
WV L03EE
BV %0;BV %6C
WV L03EE
BV %0;BV %4C
WV L043E
BV %0;BV %75
WV L0492
BV %0;BV %72
WV L0424
BV %0;BV %44
WV L040E
BV %0;BV %4F
WV L0412
BV %0;BV %58
WV L043C
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0DC4:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
