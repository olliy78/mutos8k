setbuf_ module
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
G	_setbuf	PR
E
_setbuf:
	call	csv
	ld	r13,%0004(r14)
	test	%0004(r13)
	jr	eq,L09D8
	bitb	%0006(r13),#3
	jr	eq,L09D8
	push	@r15,%0004(r13)
	call	_free
	inc	r15,#2
L09D8:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%FFF3
	ldb	%0006(r13),rl2
	ld	r2,%0006(r14)
	ld	%0004(r13),r2
	jr	ne,L09F6
	setb	%0006(r13),#2
	jr	L09FC
L09F6:
	ld	r2,%0004(r13)
	ld	@r13,r2
L09FC:
	clr	%0002(r13)
	jp	cret
end _setbuf
end setbuf_
