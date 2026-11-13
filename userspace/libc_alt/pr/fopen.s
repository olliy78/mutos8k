fopen_ module
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
G	_fopen	PR
E
_fopen:
	call	csv
	call	__findio
	push	@r15,r2
	push	@r15,%0006(r14)
	push	@r15,%0004(r14)
	call	__endope
	inc	r15,#6
	jp	cret
end _fopen
end fopen_
