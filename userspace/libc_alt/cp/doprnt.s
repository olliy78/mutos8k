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
L02A6:
	ld	r10,r15
L02A8:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L02BC
	cpb	rl0,#%25
	jr	eq,L02BC
	ldb	@r10,rl0
	inc	r10,#1
	jr	L02A8
L02BC:
	cp	r10,r15
	jr	eq,L02DA
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
L02DA:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L02FC
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L02FC:
	cpb	@r12,#%30
	jr	ne,L0308
	ld	%FFEE(r14),#%0030
L0308:
	calr	L0440
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L031A
	calr	L0440
	ld	r11,r1
L031A:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0D0A
L0322:
	pop	r4,@r7
	test	r4
	jr	ne,L032E
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0412
L032E:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0322
	jp	@r4
L0336:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0356
	cpb	rl1,#%78
	jr	eq,L035A
	cpb	rl1,#%64
	jr	eq,L036C
	cpb	rl1,#%75
	jr	eq,L0384
	dec	r12,#1
	jr	L0386
L0356:
	pop	r6,@r13
	jr	L035E
L035A:
	pop	r6,@r13
L035C:
	rl	r3,#1
L035E:
	pop	r7,@r13
	jr	L038A
L0362:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0374
	jr	L0388
L036C:
	pop	r6,@r13
	test	r6
	jr	pl,L0386
	pop	r7,@r13
L0374:
	neg	r6
	neg	r7
	jr	uge,L037C
	dec	r6,#1
L037C:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0388
L0384:
	pop	r6,@r13
L0386:
	pop	r7,@r13
L0388:
	inc	r3,#2
L038A:
	testl	rr6
	jr	eq,L0398
	test	r11
	jr	eq,L0398
	ldb	@r10,#%30
	inc	r10,#1
L0398:
	xor	r2,r2
	calr	L039E
	jr	L0412
L039E:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L03A8
	calr	L039E
L03A8:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L03B8
	add	r0,#%0007
L03B8:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L03BE:
	call	pscien
	jr	L0412
L03C4:
	call	pscien
	jr	L0412
L03CA:
	inc	r11,#1
	test	r9
	jr	ne,L03D4
	ldk	r11,#7
	ld	r9,r11
L03D4:
	call	pscien
	jr	L0412
L03DA:
	ld	r13,@r13
	pop	r12,@r13
	jp	L02A6
L03E2:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0412
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0412
L03F4:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0404
	ld	r2,#D0D4E
L0404:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0414
	dec	r10,#1
	jr	L0414
L0412:
	ld	r2,r15
L0414:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0420
	xor	r1,r1
L0420:
	test	%FFF0(r14)
	jr	ne,L0428
	neg	r1
L0428:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L02A6
L0440:
	xor	r9,r9
	ld	r1,r9
L0444:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0458
	pop	r2,@r13
	jr	L0468
L0458:
	cp	r2,#%0009
	jr	ugt,L0468
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0444
L0468:
	add	r2,#%0030
	ret
end __doprnt
I
D0D0A:
WV L0362
BV %0;BV %64
WV L035E
BV %0;BV %6F
WV L035C
BV %0;BV %78
WV L03BE
BV %0;BV %66
WV L03CA
BV %0;BV %65
WV L03C4
BV %0;BV %67
WV L03E2
BV %0;BV %63
WV L03F4
BV %0;BV %73
WV L0336
BV %0;BV %6C
WV L0336
BV %0;BV %4C
WV L0386
BV %0;BV %75
WV L03DA
BV %0;BV %72
WV L036C
BV %0;BV %44
WV L0356
BV %0;BV %4F
WV L035A
BV %0;BV %58
WV L0384
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0D4E:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
