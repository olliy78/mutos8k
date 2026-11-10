rindex_ module
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
G	_rindex	PR
E
_rindex:
	call	csv
	ld	r13,%0004(r14)
	xor	r12,r12
L0C3A:
	ldb	rl0,@r13
	cpb	rl0,%0007(r14)
	jr	ne,L0C44
	ld	r12,r13
L0C44:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	testb	rl3
	jr	ne,L0C3A
	ld	r2,r12
	jp	cret
end _rindex
end rindex_
