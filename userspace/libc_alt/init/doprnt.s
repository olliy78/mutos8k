doprnt module
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
L069E:
	ld	r10,r15
L06A0:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L06B4
	cpb	rl0,#%25
	jr	eq,L06B4
	ldb	@r10,rl0
	inc	r10,#1
	jr	L06A0
L06B4:
	cp	r10,r15
	jr	eq,L06D2
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
L06D2:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L06F4
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L06F4:
	cpb	@r12,#%30
	jr	ne,L0700
	ld	%FFEE(r14),#%0030
L0700:
	calr	L0838
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L0712
	calr	L0838
	ld	r11,r1
L0712:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1274
L071A:
	pop	r4,@r7
	test	r4
	jr	ne,L0726
	ldb	@r10,rl2
	inc	r10,#1
	jr	L080A
L0726:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L071A
	jp	@r4
L072E:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L074E
	cpb	rl1,#%78
	jr	eq,L0752
	cpb	rl1,#%64
	jr	eq,L0764
	cpb	rl1,#%75
	jr	eq,L077C
	dec	r12,#1
	jr	L077E
L074E:
	pop	r6,@r13
	jr	L0756
L0752:
	pop	r6,@r13
L0754:
	rl	r3,#1
L0756:
	pop	r7,@r13
	jr	L0782
L075A:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L076C
	jr	L0780
L0764:
	pop	r6,@r13
	test	r6
	jr	pl,L077E
	pop	r7,@r13
L076C:
	neg	r6
	neg	r7
	jr	uge,L0774
	dec	r6,#1
L0774:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L0780
L077C:
	pop	r6,@r13
L077E:
	pop	r7,@r13
L0780:
	inc	r3,#2
L0782:
	testl	rr6
	jr	eq,L0790
	test	r11
	jr	eq,L0790
	ldb	@r10,#%30
	inc	r10,#1
L0790:
	xor	r2,r2
	calr	L0796
	jr	L080A
L0796:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L07A0
	calr	L0796
L07A0:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L07B0
	add	r0,#%0007
L07B0:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L07B6:
	call	pscien
	jr	L080A
L07BC:
	call	pscien
	jr	L080A
L07C2:
	inc	r11,#1
	test	r9
	jr	ne,L07CC
	ldk	r11,#7
	ld	r9,r11
L07CC:
	call	pscien
	jr	L080A
L07D2:
	ld	r13,@r13
	pop	r12,@r13
	jp	L069E
L07DA:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L080A
	ldb	@r10,rl0
	inc	r10,#1
	jr	L080A
L07EC:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L07FC
	ld	r2,#D12B8
L07FC:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L080C
	dec	r10,#1
	jr	L080C
L080A:
	ld	r2,r15
L080C:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L0818
	xor	r1,r1
L0818:
	test	%FFF0(r14)
	jr	ne,L0820
	neg	r1
L0820:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L069E
L0838:
	xor	r9,r9
	ld	r1,r9
L083C:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L0850
	pop	r2,@r13
	jr	L0860
L0850:
	cp	r2,#%0009
	jr	ugt,L0860
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L083C
L0860:
	add	r2,#%0030
	ret
end __doprnt
I
D1274:
WV L075A
BV %0;BV %64
WV L0756
BV %0;BV %6F
WV L0754
BV %0;BV %78
WV L07B6
BV %0;BV %66
WV L07C2
BV %0;BV %65
WV L07BC
BV %0;BV %67
WV L07DA
BV %0;BV %63
WV L07EC
BV %0;BV %73
WV L072E
BV %0;BV %6C
WV L072E
BV %0;BV %4C
WV L077E
BV %0;BV %75
WV L07D2
BV %0;BV %72
WV L0764
BV %0;BV %44
WV L074E
BV %0;BV %4F
WV L0752
BV %0;BV %58
WV L077C
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D12B8:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt
