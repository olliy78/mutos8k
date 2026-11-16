doscan_ module
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
G	__doscan	PR
E
__doscan:
	call	csv
	ld	r13,%0006(r14)
	ld	r12,%0008(r14)
	dec	r15,#6
	xor	r10,r10
	clr	%FFF0(r14)
L1ADC:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	ld	r3,r11
	ld	r2,r3
	test	r11
	jp	eq,L1C24
	cp	r11,#%0009
	jp	eq,L1C2A
	cp	r11,#%000A
	jp	eq,L1C2A
	cp	r11,#%0020
	jp	eq,L1C2A
	cp	r11,#%0025
	jr	eq,L1B3C
L1B0E:
	ld	r2,%0004(r14)
	inc	r2,#6
	bitb	@r2,#1
	jp	ne,L1C90
	ld	r2,%0004(r14)
	inc	r2,#2
	dec	@r2,#1
	jp	lt,L1C90
	ld	r2,%0004(r14)
	ld	r3,@r2
	inc	@r2,#1
	ld	r2,r3
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jp	L1CA0
L1B3C:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	cp	r11,#%0025
	jr	eq,L1B0E
	clr	%FFF2(r14)
	cp	r11,#%002A
	jr	eq,L1B5E
	ld	%FFF2(r14),r12
	inc	r12,#2
	jr	L1B68
L1B5E:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
L1B68:
	xor	r9,r9
	ld	%FFEE(r14),#%0001
	jr	L1B8A
L1B72:
	ld	r3,r9
	mult	rr2,#%000A
	ld	r9,r3
	add	r9,r11
	add	r9,#%FFD0
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
L1B8A:
	bitb	%1+__ctype_(r11),#2
	jr	ne,L1B72
	test	r9
	jr	ne,L1B98
	ld	r9,#%7530
L1B98:
	cp	r11,#%006C
	jr	ne,L1BB0
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	ld	%FFEE(r14),#%0002
	jr	L1BD6
L1BB0:
	cp	r11,#%0068
	jr	ne,L1BC6
	clr	%FFEE(r14)
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	jr	L1BD6
L1BC6:
	cp	r11,#%005B
	jr	ne,L1BD6
	push	@r15,r13
	call	__getccl
	inc	r15,#2
	ld	r13,r2
L1BD6:
	bitb	%1+__ctype_(r11),#0
	jr	eq,L1BE6
	add	r11,#%0020
	ld	%FFEE(r14),#%0002
L1BE6:
	test	r11
	jr	ne,L1BF0
L1BEA:
	ld	r2,#%FFFF
	jr	L1C26
L1BF0:
	ld	r2,r14
	dec	r2,#16
	push	@r15,r2
	push	@r15,%0004(r14)
	push	@r15,%FFEE(r14)
	push	@r15,r9
	push	@r15,r11
	push	@r15,%FFF2(r14)
	call	__innum
	inc	r15,#12
	test	r2
	jr	eq,L1C18
	test	%FFF2(r14)
	jr	eq,L1C18
	inc	r10,#1
L1C18:
	test	%FFF0(r14)
	jp	eq,L1ADC
	test	r10
	jr	eq,L1BEA
L1C24:
	ld	r2,r10
L1C26:
	jp	cret
L1C2A:
	ld	r2,%0004(r14)
	inc	r2,#6
	bitb	@r2,#1
	jr	ne,L1C52
	ld	r2,%0004(r14)
	inc	r2,#2
	dec	@r2,#1
	jr	lt,L1C52
	ld	r2,%0004(r14)
	ld	r3,@r2
	inc	@r2,#1
	ld	r2,r3
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L1C62
L1C52:
	push	@r15,r2
	push	@r15,%0004(r14)
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L1C62:
	ld	r2,r3
	ld	r8,r3
	cp	r8,#%0020
	jr	eq,L1C2A
	cp	r8,#%0009
	jr	eq,L1C2A
	cp	r8,#%000A
	jr	eq,L1C2A
	cp	r8,#%FFFF
	jp	eq,L1ADC
	push	@r15,%0004(r14)
	push	@r15,r8
	call	_ungetc
	inc	r15,#4
	jp	L1ADC
L1C90:
	push	@r15,r2
	push	@r15,%0004(r14)
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L1CA0:
	ld	r2,r3
	ld	r8,r3
	cp	r8,r11
	jp	eq,L1ADC
	cp	r8,#%FFFF
	jr	eq,L1BEA
	push	@r15,%0004(r14)
	push	@r15,r8
	call	_ungetc
	inc	r15,#4
	jr	L1C24
end __doscan
G	__innum	PR
E
__innum:
	call	csv
	sub	r15,#%0048
	cp	%0006(r14),#%0063
	jr	eq,L1CDE
	cp	%0006(r14),#%0073
	jr	eq,L1CDE
	cp	%0006(r14),#%005B
	jr	ne,L1D0A
L1CDE:
	push	@r15,%000E(r14)
	push	@r15,%000C(r14)
	push	@r15,%0008(r14)
	push	@r15,%0006(r14)
	test	%0004(r14)
	jr	eq,L1CFC
	ld	r2,%0004(r14)
	push	@r15,@r2
	jr	L1D00
L1CFC:
	push	@r15,#%0000
L1D00:
	call	__instr
	inc	r15,#10
L1D06:
	jp	cret
L1D0A:
	xor	r0,r0
	ld	r1,r0
	ldl	%FFAC(r14),rr0
	clr	%FFB0(r14)
	xor	r9,r9
	cp	%0006(r14),#%0065
	jr	eq,L1D28
	cp	%0006(r14),#%0066
	jr	ne,L1D2A
L1D28:
	ldk	r9,#1
L1D2A:
	ldk	r11,#10
	cp	%0006(r14),#%006F
	jr	ne,L1D38
	ldk	r11,#8
	jr	L1D44
L1D38:
	cp	%0006(r14),#%0078
	jr	ne,L1D44
	ld	r11,#%0010
L1D44:
	ld	r13,r14
	add	r13,#%FFB4
	xor	r10,r10
	xor	r8,r8
L1D4E:
	ld	r2,%000C(r14)
	inc	r2,#6
	bitb	@r2,#1
	jr	ne,L1D76
	ld	r2,%000C(r14)
	inc	r2,#2
	dec	@r2,#1
	jr	lt,L1D76
	ld	r2,%000C(r14)
	ld	r3,@r2
	inc	@r2,#1
	ld	r2,r3
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L1D86
L1D76:
	push	@r15,r2
	push	@r15,%000C(r14)
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L1D86:
	ld	r2,r3
	ld	r12,r3
	cp	r12,#%0020
	jr	eq,L1D4E
	cp	r12,#%0009
	jr	eq,L1D4E
	cp	r12,#%000A
	jr	eq,L1D4E
	cp	r12,#%002D
	jr	ne,L1E24
	inc	r8,#1
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	ldb	@r2,rl3
	ld	r2,%000C(r14)
	inc	r2,#6
	bitb	@r2,#1
	jr	ne,L1DD4
	ld	r2,%000C(r14)
	inc	r2,#2
	dec	@r2,#1
	jr	lt,L1DD4
	ld	r2,%000C(r14)
	ld	r3,@r2
	inc	@r2,#1
	ld	r2,r3
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L1DE4
L1DD4:
	push	@r15,r2
	push	@r15,%000C(r14)
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L1DE4:
	ld	r2,r3
	ld	r12,r3
	dec	%0008(r14),#1
	jp	L1EF8
L1DF0:
	test	r8
	jr	eq,L1E06
	ldl	rr2,%FFAC(r14)
	com	r3
	com	r2
	addl	rr2,#%00000001
	ldl	%FFAC(r14),rr2
L1E06:
	cp	r12,#%FFFF
	jp	eq,L1FD6
	push	@r15,%000C(r14)
	push	@r15,r12
	call	_ungetc
	inc	r15,#4
	ld	r2,%000E(r14)
	clr	@r2
	jp	L1FDE
L1E24:
	cp	r12,#%002B
	jr	ne,L1EF8
	dec	%0008(r14),#1
	ld	r2,%000C(r14)
	inc	r2,#6
	bitb	@r2,#1
	jp	ne,L1FC4
	ld	r2,%000C(r14)
	inc	r2,#2
	dec	@r2,#1
	jp	lt,L1FC4
	jr	L1EE2
L1E48:
	cp	r12,#%0061
	jr	lt,L1E54
	cp	r12,#%0066
	jr	le,L1E60
L1E54:
	cp	r12,#%0041
	jr	lt,L1F0C
	cp	r12,#%0046
	jr	gt,L1F0C
L1E60:
	inc	%FFB0(r14),#1
	cp	r11,#%0008
	jr	ne,L1E74
	ldl	rr2,%FFAC(r14)
	slal	rr2,#3
	jr	L1E94
L1E74:
	cp	r11,#%000A
	jr	ne,L1E8C
	ldl	rr2,%FFAC(r14)
	slal	rr2,#2
	addl	rr2,%FFAC(r14)
	slal	rr2,#1
	jr	L1E94
L1E8C:
	ldl	rr2,%FFAC(r14)
	slal	rr2,#4
L1E94:
	ldl	%FFAC(r14),rr2
	ld	%FFB2(r14),r12
	cp	r12,#%0030
	jr	lt,L1EAE
	cp	r12,#%0039
	jr	gt,L1EAE
	sub	r12,#%0030
	jr	L1EC4
L1EAE:
	cp	r12,#%0061
	jr	lt,L1EC0
	cp	r12,#%0066
	jr	gt,L1EC0
	sub	r12,#%0057
	jr	L1EC4
L1EC0:
	sub	r12,#%0037
L1EC4:
	ldl	rr2,%FFAC(r14)
	ld	r5,r12
	exts	rr4
	addl	rr2,rr4
	ldl	%FFAC(r14),rr2
	ld	r12,%FFB2(r14)
	jr	L1FB2
L1ED8:
	ld	r2,%000C(r14)
	inc	r2,#2
	dec	@r2,#1
	jr	lt,L1FC4
L1EE2:
	ld	r2,%000C(r14)
	ld	r3,@r2
	inc	@r2,#1
	ld	r2,r3
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
L1EF4:
	ld	r2,r3
	ld	r12,r3
L1EF8:
	dec	%0008(r14),#1
	jp	mi,L1DF0
	bitb	%1+__ctype_(r12),#2
	jr	ne,L1E60
	cp	r11,#%0010
	jr	eq,L1E48
L1F0C:
	cp	r12,#%002E
	jr	ne,L1F26
	cp	r11,#%000A
	jp	ne,L1DF0
	test	r9
	jp	eq,L1DF0
	inc	%FFB0(r14),#1
	jr	L1FB2
L1F26:
	cp	r12,#%0065
	jr	eq,L1F34
	cp	r12,#%0045
	jp	ne,L1DF0
L1F34:
	test	r10
	jp	ne,L1DF0
	cp	r11,#%000A
	jp	ne,L1DF0
	test	r9
	jp	eq,L1DF0
	test	%FFB0(r14)
	jp	eq,L1DF0
	inc	r10,#1
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	ldb	@r2,rl3
	ld	r2,%000C(r14)
	inc	r2,#6
	bitb	@r2,#1
	jr	ne,L1F82
	ld	r2,%000C(r14)
	inc	r2,#2
	dec	@r2,#1
	jr	lt,L1F82
	ld	r2,%000C(r14)
	ld	r3,@r2
	inc	@r2,#1
	ld	r2,r3
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L1F92
L1F82:
	push	@r15,r2
	push	@r15,%000C(r14)
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L1F92:
	ld	r2,r3
	ld	r12,r3
	cp	r12,#%002B
	jr	eq,L1FB2
	cp	r12,#%002D
	jr	eq,L1FB2
	cp	r12,#%0030
	jp	lt,L1DF0
	cp	r12,#%0039
	jp	gt,L1DF0
L1FB2:
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	ldb	@r2,rl3
	ld	r2,%000C(r14)
	inc	r2,#6
	bitb	@r2,#1
	jr	eq,L1ED8
L1FC4:
	push	@r15,r2
	push	@r15,%000C(r14)
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
	jr	L1EF4
L1FD6:
	ld	r2,%000E(r14)
	ld	@r2,#%0001
L1FDE:
	test	%0004(r14)
	jr	eq,L1FEE
	ld	r2,r14
	add	r2,#%FFB4
	cp	r2,r13
	jr	ne,L1FF4
L1FEE:
	xor	r2,r2
	jp	L1D06
L1FF4:
	ld	r2,r13
	inc	r13,#1
	clrb	@r2
	ld	r2,r9
	sla	r2,#4
	or	r2,%000A(r14)
	cp	r2,#%0012
	jr	ugt,L202E
	add	r2,r2
	ld	r1,D402A(r2)
	jp	@r1
L2012:
	ld	r2,%0004(r14)
	ld	r3,@r2
	ld	r4,%FFAE(r14)
	ld	@r3,r4
	jr	L202E
L2020:
	ld	r2,%0004(r14)
	ld	r3,@r2
	ldl	rr4,%FFAC(r14)
	ldl	@r3,rr4
	jr	L202E
L202E:
	ldk	r2,#1
	jp	L1D06
end __innum
G	__instr	PR
E
__instr:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%000A(r14)
	ld	r2,%000C(r14)
	clr	@r2
	ld	r10,r13
	cp	%0006(r14),#%0063
	jr	ne,L205E
	cp	%0008(r14),#%7530
	jr	ne,L205E
	ld	%0008(r14),#%0001
L205E:
	xor	r9,r9
	cp	%0006(r14),#%0073
	jr	ne,L206A
	ldk	r9,#1
L206A:
	bitb	%0006(r12),#1
	jr	ne,L2088
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L2088
	ld	r2,@r12
	inc	@r12,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L2096
L2088:
	push	@r15,r2
	push	@r15,r12
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L2096:
	ld	r11,r3
	ld	r2,r11
	add	r2,#__sctab
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,r9
	jr	eq,L20AC
	cp	r11,#%FFFF
	jr	ne,L206A
L20AC:
	ldk	r9,#1
	cp	%0006(r14),#%0063
	jr	ne,L20BA
	xor	r9,r9
	jr	L2114
L20BA:
	cp	%0006(r14),#%005B
	jr	ne,L2114
	ldk	r9,#2
	jr	L2114
L20C6:
	ldb	rl2,__sctab(r11)
	xorb	rh2,rh2
	and	r2,r9
	jr	ne,L211A
	test	r13
	jr	eq,L20DC
	ld	r2,r13
	inc	r13,#1
	ld	r3,r11
	ldb	@r2,rl3
L20DC:
	dec	%0008(r14),#1
	jr	mi,L211A
	jr	eq,L211A
	bitb	%0006(r12),#1
	jr	ne,L2102
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L2102
	ld	r2,@r12
	inc	@r12,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L2110
L2102:
	push	@r15,r2
	push	@r15,r12
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L2110:
	ld	r2,r3
	ld	r11,r3
L2114:
	cp	r11,#%FFFF
	jr	ne,L20C6
L211A:
	cp	r11,#%FFFF
	jr	eq,L213A
	test	%0008(r14)
	jr	mi,L2132
	jr	eq,L2132
	push	@r15,r12
	push	@r15,r11
	call	_ungetc
	inc	r15,#4
L2132:
	ld	r2,%000C(r14)
	clr	@r2
	jr	L2142
L213A:
	ld	r2,%000C(r14)
	ld	@r2,#%0001
L2142:
	test	r13
	jr	eq,L215E
	cp	r13,r10
	jr	eq,L215E
	cp	%0006(r14),#%0063
	jr	eq,L2158
	ld	r2,r13
	inc	r13,#1
	clrb	@r2
L2158:
	ldk	r2,#1
L215A:
	jp	cret
L215E:
	xor	r2,r2
	jr	L215A
end __instr
G	__getccl	PR
E
__getccl:
	call	csv
	ld	r13,%0004(r14)
	xor	r11,r11
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%005E
	jr	ne,L217A
	inc	r11,#1
	inc	r13,#1
L217A:
	xor	r12,r12
	jr	L218E
L217E:
	test	r11
	jr	eq,L2188
	resb	__sctab(r12),#1
	jr	L218C
L2188:
	setb	__sctab(r12),#1
L218C:
	inc	r12,#1
L218E:
	cp	r12,#%0080
	jr	lt,L217E
L2194:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r12,r3
	ld	r2,r12
	and	r2,#%007F
	cp	r2,#%005D
	jr	eq,L21CA
	test	r11
	jr	eq,L21BA
	ld	r2,r12
	add	r2,#__sctab
	inc	r12,#1
	setb	@r2,#1
	jr	L21C4
L21BA:
	ld	r2,r12
	add	r2,#__sctab
	inc	r12,#1
	resb	@r2,#1
L21C4:
	test	r12
	jr	ne,L2194
	dec	r13,#1
L21CA:
	ld	r2,r13
	jp	cret
end __getccl
I
D3FAA:
G
__sctab	L
__sctab:
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %1;BV %1;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %1;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
D402A:
WV L2012
WV L2012
WV L2020
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
WV L202E
end doscan_
