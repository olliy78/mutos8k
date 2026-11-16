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
L23FA:
	ld	r10,r15
L23FC:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L2410
	cpb	rl0,#%25
	jr	eq,L2410
	ldb	@r10,rl0
	inc	r10,#1
	jr	L23FC
L2410:
	cp	r10,r15
	jr	eq,L242E
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
L242E:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L2450
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L2450:
	cpb	@r12,#%30
	jr	ne,L245C
	ld	%FFEE(r14),#%0030
L245C:
	calr	L2596
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L246E
	calr	L2596
	ld	r11,r1
L246E:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D4050
L2476:
	pop	r4,@r7
	test	r4
	jr	ne,L2482
	ldb	@r10,rl2
	inc	r10,#1
	jr	L2568
L2482:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L2476
	jp	@r4
L248A:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L24AA
	cpb	rl1,#%78
	jr	eq,L24AE
	cpb	rl1,#%64
	jr	eq,L24C0
	cpb	rl1,#%75
	jr	eq,L24D8
	dec	r12,#1
	jr	L24DA
L24AA:
	pop	r6,@r13
	jr	L24B2
L24AE:
	pop	r6,@r13
L24B0:
	rl	r3,#1
L24B2:
	pop	r7,@r13
	jr	L24DE
L24B6:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L24C8
	jr	L24DC
L24C0:
	pop	r6,@r13
	test	r6
	jr	pl,L24DA
	pop	r7,@r13
L24C8:
	neg	r6
	neg	r7
	jr	uge,L24D0
	dec	r6,#1
L24D0:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L24DC
L24D8:
	pop	r6,@r13
L24DA:
	pop	r7,@r13
L24DC:
	inc	r3,#2
L24DE:
	testl	rr6
	jr	eq,L24EC
	test	r11
	jr	eq,L24EC
	ldb	@r10,#%30
	inc	r10,#1
L24EC:
	xor	r2,r2
	calr	L24F2
	jr	L2568
L24F2:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L24FE
	calr	L24F2
L24FE:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L250E
	add	r0,#%0007
L250E:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L2514:
	call	pscien
	jr	L2568
L251A:
	call	pscien
	jr	L2568
L2520:
	inc	r11,#1
	test	r9
	jr	ne,L252A
	ldk	r11,#7
	ld	r9,r11
L252A:
	call	pscien
	jr	L2568
L2530:
	ld	r13,@r13
	pop	r12,@r13
	jp	L23FA
L2538:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L2568
	ldb	@r10,rl0
	inc	r10,#1
	jr	L2568
L254A:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L255A
	ld	r2,#D4094
L255A:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L256A
	dec	r10,#1
	jr	L256A
L2568:
	ld	r2,r15
L256A:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L2576
	xor	r1,r1
L2576:
	test	%FFF0(r14)
	jr	ne,L257E
	neg	r1
L257E:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L23FA
L2596:
	xor	r9,r9
	ld	r1,r9
L259A:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L25AE
	pop	r2,@r13
	jr	L25BE
L25AE:
	cp	r2,#%0009
	jr	ugt,L25BE
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L259A
L25BE:
	add	r2,#%0030
	ret
end __doprnt
I
D4050:
WV L24B6
BV %0;BV %64
WV L24B2
BV %0;BV %6F
WV L24B0
BV %0;BV %78
WV L2514
BV %0;BV %66
WV L2520
BV %0;BV %65
WV L251A
BV %0;BV %67
WV L2538
BV %0;BV %63
WV L254A
BV %0;BV %73
WV L248A
BV %0;BV %6C
WV L248A
BV %0;BV %4C
WV L24DA
BV %0;BV %75
WV L2530
BV %0;BV %72
WV L24C0
BV %0;BV %44
WV L24AA
BV %0;BV %4F
WV L24AE
BV %0;BV %58
WV L24D8
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D4094:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
