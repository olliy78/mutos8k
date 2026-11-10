getgid_ module
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
G	_getgid	PR
E
_getgid:
	push	@r15,r14
	ld	r14,r15
	sc	#%2F
	ld	r2,r4
	pop	r14,@r15
	ret
end _getgid
G	_getegid	PR
E
_getegid:
	push	@r15,r14
	ld	r14,r15
	sc	#%2F
	ld	r2,r5
	pop	r14,@r15
	ret
end _getegid
end getgid_
