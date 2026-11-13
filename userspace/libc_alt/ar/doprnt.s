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
L0F62:
	ld	r10,r15
L0F64:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0F78
	cpb	rl0,#%25
	jr	eq,L0F78
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0F64
L0F78:
	cp	r10,r15
	jr	eq,L0F96
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
L0F96:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0FB8
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0FB8:
	cpb	@r12,#%30
	jr	ne,L0FC4
	ld	%FFEE(r14),#%0030
L0FC4:
	calr	L10FC
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0FD6
	calr	L10FC
	ld	r11,r1
L0FD6:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D2322
L0FDE:
	pop	r4,@r7
	test	r4
	jr	ne,L0FEA
	ldb	@r10,rl2
	inc	r10,#1
	jr	L10CE
L0FEA:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0FDE
	jp	@r4
L0FF2:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L1012
	cpb	rl1,#%78
	jr	eq,L1016
	cpb	rl1,#%64
	jr	eq,L1028
	cpb	rl1,#%75
	jr	eq,L1040
	dec	r12,#1
	jr	L1042
L1012:
	pop	r6,@r13
	jr	L101A
L1016:
	pop	r6,@r13
L1018:
	rl	r3,#1
L101A:
	pop	r7,@r13
	jr	L1046
L101E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L1030
	jr	L1044
L1028:
	pop	r6,@r13
	test	r6
	jr	pl,L1042
	pop	r7,@r13
L1030:
	neg	r6
	neg	r7
	jr	uge,L1038
	dec	r6,#1
L1038:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L1044
L1040:
	pop	r6,@r13
L1042:
	pop	r7,@r13
L1044:
	inc	r3,#2
L1046:
	testl	rr6
	jr	eq,L1054
	test	r11
	jr	eq,L1054
	ldb	@r10,#%30
	inc	r10,#1
L1054:
	xor	r2,r2
	calr	L105A
	jr	L10CE
L105A:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L1064
	calr	L105A
L1064:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L1074
	add	r0,#%0007
L1074:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L107A:
	call	pscien
	jr	L10CE
L1080:
	call	pscien
	jr	L10CE
L1086:
	inc	r11,#1
	test	r9
	jr	ne,L1090
	ldk	r11,#7
	ld	r9,r11
L1090:
	call	pscien
	jr	L10CE
L1096:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0F62
L109E:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L10CE
	ldb	@r10,rl0
	inc	r10,#1
	jr	L10CE
L10B0:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L10C0
	ld	r2,#D2366
L10C0:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L10D0
	dec	r10,#1
	jr	L10D0
L10CE:
	ld	r2,r15
L10D0:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L10DC
	xor	r1,r1
L10DC:
	test	%FFF0(r14)
	jr	ne,L10E4
	neg	r1
L10E4:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0F62
L10FC:
	xor	r9,r9
	ld	r1,r9
L1100:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L1114
	pop	r2,@r13
	jr	L1124
L1114:
	cp	r2,#%0009
	jr	ugt,L1124
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L1100
L1124:
	add	r2,#%0030
	ret
end __doprnt
I
D2322:
WV L101E
BV %0;BV %64
WV L101A
BV %0;BV %6F
WV L1018
BV %0;BV %78
WV L107A
BV %0;BV %66
WV L1086
BV %0;BV %65
WV L1080
BV %0;BV %67
WV L109E
BV %0;BV %63
WV L10B0
BV %0;BV %73
WV L0FF2
BV %0;BV %6C
WV L0FF2
BV %0;BV %4C
WV L1042
BV %0;BV %75
WV L1096
BV %0;BV %72
WV L1028
BV %0;BV %44
WV L1012
BV %0;BV %4F
WV L1016
BV %0;BV %58
WV L1040
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D2366:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
