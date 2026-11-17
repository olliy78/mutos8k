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
L0C10:
	ld	r10,r15
L0C12:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0C26
	cpb	rl0,#%25
	jr	eq,L0C26
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0C12
L0C26:
	cp	r10,r15
	jr	eq,L0C44
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
L0C44:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0C66
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0C66:
	cpb	@r12,#%30
	jr	ne,L0C72
	ld	%FFEE(r14),#%0030
L0C72:
	calr	L0DAC
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0C84
	calr	L0DAC
	ld	r11,r1
L0C84:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1888
L0C8C:
	pop	r4,@r7
	test	r4
	jr	ne,L0C98
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0D7E
L0C98:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0C8C
	jp	@r4
L0CA0:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0CC0
	cpb	rl1,#%78
	jr	eq,L0CC4
	cpb	rl1,#%64
	jr	eq,L0CD6
	cpb	rl1,#%75
	jr	eq,L0CEE
	dec	r12,#1
	jr	L0CF0
L0CC0:
	pop	r6,@r13
	jr	L0CC8
L0CC4:
	pop	r6,@r13
L0CC6:
	rl	r3,#1
L0CC8:
	pop	r7,@r13
	jr	L0CF4
L0CCC:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0CDE
	jr	L0CF2
L0CD6:
	pop	r6,@r13
	test	r6
	jr	pl,L0CF0
	pop	r7,@r13
L0CDE:
	neg	r6
	neg	r7
	jr	uge,L0CE6
	dec	r6,#1
L0CE6:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0CF2
L0CEE:
	pop	r6,@r13
L0CF0:
	pop	r7,@r13
L0CF2:
	inc	r3,#2
L0CF4:
	testl	rr6
	jr	eq,L0D02
	test	r11
	jr	eq,L0D02
	ldb	@r10,#%30
	inc	r10,#1
L0D02:
	xor	r2,r2
	calr	L0D08
	jr	L0D7E
L0D08:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0D14
	calr	L0D08
L0D14:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0D24
	add	r0,#%0007
L0D24:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0D2A:
	call	pscien
	jr	L0D7E
L0D30:
	call	pscien
	jr	L0D7E
L0D36:
	inc	r11,#1
	test	r9
	jr	ne,L0D40
	ldk	r11,#7
	ld	r9,r11
L0D40:
	call	pscien
	jr	L0D7E
L0D46:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0C10
L0D4E:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0D7E
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0D7E
L0D60:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0D70
	ld	r2,#D18CC
L0D70:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L0D80
	dec	r10,#1
	jr	L0D80
L0D7E:
	ld	r2,r15
L0D80:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0D8C
	xor	r1,r1
L0D8C:
	test	%FFF0(r14)
	jr	ne,L0D94
	neg	r1
L0D94:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0C10
L0DAC:
	xor	r9,r9
	ld	r1,r9
L0DB0:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0DC4
	pop	r2,@r13
	jr	L0DD4
L0DC4:
	cp	r2,#%0009
	jr	ugt,L0DD4
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0DB0
L0DD4:
	add	r2,#%0030
	ret
end __doprnt
I
D1888:
WV L0CCC
BV %0;BV %64
WV L0CC8
BV %0;BV %6F
WV L0CC6
BV %0;BV %78
WV L0D2A
BV %0;BV %66
WV L0D36
BV %0;BV %65
WV L0D30
BV %0;BV %67
WV L0D4E
BV %0;BV %63
WV L0D60
BV %0;BV %73
WV L0CA0
BV %0;BV %6C
WV L0CA0
BV %0;BV %4C
WV L0CF0
BV %0;BV %75
WV L0D46
BV %0;BV %72
WV L0CD6
BV %0;BV %44
WV L0CC0
BV %0;BV %4F
WV L0CC4
BV %0;BV %58
WV L0CEE
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D18CC:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
