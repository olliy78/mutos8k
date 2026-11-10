atol_ module
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
G	_atol	PR
E
_atol:
	call	csv
	ld	r13,%0004(r14)
	dec	r15,#4
	xor	r0,r0
	ld	r1,r0
	ldl	%FFF0(r14),rr0
	xor	r12,r12
	jr	L0BD0
L0B9A:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0039
	jr	ugt,L0BF6
	ldl	rr2,%FFF0(r14)
	ldk	r5,#10
	exts	rr4
	multl	rq0,rr4
	ld	r4,r13
	inc	r13,#1
	ldb	rl7,@r4
	xorb	rh7,rh7
	exts	rr6
	ldl	rr4,rr6
	addl	rr2,rr4
	addl	rr2,#%FFFFFFD0
	ldl	%FFF0(r14),rr2
	jr	L0BEC
L0BC8:
	inc	r12,#1
L0BCA:
	inc	r13,#1
	jr	L0BEC
L0BCE:
	inc	r13,#1
L0BD0:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0009
	jr	eq,L0BCE
	cp	r2,#%0020
	jr	eq,L0BCE
	cp	r2,#%002B
	jr	eq,L0BCA
	cp	r2,#%002D
	jr	eq,L0BC8
L0BEC:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0030
	jr	uge,L0B9A
L0BF6:
	test	r12
	jr	eq,L0C06
	ldl	rr2,%FFF0(r14)
	neg	r3
	neg	r2
L0C02:
	jp	cret
L0C06:
	ldl	rr2,%FFF0(r14)
	jr	L0C02
end _atol
end atol_
