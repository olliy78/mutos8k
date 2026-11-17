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
	jr	L5860
L5852:
	cp	r13,__lastbu
	jr	ult,L585E
	xor	r2,r2
L585A:
	jp	cret
L585E:
	inc	r13,#8
L5860:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L5852
	ld	r2,r13
	jr	L585A
end __findio
end findiop_
