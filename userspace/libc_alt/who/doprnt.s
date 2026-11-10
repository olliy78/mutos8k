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
L0652:
	ld	r10,r15
L0654:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0668
	cpb	rl0,#%25
	jr	eq,L0668
	ldb	@r10,rl0
	inc	r10,#1
	jr	L0654
L0668:
	cp	r10,r15
	jr	eq,L0686
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
L0686:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L06A8
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L06A8:
	cpb	@r12,#%30
	jr	ne,L06B4
	ld	%FFEE(r14),#%0030
L06B4:
	calr	L07EC
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L06C6
	calr	L07EC
	ld	r11,r1
L06C6:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D188C
L06CE:
	pop	r4,@r7
	test	r4
	jr	ne,L06DA
	ldb	@r10,rl2
	inc	r10,#1
	jr	L07BE
L06DA:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L06CE
	jp	@r4
L06E2:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0702
	cpb	rl1,#%78
	jr	eq,L0706
	cpb	rl1,#%64
	jr	eq,L0718
	cpb	rl1,#%75
	jr	eq,L0730
	dec	r12,#1
	jr	L0732
L0702:
	pop	r6,@r13
	jr	L070A
L0706:
	pop	r6,@r13
L0708:
	rl	r3,#1
L070A:
	pop	r7,@r13
	jr	L0736
L070E:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0720
	jr	L0734
L0718:
	pop	r6,@r13
	test	r6
	jr	pl,L0732
	pop	r7,@r13
L0720:
	neg	r6
	neg	r7
	jr	uge,L0728
	dec	r6,#1
L0728:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0734
L0730:
	pop	r6,@r13
L0732:
	pop	r7,@r13
L0734:
	inc	r3,#2
L0736:
	testl	rr6
	jr	eq,L0744
	test	r11
	jr	eq,L0744
	ldb	@r10,#%30
	inc	r10,#1
L0744:
	xor	r2,r2
	calr	L074A
	jr	L07BE
L074A:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L0754
	calr	L074A
L0754:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L0764
	add	r0,#%0007
L0764:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L076A:
	call	pscien
	jr	L07BE
L0770:
	call	pscien
	jr	L07BE
L0776:
	inc	r11,#1
	test	r9
	jr	ne,L0780
	ldk	r11,#7
	ld	r9,r11
L0780:
	call	pscien
	jr	L07BE
L0786:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0652
L078E:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L07BE
	ldb	@r10,rl0
	inc	r10,#1
	jr	L07BE
L07A0:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L07B0
	ld	r2,#D18D0
L07B0:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L07C0
	dec	r10,#1
	jr	L07C0
L07BE:
	ld	r2,r15
L07C0:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L07CC
	xor	r1,r1
L07CC:
	test	%FFF0(r14)
	jr	ne,L07D4
	neg	r1
L07D4:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0652
L07EC:
	xor	r9,r9
	ld	r1,r9
L07F0:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0804
	pop	r2,@r13
	jr	L0814
L0804:
	cp	r2,#%0009
	jr	ugt,L0814
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L07F0
L0814:
	add	r2,#%0030
	ret
end __doprnt
I
D188C:
WV L070E
BV %0;BV %64
WV L070A
BV %0;BV %6F
WV L0708
BV %0;BV %78
WV L076A
BV %0;BV %66
WV L0776
BV %0;BV %65
WV L0770
BV %0;BV %67
WV L078E
BV %0;BV %63
WV L07A0
BV %0;BV %73
WV L06E2
BV %0;BV %6C
WV L06E2
BV %0;BV %4C
WV L0732
BV %0;BV %75
WV L0786
BV %0;BV %72
WV L0718
BV %0;BV %44
WV L0702
BV %0;BV %4F
WV L0706
BV %0;BV %58
WV L0730
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D18D0:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
