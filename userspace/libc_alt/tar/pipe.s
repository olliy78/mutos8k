pipe_ module
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
G	_pipe	PR
E
_pipe:
	push	@r15,r14
	ld	r14,r15
	sc	#%2A
	jp	ult,cerror
	ld	r1,%0004(r14)
	ldl	@r1,rr4
	xor	r2,r2
	pop	r14,@r15
	ret
end _pipe
end pipe_
