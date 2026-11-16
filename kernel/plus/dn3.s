dn3 module
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
_conptr	L
G
_nlp	L
G
_cf_8c94	L
G	_p_dn3	PR
E
end _p_dn3
I
_cf_8c94:
	BV %00;BV %04
_conptr:
	WV _conlog
_nlp:
	BV %00;BV %01
end dn3
