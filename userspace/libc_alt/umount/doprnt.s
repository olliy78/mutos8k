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
L01CC:
	ld	r10,r15
L01CE:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L01E2
	cpb	rl0,#%25
	jr	eq,L01E2
	ldb	@r10,rl0
	inc	r10,#1
	jr	L01CE
L01E2:
	cp	r10,r15
	jr	eq,L0200
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
L0200:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0222
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0222:
	cpb	@r12,#%30
	jr	ne,L022E
	ld	%FFEE(r14),#%0030
L022E:
	calr	L0366
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0240
	calr	L0366
	ld	r11,r1
L0240:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0C68
L0248:
	pop	r4,@r7
	test	r4
	jr	ne,L0254
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0338
L0254:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0248
	jp	@r4
L025C:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L027C
	cpb	rl1,#%78
	jr	eq,L0280
	cpb	rl1,#%64
	jr	eq,L0292
	cpb	rl1,#%75
	jr	eq,L02AA
	dec	r12,#1
	jr	L02AC
L027C:
	pop	r6,@r13
	jr	L0284
L0280:
	pop	r6,@r13
L0282:
	rl	r3,#1
L0284:
	pop	r7,@r13
	jr	L02B0
L0288:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L029A
	jr	L02AE
L0292:
	pop	r6,@r13
	test	r6
	jr	pl,L02AC
	pop	r7,@r13
L029A:
	neg	r6
	neg	r7
	jr	uge,L02A2
	dec	r6,#1
L02A2:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L02AE
L02AA:
	pop	r6,@r13
L02AC:
	pop	r7,@r13
L02AE:
	inc	r3,#2
L02B0:
	testl	rr6
	jr	eq,L02BE
	test	r11
	jr	eq,L02BE
	ldb	@r10,#%30
	inc	r10,#1
L02BE:
	xor	r2,r2
	calr	L02C4
	jr	L0338
L02C4:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L02CE
	calr	L02C4
L02CE:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L02DE
	add	r0,#%0007
L02DE:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L02E4:
	call	pscien
	jr	L0338
L02EA:
	call	pscien
	jr	L0338
L02F0:
	inc	r11,#1
	test	r9
	jr	ne,L02FA
	ldk	r11,#7
	ld	r9,r11
L02FA:
	call	pscien
	jr	L0338
L0300:
	ld	r13,@r13
	pop	r12,@r13
	jp	L01CC
L0308:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0338
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0338
L031A:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L032A
	ld	r2,#D0CAC
L032A:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L033A
	dec	r10,#1
	jr	L033A
L0338:
	ld	r2,r15
L033A:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0346
	xor	r1,r1
L0346:
	test	%FFF0(r14)
	jr	ne,L034E
	neg	r1
L034E:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L01CC
L0366:
	xor	r9,r9
	ld	r1,r9
L036A:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L037E
	pop	r2,@r13
	jr	L038E
L037E:
	cp	r2,#%0009
	jr	ugt,L038E
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L036A
L038E:
	add	r2,#%0030
	ret
end __doprnt
I
D0C68:
WV L0288
BV %0;BV %64
WV L0284
BV %0;BV %6F
WV L0282
BV %0;BV %78
WV L02E4
BV %0;BV %66
WV L02F0
BV %0;BV %65
WV L02EA
BV %0;BV %67
WV L0308
BV %0;BV %63
WV L031A
BV %0;BV %73
WV L025C
BV %0;BV %6C
WV L025C
BV %0;BV %4C
WV L02AC
BV %0;BV %75
WV L0300
BV %0;BV %72
WV L0292
BV %0;BV %44
WV L027C
BV %0;BV %4F
WV L0280
BV %0;BV %58
WV L02AA
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0CAC:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
