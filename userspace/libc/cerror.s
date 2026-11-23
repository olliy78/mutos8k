! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
cerror_ module
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
G	cerror	PR
E
cerror:
	ld	_errno,r4
	ld	r2,#%FFFF
	ld	r15,r14
	pop	r14,@r15
	ret
end cerror
$SECTION BSS_B
I
G
_errno	L
_errno:
I
$REL	$+%2
$SDEFAULT
end cerror_
