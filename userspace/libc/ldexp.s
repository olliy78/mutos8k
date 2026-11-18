! RECONSTRUCTED (W8): text and data of the shipped libc.a member as data words (no source with these instructions), labels from its symbol table !
ldexp_ module
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
X	csv	PR;
X	cret	PR;
G	_ldexp	PR
E
_ldexp:
	WV	%5F00
	WV	csv
	WV	%61E0
	WV	%C
	WV	%100
	WV	%3FF
	WV	%B00
	WV	%7FF
	WV	%EA0C
	WV	%B301
	WV	%4
$1:
	WV	%6F00
	WV	NU
	WV	%4F04
	WV	%8003
	WV	NU
	WV	%4FE4
	WV	%40B3
	WV	%4
	WV	%5E08
	WV	cret
huge:
	WV	%2100
	WV	%7FF0
	WV	%E8F3
end _ldexp
I
G
NU	L
NU:
I
WV	%0
WV	%0
WV	%0
WV	%0
end ldexp_
