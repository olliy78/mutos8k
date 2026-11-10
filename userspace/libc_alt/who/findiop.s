findiop_ module
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
G	__findio	PR
E
__findio:
	call	csv
	ld	r13,#__iob
	jr	L0DC2
L0DB4:
	cp	r13,__lastbu
	jr	ult,L0DC0
	xor	r2,r2
L0DBC:
	jp	cret
L0DC0:
	inc	r13,#8
L0DC2:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L0DB4
	ld	r2,r13
	jr	L0DBC
end __findio
end findiop_
