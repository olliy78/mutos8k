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
L0264:
	ld	r10,r15
L0266:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L027A
	cpb	rl0,#%25
	jr	eq,L027A
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0266
L027A:
	cp	r10,r15
	jr	eq,L0298
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
L0298:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L02BA
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L02BA:
	cpb	@r12,#%30
	jr	ne,L02C6
	ld	%FFEE(r14),#%0030
L02C6:
	calr	L03FE
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L02D8
	calr	L03FE
	ld	r11,r1
L02D8:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0D42
L02E0:
	pop	r4,@r7
	test	r4
	jr	ne,L02EC
	ldb	@r10,rl2
	inc	r10,#1
	jr	L03D0
L02EC:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L02E0
	jp	@r4
L02F4:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0314
	cpb	rl1,#%78
	jr	eq,L0318
	cpb	rl1,#%64
	jr	eq,L032A
	cpb	rl1,#%75
	jr	eq,L0342
	dec	r12,#1
	jr	L0344
L0314:
	pop	r6,@r13
	jr	L031C
L0318:
	pop	r6,@r13
L031A:
	rl	r3,#1
L031C:
	pop	r7,@r13
	jr	L0348
L0320:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0332
	jr	L0346
L032A:
	pop	r6,@r13
	test	r6
	jr	pl,L0344
	pop	r7,@r13
L0332:
	neg	r6
	neg	r7
	jr	uge,L033A
	dec	r6,#1
L033A:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0346
L0342:
	pop	r6,@r13
L0344:
	pop	r7,@r13
L0346:
	inc	r3,#2
L0348:
	testl	rr6
	jr	eq,L0356
	test	r11
	jr	eq,L0356
	ldb	@r10,#%30
	inc	r10,#1
L0356:
	xor	r2,r2
	calr	L035C
	jr	L03D0
L035C:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0366
	calr	L035C
L0366:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0376
	add	r0,#%0007
L0376:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L037C:
	call	pscien
	jr	L03D0
L0382:
	call	pscien
	jr	L03D0
L0388:
	inc	r11,#1
	test	r9
	jr	ne,L0392
	ldk	r11,#7
	ld	r9,r11
L0392:
	call	pscien
	jr	L03D0
L0398:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0264
L03A0:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L03D0
	ldb	@r10,rl0
	inc	r10,#1
	jr	L03D0
L03B2:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L03C2
	ld	r2,#D0D86
L03C2:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L03D2
	dec	r10,#1
	jr	L03D2
L03D0:
	ld	r2,r15
L03D2:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L03DE
	xor	r1,r1
L03DE:
	test	%FFF0(r14)
	jr	ne,L03E6
	neg	r1
L03E6:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0264
L03FE:
	xor	r9,r9
	ld	r1,r9
L0402:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0416
	pop	r2,@r13
	jr	L0426
L0416:
	cp	r2,#%0009
	jr	ugt,L0426
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0402
L0426:
	add	r2,#%0030
	ret
end __doprnt
I
D0D42:
WV L0320
BV %0;BV %64
WV L031C
BV %0;BV %6F
WV L031A
BV %0;BV %78
WV L037C
BV %0;BV %66
WV L0388
BV %0;BV %65
WV L0382
BV %0;BV %67
WV L03A0
BV %0;BV %63
WV L03B2
BV %0;BV %73
WV L02F4
BV %0;BV %6C
WV L02F4
BV %0;BV %4C
WV L0344
BV %0;BV %75
WV L0398
BV %0;BV %72
WV L032A
BV %0;BV %44
WV L0314
BV %0;BV %4F
WV L0318
BV %0;BV %58
WV L0342
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0D86:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
