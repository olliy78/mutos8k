index_ module
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
G	_index	PR
E
_index:
	call	csv
	ld	r13,%0004(r14)
L1622:
	ldb	rl0,@r13
	cpb	rl0,%0007(r14)
	jr	ne,L1630
	ld	r2,r13
L162C:
	jp	cret
L1630:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	testb	rl3
	jr	ne,L1622
	xor	r2,r2
	jr	L162C
end _index
end index_
