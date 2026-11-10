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
L038C:
	ld	r10,r15
L038E:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L03A2
	cpb	rl0,#%25
	jr	eq,L03A2
	ldb	@r10,rl0
	inc	r10,#1
	jr	L038E
L03A2:
	cp	r10,r15
	jr	eq,L03C0
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
L03C0:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L03E2
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L03E2:
	cpb	@r12,#%30
	jr	ne,L03EE
	ld	%FFEE(r14),#%0030
L03EE:
	calr	L0526
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0400
	calr	L0526
	ld	r11,r1
L0400:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0F42
L0408:
	pop	r4,@r7
	test	r4
	jr	ne,L0414
	ldb	@r10,rl2
	inc	r10,#1
	jr	L04F8
L0414:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0408
	jp	@r4
L041C:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L043C
	cpb	rl1,#%78
	jr	eq,L0440
	cpb	rl1,#%64
	jr	eq,L0452
	cpb	rl1,#%75
	jr	eq,L046A
	dec	r12,#1
	jr	L046C
L043C:
	pop	r6,@r13
	jr	L0444
L0440:
	pop	r6,@r13
L0442:
	rl	r3,#1
L0444:
	pop	r7,@r13
	jr	L0470
L0448:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L045A
	jr	L046E
L0452:
	pop	r6,@r13
	test	r6
	jr	pl,L046C
	pop	r7,@r13
L045A:
	neg	r6
	neg	r7
	jr	uge,L0462
	dec	r6,#1
L0462:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L046E
L046A:
	pop	r6,@r13
L046C:
	pop	r7,@r13
L046E:
	inc	r3,#2
L0470:
	testl	rr6
	jr	eq,L047E
	test	r11
	jr	eq,L047E
	ldb	@r10,#%30
	inc	r10,#1
L047E:
	xor	r2,r2
	calr	L0484
	jr	L04F8
L0484:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L048E
	calr	L0484
L048E:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L049E
	add	r0,#%0007
L049E:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L04A4:
	call	pscien
	jr	L04F8
L04AA:
	call	pscien
	jr	L04F8
L04B0:
	inc	r11,#1
	test	r9
	jr	ne,L04BA
	ldk	r11,#7
	ld	r9,r11
L04BA:
	call	pscien
	jr	L04F8
L04C0:
	ld	r13,@r13
	pop	r12,@r13
	jp	L038C
L04C8:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L04F8
	ldb	@r10,rl0
	inc	r10,#1
	jr	L04F8
L04DA:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L04EA
	ld	r2,#D0F86
L04EA:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L04FA
	dec	r10,#1
	jr	L04FA
L04F8:
	ld	r2,r15
L04FA:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0506
	xor	r1,r1
L0506:
	test	%FFF0(r14)
	jr	ne,L050E
	neg	r1
L050E:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L038C
L0526:
	xor	r9,r9
	ld	r1,r9
L052A:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L053E
	pop	r2,@r13
	jr	L054E
L053E:
	cp	r2,#%0009
	jr	ugt,L054E
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L052A
L054E:
	add	r2,#%0030
	ret
end __doprnt
I
D0F42:
WV L0448
BV %0;BV %64
WV L0444
BV %0;BV %6F
WV L0442
BV %0;BV %78
WV L04A4
BV %0;BV %66
WV L04B0
BV %0;BV %65
WV L04AA
BV %0;BV %67
WV L04C8
BV %0;BV %63
WV L04DA
BV %0;BV %73
WV L041C
BV %0;BV %6C
WV L041C
BV %0;BV %4C
WV L046C
BV %0;BV %75
WV L04C0
BV %0;BV %72
WV L0452
BV %0;BV %44
WV L043C
BV %0;BV %4F
WV L0440
BV %0;BV %58
WV L046A
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0F86:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
