! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
modf_ module
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
G	_modf	PR
E
_modf:
	call	csv
	WV %4FE4;WV %8003;WV %0004
	WV %8F00;WV %8023
	WV %8F18;WV %8023
	ld	r1,%000C(r14)
	WV %0F1C;WV %8103
	WV %8E04;WV %4190
	jp	cret
end _modf
end modf_
