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
L0288:
	ld	r10,r15
L028A:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L029E
	cpb	rl0,#%25
	jr	eq,L029E
	ldb	@r10,rl0
	inc	r10,#1
	jr	L028A
L029E:
	cp	r10,r15
	jr	eq,L02BC
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
L02BC:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L02DE
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L02DE:
	cpb	@r12,#%30
	jr	ne,L02EA
	ld	%FFEE(r14),#%0030
L02EA:
	calr	L0422
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L02FC
	calr	L0422
	ld	r11,r1
L02FC:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0CF8
L0304:
	pop	r4,@r7
	test	r4
	jr	ne,L0310
	ldb	@r10,rl2
	inc	r10,#1
	jr	L03F4
L0310:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0304
	jp	@r4
L0318:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0338
	cpb	rl1,#%78
	jr	eq,L033C
	cpb	rl1,#%64
	jr	eq,L034E
	cpb	rl1,#%75
	jr	eq,L0366
	dec	r12,#1
	jr	L0368
L0338:
	pop	r6,@r13
	jr	L0340
L033C:
	pop	r6,@r13
L033E:
	rl	r3,#1
L0340:
	pop	r7,@r13
	jr	L036C
L0344:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0356
	jr	L036A
L034E:
	pop	r6,@r13
	test	r6
	jr	pl,L0368
	pop	r7,@r13
L0356:
	neg	r6
	neg	r7
	jr	uge,L035E
	dec	r6,#1
L035E:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L036A
L0366:
	pop	r6,@r13
L0368:
	pop	r7,@r13
L036A:
	inc	r3,#2
L036C:
	testl	rr6
	jr	eq,L037A
	test	r11
	jr	eq,L037A
	ldb	@r10,#%30
	inc	r10,#1
L037A:
	xor	r2,r2
	calr	L0380
	jr	L03F4
L0380:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L038A
	calr	L0380
L038A:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L039A
	add	r0,#%0007
L039A:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L03A0:
	call	pscien
	jr	L03F4
L03A6:
	call	pscien
	jr	L03F4
L03AC:
	inc	r11,#1
	test	r9
	jr	ne,L03B6
	ldk	r11,#7
	ld	r9,r11
L03B6:
	call	pscien
	jr	L03F4
L03BC:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0288
L03C4:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L03F4
	ldb	@r10,rl0
	inc	r10,#1
	jr	L03F4
L03D6:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L03E6
	ld	r2,#D0D3C
L03E6:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L03F6
	dec	r10,#1
	jr	L03F6
L03F4:
	ld	r2,r15
L03F6:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0402
	xor	r1,r1
L0402:
	test	%FFF0(r14)
	jr	ne,L040A
	neg	r1
L040A:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0288
L0422:
	xor	r9,r9
	ld	r1,r9
L0426:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L043A
	pop	r2,@r13
	jr	L044A
L043A:
	cp	r2,#%0009
	jr	ugt,L044A
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0426
L044A:
	add	r2,#%0030
	ret
end __doprnt
I
D0CF8:
WV L0344
BV %0;BV %64
WV L0340
BV %0;BV %6F
WV L033E
BV %0;BV %78
WV L03A0
BV %0;BV %66
WV L03AC
BV %0;BV %65
WV L03A6
BV %0;BV %67
WV L03C4
BV %0;BV %63
WV L03D6
BV %0;BV %73
WV L0318
BV %0;BV %6C
WV L0318
BV %0;BV %4C
WV L0368
BV %0;BV %75
WV L03BC
BV %0;BV %72
WV L034E
BV %0;BV %44
WV L0338
BV %0;BV %4F
WV L033C
BV %0;BV %58
WV L0366
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0D3C:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
