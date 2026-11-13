atoi_ module
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
G	_atoi	PR
E
_atoi:
	call	csv
	ld	r13,%0004(r14)
	xor	r12,r12
	xor	r11,r11
	jr	L13BC
L138E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0039
	jr	ugt,L13E2
	ld	r2,r13
	inc	r13,#1
	ld	r5,r12
	mult	rr4,#%000A
	ld	r3,r5
	ldb	rl4,@r2
	xorb	rh4,rh4
	add	r3,r4
	ld	r2,r3
	ld	r12,r2
	add	r12,#%FFD0
	jr	L13D8
L13B4:
	inc	r11,#1
L13B6:
	inc	r13,#1
	jr	L13D8
L13BA:
	inc	r13,#1
L13BC:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0009
	jr	eq,L13BA
	cp	r2,#%0020
	jr	eq,L13BA
	cp	r2,#%002B
	jr	eq,L13B6
	cp	r2,#%002D
	jr	eq,L13B4
L13D8:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0030
	jr	uge,L138E
L13E2:
	test	r11
	jr	eq,L13EE
	ld	r2,r12
	neg	r2
L13EA:
	jp	cret
L13EE:
	ld	r2,r12
	jr	L13EA
end _atoi
end atoi_
