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
L0BD8:
	ld	r10,r15
L0BDA:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0BEE
	cpb	rl0,#%25
	jr	eq,L0BEE
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0BDA
L0BEE:
	cp	r10,r15
	jr	eq,L0C0C
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
L0C0C:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0C2E
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0C2E:
	cpb	@r12,#%30
	jr	ne,L0C3A
	ld	%FFEE(r14),#%0030
L0C3A:
	calr	L0D72
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0C4C
	calr	L0D72
	ld	r11,r1
L0C4C:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1ED0
L0C54:
	pop	r4,@r7
	test	r4
	jr	ne,L0C60
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0D44
L0C60:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0C54
	jp	@r4
L0C68:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0C88
	cpb	rl1,#%78
	jr	eq,L0C8C
	cpb	rl1,#%64
	jr	eq,L0C9E
	cpb	rl1,#%75
	jr	eq,L0CB6
	dec	r12,#1
	jr	L0CB8
L0C88:
	pop	r6,@r13
	jr	L0C90
L0C8C:
	pop	r6,@r13
L0C8E:
	rl	r3,#1
L0C90:
	pop	r7,@r13
	jr	L0CBC
L0C94:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0CA6
	jr	L0CBA
L0C9E:
	pop	r6,@r13
	test	r6
	jr	pl,L0CB8
	pop	r7,@r13
L0CA6:
	neg	r6
	neg	r7
	jr	uge,L0CAE
	dec	r6,#1
L0CAE:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0CBA
L0CB6:
	pop	r6,@r13
L0CB8:
	pop	r7,@r13
L0CBA:
	inc	r3,#2
L0CBC:
	testl	rr6
	jr	eq,L0CCA
	test	r11
	jr	eq,L0CCA
	ldb	@r10,#%30
	inc	r10,#1
L0CCA:
	xor	r2,r2
	calr	L0CD0
	jr	L0D44
L0CD0:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0CDA
	calr	L0CD0
L0CDA:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0CEA
	add	r0,#%0007
L0CEA:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0CF0:
	call	pscien
	jr	L0D44
L0CF6:
	call	pscien
	jr	L0D44
L0CFC:
	inc	r11,#1
	test	r9
	jr	ne,L0D06
	ldk	r11,#7
	ld	r9,r11
L0D06:
	call	pscien
	jr	L0D44
L0D0C:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0BD8
L0D14:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0D44
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0D44
L0D26:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0D36
	ld	r2,#D1F14
L0D36:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0D46
	dec	r10,#1
	jr	L0D46
L0D44:
	ld	r2,r15
L0D46:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0D52
	xor	r1,r1
L0D52:
	test	%FFF0(r14)
	jr	ne,L0D5A
	neg	r1
L0D5A:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0BD8
L0D72:
	xor	r9,r9
	ld	r1,r9
L0D76:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0D8A
	pop	r2,@r13
	jr	L0D9A
L0D8A:
	cp	r2,#%0009
	jr	ugt,L0D9A
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0D76
L0D9A:
	add	r2,#%0030
	ret
end __doprnt
I
D1ED0:
WV L0C94
BV %0;BV %64
WV L0C90
BV %0;BV %6F
WV L0C8E
BV %0;BV %78
WV L0CF0
BV %0;BV %66
WV L0CFC
BV %0;BV %65
WV L0CF6
BV %0;BV %67
WV L0D14
BV %0;BV %63
WV L0D26
BV %0;BV %73
WV L0C68
BV %0;BV %6C
WV L0C68
BV %0;BV %4C
WV L0CB8
BV %0;BV %75
WV L0D0C
BV %0;BV %72
WV L0C9E
BV %0;BV %44
WV L0C88
BV %0;BV %4F
WV L0C8C
BV %0;BV %58
WV L0CB6
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D1F14:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
