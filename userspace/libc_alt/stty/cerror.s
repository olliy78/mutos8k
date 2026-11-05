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
B1AD2:
G
_errno	L
_errno:
I
$REL	$+%2
$SDEFAULT
end cerror_
