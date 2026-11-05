execv_ module
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
G	_execv	PR
E
_execv:
	push	@r15,r14
	ld	r14,r15
	ldm	r0,%0004(r14),#2
	ld	r2,%1F6+__sobuf
	sc	#%3B
	jp	cerror
end _execv
end execv_
