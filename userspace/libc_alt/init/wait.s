wait_ module
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
G	_wait	PR
E
_wait:
	push	@r15,r14
	ld	r14,r15
	sc	#%07
	jp	ult,cerror
	ld	r2,r4
	ld	r1,%0004(r14)
	test	r1
	jr	eq,L11BE
	ld	@r1,r5
L11BE:
	pop	r14,@r15
	ret
end _wait
end wait_
