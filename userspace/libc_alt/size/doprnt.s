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
L0392:
	ld	r10,r15
L0394:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L03A8
	cpb	rl0,#%25
	jr	eq,L03A8
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0394
L03A8:
	cp	r10,r15
	jr	eq,L03C6
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
L03C6:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L03E8
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L03E8:
	cpb	@r12,#%30
	jr	ne,L03F4
	ld	%FFEE(r14),#%0030
L03F4:
	calr	L052C
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0406
	calr	L052C
	ld	r11,r1
L0406:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0EE2
L040E:
	pop	r4,@r7
	test	r4
	jr	ne,L041A
	ldb	@r10,rl2
	inc	r10,#1
	jr	L04FE
L041A:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L040E
	jp	@r4
L0422:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0442
	cpb	rl1,#%78
	jr	eq,L0446
	cpb	rl1,#%64
	jr	eq,L0458
	cpb	rl1,#%75
	jr	eq,L0470
	dec	r12,#1
	jr	L0472
L0442:
	pop	r6,@r13
	jr	L044A
L0446:
	pop	r6,@r13
L0448:
	rl	r3,#1
L044A:
	pop	r7,@r13
	jr	L0476
L044E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0460
	jr	L0474
L0458:
	pop	r6,@r13
	test	r6
	jr	pl,L0472
	pop	r7,@r13
L0460:
	neg	r6
	neg	r7
	jr	uge,L0468
	dec	r6,#1
L0468:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0474
L0470:
	pop	r6,@r13
L0472:
	pop	r7,@r13
L0474:
	inc	r3,#2
L0476:
	testl	rr6
	jr	eq,L0484
	test	r11
	jr	eq,L0484
	ldb	@r10,#%30
	inc	r10,#1
L0484:
	xor	r2,r2
	calr	L048A
	jr	L04FE
L048A:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0494
	calr	L048A
L0494:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L04A4
	add	r0,#%0007
L04A4:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L04AA:
	call	pscien
	jr	L04FE
L04B0:
	call	pscien
	jr	L04FE
L04B6:
	inc	r11,#1
	test	r9
	jr	ne,L04C0
	ldk	r11,#7
	ld	r9,r11
L04C0:
	call	pscien
	jr	L04FE
L04C6:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0392
L04CE:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L04FE
	ldb	@r10,rl0
	inc	r10,#1
	jr	L04FE
L04E0:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L04F0
	ld	r2,#D0F26
L04F0:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0500
	dec	r10,#1
	jr	L0500
L04FE:
	ld	r2,r15
L0500:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L050C
	xor	r1,r1
L050C:
	test	%FFF0(r14)
	jr	ne,L0514
	neg	r1
L0514:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0392
L052C:
	xor	r9,r9
	ld	r1,r9
L0530:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0544
	pop	r2,@r13
	jr	L0554
L0544:
	cp	r2,#%0009
	jr	ugt,L0554
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0530
L0554:
	add	r2,#%0030
	ret
end __doprnt
I
D0EE2:
WV L044E
BV %0;BV %64
WV L044A
BV %0;BV %6F
WV L0448
BV %0;BV %78
WV L04AA
BV %0;BV %66
WV L04B6
BV %0;BV %65
WV L04B0
BV %0;BV %67
WV L04CE
BV %0;BV %63
WV L04E0
BV %0;BV %73
WV L0422
BV %0;BV %6C
WV L0422
BV %0;BV %4C
WV L0472
BV %0;BV %75
WV L04C6
BV %0;BV %72
WV L0458
BV %0;BV %44
WV L0442
BV %0;BV %4F
WV L0446
BV %0;BV %58
WV L0470
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0F26:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
