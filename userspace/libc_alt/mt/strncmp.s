strncmp_ module
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
G	_strncmp	PR
E
_strncmp:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	ld	r11,%0008(r14)
L0B7C:
	dec	r11,#1
	jr	mi,L0B96
	ld	r2,r12
	inc	r12,#1
	ldb	rl0,@r2
	cpb	rl0,@r13
	jr	ne,L0B96
	ld	r2,r13
	inc	r13,#1
	testb	@r2
	jr	ne,L0B7C
L0B92:
	xor	r2,r2
	jr	L0BAA
L0B96:
	test	r11
	jr	mi,L0B92
	dec	r12,#1
	ld	r2,r12
	ldb	rl3,@r13
	xorb	rh3,rh3
	ldb	rl4,@r2
	xorb	rh4,rh4
	sub	r3,r4
	ld	r2,r3
L0BAA:
	jp	cret
end _strncmp
end strncmp_
