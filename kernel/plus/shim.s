shim module
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
G
_save	L
G
_mchinit	L
G	_p_shim	PR
E
_save:
	jp	_savu
_mchinit:
	jp	_ttyinit
end _p_shim
end shim
