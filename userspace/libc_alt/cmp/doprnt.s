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
L054A:
	ld	r10,r15
L054C:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0560
	cpb	rl0,#%25
	jr	eq,L0560
	ldb	@r10,rl0
	inc	r10,#1
	jr	L054C
L0560:
	cp	r10,r15
	jr	eq,L057E
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
L057E:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L05A0
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L05A0:
	cpb	@r12,#%30
	jr	ne,L05AC
	ld	%FFEE(r14),#%0030
L05AC:
	calr	L06E4
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L05BE
	calr	L06E4
	ld	r11,r1
L05BE:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D10B0
L05C6:
	pop	r4,@r7
	test	r4
	jr	ne,L05D2
	ldb	@r10,rl2
	inc	r10,#1
	jr	L06B6
L05D2:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L05C6
	jp	@r4
L05DA:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L05FA
	cpb	rl1,#%78
	jr	eq,L05FE
	cpb	rl1,#%64
	jr	eq,L0610
	cpb	rl1,#%75
	jr	eq,L0628
	dec	r12,#1
	jr	L062A
L05FA:
	pop	r6,@r13
	jr	L0602
L05FE:
	pop	r6,@r13
L0600:
	rl	r3,#1
L0602:
	pop	r7,@r13
	jr	L062E
L0606:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0618
	jr	L062C
L0610:
	pop	r6,@r13
	test	r6
	jr	pl,L062A
	pop	r7,@r13
L0618:
	neg	r6
	neg	r7
	jr	uge,L0620
	dec	r6,#1
L0620:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L062C
L0628:
	pop	r6,@r13
L062A:
	pop	r7,@r13
L062C:
	inc	r3,#2
L062E:
	testl	rr6
	jr	eq,L063C
	test	r11
	jr	eq,L063C
	ldb	@r10,#%30
	inc	r10,#1
L063C:
	xor	r2,r2
	calr	L0642
	jr	L06B6
L0642:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L064C
	calr	L0642
L064C:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L065C
	add	r0,#%0007
L065C:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0662:
	call	pscien
	jr	L06B6
L0668:
	call	pscien
	jr	L06B6
L066E:
	inc	r11,#1
	test	r9
	jr	ne,L0678
	ldk	r11,#7
	ld	r9,r11
L0678:
	call	pscien
	jr	L06B6
L067E:
	ld	r13,@r13
	pop	r12,@r13
	jp	L054A
L0686:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L06B6
	ldb	@r10,rl0
	inc	r10,#1
	jr	L06B6
L0698:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L06A8
	ld	r2,#D10F4
L06A8:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L06B8
	dec	r10,#1
	jr	L06B8
L06B6:
	ld	r2,r15
L06B8:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L06C4
	xor	r1,r1
L06C4:
	test	%FFF0(r14)
	jr	ne,L06CC
	neg	r1
L06CC:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L054A
L06E4:
	xor	r9,r9
	ld	r1,r9
L06E8:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L06FC
	pop	r2,@r13
	jr	L070C
L06FC:
	cp	r2,#%0009
	jr	ugt,L070C
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L06E8
L070C:
	add	r2,#%0030
	ret
end __doprnt
I
BV %0;BV %0
D10B0:
WV L0606
BV %0;BV %64
WV L0602
BV %0;BV %6F
WV L0600
BV %0;BV %78
WV L0662
BV %0;BV %66
WV L066E
BV %0;BV %65
WV L0668
BV %0;BV %67
WV L0686
BV %0;BV %63
WV L0698
BV %0;BV %73
WV L05DA
BV %0;BV %6C
WV L05DA
BV %0;BV %4C
WV L062A
BV %0;BV %75
WV L067E
BV %0;BV %72
WV L0610
BV %0;BV %44
WV L05FA
BV %0;BV %4F
WV L05FE
BV %0;BV %58
WV L0628
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D10F4:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
