l3_ module
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
G	_ltol3	PR
E
_ltol3:
	call	csv
	ld	r12,%0004(r14)
	ld	r11,%0006(r14)
	xor	r13,r13
	jr	L1C7C
L1C54:
	inc	r11,#1
	ld	r2,r12
	inc	r12,#1
	ld	r3,r11
	inc	r11,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r2,r12
	inc	r12,#1
	ld	r3,r11
	inc	r11,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r2,r12
	inc	r12,#1
	ld	r3,r11
	inc	r11,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	inc	r13,#1
L1C7C:
	cp	r13,%0008(r14)
	jr	lt,L1C54
	jp	cret
end _ltol3
G	_l3tol	PR
E
_l3tol:
	call	csv
	ld	r12,%0004(r14)
	ld	r11,%0006(r14)
	xor	r13,r13
	jr	L1CC2
L1C96:
	ld	r2,r12
	inc	r12,#1
	clrb	@r2
	ld	r2,r12
	inc	r12,#1
	ld	r3,r11
	inc	r11,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r2,r12
	inc	r12,#1
	ld	r3,r11
	inc	r11,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r2,r12
	inc	r12,#1
	ld	r3,r11
	inc	r11,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	inc	r13,#1
L1CC2:
	cp	r13,%0008(r14)
	jr	lt,L1C96
	jp	cret
end _l3tol
end l3_
