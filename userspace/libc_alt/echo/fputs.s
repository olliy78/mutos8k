fputs_ module
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
G	_fputs	PR
E
_fputs:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	jr	L0148
L011A:
	bitb	%0006(r12),#0
	jr	ne,L0134
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L0134
	ld	r2,@r12
	inc	@r12,#1
	ld	r3,r10
	ldb	@r2,rl3
	jr	L0144
L0134:
	push	@r15,r2
	push	@r15,r12
	push	@r15,r10
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0144:
	ld	r2,r3
	ld	r11,r2
L0148:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r10,r3
	test	r3
	jr	ne,L011A
	ld	r2,r11
	jp	cret
end _fputs
end fputs_
