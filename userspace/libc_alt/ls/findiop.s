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
	jr	L1348
L133A:
	cp	r13,__lastbu
	jr	ult,L1346
	xor	r2,r2
L1342:
	jp	cret
L1346:
	inc	r13,#8
L1348:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L133A
	ld	r2,r13
	jr	L1342
end __findio
end findiop_
