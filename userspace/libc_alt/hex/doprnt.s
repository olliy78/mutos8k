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
L049A:
	ld	r10,r15
L049C:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L04B0
	cpb	rl0,#%25
	jr	eq,L04B0
	ldb	@r10,rl0
	inc	r10,#1
	jr	L049C
L04B0:
	cp	r10,r15
	jr	eq,L04CE
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
L04CE:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L04F0
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L04F0:
	cpb	@r12,#%30
	jr	ne,L04FC
	ld	%FFEE(r14),#%0030
L04FC:
	calr	L0636
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L050E
	calr	L0636
	ld	r11,r1
L050E:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0FE8
L0516:
	pop	r4,@r7
	test	r4
	jr	ne,L0522
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0608
L0522:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0516
	jp	@r4
L052A:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L054A
	cpb	rl1,#%78
	jr	eq,L054E
	cpb	rl1,#%64
	jr	eq,L0560
	cpb	rl1,#%75
	jr	eq,L0578
	dec	r12,#1
	jr	L057A
L054A:
	pop	r6,@r13
	jr	L0552
L054E:
	pop	r6,@r13
L0550:
	rl	r3,#1
L0552:
	pop	r7,@r13
	jr	L057E
L0556:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0568
	jr	L057C
L0560:
	pop	r6,@r13
	test	r6
	jr	pl,L057A
	pop	r7,@r13
L0568:
	neg	r6
	neg	r7
	jr	uge,L0570
	dec	r6,#1
L0570:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L057C
L0578:
	pop	r6,@r13
L057A:
	pop	r7,@r13
L057C:
	inc	r3,#2
L057E:
	testl	rr6
	jr	eq,L058C
	test	r11
	jr	eq,L058C
	ldb	@r10,#%30
	inc	r10,#1
L058C:
	xor	r2,r2
	calr	L0592
	jr	L0608
L0592:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L059E
	calr	L0592
L059E:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L05AE
	add	r0,#%0007
L05AE:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L05B4:
	call	pscien
	jr	L0608
L05BA:
	call	pscien
	jr	L0608
L05C0:
	inc	r11,#1
	test	r9
	jr	ne,L05CA
	ldk	r11,#7
	ld	r9,r11
L05CA:
	call	pscien
	jr	L0608
L05D0:
	ld	r13,@r13
	pop	r12,@r13
	jp	L049A
L05D8:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0608
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0608
L05EA:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L05FA
	ld	r2,#D102C
L05FA:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L060A
	dec	r10,#1
	jr	L060A
L0608:
	ld	r2,r15
L060A:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0616
	xor	r1,r1
L0616:
	test	%FFF0(r14)
	jr	ne,L061E
	neg	r1
L061E:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L049A
L0636:
	xor	r9,r9
	ld	r1,r9
L063A:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L064E
	pop	r2,@r13
	jr	L065E
L064E:
	cp	r2,#%0009
	jr	ugt,L065E
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L063A
L065E:
	add	r2,#%0030
	ret
end __doprnt
I
D0FE8:
WV L0556
BV %0;BV %64
WV L0552
BV %0;BV %6F
WV L0550
BV %0;BV %78
WV L05B4
BV %0;BV %66
WV L05C0
BV %0;BV %65
WV L05BA
BV %0;BV %67
WV L05D8
BV %0;BV %63
WV L05EA
BV %0;BV %73
WV L052A
BV %0;BV %6C
WV L052A
BV %0;BV %4C
WV L057A
BV %0;BV %75
WV L05D0
BV %0;BV %72
WV L0560
BV %0;BV %44
WV L054A
BV %0;BV %4F
WV L054E
BV %0;BV %58
WV L0578
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D102C:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
