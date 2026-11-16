dn1 module
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
_max_pro	L
G	_p_dn1	PR
E
end _p_dn1
I
_max_pro:
	BV %A1;BV %54
end dn1
