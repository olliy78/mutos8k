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
L0BB2:
	ld	r10,r15
L0BB4:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0BC8
	cpb	rl0,#%25
	jr	eq,L0BC8
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0BB4
L0BC8:
	cp	r10,r15
	jr	eq,L0BE6
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
L0BE6:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0C08
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0C08:
	cpb	@r12,#%30
	jr	ne,L0C14
	ld	%FFEE(r14),#%0030
L0C14:
	calr	L0D4E
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0C26
	calr	L0D4E
	ld	r11,r1
L0C26:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1890
L0C2E:
	pop	r4,@r7
	test	r4
	jr	ne,L0C3A
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0D20
L0C3A:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0C2E
	jp	@r4
L0C42:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0C62
	cpb	rl1,#%78
	jr	eq,L0C66
	cpb	rl1,#%64
	jr	eq,L0C78
	cpb	rl1,#%75
	jr	eq,L0C90
	dec	r12,#1
	jr	L0C92
L0C62:
	pop	r6,@r13
	jr	L0C6A
L0C66:
	pop	r6,@r13
L0C68:
	rl	r3,#1
L0C6A:
	pop	r7,@r13
	jr	L0C96
L0C6E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0C80
	jr	L0C94
L0C78:
	pop	r6,@r13
	test	r6
	jr	pl,L0C92
	pop	r7,@r13
L0C80:
	neg	r6
	neg	r7
	jr	uge,L0C88
	dec	r6,#1
L0C88:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0C94
L0C90:
	pop	r6,@r13
L0C92:
	pop	r7,@r13
L0C94:
	inc	r3,#2
L0C96:
	testl	rr6
	jr	eq,L0CA4
	test	r11
	jr	eq,L0CA4
	ldb	@r10,#%30
	inc	r10,#1
L0CA4:
	xor	r2,r2
	calr	L0CAA
	jr	L0D20
L0CAA:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0CB6
	calr	L0CAA
L0CB6:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0CC6
	add	r0,#%0007
L0CC6:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0CCC:
	call	pscien
	jr	L0D20
L0CD2:
	call	pscien
	jr	L0D20
L0CD8:
	inc	r11,#1
	test	r9
	jr	ne,L0CE2
	ldk	r11,#7
	ld	r9,r11
L0CE2:
	call	pscien
	jr	L0D20
L0CE8:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0BB2
L0CF0:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0D20
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0D20
L0D02:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0D12
	ld	r2,#D18D4
L0D12:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0D22
	dec	r10,#1
	jr	L0D22
L0D20:
	ld	r2,r15
L0D22:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0D2E
	xor	r1,r1
L0D2E:
	test	%FFF0(r14)
	jr	ne,L0D36
	neg	r1
L0D36:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0BB2
L0D4E:
	xor	r9,r9
	ld	r1,r9
L0D52:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0D66
	pop	r2,@r13
	jr	L0D76
L0D66:
	cp	r2,#%0009
	jr	ugt,L0D76
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0D52
L0D76:
	add	r2,#%0030
	ret
end __doprnt
I
D1890:
WV L0C6E
BV %0;BV %64
WV L0C6A
BV %0;BV %6F
WV L0C68
BV %0;BV %78
WV L0CCC
BV %0;BV %66
WV L0CD8
BV %0;BV %65
WV L0CD2
BV %0;BV %67
WV L0CF0
BV %0;BV %63
WV L0D02
BV %0;BV %73
WV L0C42
BV %0;BV %6C
WV L0C42
BV %0;BV %4C
WV L0C92
BV %0;BV %75
WV L0CE8
BV %0;BV %72
WV L0C78
BV %0;BV %44
WV L0C62
BV %0;BV %4F
WV L0C66
BV %0;BV %58
WV L0C90
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D18D4:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
