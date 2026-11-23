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
L4B68:
	ld	r10,r15
L4B6A:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L4B7E
	cpb	rl0,#%25
	jr	eq,L4B7E
	ldb	@r10,rl0
	inc	r10,#1
	jr	L4B6A
L4B7E:
	cp	r10,r15
	jr	eq,L4B9C
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
L4B9C:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L4BBE
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L4BBE:
	cpb	@r12,#%30
	jr	ne,L4BCA
	ld	%FFEE(r14),#%0030
L4BCA:
	calr	L4D04
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L4BDC
	calr	L4D04
	ld	r11,r1
L4BDC:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D8AE8
L4BE4:
	pop	r4,@r7
	test	r4
	jr	ne,L4BF0
	ldb	@r10,rl2
	inc	r10,#1
	jr	L4CD6
L4BF0:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L4BE4
	jp	@r4
L4BF8:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
L4C00:
	jr	eq,L4C18
	cpb	rl1,#%78
	jr	eq,L4C1C
	cpb	rl1,#%64
	jr	eq,L4C2E
	cpb	rl1,#%75
	jr	eq,L4C46
	dec	r12,#1
	jr	L4C48
L4C18:
	pop	r6,@r13
	jr	L4C20
L4C1C:
	pop	r6,@r13
L4C1E:
	rl	r3,#1
L4C20:
	pop	r7,@r13
	jr	L4C4C
L4C24:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L4C36
	jr	L4C4A
L4C2E:
	pop	r6,@r13
	test	r6
	jr	pl,L4C48
	pop	r7,@r13
L4C36:
	neg	r6
	neg	r7
	jr	uge,L4C3E
	dec	r6,#1
L4C3E:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L4C4A
L4C46:
	pop	r6,@r13
L4C48:
	pop	r7,@r13
L4C4A:
	inc	r3,#2
L4C4C:
	testl	rr6
L4C4E:
	jr	eq,L4C5A
	test	r11
L4C52:
	jr	eq,L4C5A
L4C54:
	ldb	@r10,#%30
L4C58:
	inc	r10,#1
L4C5A:
	xor	r2,r2
	calr	L4C60
	jr	L4CD6
L4C60:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L4C6C
	calr	L4C60
L4C6C:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L4C7C
	add	r0,#%0007
L4C7C:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L4C82:
	call	pscien
	jr	L4CD6
L4C88:
	call	pscien
	jr	L4CD6
L4C8E:
	inc	r11,#1
	test	r9
	jr	ne,L4C98
	ldk	r11,#7
	ld	r9,r11
L4C98:
	call	pscien
	jr	L4CD6
L4C9E:
	ld	r13,@r13
	pop	r12,@r13
	jp	L4B68
L4CA6:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L4CD6
	ldb	@r10,rl0
	inc	r10,#1
	jr	L4CD6
L4CB8:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L4CC8
	ld	r2,#D8B2C
L4CC8:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L4CD8
	dec	r10,#1
	jr	L4CD8
L4CD6:
	ld	r2,r15
L4CD8:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L4CE4
	xor	r1,r1
L4CE4:
	test	%FFF0(r14)
	jr	ne,L4CEC
	neg	r1
L4CEC:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L4B68
L4D04:
	xor	r9,r9
	ld	r1,r9
L4D08:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L4D1C
	pop	r2,@r13
	jr	L4D2C
L4D1C:
	cp	r2,#%0009
	jr	ugt,L4D2C
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L4D08
L4D2C:
	add	r2,#%0030
	ret
end __doprnt
I
D8AE8:
WV L4C24
BV %0;BV %64
WV L4C20
BV %0;BV %6F
WV L4C1E
BV %0;BV %78
WV L4C82
BV %0;BV %66
WV L4C8E
BV %0;BV %65
WV L4C88
BV %0;BV %67
WV L4CA6
BV %0;BV %63
WV L4CB8
BV %0;BV %73
WV L4BF8
BV %0;BV %6C
WV L4BF8
BV %0;BV %4C
WV L4C48
BV %0;BV %75
WV L4C9E
BV %0;BV %72
WV L4C2E
BV %0;BV %44
WV L4C18
BV %0;BV %4F
WV L4C1C
BV %0;BV %58
WV L4C46
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D8B2C:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
