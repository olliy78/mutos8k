pause_ module
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
G	_pause	PR
E
_pause:
	push	@r15,r14
	ld	r14,r15
	sc	#%1D
	pop	r14,@r15
	ret
end _pause
end pause_
