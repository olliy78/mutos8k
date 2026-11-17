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
L19EC:
	ld	r10,r15
L19EE:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L1A02
	cpb	rl0,#%25
	jr	eq,L1A02
	ldb	@r10,rl0
	inc	r10,#1
	jr	L19EE
L1A02:
	cp	r10,r15
	jr	eq,L1A20
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
L1A20:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L1A42
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L1A42:
	cpb	@r12,#%30
	jr	ne,L1A4E
	ld	%FFEE(r14),#%0030
L1A4E:
	calr	L1B86
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L1A60
	calr	L1B86
	ld	r11,r1
L1A60:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D28E6
L1A68:
	pop	r4,@r7
	test	r4
	jr	ne,L1A74
	ldb	@r10,rl2
	inc	r10,#1
	jr	L1B58
L1A74:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L1A68
	jp	@r4
L1A7C:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L1A9C
	cpb	rl1,#%78
	jr	eq,L1AA0
	cpb	rl1,#%64
	jr	eq,L1AB2
	cpb	rl1,#%75
	jr	eq,L1ACA
	dec	r12,#1
	jr	L1ACC
L1A9C:
	pop	r6,@r13
	jr	L1AA4
L1AA0:
	pop	r6,@r13
L1AA2:
	rl	r3,#1
L1AA4:
	pop	r7,@r13
	jr	L1AD0
L1AA8:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L1ABA
	jr	L1ACE
L1AB2:
	pop	r6,@r13
	test	r6
	jr	pl,L1ACC
	pop	r7,@r13
L1ABA:
	neg	r6
	neg	r7
	jr	uge,L1AC2
	dec	r6,#1
L1AC2:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L1ACE
L1ACA:
	pop	r6,@r13
L1ACC:
	pop	r7,@r13
L1ACE:
	inc	r3,#2
L1AD0:
	testl	rr6
	jr	eq,L1ADE
	test	r11
	jr	eq,L1ADE
	ldb	@r10,#%30
	inc	r10,#1
L1ADE:
	xor	r2,r2
	calr	L1AE4
	jr	L1B58
L1AE4:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L1AEE
	calr	L1AE4
L1AEE:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L1AFE
	add	r0,#%0007
L1AFE:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L1B04:
	call	pscien
	jr	L1B58
L1B0A:
	call	pscien
	jr	L1B58
L1B10:
	inc	r11,#1
	test	r9
	jr	ne,L1B1A
	ldk	r11,#7
	ld	r9,r11
L1B1A:
	call	pscien
	jr	L1B58
L1B20:
	ld	r13,@r13
	pop	r12,@r13
	jp	L19EC
L1B28:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L1B58
	ldb	@r10,rl0
	inc	r10,#1
	jr	L1B58
L1B3A:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L1B4A
	ld	r2,#D292A
L1B4A:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L1B5A
	dec	r10,#1
	jr	L1B5A
L1B58:
	ld	r2,r15
L1B5A:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L1B66
	xor	r1,r1
L1B66:
	test	%FFF0(r14)
	jr	ne,L1B6E
	neg	r1
L1B6E:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L19EC
L1B86:
	xor	r9,r9
	ld	r1,r9
L1B8A:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L1B9E
	pop	r2,@r13
	jr	L1BAE
L1B9E:
	cp	r2,#%0009
	jr	ugt,L1BAE
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L1B8A
L1BAE:
	add	r2,#%0030
	ret
end __doprnt
I
D28E6:
WV L1AA8
BV %0;BV %64
WV L1AA4
BV %0;BV %6F
WV L1AA2
BV %0;BV %78
WV L1B04
BV %0;BV %66
WV L1B10
BV %0;BV %65
WV L1B0A
BV %0;BV %67
WV L1B28
BV %0;BV %63
WV L1B3A
BV %0;BV %73
WV L1A7C
BV %0;BV %6C
WV L1A7C
BV %0;BV %4C
WV L1ACC
BV %0;BV %75
WV L1B20
BV %0;BV %72
WV L1AB2
BV %0;BV %44
WV L1A9C
BV %0;BV %4F
WV L1AA0
BV %0;BV %58
WV L1ACA
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D292A:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
