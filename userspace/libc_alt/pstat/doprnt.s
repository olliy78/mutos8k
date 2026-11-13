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
L0BF8:
	ld	r10,r15
L0BFA:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0C0E
	cpb	rl0,#%25
	jr	eq,L0C0E
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0BFA
L0C0E:
	cp	r10,r15
	jr	eq,L0C2C
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
L0C2C:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0C4E
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0C4E:
	cpb	@r12,#%30
	jr	ne,L0C5A
	ld	%FFEE(r14),#%0030
L0C5A:
	calr	L0D94
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0C6C
	calr	L0D94
	ld	r11,r1
L0C6C:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D19D4
L0C74:
	pop	r4,@r7
	test	r4
	jr	ne,L0C80
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0D66
L0C80:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0C74
	jp	@r4
L0C88:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0CA8
	cpb	rl1,#%78
	jr	eq,L0CAC
	cpb	rl1,#%64
	jr	eq,L0CBE
	cpb	rl1,#%75
	jr	eq,L0CD6
	dec	r12,#1
	jr	L0CD8
L0CA8:
	pop	r6,@r13
	jr	L0CB0
L0CAC:
	pop	r6,@r13
L0CAE:
	rl	r3,#1
L0CB0:
	pop	r7,@r13
	jr	L0CDC
L0CB4:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0CC6
	jr	L0CDA
L0CBE:
	pop	r6,@r13
	test	r6
	jr	pl,L0CD8
	pop	r7,@r13
L0CC6:
	neg	r6
	neg	r7
	jr	uge,L0CCE
	dec	r6,#1
L0CCE:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0CDA
L0CD6:
	pop	r6,@r13
L0CD8:
	pop	r7,@r13
L0CDA:
	inc	r3,#2
L0CDC:
	testl	rr6
	jr	eq,L0CEA
	test	r11
	jr	eq,L0CEA
	ldb	@r10,#%30
	inc	r10,#1
L0CEA:
	xor	r2,r2
	calr	L0CF0
	jr	L0D66
L0CF0:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0CFC
	calr	L0CF0
L0CFC:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0D0C
	add	r0,#%0007
L0D0C:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0D12:
	call	pscien
	jr	L0D66
L0D18:
	call	pscien
	jr	L0D66
L0D1E:
	inc	r11,#1
	test	r9
	jr	ne,L0D28
	ldk	r11,#7
	ld	r9,r11
L0D28:
	call	pscien
	jr	L0D66
L0D2E:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0BF8
L0D36:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0D66
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0D66
L0D48:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0D58
	ld	r2,#D1A18
L0D58:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0D68
	dec	r10,#1
	jr	L0D68
L0D66:
	ld	r2,r15
L0D68:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0D74
	xor	r1,r1
L0D74:
	test	%FFF0(r14)
	jr	ne,L0D7C
	neg	r1
L0D7C:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0BF8
L0D94:
	xor	r9,r9
	ld	r1,r9
L0D98:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0DAC
	pop	r2,@r13
	jr	L0DBC
L0DAC:
	cp	r2,#%0009
	jr	ugt,L0DBC
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0D98
L0DBC:
	add	r2,#%0030
	ret
end __doprnt
I
D19D4:
WV L0CB4
BV %0;BV %64
WV L0CB0
BV %0;BV %6F
WV L0CAE
BV %0;BV %78
WV L0D12
BV %0;BV %66
WV L0D1E
BV %0;BV %65
WV L0D18
BV %0;BV %67
WV L0D36
BV %0;BV %63
WV L0D48
BV %0;BV %73
WV L0C88
BV %0;BV %6C
WV L0C88
BV %0;BV %4C
WV L0CD8
BV %0;BV %75
WV L0D2E
BV %0;BV %72
WV L0CBE
BV %0;BV %44
WV L0CA8
BV %0;BV %4F
WV L0CAC
BV %0;BV %58
WV L0CD6
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D1A18:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
