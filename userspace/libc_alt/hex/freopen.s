freopen_ module
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
G	_freopen	PR
E
_freopen:
	call	csv
	ld	r13,%0008(r14)
	push	@r15,r13
	call	_fclose
	ld	@r15,r13
	push	@r15,%0006(r14)
	push	@r15,%0004(r14)
	call	__endope
	inc	r15,#6
	jp	cret
end _freopen
end freopen_
