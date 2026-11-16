dn0 module
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
_regloc	L
G	_p_dn0	PR
E
end _p_dn0
I
_regloc:
	BV %00;BV %01;BV %02;BV %03;BV %04;BV %05;BV %06;BV %07
end dn0
