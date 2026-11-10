isatty_ module
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
G	_isatty	PR
E
_isatty:
	call	csv
	dec	r15,#12
	ld	r2,r14
	add	r2,#%FFE8
	push	@r15,r2
	push	@r15,%0004(r14)
	call	_gtty
	inc	r15,#4
	test	r2
	jr	pl,L0BCA
	xor	r2,r2
L0BC6:
	jp	cret
L0BCA:
	ldk	r2,#1
	jr	L0BC6
end _isatty
end isatty_
