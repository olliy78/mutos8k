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
	jr	L0D08
L0CDA:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0039
	jr	ugt,L0D2E
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
	jr	L0D24
L0D00:
	inc	r11,#1
L0D02:
	inc	r13,#1
	jr	L0D24
L0D06:
	inc	r13,#1
L0D08:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0009
	jr	eq,L0D06
	cp	r2,#%0020
	jr	eq,L0D06
	cp	r2,#%002B
	jr	eq,L0D02
	cp	r2,#%002D
	jr	eq,L0D00
L0D24:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0030
	jr	uge,L0CDA
L0D2E:
	test	r11
	jr	eq,L0D3A
	ld	r2,r12
	neg	r2
L0D36:
	jp	cret
L0D3A:
	ld	r2,r12
	jr	L0D36
end _atoi
end atoi_
