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
L3782:
	ld	r10,r15
L3784:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L3798
	cpb	rl0,#%25
	jr	eq,L3798
	ldb	@r10,rl0
	inc	r10,#1
	jr	L3784
L3798:
	cp	r10,r15
	jr	eq,L37B6
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
L37B6:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L37D8
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L37D8:
	cpb	@r12,#%30
	jr	ne,L37E4
	ld	%FFEE(r14),#%0030
L37E4:
	calr	L391E
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L37F6
	calr	L391E
	ld	r11,r1
L37F6:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D4922
L37FE:
	pop	r4,@r7
	test	r4
	jr	ne,L380A
	ldb	@r10,rl2
	inc	r10,#1
	jr	L38F0
L380A:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L37FE
	jp	@r4
L3812:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L3832
	cpb	rl1,#%78
	jr	eq,L3836
	cpb	rl1,#%64
	jr	eq,L3848
	cpb	rl1,#%75
	jr	eq,L3860
	dec	r12,#1
	jr	L3862
L3832:
	pop	r6,@r13
	jr	L383A
L3836:
	pop	r6,@r13
L3838:
	rl	r3,#1
L383A:
	pop	r7,@r13
	jr	L3866
L383E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L3850
	jr	L3864
L3848:
	pop	r6,@r13
	test	r6
	jr	pl,L3862
	pop	r7,@r13
L3850:
	neg	r6
	neg	r7
	jr	uge,L3858
	dec	r6,#1
L3858:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L3864
L3860:
	pop	r6,@r13
L3862:
	pop	r7,@r13
L3864:
	inc	r3,#2
L3866:
	testl	rr6
	jr	eq,L3874
	test	r11
	jr	eq,L3874
	ldb	@r10,#%30
	inc	r10,#1
L3874:
	xor	r2,r2
	calr	L387A
	jr	L38F0
L387A:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L3886
	calr	L387A
L3886:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L3896
	add	r0,#%0007
L3896:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L389C:
	call	pscien
	jr	L38F0
L38A2:
	call	pscien
	jr	L38F0
L38A8:
	inc	r11,#1
	test	r9
	jr	ne,L38B2
	ldk	r11,#7
	ld	r9,r11
L38B2:
	call	pscien
	jr	L38F0
L38B8:
	ld	r13,@r13
	pop	r12,@r13
	jp	L3782
L38C0:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L38F0
	ldb	@r10,rl0
	inc	r10,#1
	jr	L38F0
L38D2:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L38E2
	ld	r2,#D4966
L38E2:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L38F2
	dec	r10,#1
	jr	L38F2
L38F0:
	ld	r2,r15
L38F2:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L38FE
	xor	r1,r1
L38FE:
	test	%FFF0(r14)
	jr	ne,L3906
	neg	r1
L3906:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L3782
L391E:
	xor	r9,r9
	ld	r1,r9
L3922:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L3936
	pop	r2,@r13
	jr	L3946
L3936:
	cp	r2,#%0009
	jr	ugt,L3946
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L3922
L3946:
	add	r2,#%0030
	ret
end __doprnt
I
D4922:
WV L383E
BV %0;BV %64
WV L383A
BV %0;BV %6F
WV L3838
BV %0;BV %78
WV L389C
BV %0;BV %66
WV L38A8
BV %0;BV %65
WV L38A2
BV %0;BV %67
WV L38C0
BV %0;BV %63
WV L38D2
BV %0;BV %73
WV L3812
BV %0;BV %6C
WV L3812
BV %0;BV %4C
WV L3862
BV %0;BV %75
WV L38B8
BV %0;BV %72
WV L3848
BV %0;BV %44
WV L3832
BV %0;BV %4F
WV L3836
BV %0;BV %58
WV L3860
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D4966:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
