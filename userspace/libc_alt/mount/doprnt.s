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
L0292:
	ld	r10,r15
L0294:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L02A8
	cpb	rl0,#%25
	jr	eq,L02A8
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0294
L02A8:
	cp	r10,r15
	jr	eq,L02C6
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
L02C6:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L02E8
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L02E8:
	cpb	@r12,#%30
	jr	ne,L02F4
	ld	%FFEE(r14),#%0030
L02F4:
	calr	L042C
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0306
	calr	L042C
	ld	r11,r1
L0306:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0D18
L030E:
	pop	r4,@r7
	test	r4
	jr	ne,L031A
	ldb	@r10,rl2
	inc	r10,#1
	jr	L03FE
L031A:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L030E
	jp	@r4
L0322:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0342
	cpb	rl1,#%78
	jr	eq,L0346
	cpb	rl1,#%64
	jr	eq,L0358
	cpb	rl1,#%75
	jr	eq,L0370
	dec	r12,#1
	jr	L0372
L0342:
	pop	r6,@r13
	jr	L034A
L0346:
	pop	r6,@r13
L0348:
	rl	r3,#1
L034A:
	pop	r7,@r13
	jr	L0376
L034E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0360
	jr	L0374
L0358:
	pop	r6,@r13
	test	r6
	jr	pl,L0372
	pop	r7,@r13
L0360:
	neg	r6
	neg	r7
	jr	uge,L0368
	dec	r6,#1
L0368:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0374
L0370:
	pop	r6,@r13
L0372:
	pop	r7,@r13
L0374:
	inc	r3,#2
L0376:
	testl	rr6
	jr	eq,L0384
	test	r11
	jr	eq,L0384
	ldb	@r10,#%30
	inc	r10,#1
L0384:
	xor	r2,r2
	calr	L038A
	jr	L03FE
L038A:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0394
	calr	L038A
L0394:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L03A4
	add	r0,#%0007
L03A4:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L03AA:
	call	pscien
	jr	L03FE
L03B0:
	call	pscien
	jr	L03FE
L03B6:
	inc	r11,#1
	test	r9
	jr	ne,L03C0
	ldk	r11,#7
	ld	r9,r11
L03C0:
	call	pscien
	jr	L03FE
L03C6:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0292
L03CE:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L03FE
	ldb	@r10,rl0
	inc	r10,#1
	jr	L03FE
L03E0:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L03F0
	ld	r2,#D0D5C
L03F0:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0400
	dec	r10,#1
	jr	L0400
L03FE:
	ld	r2,r15
L0400:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L040C
	xor	r1,r1
L040C:
	test	%FFF0(r14)
	jr	ne,L0414
	neg	r1
L0414:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0292
L042C:
	xor	r9,r9
	ld	r1,r9
L0430:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0444
	pop	r2,@r13
	jr	L0454
L0444:
	cp	r2,#%0009
	jr	ugt,L0454
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0430
L0454:
	add	r2,#%0030
	ret
end __doprnt
I
D0D18:
WV L034E
BV %0;BV %64
WV L034A
BV %0;BV %6F
WV L0348
BV %0;BV %78
WV L03AA
BV %0;BV %66
WV L03B6
BV %0;BV %65
WV L03B0
BV %0;BV %67
WV L03CE
BV %0;BV %63
WV L03E0
BV %0;BV %73
WV L0322
BV %0;BV %6C
WV L0322
BV %0;BV %4C
WV L0372
BV %0;BV %75
WV L03C6
BV %0;BV %72
WV L0358
BV %0;BV %44
WV L0342
BV %0;BV %4F
WV L0346
BV %0;BV %58
WV L0370
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0D5C:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
