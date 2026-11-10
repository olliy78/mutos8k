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
	jr	L0904
L08D6:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0039
	jr	ugt,L092A
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
	jr	L0920
L08FC:
	inc	r11,#1
L08FE:
	inc	r13,#1
	jr	L0920
L0902:
	inc	r13,#1
L0904:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0009
	jr	eq,L0902
	cp	r2,#%0020
	jr	eq,L0902
	cp	r2,#%002B
	jr	eq,L08FE
	cp	r2,#%002D
	jr	eq,L08FC
L0920:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0030
	jr	uge,L08D6
L092A:
	test	r11
	jr	eq,L0936
	ld	r2,r12
	neg	r2
L0932:
	jp	cret
L0936:
	ld	r2,r12
	jr	L0932
end _atoi
end atoi_
