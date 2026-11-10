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
L02CA:
	ld	r10,r15
L02CC:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L02E0
	cpb	rl0,#%25
	jr	eq,L02E0
	ldb	@r10,rl0
	inc	r10,#1
	jr	L02CC
L02E0:
	cp	r10,r15
	jr	eq,L02FE
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
L02FE:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0320
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0320:
	cpb	@r12,#%30
	jr	ne,L032C
	ld	%FFEE(r14),#%0030
L032C:
	calr	L0466
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L033E
	calr	L0466
	ld	r11,r1
L033E:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0CEC
L0346:
	pop	r4,@r7
	test	r4
	jr	ne,L0352
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0438
L0352:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0346
	jp	@r4
L035A:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L037A
	cpb	rl1,#%78
	jr	eq,L037E
	cpb	rl1,#%64
	jr	eq,L0390
	cpb	rl1,#%75
	jr	eq,L03A8
	dec	r12,#1
	jr	L03AA
L037A:
	pop	r6,@r13
	jr	L0382
L037E:
	pop	r6,@r13
L0380:
	rl	r3,#1
L0382:
	pop	r7,@r13
	jr	L03AE
L0386:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0398
	jr	L03AC
L0390:
	pop	r6,@r13
	test	r6
	jr	pl,L03AA
	pop	r7,@r13
L0398:
	neg	r6
	neg	r7
	jr	uge,L03A0
	dec	r6,#1
L03A0:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L03AC
L03A8:
	pop	r6,@r13
L03AA:
	pop	r7,@r13
L03AC:
	inc	r3,#2
L03AE:
	testl	rr6
	jr	eq,L03BC
	test	r11
	jr	eq,L03BC
	ldb	@r10,#%30
	inc	r10,#1
L03BC:
	xor	r2,r2
	calr	L03C2
	jr	L0438
L03C2:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L03CE
	calr	L03C2
L03CE:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L03DE
	add	r0,#%0007
L03DE:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L03E4:
	call	pscien
	jr	L0438
L03EA:
	call	pscien
	jr	L0438
L03F0:
	inc	r11,#1
	test	r9
	jr	ne,L03FA
	ldk	r11,#7
	ld	r9,r11
L03FA:
	call	pscien
	jr	L0438
L0400:
	ld	r13,@r13
	pop	r12,@r13
	jp	L02CA
L0408:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0438
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0438
L041A:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L042A
	ld	r2,#D0D30
L042A:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L043A
	dec	r10,#1
	jr	L043A
L0438:
	ld	r2,r15
L043A:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0446
	xor	r1,r1
L0446:
	test	%FFF0(r14)
	jr	ne,L044E
	neg	r1
L044E:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L02CA
L0466:
	xor	r9,r9
	ld	r1,r9
L046A:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L047E
	pop	r2,@r13
	jr	L048E
L047E:
	cp	r2,#%0009
	jr	ugt,L048E
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L046A
L048E:
	add	r2,#%0030
	ret
end __doprnt
I
D0CEC:
WV L0386
BV %0;BV %64
WV L0382
BV %0;BV %6F
WV L0380
BV %0;BV %78
WV L03E4
BV %0;BV %66
WV L03F0
BV %0;BV %65
WV L03EA
BV %0;BV %67
WV L0408
BV %0;BV %63
WV L041A
BV %0;BV %73
WV L035A
BV %0;BV %6C
WV L035A
BV %0;BV %4C
WV L03AA
BV %0;BV %75
WV L0400
BV %0;BV %72
WV L0390
BV %0;BV %44
WV L037A
BV %0;BV %4F
WV L037E
BV %0;BV %58
WV L03A8
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0D30:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
