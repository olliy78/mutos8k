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
	jr	L1984
L1976:
	cp	r13,__lastbu
	jr	ult,L1982
	xor	r2,r2
L197E:
	jp	cret
L1982:
	inc	r13,#8
L1984:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L1976
	ld	r2,r13
	jr	L197E
end __findio
end findiop_
