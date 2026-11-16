ungetc_ module
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
G	_ungetc	PR
E
_ungetc:
	call	csv
	ld	r13,%0006(r14)
	ld	r0,%0004(r14)
	cp	r0,#%FFFF
	jr	ne,L22D8
L22B0:
	ld	r2,#%FFFF
	jr	L22D4
L22B6:
	test	%0002(r13)
	jr	ne,L22B0
	ld	r2,@r13
	ldb	rl3,@r2
	xorb	rh3,rh3
	inc	@r13,#1
L22C4:
	inc	%0002(r13),#1
	dec	@r13,#1
	ld	r2,@r13
	ld	r3,%0004(r14)
	ldb	@r2,rl3
	xor	r2,r2
L22D4:
	jp	cret
L22D8:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L22EC
	ld	r0,@r13
	cp	r0,%0004(r13)
	jr	ugt,L22C4
L22EC:
	ld	r0,@r13
	cp	r0,%0004(r13)
	jr	eq,L22B6
	jr	L22B0
end _ungetc
end ungetc_
