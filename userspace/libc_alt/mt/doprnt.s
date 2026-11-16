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
L01AE:
	ld	r10,r15
L01B0:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L01C4
	cpb	rl0,#%25
	jr	eq,L01C4
	ldb	@r10,rl0
	inc	r10,#1
	jr	L01B0
L01C4:
	cp	r10,r15
	jr	eq,L01E2
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
L01E2:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0204
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0204:
	cpb	@r12,#%30
	jr	ne,L0210
	ld	%FFEE(r14),#%0030
L0210:
	calr	L034A
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0222
	calr	L034A
	ld	r11,r1
L0222:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0D4E
L022A:
	pop	r4,@r7
	test	r4
	jr	ne,L0236
	ldb	@r10,rl2
	inc	r10,#1
	jr	L031C
L0236:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L022A
	jp	@r4
L023E:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L025E
	cpb	rl1,#%78
	jr	eq,L0262
	cpb	rl1,#%64
	jr	eq,L0274
	cpb	rl1,#%75
	jr	eq,L028C
	dec	r12,#1
	jr	L028E
L025E:
	pop	r6,@r13
	jr	L0266
L0262:
	pop	r6,@r13
L0264:
	rl	r3,#1
L0266:
	pop	r7,@r13
	jr	L0292
L026A:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L027C
	jr	L0290
L0274:
	pop	r6,@r13
	test	r6
	jr	pl,L028E
	pop	r7,@r13
L027C:
	neg	r6
	neg	r7
	jr	uge,L0284
	dec	r6,#1
L0284:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0290
L028C:
	pop	r6,@r13
L028E:
	pop	r7,@r13
L0290:
	inc	r3,#2
L0292:
	testl	rr6
	jr	eq,L02A0
	test	r11
	jr	eq,L02A0
	ldb	@r10,#%30
	inc	r10,#1
L02A0:
	xor	r2,r2
	calr	L02A6
	jr	L031C
L02A6:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L02B2
	calr	L02A6
L02B2:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L02C2
	add	r0,#%0007
L02C2:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L02C8:
	call	pscien
	jr	L031C
L02CE:
	call	pscien
	jr	L031C
L02D4:
	inc	r11,#1
	test	r9
	jr	ne,L02DE
	ldk	r11,#7
	ld	r9,r11
L02DE:
	call	pscien
	jr	L031C
L02E4:
	ld	r13,@r13
	pop	r12,@r13
	jp	L01AE
L02EC:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L031C
	ldb	@r10,rl0
	inc	r10,#1
	jr	L031C
L02FE:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L030E
	ld	r2,#D0D92
L030E:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L031E
	dec	r10,#1
	jr	L031E
L031C:
	ld	r2,r15
L031E:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L032A
	xor	r1,r1
L032A:
	test	%FFF0(r14)
	jr	ne,L0332
	neg	r1
L0332:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L01AE
L034A:
	xor	r9,r9
	ld	r1,r9
L034E:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0362
	pop	r2,@r13
	jr	L0372
L0362:
	cp	r2,#%0009
	jr	ugt,L0372
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L034E
L0372:
	add	r2,#%0030
	ret
end __doprnt
I
D0D4E:
WV L026A
BV %0;BV %64
WV L0266
BV %0;BV %6F
WV L0264
BV %0;BV %78
WV L02C8
BV %0;BV %66
WV L02D4
BV %0;BV %65
WV L02CE
BV %0;BV %67
WV L02EC
BV %0;BV %63
WV L02FE
BV %0;BV %73
WV L023E
BV %0;BV %6C
WV L023E
BV %0;BV %4C
WV L028E
BV %0;BV %75
WV L02E4
BV %0;BV %72
WV L0274
BV %0;BV %44
WV L025E
BV %0;BV %4F
WV L0262
BV %0;BV %58
WV L028C
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0D92:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
