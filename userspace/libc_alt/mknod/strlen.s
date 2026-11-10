strlen_ module
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
G	_strlen	PR
E
_strlen:
	call	csv
	ld	r13,%0004(r14)
	xor	r12,r12
	jr	L0AB0
L0AAE:
	inc	r12,#1
L0AB0:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	testb	rl3
	jr	ne,L0AAE
	ld	r2,r12
	jp	cret
end _strlen
end strlen_
