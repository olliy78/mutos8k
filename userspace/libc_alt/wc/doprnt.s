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
L040C:
	ld	r10,r15
L040E:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0422
	cpb	rl0,#%25
	jr	eq,L0422
	ldb	@r10,rl0
	inc	r10,#1
	jr	L040E
L0422:
	cp	r10,r15
	jr	eq,L0440
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
L0440:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0462
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0462:
	cpb	@r12,#%30
	jr	ne,L046E
	ld	%FFEE(r14),#%0030
L046E:
	calr	L05A6
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0480
	calr	L05A6
	ld	r11,r1
L0480:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0F36
L0488:
	pop	r4,@r7
	test	r4
	jr	ne,L0494
	ldb	@r10,rl2
	inc	r10,#1
	jr	L0578
L0494:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0488
	jp	@r4
L049C:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L04BC
	cpb	rl1,#%78
	jr	eq,L04C0
	cpb	rl1,#%64
	jr	eq,L04D2
	cpb	rl1,#%75
	jr	eq,L04EA
	dec	r12,#1
	jr	L04EC
L04BC:
	pop	r6,@r13
	jr	L04C4
L04C0:
	pop	r6,@r13
L04C2:
	rl	r3,#1
L04C4:
	pop	r7,@r13
	jr	L04F0
L04C8:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L04DA
	jr	L04EE
L04D2:
	pop	r6,@r13
	test	r6
	jr	pl,L04EC
	pop	r7,@r13
L04DA:
	neg	r6
	neg	r7
	jr	uge,L04E2
	dec	r6,#1
L04E2:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L04EE
L04EA:
	pop	r6,@r13
L04EC:
	pop	r7,@r13
L04EE:
	inc	r3,#2
L04F0:
	testl	rr6
	jr	eq,L04FE
	test	r11
	jr	eq,L04FE
	ldb	@r10,#%30
	inc	r10,#1
L04FE:
	xor	r2,r2
	calr	L0504
	jr	L0578
L0504:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L050E
	calr	L0504
L050E:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L051E
	add	r0,#%0007
L051E:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0524:
	call	pscien
	jr	L0578
L052A:
	call	pscien
	jr	L0578
L0530:
	inc	r11,#1
	test	r9
	jr	ne,L053A
	ldk	r11,#7
	ld	r9,r11
L053A:
	call	pscien
	jr	L0578
L0540:
	ld	r13,@r13
	pop	r12,@r13
	jp	L040C
L0548:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L0578
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0578
L055A:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L056A
	ld	r2,#D0F7A
L056A:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L057A
	dec	r10,#1
	jr	L057A
L0578:
	ld	r2,r15
L057A:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0586
	xor	r1,r1
L0586:
	test	%FFF0(r14)
	jr	ne,L058E
	neg	r1
L058E:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L040C
L05A6:
	xor	r9,r9
	ld	r1,r9
L05AA:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L05BE
	pop	r2,@r13
	jr	L05CE
L05BE:
	cp	r2,#%0009
	jr	ugt,L05CE
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L05AA
L05CE:
	add	r2,#%0030
	ret
end __doprnt
I
D0F36:
WV L04C8
BV %0;BV %64
WV L04C4
BV %0;BV %6F
WV L04C2
BV %0;BV %78
WV L0524
BV %0;BV %66
WV L0530
BV %0;BV %65
WV L052A
BV %0;BV %67
WV L0548
BV %0;BV %63
WV L055A
BV %0;BV %73
WV L049C
BV %0;BV %6C
WV L049C
BV %0;BV %4C
WV L04EC
BV %0;BV %75
WV L0540
BV %0;BV %72
WV L04D2
BV %0;BV %44
WV L04BC
BV %0;BV %4F
WV L04C0
BV %0;BV %58
WV L04EA
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0F7A:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
