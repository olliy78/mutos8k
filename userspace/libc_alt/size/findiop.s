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
	jr	L0B02
L0AF4:
	cp	r13,__lastbu
	jr	ult,L0B00
	xor	r2,r2
L0AFC:
	jp	cret
L0B00:
	inc	r13,#8
L0B02:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L0AF4
	ld	r2,r13
	jr	L0AFC
end __findio
end findiop_
