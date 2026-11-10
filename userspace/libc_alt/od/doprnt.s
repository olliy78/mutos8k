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
L099A:
	ld	r10,r15
L099C:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L09B0
	cpb	rl0,#%25
	jr	eq,L09B0
	ldb	@r10,rl0
	inc	r10,#1
	jr	L099C
L09B0:
	cp	r10,r15
	jr	eq,L09CE
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
L09CE:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L09F0
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L09F0:
	cpb	@r12,#%30
	jr	ne,L09FC
	ld	%FFEE(r14),#%0030
L09FC:
	calr	L0B34
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0A0E
	calr	L0B34
	ld	r11,r1
L0A0E:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D14B2
L0A16:
	pop	r4,@r7
	test	r4
	jr	ne,L0A22
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0B06
L0A22:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0A16
	jp	@r4
L0A2A:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0A4A
	cpb	rl1,#%78
	jr	eq,L0A4E
	cpb	rl1,#%64
	jr	eq,L0A60
	cpb	rl1,#%75
	jr	eq,L0A78
	dec	r12,#1
	jr	L0A7A
L0A4A:
	pop	r6,@r13
	jr	L0A52
L0A4E:
	pop	r6,@r13
L0A50:
	rl	r3,#1
L0A52:
	pop	r7,@r13
	jr	L0A7E
L0A56:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0A68
	jr	L0A7C
L0A60:
	pop	r6,@r13
	test	r6
	jr	pl,L0A7A
	pop	r7,@r13
L0A68:
	neg	r6
	neg	r7
	jr	uge,L0A70
	dec	r6,#1
L0A70:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0A7C
L0A78:
	pop	r6,@r13
L0A7A:
	pop	r7,@r13
L0A7C:
	inc	r3,#2
L0A7E:
	testl	rr6
	jr	eq,L0A8C
	test	r11
	jr	eq,L0A8C
	ldb	@r10,#%30
	inc	r10,#1
L0A8C:
	xor	r2,r2
	calr	L0A92
	jr	L0B06
L0A92:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0A9C
	calr	L0A92
L0A9C:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0AAC
	add	r0,#%0007
L0AAC:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0AB2:
	call	pscien
	jr	L0B06
L0AB8:
	call	pscien
	jr	L0B06
L0ABE:
	inc	r11,#1
	test	r9
	jr	ne,L0AC8
	ldk	r11,#7
	ld	r9,r11
L0AC8:
	call	pscien
	jr	L0B06
L0ACE:
	ld	r13,@r13
	pop	r12,@r13
	jp	L099A
L0AD6:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0B06
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0B06
L0AE8:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0AF8
	ld	r2,#D14F6
L0AF8:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0B08
	dec	r10,#1
	jr	L0B08
L0B06:
	ld	r2,r15
L0B08:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0B14
	xor	r1,r1
L0B14:
	test	%FFF0(r14)
	jr	ne,L0B1C
	neg	r1
L0B1C:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L099A
L0B34:
	xor	r9,r9
	ld	r1,r9
L0B38:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0B4C
	pop	r2,@r13
	jr	L0B5C
L0B4C:
	cp	r2,#%0009
	jr	ugt,L0B5C
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0B38
L0B5C:
	add	r2,#%0030
	ret
end __doprnt
I
D14B2:
WV L0A56
BV %0;BV %64
WV L0A52
BV %0;BV %6F
WV L0A50
BV %0;BV %78
WV L0AB2
BV %0;BV %66
WV L0ABE
BV %0;BV %65
WV L0AB8
BV %0;BV %67
WV L0AD6
BV %0;BV %63
WV L0AE8
BV %0;BV %73
WV L0A2A
BV %0;BV %6C
WV L0A2A
BV %0;BV %4C
WV L0A7A
BV %0;BV %75
WV L0ACE
BV %0;BV %72
WV L0A60
BV %0;BV %44
WV L0A4A
BV %0;BV %4F
WV L0A4E
BV %0;BV %58
WV L0A78
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D14F6:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
