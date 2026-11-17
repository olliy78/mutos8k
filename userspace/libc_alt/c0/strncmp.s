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
L5B0E:
	dec	r11,#1
	jr	mi,L5B28
	ld	r2,r12
	inc	r12,#1
	ldb	rl0,@r2
	cpb	rl0,@r13
	jr	ne,L5B28
	ld	r2,r13
	inc	r13,#1
	testb	@r2
	jr	ne,L5B0E
L5B24:
	xor	r2,r2
	jr	L5B3C
L5B28:
	test	r11
	jr	mi,L5B24
	dec	r12,#1
	ld	r2,r12
	ldb	rl3,@r13
	xorb	rh3,rh3
	ldb	rl4,@r2
	xorb	rh4,rh4
	sub	r3,r4
	ld	r2,r3
L5B3C:
	jp	cret
end _strncmp
end strncmp_
