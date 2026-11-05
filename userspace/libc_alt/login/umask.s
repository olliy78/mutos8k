umask_ module
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
G	_umask	PR
E
_umask:
	push	@r15,r14
	ld	r14,r15
	ld	r0,%0004(r14)
	sc	#%3C
	jp	ult,cerror
	ld	r2,r4
	pop	r14,@r15
	ret
end _umask
end umask_
