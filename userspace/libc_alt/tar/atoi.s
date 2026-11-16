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
	jr	L2E44
L2E16:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0039
	jr	ugt,L2E6A
L2E20:
	ld	r2,r13
	inc	r13,#1
	ld	r5,r12
	mult	rr4,#%000A
	ld	r3,r5
	ldb	rl4,@r2
L2E2E:
	xorb	rh4,rh4
	add	r3,r4
	ld	r2,r3
	ld	r12,r3
	add	r12,#%FFD0
	jr	L2E60
L2E3C:
	inc	r11,#1
L2E3E:
	inc	r13,#1
	jr	L2E60
L2E42:
	inc	r13,#1
L2E44:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0009
	jr	eq,L2E42
	cp	r2,#%0020
	jr	eq,L2E42
	cp	r2,#%002B
	jr	eq,L2E3E
	cp	r2,#%002D
	jr	eq,L2E3C
L2E60:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0030
	jr	uge,L2E16
L2E6A:
	test	r11
	jr	eq,L2E76
	ld	r2,r12
	neg	r2
L2E72:
	jp	cret
L2E76:
	ld	r2,r12
	jr	L2E72
end _atoi
end atoi_
