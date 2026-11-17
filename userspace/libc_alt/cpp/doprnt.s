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
L2810:
	ld	r10,r15
L2812:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L2826
	cpb	rl0,#%25
	jr	eq,L2826
	ldb	@r10,rl0
	inc	r10,#1
	jr	L2812
L2826:
	cp	r10,r15
	jr	eq,L2844
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
L2844:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L2866
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L2866:
	cpb	@r12,#%30
	jr	ne,L2872
	ld	%FFEE(r14),#%0030
L2872:
	calr	L29AC
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L2884
	calr	L29AC
	ld	r11,r1
L2884:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D3F00
L288C:
	pop	r4,@r7
	test	r4
	jr	ne,L2898
	ldb	@r10,rl2
	inc	r10,#1
	jr	L297E
L2898:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L288C
	jp	@r4
L28A0:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L28C0
	cpb	rl1,#%78
	jr	eq,L28C4
	cpb	rl1,#%64
	jr	eq,L28D6
	cpb	rl1,#%75
	jr	eq,L28EE
	dec	r12,#1
	jr	L28F0
L28C0:
	pop	r6,@r13
	jr	L28C8
L28C4:
	pop	r6,@r13
L28C6:
	rl	r3,#1
L28C8:
	pop	r7,@r13
	jr	L28F4
L28CC:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L28DE
	jr	L28F2
L28D6:
	pop	r6,@r13
	test	r6
	jr	pl,L28F0
	pop	r7,@r13
L28DE:
	neg	r6
	neg	r7
	jr	uge,L28E6
	dec	r6,#1
L28E6:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L28F2
L28EE:
	pop	r6,@r13
L28F0:
	pop	r7,@r13
L28F2:
	inc	r3,#2
L28F4:
	testl	rr6
	jr	eq,L2902
	test	r11
	jr	eq,L2902
	ldb	@r10,#%30
	inc	r10,#1
L2902:
	xor	r2,r2
	calr	L2908
	jr	L297E
L2908:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L2914
	calr	L2908
L2914:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L2924
L2920:
	add	r0,#%0007
L2924:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L292A:
	call	pscien
	jr	L297E
L2930:
	call	pscien
	jr	L297E
L2936:
	inc	r11,#1
	test	r9
	jr	ne,L2940
	ldk	r11,#7
	ld	r9,r11
L2940:
	call	pscien
	jr	L297E
L2946:
	ld	r13,@r13
	pop	r12,@r13
	jp	L2810
L294E:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L297E
	ldb	@r10,rl0
	inc	r10,#1
	jr	L297E
L2960:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L2970
	ld	r2,#D3F44
L2970:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L2980
	dec	r10,#1
	jr	L2980
L297E:
	ld	r2,r15
L2980:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L298C
	xor	r1,r1
L298C:
	test	%FFF0(r14)
	jr	ne,L2994
	neg	r1
L2994:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L2810
L29AC:
	xor	r9,r9
	ld	r1,r9
L29B0:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L29C4
	pop	r2,@r13
	jr	L29D4
L29C4:
	cp	r2,#%0009
	jr	ugt,L29D4
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L29B0
L29D4:
	add	r2,#%0030
	ret
end __doprnt
I
D3F00:
WV L28CC
BV %0;BV %64
WV L28C8
BV %0;BV %6F
WV L28C6
BV %0;BV %78
WV L292A
BV %0;BV %66
WV L2936
BV %0;BV %65
WV L2930
BV %0;BV %67
WV L294E
BV %0;BV %63
WV L2960
BV %0;BV %73
WV L28A0
BV %0;BV %6C
WV L28A0
BV %0;BV %4C
WV L28F0
BV %0;BV %75
WV L2946
BV %0;BV %72
WV L28D6
BV %0;BV %44
WV L28C0
BV %0;BV %4F
WV L28C4
BV %0;BV %58
WV L28EE
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D3F44:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
