getgrgid_ module
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
G	_getgrgi	PR
E
_getgrgi:
	call	csv
	ld	r13,%0004(r14)
	call	_setpwen
L0188:
	call	_getpwen
	ld	r12,r2
	test	r2
	jr	eq,L019A
	ld	r0,%0004(r12)
	cp	r0,r13
	jr	ne,L0188
L019A:
	call	_endpwen
	ld	r2,r12
	jp	cret
end _getgrgi
end getgrgid_
