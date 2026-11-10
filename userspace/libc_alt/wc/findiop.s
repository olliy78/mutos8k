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
	jr	L0B7C
L0B6E:
	cp	r13,__lastbu
	jr	ult,L0B7A
	xor	r2,r2
L0B76:
	jp	cret
L0B7A:
	inc	r13,#8
L0B7C:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L0B6E
	ld	r2,r13
	jr	L0B76
end __findio
end findiop_
