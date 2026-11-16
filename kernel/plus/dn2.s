dn2 module
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
_icode	L
G
_szicode	L
G	_p_dn2	PR
E
end _p_dn2
I
_icode:
	BV %21;BV %00;BV %00;BV %10;BV %21;BV %01;BV %00;BV %0C
	BV %7F;BV %0B;BV %E8;BV %FF;BV %00;BV %10;BV %00;BV %00
	BV %2F;BV %65;BV %74;BV %63;BV %2F;BV %69;BV %6E;BV %69
	BV %74;BV %00
_szicode:
	BV %00;BV %1A
end dn2
