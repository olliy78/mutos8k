getenv_ module
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
G	_getenv	PR
E
_getenv:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,_environ
L2D1A:
	test	@r12
	jr	eq,L2D38
	ld	r2,r12
	inc	r12,#2
	push	@r15,@r2
	push	@r15,r13
	call	L2D3C
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	eq,L2D1A
	ld	r2,r11
L2D34:
	jp	cret
L2D38:
	xor	r2,r2
	jr	L2D34
L2D3C:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
L2D48:
	ld	r2,r12
	inc	r12,#1
	ldb	rl0,@r2
	cpb	rl0,@r13
	jr	ne,L2D74
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%003D
	jr	ne,L2D48
L2D60:
	ld	r2,r12
	jr	L2D7A
L2D64:
	ld	r2,r12
	dec	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%003D
	jr	ne,L2D78
	jr	L2D60
L2D74:
	testb	@r13
	jr	eq,L2D64
L2D78:
	xor	r2,r2
L2D7A:
	jp	cret
end _getenv
end getenv_
