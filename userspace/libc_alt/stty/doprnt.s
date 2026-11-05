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
L085A:
	ld	r10,r15
L085C:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0870
	cpb	rl0,#%25
	jr	eq,L0870
	ldb	@r10,rl0
	inc	r10,#1
	jr	L085C
L0870:
	cp	r10,r15
	jr	eq,L088E
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
L088E:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L08B0
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L08B0:
	cpb	@r12,#%30
	jr	ne,L08BC
	ld	%FFEE(r14),#%0030
L08BC:
	calr	L09F4
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L08CE
	calr	L09F4
	ld	r11,r1
L08CE:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D15C8
L08D6:
	pop	r4,@r7
	test	r4
	jr	ne,L08E2
	ldb	@r10,rl2
	inc	r10,#1
	jr	L09C6
L08E2:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L08D6
	jp	@r4
L08EA:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L090A
	cpb	rl1,#%78
	jr	eq,L090E
	cpb	rl1,#%64
	jr	eq,L0920
	cpb	rl1,#%75
	jr	eq,L0938
	dec	r12,#1
	jr	L093A
L090A:
	pop	r6,@r13
	jr	L0912
L090E:
	pop	r6,@r13
L0910:
	rl	r3,#1
L0912:
	pop	r7,@r13
	jr	L093E
L0916:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0928
	jr	L093C
L0920:
	pop	r6,@r13
	test	r6
	jr	pl,L093A
	pop	r7,@r13
L0928:
	neg	r6
	neg	r7
	jr	uge,L0930
	dec	r6,#1
L0930:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L093C
L0938:
	pop	r6,@r13
L093A:
	pop	r7,@r13
L093C:
	inc	r3,#2
L093E:
	testl	rr6
	jr	eq,L094C
	test	r11
	jr	eq,L094C
	ldb	@r10,#%30
	inc	r10,#1
L094C:
	xor	r2,r2
	calr	L0952
	jr	L09C6
L0952:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L095C
	calr	L0952
L095C:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L096C
	add	r0,#%0007
L096C:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0972:
	call	pscien
	jr	L09C6
L0978:
	call	pscien
	jr	L09C6
L097E:
	inc	r11,#1
	test	r9
	jr	ne,L0988
	ldk	r11,#7
	ld	r9,r11
L0988:
	call	pscien
	jr	L09C6
L098E:
	ld	r13,@r13
	pop	r12,@r13
	jp	L085A
L0996:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L09C6
	ldb	@r10,rl0
	inc	r10,#1
	jr	L09C6
L09A8:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L09B8
	ld	r2,#D160C
L09B8:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L09C8
	dec	r10,#1
	jr	L09C8
L09C6:
	ld	r2,r15
L09C8:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L09D4
	xor	r1,r1
L09D4:
	test	%FFF0(r14)
	jr	ne,L09DC
	neg	r1
L09DC:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L085A
L09F4:
	xor	r9,r9
	ld	r1,r9
L09F8:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0A0C
	pop	r2,@r13
	jr	L0A1C
L0A0C:
	cp	r2,#%0009
	jr	ugt,L0A1C
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L09F8
L0A1C:
	add	r2,#%0030
	ret
end __doprnt
I
D15C8:
WV L0916
BV %0;BV %64
WV L0912
BV %0;BV %6F
WV L0910
BV %0;BV %78
WV L0972
BV %0;BV %66
WV L097E
BV %0;BV %65
WV L0978
BV %0;BV %67
WV L0996
BV %0;BV %63
WV L09A8
BV %0;BV %73
WV L08EA
BV %0;BV %6C
WV L08EA
BV %0;BV %4C
WV L093A
BV %0;BV %75
WV L098E
BV %0;BV %72
WV L0920
BV %0;BV %44
WV L090A
BV %0;BV %4F
WV L090E
BV %0;BV %58
WV L0938
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D160C:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
