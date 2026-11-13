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
L09B6:
	ld	r10,r15
L09B8:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L09CC
	cpb	rl0,#%25
	jr	eq,L09CC
	ldb	@r10,rl0
	inc	r10,#1
	jr	L09B8
L09CC:
	cp	r10,r15
	jr	eq,L09EA
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
L09EA:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0A0C
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0A0C:
	cpb	@r12,#%30
	jr	ne,L0A18
	ld	%FFEE(r14),#%0030
L0A18:
	calr	L0B50
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0A2A
	calr	L0B50
	ld	r11,r1
L0A2A:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1F54
L0A32:
	pop	r4,@r7
	test	r4
	jr	ne,L0A3E
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0B22
L0A3E:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0A32
	jp	@r4
L0A46:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0A66
	cpb	rl1,#%78
	jr	eq,L0A6A
	cpb	rl1,#%64
	jr	eq,L0A7C
	cpb	rl1,#%75
	jr	eq,L0A94
	dec	r12,#1
	jr	L0A96
L0A66:
	pop	r6,@r13
	jr	L0A6E
L0A6A:
	pop	r6,@r13
L0A6C:
	rl	r3,#1
L0A6E:
	pop	r7,@r13
	jr	L0A9A
L0A72:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0A84
	jr	L0A98
L0A7C:
	pop	r6,@r13
	test	r6
	jr	pl,L0A96
	pop	r7,@r13
L0A84:
	neg	r6
	neg	r7
	jr	uge,L0A8C
	dec	r6,#1
L0A8C:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0A98
L0A94:
	pop	r6,@r13
L0A96:
	pop	r7,@r13
L0A98:
	inc	r3,#2
L0A9A:
	testl	rr6
	jr	eq,L0AA8
	test	r11
	jr	eq,L0AA8
	ldb	@r10,#%30
	inc	r10,#1
L0AA8:
	xor	r2,r2
	calr	L0AAE
	jr	L0B22
L0AAE:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0AB8
	calr	L0AAE
L0AB8:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0AC8
	add	r0,#%0007
L0AC8:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0ACE:
	call	pscien
	jr	L0B22
L0AD4:
	call	pscien
	jr	L0B22
L0ADA:
	inc	r11,#1
	test	r9
	jr	ne,L0AE4
	ldk	r11,#7
	ld	r9,r11
L0AE4:
	call	pscien
	jr	L0B22
L0AEA:
	ld	r13,@r13
	pop	r12,@r13
	jp	L09B6
L0AF2:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0B22
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0B22
L0B04:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
L0B0C:
	test	r2
L0B0E:
	jr	ne,L0B14
	ld	r2,#D1F98
L0B14:
	ld	r10,r2
	xorb	rl0,rl0
L0B18:
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0B24
	dec	r10,#1
	jr	L0B24
L0B22:
	ld	r2,r15
L0B24:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0B30
	xor	r1,r1
L0B30:
	test	%FFF0(r14)
	jr	ne,L0B38
	neg	r1
L0B38:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L09B6
L0B50:
	xor	r9,r9
	ld	r1,r9
L0B54:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0B68
	pop	r2,@r13
	jr	L0B78
L0B68:
	cp	r2,#%0009
	jr	ugt,L0B78
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0B54
L0B78:
	add	r2,#%0030
	ret
end __doprnt
I
D1F54:
WV L0A72
BV %0;BV %64
WV L0A6E
BV %0;BV %6F
WV L0A6C
BV %0;BV %78
WV L0ACE
BV %0;BV %66
WV L0ADA
BV %0;BV %65
WV L0AD4
BV %0;BV %67
WV L0AF2
BV %0;BV %63
WV L0B04
BV %0;BV %73
WV L0A46
BV %0;BV %6C
WV L0A46
BV %0;BV %4C
WV L0A96
BV %0;BV %75
WV L0AEA
BV %0;BV %72
WV L0A7C
BV %0;BV %44
WV L0A66
BV %0;BV %4F
WV L0A6A
BV %0;BV %58
WV L0A94
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D1F98:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
