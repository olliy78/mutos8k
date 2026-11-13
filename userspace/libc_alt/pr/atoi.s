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
	jr	L14FE
L14D0:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0039
	jr	ugt,L1524
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
	jr	L151A
L14F6:
	inc	r11,#1
L14F8:
	inc	r13,#1
	jr	L151A
L14FC:
	inc	r13,#1
L14FE:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0009
	jr	eq,L14FC
	cp	r2,#%0020
	jr	eq,L14FC
	cp	r2,#%002B
	jr	eq,L14F8
	cp	r2,#%002D
	jr	eq,L14F6
L151A:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0030
	jr	uge,L14D0
L1524:
	test	r11
	jr	eq,L1530
	ld	r2,r12
	neg	r2
L152C:
	jp	cret
L1530:
	ld	r2,r12
	jr	L152C
end _atoi
end atoi_
