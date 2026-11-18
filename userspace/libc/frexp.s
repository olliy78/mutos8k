! RECONSTRUCTED (W8): text and data of the shipped libc.a member as data words (no source with these instructions), labels from its symbol table !
frexp_ module
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
G	_frexp	PR
E
_frexp:
	WV	%5F00
	WV	csv
	WV	%61E0
	WV	%4
	WV	%A106
	WV	%A30F
	WV	%B301
	WV	%FFFC
	WV	%8D04
	WV	%E610
	WV	%706
	WV	%800F
	WV	%506
	WV	%3FE0
	WV	%6FE6
	WV	%4
	WV	%300
	WV	%3FE
rue:
	WV	%61E1
	WV	%C
	WV	%2F10
	WV	%4FE4
	WV	%8003
	WV	%4
	WV	%5E08
	WV	cret
small:
	WV	%2100
	WV	%FC01
	WV	%54E2
	WV	%4
	WV	%54E4
	WV	%8
	WV	%9C28
	WV	%EE02
	WV	%9C48
	WV	%E611
$2:
	WV	%506
	WV	%7FFF
$1:
	WV	%9644
	WV	%B533
	WV	%B522
	WV	%AB00
	WV	%A724
	WV	%E6FA
	WV	%A324
	WV	%502
	WV	%3FE
	WV	%8562
	WV	%5DE2
	WV	%4
	WV	%5DE4
	WV	%8
	WV	%E8DD
$3:
	WV	%8900
	WV	%E8DB
end _frexp
end frexp_
