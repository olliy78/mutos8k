dup module
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
G	_dup2	PR
E
_dup2:
	ld	r3,#%0040
	jr	L1004
end _dup2
G	_dup	PR
E
_dup:
	xor	r3,r3
L1004:
	push	@r15,r14
	ld	r14,r15
	ldm	r0,%0004(r14),#2
	or	r0,r3
	sc	#%29
	jp	ult,cerror
	ld	r2,r4
	pop	r14,@r15
	ret
end _dup
end dup
