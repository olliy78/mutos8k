setjmp_ module
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
G	_setjmp	PR
E
_setjmp:
	ld	r1,%0002(r15)
	inc	r1,#6
	push	@r1,@r15
	push	@r1,r15
	push	@r1,r14
	xor	r2,r2
	ret
end _setjmp
G	_longjmp	PR
E
_longjmp:
	call	csv
	ldm	r1,%0004(r14),#2
	test	r2
	jr	ne,L1CC6
	ldk	r2,#1
L1CC6:
	ld	r0,@r14
	cp	r0,@r1
	jr	eq,L1CDA
	ld	r14,r0
	test	r0
	jr	ne,L1CC6
	pop	r14,@r1
	pop	r15,@r1
	pop	@r15,@r1
	ret
L1CDA:
	ld	r0,%0004(r1)
	ld	%0002(r14),r0
	jp	cret
end _longjmp
end setjmp_
