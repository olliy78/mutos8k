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
L0E50:
	test	@r12
	jr	eq,L0E6E
	ld	r2,r12
	inc	r12,#2
	push	@r15,@r2
	push	@r15,r13
	call	L0E72
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	eq,L0E50
	ld	r2,r11
L0E6A:
	jp	cret
L0E6E:
	xor	r2,r2
	jr	L0E6A
L0E72:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
L0E7E:
	ld	r2,r12
	inc	r12,#1
	ldb	rl0,@r2
	cpb	rl0,@r13
	jr	ne,L0EAA
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%003D
	jr	ne,L0E7E
L0E96:
	ld	r2,r12
	jr	L0EB0
L0E9A:
	ld	r2,r12
	dec	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%003D
	jr	ne,L0EAE
	jr	L0E96
L0EAA:
	testb	@r13
	jr	eq,L0E9A
L0EAE:
	xor	r2,r2
L0EB0:
	jp	cret
end _getenv
end getenv_
