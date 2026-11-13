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
L0920:
	ld	r10,r15
L0922:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0936
	cpb	rl0,#%25
	jr	eq,L0936
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0922
L0936:
	cp	r10,r15
	jr	eq,L0954
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
L0954:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0976
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0976:
	cpb	@r12,#%30
	jr	ne,L0982
	ld	%FFEE(r14),#%0030
L0982:
	calr	L0ABA
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0994
	calr	L0ABA
	ld	r11,r1
L0994:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D168E
L099C:
	pop	r4,@r7
	test	r4
	jr	ne,L09A8
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0A8C
L09A8:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L099C
	jp	@r4
L09B0:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L09D0
	cpb	rl1,#%78
	jr	eq,L09D4
	cpb	rl1,#%64
	jr	eq,L09E6
	cpb	rl1,#%75
	jr	eq,L09FE
	dec	r12,#1
	jr	L0A00
L09D0:
	pop	r6,@r13
	jr	L09D8
L09D4:
	pop	r6,@r13
L09D6:
	rl	r3,#1
L09D8:
	pop	r7,@r13
	jr	L0A04
L09DC:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L09EE
	jr	L0A02
L09E6:
	pop	r6,@r13
	test	r6
	jr	pl,L0A00
	pop	r7,@r13
L09EE:
	neg	r6
	neg	r7
	jr	uge,L09F6
	dec	r6,#1
L09F6:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0A02
L09FE:
	pop	r6,@r13
L0A00:
	pop	r7,@r13
L0A02:
	inc	r3,#2
L0A04:
	testl	rr6
	jr	eq,L0A12
	test	r11
	jr	eq,L0A12
	ldb	@r10,#%30
	inc	r10,#1
L0A12:
	xor	r2,r2
	calr	L0A18
	jr	L0A8C
L0A18:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0A22
	calr	L0A18
L0A22:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0A32
	add	r0,#%0007
L0A32:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0A38:
	call	pscien
	jr	L0A8C
L0A3E:
	call	pscien
	jr	L0A8C
L0A44:
	inc	r11,#1
	test	r9
	jr	ne,L0A4E
	ldk	r11,#7
	ld	r9,r11
L0A4E:
	call	pscien
	jr	L0A8C
L0A54:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0920
L0A5C:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0A8C
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0A8C
L0A6E:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0A7E
	ld	r2,#D16D2
L0A7E:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0A8E
	dec	r10,#1
	jr	L0A8E
L0A8C:
	ld	r2,r15
L0A8E:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0A9A
	xor	r1,r1
L0A9A:
	test	%FFF0(r14)
	jr	ne,L0AA2
	neg	r1
L0AA2:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0920
L0ABA:
	xor	r9,r9
	ld	r1,r9
L0ABE:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0AD2
	pop	r2,@r13
	jr	L0AE2
L0AD2:
	cp	r2,#%0009
	jr	ugt,L0AE2
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0ABE
L0AE2:
	add	r2,#%0030
	ret
end __doprnt
I
D168E:
WV L09DC
BV %0;BV %64
WV L09D8
BV %0;BV %6F
WV L09D6
BV %0;BV %78
WV L0A38
BV %0;BV %66
WV L0A44
BV %0;BV %65
WV L0A3E
BV %0;BV %67
WV L0A5C
BV %0;BV %63
WV L0A6E
BV %0;BV %73
WV L09B0
BV %0;BV %6C
WV L09B0
BV %0;BV %4C
WV L0A00
BV %0;BV %75
WV L0A54
BV %0;BV %72
WV L09E6
BV %0;BV %44
WV L09D0
BV %0;BV %4F
WV L09D4
BV %0;BV %58
WV L09FE
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D16D2:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
