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
	jr	L1E74
L1E4A:
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	testb	rl4
	jr	ne,L1E72
	jr	L1E64
L1E5E:
	ld	r2,r13
	inc	r13,#1
	clrb	@r2
L1E64:
	inc	r11,#1
	cp	r11,%0008(r14)
	jr	lt,L1E5E
L1E6C:
	ld	r2,r10
	jp	cret
L1E72:
	inc	r11,#1
L1E74:
	cp	r11,%0008(r14)
	jr	lt,L1E4A
	jr	L1E6C
end _strncpy
end strncpy_
