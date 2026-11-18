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
	jr	L52D2
L52C4:
	cp	r13,__lastbu
	jr	ult,L52D0
	xor	r2,r2
L52CC:
	jp	cret
L52D0:
	inc	r13,#8
L52D2:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L52C4
	ld	r2,r13
	jr	L52CC
end __findio
end findiop_
