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
L0A14:
	ld	r10,r15
L0A16:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0A2A
	cpb	rl0,#%25
	jr	eq,L0A2A
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0A16
L0A2A:
	cp	r10,r15
	jr	eq,L0A48
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
L0A48:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0A6A
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0A6A:
	cpb	@r12,#%30
	jr	ne,L0A76
	ld	%FFEE(r14),#%0030
L0A76:
	calr	L0BAE
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0A88
	calr	L0BAE
	ld	r11,r1
L0A88:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D224A
L0A90:
	pop	r4,@r7
	test	r4
	jr	ne,L0A9C
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0B80
L0A9C:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0A90
	jp	@r4
L0AA4:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0AC4
	cpb	rl1,#%78
	jr	eq,L0AC8
	cpb	rl1,#%64
	jr	eq,L0ADA
	cpb	rl1,#%75
	jr	eq,L0AF2
	dec	r12,#1
	jr	L0AF4
L0AC4:
	pop	r6,@r13
	jr	L0ACC
L0AC8:
	pop	r6,@r13
L0ACA:
	rl	r3,#1
L0ACC:
	pop	r7,@r13
	jr	L0AF8
L0AD0:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0AE2
	jr	L0AF6
L0ADA:
	pop	r6,@r13
	test	r6
	jr	pl,L0AF4
	pop	r7,@r13
L0AE2:
	neg	r6
	neg	r7
	jr	uge,L0AEA
	dec	r6,#1
L0AEA:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0AF6
L0AF2:
	pop	r6,@r13
L0AF4:
	pop	r7,@r13
L0AF6:
	inc	r3,#2
L0AF8:
	testl	rr6
	jr	eq,L0B06
	test	r11
	jr	eq,L0B06
L0B00:
	ldb	@r10,#%30
L0B04:
	inc	r10,#1
L0B06:
	xor	r2,r2
	calr	L0B0C
	jr	L0B80
L0B0C:
	extsl	rq4
L0B0E:
	divl	rq4,rr2
L0B10:
	push	@r15,r5
	jr	eq,L0B16
	calr	L0B0C
L0B16:
	pop	r0,@r15
L0B18:
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0B26
	add	r0,#%0007
L0B26:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0B2C:
	call	pscien
	jr	L0B80
L0B32:
	call	pscien
	jr	L0B80
L0B38:
	inc	r11,#1
	test	r9
	jr	ne,L0B42
	ldk	r11,#7
	ld	r9,r11
L0B42:
	call	pscien
	jr	L0B80
L0B48:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0A14
L0B50:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0B80
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0B80
L0B62:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0B72
	ld	r2,#D228E
L0B72:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0B82
	dec	r10,#1
	jr	L0B82
L0B80:
	ld	r2,r15
L0B82:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0B8E
	xor	r1,r1
L0B8E:
	test	%FFF0(r14)
	jr	ne,L0B96
	neg	r1
L0B96:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0A14
L0BAE:
	xor	r9,r9
	ld	r1,r9
L0BB2:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0BC6
	pop	r2,@r13
	jr	L0BD6
L0BC6:
	cp	r2,#%0009
	jr	ugt,L0BD6
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0BB2
L0BD6:
	add	r2,#%0030
	ret
end __doprnt
I
D224A:
WV L0AD0
BV %0;BV %64
WV L0ACC
BV %0;BV %6F
WV L0ACA
BV %0;BV %78
WV L0B2C
BV %0;BV %66
WV L0B38
BV %0;BV %65
WV L0B32
BV %0;BV %67
WV L0B50
BV %0;BV %63
WV L0B62
BV %0;BV %73
WV L0AA4
BV %0;BV %6C
WV L0AA4
BV %0;BV %4C
WV L0AF4
BV %0;BV %75
WV L0B48
BV %0;BV %72
WV L0ADA
BV %0;BV %44
WV L0AC4
BV %0;BV %4F
WV L0AC8
BV %0;BV %58
WV L0AF2
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D228E:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
