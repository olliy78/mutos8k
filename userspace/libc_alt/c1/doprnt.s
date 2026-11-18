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
L6B12:
	ld	r10,r15
L6B14:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L6B28
	cpb	rl0,#%25
	jr	eq,L6B28
	ldb	@r10,rl0
	inc	r10,#1
	jr	L6B14
L6B28:
	cp	r10,r15
	jr	eq,L6B46
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
L6B46:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L6B68
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L6B68:
	cpb	@r12,#%30
	jr	ne,L6B74
	ld	%FFEE(r14),#%0030
L6B74:
	calr	L6CAE
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L6B86
	calr	L6CAE
	ld	r11,r1
L6B86:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D8A3E
L6B8E:
	pop	r4,@r7
	test	r4
	jr	ne,L6B9A
	ldb	@r10,rl2
	inc	r10,#1
	jr	L6C80
L6B9A:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L6B8E
	jp	@r4
L6BA2:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L6BC2
	cpb	rl1,#%78
	jr	eq,L6BC6
	cpb	rl1,#%64
	jr	eq,L6BD8
	cpb	rl1,#%75
	jr	eq,L6BF0
	dec	r12,#1
	jr	L6BF2
L6BC2:
	pop	r6,@r13
	jr	L6BCA
L6BC6:
	pop	r6,@r13
L6BC8:
	rl	r3,#1
L6BCA:
	pop	r7,@r13
	jr	L6BF6
L6BCE:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L6BE0
	jr	L6BF4
L6BD8:
	pop	r6,@r13
	test	r6
	jr	pl,L6BF2
	pop	r7,@r13
L6BE0:
	neg	r6
	neg	r7
	jr	uge,L6BE8
	dec	r6,#1
L6BE8:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L6BF4
L6BF0:
	pop	r6,@r13
L6BF2:
	pop	r7,@r13
L6BF4:
	inc	r3,#2
L6BF6:
	testl	rr6
	jr	eq,L6C04
	test	r11
	jr	eq,L6C04
	ldb	@r10,#%30
	inc	r10,#1
L6C04:
	xor	r2,r2
	calr	L6C0A
	jr	L6C80
L6C0A:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L6C16
	calr	L6C0A
L6C16:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L6C26
	add	r0,#%0007
L6C26:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L6C2C:
	call	pscien
	jr	L6C80
L6C32:
	call	pscien
	jr	L6C80
L6C38:
	inc	r11,#1
	test	r9
	jr	ne,L6C42
	ldk	r11,#7
	ld	r9,r11
L6C42:
	call	pscien
	jr	L6C80
L6C48:
	ld	r13,@r13
	pop	r12,@r13
	jp	L6B12
L6C50:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L6C80
	ldb	@r10,rl0
	inc	r10,#1
	jr	L6C80
L6C62:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L6C72
	ld	r2,#D8A82
L6C72:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L6C82
	dec	r10,#1
	jr	L6C82
L6C80:
	ld	r2,r15
L6C82:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L6C8E
	xor	r1,r1
L6C8E:
	test	%FFF0(r14)
	jr	ne,L6C96
	neg	r1
L6C96:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L6B12
L6CAE:
	xor	r9,r9
	ld	r1,r9
L6CB2:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L6CC6
	pop	r2,@r13
	jr	L6CD6
L6CC6:
	cp	r2,#%0009
	jr	ugt,L6CD6
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L6CB2
L6CD6:
	add	r2,#%0030
	ret
end __doprnt
I
D8A3E:
WV L6BCE
BV %0;BV %64
WV L6BCA
BV %0;BV %6F
WV L6BC8
BV %0;BV %78
WV L6C2C
BV %0;BV %66
WV L6C38
BV %0;BV %65
WV L6C32
BV %0;BV %67
WV L6C50
BV %0;BV %63
WV L6C62
BV %0;BV %73
WV L6BA2
BV %0;BV %6C
WV L6BA2
BV %0;BV %4C
WV L6BF2
BV %0;BV %75
WV L6C48
BV %0;BV %72
WV L6BD8
BV %0;BV %44
WV L6BC2
BV %0;BV %4F
WV L6BC6
BV %0;BV %58
WV L6BF0
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D8A82:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
