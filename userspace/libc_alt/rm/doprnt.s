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
L0678:
	ld	r10,r15
L067A:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L068E
	cpb	rl0,#%25
	jr	eq,L068E
	ldb	@r10,rl0
	inc	r10,#1
	jr	L067A
L068E:
	cp	r10,r15
	jr	eq,L06AC
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
L06AC:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L06CE
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L06CE:
	cpb	@r12,#%30
	jr	ne,L06DA
	ld	%FFEE(r14),#%0030
L06DA:
	calr	L0814
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L06EC
	calr	L0814
	ld	r11,r1
L06EC:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1578
L06F4:
	pop	r4,@r7
	test	r4
	jr	ne,L0700
	ldb	@r10,rl2
	inc	r10,#1
	jr	L07E6
L0700:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L06F4
	jp	@r4
L0708:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0728
	cpb	rl1,#%78
	jr	eq,L072C
	cpb	rl1,#%64
	jr	eq,L073E
	cpb	rl1,#%75
	jr	eq,L0756
	dec	r12,#1
	jr	L0758
L0728:
	pop	r6,@r13
	jr	L0730
L072C:
	pop	r6,@r13
L072E:
	rl	r3,#1
L0730:
	pop	r7,@r13
	jr	L075C
L0734:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0746
	jr	L075A
L073E:
	pop	r6,@r13
	test	r6
	jr	pl,L0758
	pop	r7,@r13
L0746:
	neg	r6
	neg	r7
	jr	uge,L074E
	dec	r6,#1
L074E:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L075A
L0756:
	pop	r6,@r13
L0758:
	pop	r7,@r13
L075A:
	inc	r3,#2
L075C:
	testl	rr6
	jr	eq,L076A
	test	r11
	jr	eq,L076A
	ldb	@r10,#%30
	inc	r10,#1
L076A:
	xor	r2,r2
	calr	L0770
	jr	L07E6
L0770:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L077C
	calr	L0770
L077C:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L078C
	add	r0,#%0007
L078C:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0792:
	call	pscien
	jr	L07E6
L0798:
	call	pscien
	jr	L07E6
L079E:
	inc	r11,#1
	test	r9
	jr	ne,L07A8
	ldk	r11,#7
	ld	r9,r11
L07A8:
	call	pscien
	jr	L07E6
L07AE:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0678
L07B6:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L07E6
	ldb	@r10,rl0
	inc	r10,#1
	jr	L07E6
L07C8:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L07D8
	ld	r2,#D15BC
L07D8:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L07E8
	dec	r10,#1
	jr	L07E8
L07E6:
	ld	r2,r15
L07E8:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L07F4
	xor	r1,r1
L07F4:
	test	%FFF0(r14)
	jr	ne,L07FC
	neg	r1
L07FC:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0678
L0814:
	xor	r9,r9
	ld	r1,r9
L0818:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L082C
	pop	r2,@r13
	jr	L083C
L082C:
	cp	r2,#%0009
	jr	ugt,L083C
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0818
L083C:
	add	r2,#%0030
	ret
end __doprnt
I
D1578:
WV L0734
BV %0;BV %64
WV L0730
BV %0;BV %6F
WV L072E
BV %0;BV %78
WV L0792
BV %0;BV %66
WV L079E
BV %0;BV %65
WV L0798
BV %0;BV %67
WV L07B6
BV %0;BV %63
WV L07C8
BV %0;BV %73
WV L0708
BV %0;BV %6C
WV L0708
BV %0;BV %4C
WV L0758
BV %0;BV %75
WV L07AE
BV %0;BV %72
WV L073E
BV %0;BV %44
WV L0728
BV %0;BV %4F
WV L072C
BV %0;BV %58
WV L0756
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D15BC:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
