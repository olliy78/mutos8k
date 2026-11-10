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
L0182:
	ld	r10,r15
L0184:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0198
	cpb	rl0,#%25
	jr	eq,L0198
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0184
L0198:
	cp	r10,r15
	jr	eq,L01B6
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
L01B6:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L01D8
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L01D8:
	cpb	@r12,#%30
	jr	ne,L01E4
	ld	%FFEE(r14),#%0030
L01E4:
	calr	L031C
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L01F6
	calr	L031C
	ld	r11,r1
L01F6:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0BCA
L01FE:
	pop	r4,@r7
	test	r4
	jr	ne,L020A
	ldb	@r10,rl2
	inc	r10,#1
	jr	L02EE
L020A:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L01FE
	jp	@r4
L0212:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0232
	cpb	rl1,#%78
	jr	eq,L0236
	cpb	rl1,#%64
	jr	eq,L0248
	cpb	rl1,#%75
	jr	eq,L0260
	dec	r12,#1
	jr	L0262
L0232:
	pop	r6,@r13
	jr	L023A
L0236:
	pop	r6,@r13
L0238:
	rl	r3,#1
L023A:
	pop	r7,@r13
	jr	L0266
L023E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0250
	jr	L0264
L0248:
	pop	r6,@r13
	test	r6
	jr	pl,L0262
	pop	r7,@r13
L0250:
	neg	r6
	neg	r7
	jr	uge,L0258
	dec	r6,#1
L0258:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0264
L0260:
	pop	r6,@r13
L0262:
	pop	r7,@r13
L0264:
	inc	r3,#2
L0266:
	testl	rr6
	jr	eq,L0274
	test	r11
	jr	eq,L0274
	ldb	@r10,#%30
	inc	r10,#1
L0274:
	xor	r2,r2
	calr	L027A
	jr	L02EE
L027A:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0284
	calr	L027A
L0284:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0294
	add	r0,#%0007
L0294:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L029A:
	call	pscien
	jr	L02EE
L02A0:
	call	pscien
	jr	L02EE
L02A6:
	inc	r11,#1
	test	r9
	jr	ne,L02B0
	ldk	r11,#7
	ld	r9,r11
L02B0:
	call	pscien
	jr	L02EE
L02B6:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0182
L02BE:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L02EE
	ldb	@r10,rl0
	inc	r10,#1
	jr	L02EE
L02D0:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L02E0
	ld	r2,#D0C0E
L02E0:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L02F0
	dec	r10,#1
	jr	L02F0
L02EE:
	ld	r2,r15
L02F0:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L02FC
	xor	r1,r1
L02FC:
	test	%FFF0(r14)
	jr	ne,L0304
	neg	r1
L0304:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0182
L031C:
	xor	r9,r9
	ld	r1,r9
L0320:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0334
	pop	r2,@r13
	jr	L0344
L0334:
	cp	r2,#%0009
	jr	ugt,L0344
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0320
L0344:
	add	r2,#%0030
	ret
end __doprnt
I
D0BCA:
WV L023E
BV %0;BV %64
WV L023A
BV %0;BV %6F
WV L0238
BV %0;BV %78
WV L029A
BV %0;BV %66
WV L02A6
BV %0;BV %65
WV L02A0
BV %0;BV %67
WV L02BE
BV %0;BV %63
WV L02D0
BV %0;BV %73
WV L0212
BV %0;BV %6C
WV L0212
BV %0;BV %4C
WV L0262
BV %0;BV %75
WV L02B6
BV %0;BV %72
WV L0248
BV %0;BV %44
WV L0232
BV %0;BV %4F
WV L0236
BV %0;BV %58
WV L0260
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0C0E:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
