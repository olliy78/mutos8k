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
L0782:
	ld	r10,r15
L0784:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0798
	cpb	rl0,#%25
	jr	eq,L0798
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0784
L0798:
	cp	r10,r15
	jr	eq,L07B6
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
L07B6:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L07D8
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L07D8:
	cpb	@r12,#%30
	jr	ne,L07E4
	ld	%FFEE(r14),#%0030
L07E4:
	calr	L091E
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L07F6
	calr	L091E
	ld	r11,r1
L07F6:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D12D8
L07FE:
	pop	r4,@r7
	test	r4
	jr	ne,L080A
	ldb	@r10,rl2
	inc	r10,#1
	jr	L08F0
L080A:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L07FE
	jp	@r4
L0812:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0832
	cpb	rl1,#%78
	jr	eq,L0836
	cpb	rl1,#%64
	jr	eq,L0848
	cpb	rl1,#%75
	jr	eq,L0860
	dec	r12,#1
	jr	L0862
L0832:
	pop	r6,@r13
	jr	L083A
L0836:
	pop	r6,@r13
L0838:
	rl	r3,#1
L083A:
	pop	r7,@r13
	jr	L0866
L083E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0850
	jr	L0864
L0848:
	pop	r6,@r13
	test	r6
	jr	pl,L0862
	pop	r7,@r13
L0850:
	neg	r6
	neg	r7
	jr	uge,L0858
	dec	r6,#1
L0858:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0864
L0860:
	pop	r6,@r13
L0862:
	pop	r7,@r13
L0864:
	inc	r3,#2
L0866:
	testl	rr6
	jr	eq,L0874
	test	r11
	jr	eq,L0874
	ldb	@r10,#%30
	inc	r10,#1
L0874:
	xor	r2,r2
	calr	L087A
	jr	L08F0
L087A:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0886
	calr	L087A
L0886:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0896
	add	r0,#%0007
L0896:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L089C:
	call	pscien
	jr	L08F0
L08A2:
	call	pscien
	jr	L08F0
L08A8:
	inc	r11,#1
	test	r9
	jr	ne,L08B2
	ldk	r11,#7
	ld	r9,r11
L08B2:
	call	pscien
	jr	L08F0
L08B8:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0782
L08C0:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L08F0
	ldb	@r10,rl0
	inc	r10,#1
	jr	L08F0
L08D2:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L08E2
	ld	r2,#D131C
L08E2:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L08F2
	dec	r10,#1
	jr	L08F2
L08F0:
	ld	r2,r15
L08F2:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L08FE
	xor	r1,r1
L08FE:
	test	%FFF0(r14)
	jr	ne,L0906
	neg	r1
L0906:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0782
L091E:
	xor	r9,r9
	ld	r1,r9
L0922:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0936
	pop	r2,@r13
	jr	L0946
L0936:
	cp	r2,#%0009
	jr	ugt,L0946
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0922
L0946:
	add	r2,#%0030
	ret
end __doprnt
I
D12D8:
WV L083E
BV %0;BV %64
WV L083A
BV %0;BV %6F
WV L0838
BV %0;BV %78
WV L089C
BV %0;BV %66
WV L08A8
BV %0;BV %65
WV L08A2
BV %0;BV %67
WV L08C0
BV %0;BV %63
WV L08D2
BV %0;BV %73
WV L0812
BV %0;BV %6C
WV L0812
BV %0;BV %4C
WV L0862
BV %0;BV %75
WV L08B8
BV %0;BV %72
WV L0848
BV %0;BV %44
WV L0832
BV %0;BV %4F
WV L0836
BV %0;BV %58
WV L0860
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D131C:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
