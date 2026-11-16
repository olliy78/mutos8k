lseek_ module
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
G	_lseek	PR
E
_lseek:
	push	@r15,r14
	ld	r14,r15
	ldm	r0,%0004(r14),#4
	sc	#%13
	jp	ult,cerror
	ldl	rr2,rr4
	pop	r14,@r15
	ret
end _lseek
end lseek_
