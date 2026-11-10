time_ module
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
G	_time	PR
E
_time:
	push	@r15,r14
	ld	r14,r15
	sc	#%0D
	ldl	rr2,rr4
	ld	r1,%0004(r14)
	test	r1
	jr	eq,L1DD0
	ldl	@r1,rr2
L1DD0:
	pop	r14,@r15
	ret
end _time
G	_ftime	PR
E
_ftime:
	push	@r15,r14
	ld	r14,r15
	ld	r0,%0004(r14)
	sc	#%23
	pop	r14,@r15
	ret
end _ftime
end time_
