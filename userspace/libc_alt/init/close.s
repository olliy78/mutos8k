close module
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
G	_close	PR
E
_close:
	push	@r15,r14
	ld	r14,r15
	ld	r0,%0004(r14)
	sc	#%06
	jp	ult,cerror
	xor	r2,r2
	pop	r14,@r15
	ret
end _close
end close
