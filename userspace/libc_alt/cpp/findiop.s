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
	jr	L2F82
L2F74:
	cp	r13,__lastbu
	jr	ult,L2F80
	xor	r2,r2
L2F7C:
	jp	cret
L2F80:
	inc	r13,#8
L2F82:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L2F74
	ld	r2,r13
	jr	L2F7C
end __findio
end findiop_
