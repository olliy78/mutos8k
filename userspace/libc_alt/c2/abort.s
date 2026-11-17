abort_ module
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
G	_abort	PR
E
_abort:
	call	csv
	sc	#%14
	ld	r0,r4
	ldk	r1,#6
	sc	#%25
	xor	r2,r2
	jp	cret
end _abort
end abort_
