strncat_ module
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
G	_strncat	PR
E
_strncat:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	ld	r11,%0008(r14)
	ld	r10,r13
L1DAC:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	testb	rl3
	jr	ne,L1DAC
	dec	r13,#1
L1DBA:
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	testb	rl4
	jr	eq,L1DD6
	dec	r11,#1
	jr	pl,L1DBA
	dec	r13,#1
	ld	r2,r13
	clrb	@r2
L1DD6:
	ld	r2,r10
	jp	cret
end _strncat
end strncat_
