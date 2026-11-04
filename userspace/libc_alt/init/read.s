read module
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
G	_read	PR
E
_read:
	push	@r15,r14
	ld	r14,r15
	ldm	r0,%0004(r14),#3
	sc	#%03
	jp	ult,cerror
	ld	r2,r4
	pop	r14,@r15
	ret
end _read
end read
