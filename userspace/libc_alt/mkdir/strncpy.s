strncpy_ module
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
G	_strncpy	PR
E
_strncpy:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	ld	r10,r13
	xor	r11,r11
	jr	L0BDC
L0BB2:
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	testb	rl4
	jr	ne,L0BDA
	jr	L0BCC
L0BC6:
	ld	r2,r13
	inc	r13,#1
	clrb	@r2
L0BCC:
	inc	r11,#1
	cp	r11,%0008(r14)
	jr	lt,L0BC6
L0BD4:
	ld	r2,r10
	jp	cret
L0BDA:
	inc	r11,#1
L0BDC:
	cp	r11,%0008(r14)
	jr	lt,L0BB2
	jr	L0BD4
end _strncpy
end strncpy_
