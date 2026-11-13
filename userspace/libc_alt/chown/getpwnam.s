getpwnam_ module
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
G	_getpwna	PR
E
_getpwna:
	call	csv
	call	_setpwen
L0148:
	call	_getpwen
	ld	r13,r2
	test	r2
	jr	eq,L0162
	push	@r15,@r13
	push	@r15,%0004(r14)
	call	_strcmp
	inc	r15,#4
	test	r2
	jr	ne,L0148
L0162:
	call	_endpwen
	ld	r2,r13
	jp	cret
end _getpwna
end getpwnam_
