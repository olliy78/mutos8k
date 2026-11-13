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
	jr	L0C32
L0C24:
	cp	r13,__lastbu
	jr	ult,L0C30
	xor	r2,r2
L0C2C:
	jp	cret
L0C30:
	inc	r13,#8
L0C32:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L0C24
	ld	r2,r13
	jr	L0C2C
end __findio
end findiop_
