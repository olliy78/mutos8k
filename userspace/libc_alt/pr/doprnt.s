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
L0C56:
	ld	r10,r15
L0C58:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0C6C
	cpb	rl0,#%25
	jr	eq,L0C6C
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0C58
L0C6C:
	cp	r10,r15
	jr	eq,L0C8A
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
L0C8A:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0CAC
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0CAC:
	cpb	@r12,#%30
	jr	ne,L0CB8
	ld	%FFEE(r14),#%0030
L0CB8:
	calr	L0DF0
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0CCA
	calr	L0DF0
	ld	r11,r1
L0CCA:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1EFC
L0CD2:
	pop	r4,@r7
	test	r4
	jr	ne,L0CDE
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0DC2
L0CDE:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0CD2
	jp	@r4
L0CE6:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0D06
	cpb	rl1,#%78
	jr	eq,L0D0A
	cpb	rl1,#%64
	jr	eq,L0D1C
	cpb	rl1,#%75
	jr	eq,L0D34
	dec	r12,#1
	jr	L0D36
L0D06:
	pop	r6,@r13
	jr	L0D0E
L0D0A:
	pop	r6,@r13
L0D0C:
	rl	r3,#1
L0D0E:
	pop	r7,@r13
	jr	L0D3A
L0D12:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0D24
	jr	L0D38
L0D1C:
	pop	r6,@r13
	test	r6
	jr	pl,L0D36
	pop	r7,@r13
L0D24:
	neg	r6
	neg	r7
	jr	uge,L0D2C
	dec	r6,#1
L0D2C:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0D38
L0D34:
	pop	r6,@r13
L0D36:
	pop	r7,@r13
L0D38:
	inc	r3,#2
L0D3A:
	testl	rr6
	jr	eq,L0D48
	test	r11
	jr	eq,L0D48
	ldb	@r10,#%30
	inc	r10,#1
L0D48:
	xor	r2,r2
	calr	L0D4E
	jr	L0DC2
L0D4E:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0D58
	calr	L0D4E
L0D58:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0D68
	add	r0,#%0007
L0D68:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0D6E:
	call	pscien
	jr	L0DC2
L0D74:
	call	pscien
	jr	L0DC2
L0D7A:
	inc	r11,#1
	test	r9
	jr	ne,L0D84
	ldk	r11,#7
	ld	r9,r11
L0D84:
	call	pscien
	jr	L0DC2
L0D8A:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0C56
L0D92:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0DC2
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0DC2
L0DA4:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0DB4
	ld	r2,#D1F40
L0DB4:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0DC4
	dec	r10,#1
	jr	L0DC4
L0DC2:
	ld	r2,r15
L0DC4:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0DD0
	xor	r1,r1
L0DD0:
	test	%FFF0(r14)
	jr	ne,L0DD8
	neg	r1
L0DD8:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0C56
L0DF0:
	xor	r9,r9
	ld	r1,r9
L0DF4:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0E08
	pop	r2,@r13
	jr	L0E18
L0E08:
	cp	r2,#%0009
	jr	ugt,L0E18
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0DF4
L0E18:
	add	r2,#%0030
	ret
end __doprnt
I
D1EFC:
WV L0D12
BV %0;BV %64
WV L0D0E
BV %0;BV %6F
WV L0D0C
BV %0;BV %78
WV L0D6E
BV %0;BV %66
WV L0D7A
BV %0;BV %65
WV L0D74
BV %0;BV %67
WV L0D92
BV %0;BV %63
WV L0DA4
BV %0;BV %73
WV L0CE6
BV %0;BV %6C
WV L0CE6
BV %0;BV %4C
WV L0D36
BV %0;BV %75
WV L0D8A
BV %0;BV %72
WV L0D1C
BV %0;BV %44
WV L0D06
BV %0;BV %4F
WV L0D0A
BV %0;BV %58
WV L0D34
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D1F40:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
