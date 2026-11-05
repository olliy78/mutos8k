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
	jr	L0ED6
L0EA8:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0039
	jr	ugt,L0EFC
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
	jr	L0EF2
L0ECE:
	inc	r11,#1
L0ED0:
	inc	r13,#1
	jr	L0EF2
L0ED4:
	inc	r13,#1
L0ED6:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0009
	jr	eq,L0ED4
	cp	r2,#%0020
	jr	eq,L0ED4
	cp	r2,#%002B
	jr	eq,L0ED0
	cp	r2,#%002D
	jr	eq,L0ECE
L0EF2:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0030
	jr	uge,L0EA8
L0EFC:
	test	r11
	jr	eq,L0F08
	ld	r2,r12
	neg	r2
L0F04:
	jp	cret
L0F08:
	ld	r2,r12
	jr	L0F04
end _atoi
end atoi_
