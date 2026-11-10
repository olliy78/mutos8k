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
L0AA4:
	ld	r10,r15
L0AA6:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0ABA
	cpb	rl0,#%25
	jr	eq,L0ABA
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0AA6
L0ABA:
	cp	r10,r15
	jr	eq,L0AD8
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
L0AD8:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0AFA
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0AFA:
	cpb	@r12,#%30
	jr	ne,L0B06
	ld	%FFEE(r14),#%0030
L0B06:
	calr	L0C3E
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0B18
	calr	L0C3E
	ld	r11,r1
L0B18:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D19B6
L0B20:
	pop	r4,@r7
	test	r4
	jr	ne,L0B2C
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0C10
L0B2C:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0B20
	jp	@r4
L0B34:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0B54
	cpb	rl1,#%78
	jr	eq,L0B58
	cpb	rl1,#%64
	jr	eq,L0B6A
	cpb	rl1,#%75
	jr	eq,L0B82
	dec	r12,#1
	jr	L0B84
L0B54:
	pop	r6,@r13
	jr	L0B5C
L0B58:
	pop	r6,@r13
L0B5A:
	rl	r3,#1
L0B5C:
	pop	r7,@r13
	jr	L0B88
L0B60:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0B72
	jr	L0B86
L0B6A:
	pop	r6,@r13
	test	r6
	jr	pl,L0B84
	pop	r7,@r13
L0B72:
	neg	r6
	neg	r7
	jr	uge,L0B7A
	dec	r6,#1
L0B7A:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0B86
L0B82:
	pop	r6,@r13
L0B84:
	pop	r7,@r13
L0B86:
	inc	r3,#2
L0B88:
	testl	rr6
	jr	eq,L0B96
	test	r11
	jr	eq,L0B96
	ldb	@r10,#%30
	inc	r10,#1
L0B96:
	xor	r2,r2
	calr	L0B9C
	jr	L0C10
L0B9C:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0BA6
	calr	L0B9C
L0BA6:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0BB6
	add	r0,#%0007
L0BB6:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0BBC:
	call	pscien
	jr	L0C10
L0BC2:
	call	pscien
	jr	L0C10
L0BC8:
	inc	r11,#1
	test	r9
	jr	ne,L0BD2
	ldk	r11,#7
	ld	r9,r11
L0BD2:
	call	pscien
	jr	L0C10
L0BD8:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0AA4
L0BE0:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0C10
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0C10
L0BF2:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0C02
	ld	r2,#D19FA
L0C02:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0C12
	dec	r10,#1
	jr	L0C12
L0C10:
	ld	r2,r15
L0C12:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0C1E
	xor	r1,r1
L0C1E:
	test	%FFF0(r14)
	jr	ne,L0C26
	neg	r1
L0C26:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0AA4
L0C3E:
	xor	r9,r9
	ld	r1,r9
L0C42:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0C56
	pop	r2,@r13
	jr	L0C66
L0C56:
	cp	r2,#%0009
	jr	ugt,L0C66
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0C42
L0C66:
	add	r2,#%0030
	ret
end __doprnt
I
D19B6:
WV L0B60
BV %0;BV %64
WV L0B5C
BV %0;BV %6F
WV L0B5A
BV %0;BV %78
WV L0BBC
BV %0;BV %66
WV L0BC8
BV %0;BV %65
WV L0BC2
BV %0;BV %67
WV L0BE0
BV %0;BV %63
WV L0BF2
BV %0;BV %73
WV L0B34
BV %0;BV %6C
WV L0B34
BV %0;BV %4C
WV L0B84
BV %0;BV %75
WV L0BD8
BV %0;BV %72
WV L0B6A
BV %0;BV %44
WV L0B54
BV %0;BV %4F
WV L0B58
BV %0;BV %58
WV L0B82
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D19FA:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
