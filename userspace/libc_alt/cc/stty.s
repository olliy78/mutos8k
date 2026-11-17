stty_ module
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
G	_stty	PR
E
_stty:
	call	csv
	push	@r15,%0006(r14)
	push	@r15,#%7409
	push	@r15,%0004(r14)
	call	_ioctl
	inc	r15,#6
	jp	cret
end _stty
G	_gtty	PR
E
_gtty:
	call	csv
	push	@r15,%0006(r14)
	push	@r15,#%7408
	push	@r15,%0004(r14)
	call	_ioctl
	inc	r15,#6
	jp	cret
end _gtty
end stty_
