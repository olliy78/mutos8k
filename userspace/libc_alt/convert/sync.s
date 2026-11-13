sync_ module
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
G	_sync	PR
E
_sync:
	push	@r15,r14
	ld	r14,r15
	sc	#%24
	pop	r14,@r15
	ret
end _sync
end sync_
