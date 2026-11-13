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
	jr	L13C6
L13B8:
	cp	r13,__lastbu
	jr	ult,L13C4
	xor	r2,r2
L13C0:
	jp	cret
L13C4:
	inc	r13,#8
L13C6:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L13B8
	ld	r2,r13
	jr	L13C0
end __findio
end findiop_
