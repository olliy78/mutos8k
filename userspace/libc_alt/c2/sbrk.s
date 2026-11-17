sbrk_ module
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
G	_sbrk	PR
E
_sbrk:
	push	@r15,r14
	ld	r14,r15
	ld	r0,%0004(r14)
	ld	r1,D4A0E
	or	r0,r0
	jp	eq,L41F2
	add	r0,r1
	sc	#%11
	jp	ult,cerror
	ld	D4A0E,r0
L41F2:
	ld	r2,r1
	pop	r14,@r15
	ret
end _sbrk
G	_brk	PR
E
_brk:
	push	@r15,r14
	ld	r14,r15
	ld	r0,%0004(r14)
	sc	#%11
	jp	ult,cerror
	ld	D4A0E,r0
	xor	r2,r2
	pop	r14,@r15
	ret
end _brk
I
D4A0E:
WV _end
end sbrk_
