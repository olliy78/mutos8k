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
L0EA8:
	ld	r10,r15
L0EAA:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0EBE
	cpb	rl0,#%25
	jr	eq,L0EBE
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0EAA
L0EBE:
	cp	r10,r15
	jr	eq,L0EDC
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
L0EDC:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0EFE
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0EFE:
	cpb	@r12,#%30
	jr	ne,L0F0A
	ld	%FFEE(r14),#%0030
L0F0A:
	calr	L1044
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0F1C
	calr	L1044
	ld	r11,r1
L0F1C:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1DA8
L0F24:
	pop	r4,@r7
	test	r4
	jr	ne,L0F30
	ldb	@r10,rl2
	inc	r10,#1
	jr	L1016
L0F30:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0F24
	jp	@r4
L0F38:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0F58
	cpb	rl1,#%78
	jr	eq,L0F5C
	cpb	rl1,#%64
	jr	eq,L0F6E
	cpb	rl1,#%75
	jr	eq,L0F86
	dec	r12,#1
	jr	L0F88
L0F58:
	pop	r6,@r13
	jr	L0F60
L0F5C:
	pop	r6,@r13
L0F5E:
	rl	r3,#1
L0F60:
	pop	r7,@r13
	jr	L0F8C
L0F64:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0F76
	jr	L0F8A
L0F6E:
	pop	r6,@r13
	test	r6
	jr	pl,L0F88
	pop	r7,@r13
L0F76:
	neg	r6
	neg	r7
	jr	uge,L0F7E
	dec	r6,#1
L0F7E:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0F8A
L0F86:
	pop	r6,@r13
L0F88:
	pop	r7,@r13
L0F8A:
	inc	r3,#2
L0F8C:
	testl	rr6
	jr	eq,L0F9A
	test	r11
	jr	eq,L0F9A
	ldb	@r10,#%30
	inc	r10,#1
L0F9A:
	xor	r2,r2
	calr	L0FA0
	jr	L1016
L0FA0:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0FAC
	calr	L0FA0
L0FAC:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0FBC
	add	r0,#%0007
L0FBC:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0FC2:
	call	pscien
	jr	L1016
L0FC8:
	call	pscien
	jr	L1016
L0FCE:
	inc	r11,#1
	test	r9
	jr	ne,L0FD8
	ldk	r11,#7
	ld	r9,r11
L0FD8:
	call	pscien
	jr	L1016
L0FDE:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0EA8
L0FE6:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L1016
	ldb	@r10,rl0
	inc	r10,#1
	jr	L1016
L0FF8:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L1008
	ld	r2,#D1DEC
L1008:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L1018
	dec	r10,#1
	jr	L1018
L1016:
	ld	r2,r15
L1018:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L1024
	xor	r1,r1
L1024:
	test	%FFF0(r14)
	jr	ne,L102C
	neg	r1
L102C:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0EA8
L1044:
	xor	r9,r9
	ld	r1,r9
L1048:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L105C
	pop	r2,@r13
	jr	L106C
L105C:
	cp	r2,#%0009
	jr	ugt,L106C
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L1048
L106C:
	add	r2,#%0030
	ret
end __doprnt
I
D1DA8:
WV L0F64
BV %0;BV %64
WV L0F60
BV %0;BV %6F
WV L0F5E
BV %0;BV %78
WV L0FC2
BV %0;BV %66
WV L0FCE
BV %0;BV %65
WV L0FC8
BV %0;BV %67
WV L0FE6
BV %0;BV %63
WV L0FF8
BV %0;BV %73
WV L0F38
BV %0;BV %6C
WV L0F38
BV %0;BV %4C
WV L0F88
BV %0;BV %75
WV L0FDE
BV %0;BV %72
WV L0F6E
BV %0;BV %44
WV L0F58
BV %0;BV %4F
WV L0F5C
BV %0;BV %58
WV L0F86
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D1DEC:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
