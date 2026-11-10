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
L0272:
	ld	r10,r15
L0274:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0288
	cpb	rl0,#%25
	jr	eq,L0288
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0274
L0288:
	cp	r10,r15
	jr	eq,L02A6
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
L02A6:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L02C8
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L02C8:
	cpb	@r12,#%30
	jr	ne,L02D4
	ld	%FFEE(r14),#%0030
L02D4:
	calr	L040C
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L02E6
	calr	L040C
	ld	r11,r1
L02E6:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0C86
L02EE:
	pop	r4,@r7
	test	r4
	jr	ne,L02FA
	ldb	@r10,rl2
	inc	r10,#1
	jr	L03DE
L02FA:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L02EE
	jp	@r4
L0302:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0322
	cpb	rl1,#%78
	jr	eq,L0326
	cpb	rl1,#%64
	jr	eq,L0338
	cpb	rl1,#%75
	jr	eq,L0350
	dec	r12,#1
	jr	L0352
L0322:
	pop	r6,@r13
	jr	L032A
L0326:
	pop	r6,@r13
L0328:
	rl	r3,#1
L032A:
	pop	r7,@r13
	jr	L0356
L032E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0340
	jr	L0354
L0338:
	pop	r6,@r13
	test	r6
	jr	pl,L0352
	pop	r7,@r13
L0340:
	neg	r6
	neg	r7
	jr	uge,L0348
	dec	r6,#1
L0348:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0354
L0350:
	pop	r6,@r13
L0352:
	pop	r7,@r13
L0354:
	inc	r3,#2
L0356:
	testl	rr6
	jr	eq,L0364
	test	r11
	jr	eq,L0364
	ldb	@r10,#%30
	inc	r10,#1
L0364:
	xor	r2,r2
	calr	L036A
	jr	L03DE
L036A:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0374
	calr	L036A
L0374:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0384
	add	r0,#%0007
L0384:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L038A:
	call	pscien
	jr	L03DE
L0390:
	call	pscien
	jr	L03DE
L0396:
	inc	r11,#1
	test	r9
	jr	ne,L03A0
	ldk	r11,#7
	ld	r9,r11
L03A0:
	call	pscien
	jr	L03DE
L03A6:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0272
L03AE:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L03DE
	ldb	@r10,rl0
	inc	r10,#1
	jr	L03DE
L03C0:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L03D0
	ld	r2,#D0CCA
L03D0:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L03E0
	dec	r10,#1
	jr	L03E0
L03DE:
	ld	r2,r15
L03E0:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L03EC
	xor	r1,r1
L03EC:
	test	%FFF0(r14)
	jr	ne,L03F4
	neg	r1
L03F4:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0272
L040C:
	xor	r9,r9
	ld	r1,r9
L0410:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0424
	pop	r2,@r13
	jr	L0434
L0424:
	cp	r2,#%0009
	jr	ugt,L0434
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0410
L0434:
	add	r2,#%0030
	ret
end __doprnt
I
D0C86:
WV L032E
BV %0;BV %64
WV L032A
BV %0;BV %6F
WV L0328
BV %0;BV %78
WV L038A
BV %0;BV %66
WV L0396
BV %0;BV %65
WV L0390
BV %0;BV %67
WV L03AE
BV %0;BV %63
WV L03C0
BV %0;BV %73
WV L0302
BV %0;BV %6C
WV L0302
BV %0;BV %4C
WV L0352
BV %0;BV %75
WV L03A6
BV %0;BV %72
WV L0338
BV %0;BV %44
WV L0322
BV %0;BV %4F
WV L0326
BV %0;BV %58
WV L0350
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0CCA:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
