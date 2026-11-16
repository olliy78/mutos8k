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
	jr	L08A2
L0874:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0039
	jr	ugt,L08C8
	ld	r2,r13
	inc	r13,#1
	ld	r5,r12
	mult	rr4,#%000A
	ld	r3,r5
	ldb	rl4,@r2
	xorb	rh4,rh4
	add	r3,r4
	ld	r2,r3
	ld	r12,r3
	add	r12,#%FFD0
	jr	L08BE
L089A:
	inc	r11,#1
L089C:
	inc	r13,#1
	jr	L08BE
L08A0:
	inc	r13,#1
L08A2:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0009
	jr	eq,L08A0
	cp	r2,#%0020
	jr	eq,L08A0
	cp	r2,#%002B
	jr	eq,L089C
	cp	r2,#%002D
	jr	eq,L089A
L08BE:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0030
	jr	uge,L0874
L08C8:
	test	r11
	jr	eq,L08D4
	ld	r2,r12
	neg	r2
L08D0:
	jp	cret
L08D4:
	ld	r2,r12
	jr	L08D0
end _atoi
end atoi_
