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
L0688:
	ld	r10,r15
L068A:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L069E
	cpb	rl0,#%25
	jr	eq,L069E
	ldb	@r10,rl0
	inc	r10,#1
	jr	L068A
L069E:
	cp	r10,r15
	jr	eq,L06BC
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
L06BC:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L06DE
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L06DE:
	cpb	@r12,#%30
	jr	ne,L06EA
	ld	%FFEE(r14),#%0030
L06EA:
	calr	L0824
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L06FC
	calr	L0824
	ld	r11,r1
L06FC:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D10FC
L0704:
	pop	r4,@r7
	test	r4
	jr	ne,L0710
	ldb	@r10,rl2
	inc	r10,#1
	jr	L07F6
L0710:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L0704
	jp	@r4
L0718:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L0738
	cpb	rl1,#%78
	jr	eq,L073C
	cpb	rl1,#%64
	jr	eq,L074E
	cpb	rl1,#%75
	jr	eq,L0766
	dec	r12,#1
	jr	L0768
L0738:
	pop	r6,@r13
	jr	L0740
L073C:
	pop	r6,@r13
L073E:
	rl	r3,#1
L0740:
	pop	r7,@r13
	jr	L076C
L0744:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0756
	jr	L076A
L074E:
	pop	r6,@r13
	test	r6
	jr	pl,L0768
	pop	r7,@r13
L0756:
	neg	r6
	neg	r7
	jr	uge,L075E
	dec	r6,#1
L075E:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L076A
L0766:
	pop	r6,@r13
L0768:
	pop	r7,@r13
L076A:
	inc	r3,#2
L076C:
	testl	rr6
	jr	eq,L077A
	test	r11
	jr	eq,L077A
	ldb	@r10,#%30
	inc	r10,#1
L077A:
	xor	r2,r2
	calr	L0780
	jr	L07F6
L0780:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L078C
	calr	L0780
L078C:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L079C
	add	r0,#%0007
L079C:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L07A2:
	call	pscien
	jr	L07F6
L07A8:
	call	pscien
	jr	L07F6
L07AE:
	inc	r11,#1
	test	r9
	jr	ne,L07B8
	ldk	r11,#7
	ld	r9,r11
L07B8:
	call	pscien
	jr	L07F6
L07BE:
	ld	r13,@r13
	pop	r12,@r13
	jp	L0688
L07C6:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L07F6
	ldb	@r10,rl0
	inc	r10,#1
	jr	L07F6
L07D8:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L07E8
	ld	r2,#D1140
L07E8:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L07F8
	dec	r10,#1
	jr	L07F8
L07F6:
	ld	r2,r15
L07F8:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0804
	xor	r1,r1
L0804:
	test	%FFF0(r14)
	jr	ne,L080C
	neg	r1
L080C:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L0688
L0824:
	xor	r9,r9
	ld	r1,r9
L0828:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L083C
	pop	r2,@r13
	jr	L084C
L083C:
	cp	r2,#%0009
	jr	ugt,L084C
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L0828
L084C:
	add	r2,#%0030
	ret
end __doprnt
I
D10FC:
WV L0744
BV %0;BV %64
WV L0740
BV %0;BV %6F
WV L073E
BV %0;BV %78
WV L07A2
BV %0;BV %66
WV L07AE
BV %0;BV %65
WV L07A8
BV %0;BV %67
WV L07C6
BV %0;BV %63
WV L07D8
BV %0;BV %73
WV L0718
BV %0;BV %6C
WV L0718
BV %0;BV %4C
WV L0768
BV %0;BV %75
WV L07BE
BV %0;BV %72
WV L074E
BV %0;BV %44
WV L0738
BV %0;BV %4F
WV L073C
BV %0;BV %58
WV L0766
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D1140:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
