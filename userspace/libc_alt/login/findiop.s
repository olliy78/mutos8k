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
	jr	L1184
L1176:
	cp	r13,__lastbu
	jr	ult,L1182
	xor	r2,r2
L117E:
	jp	cret
L1182:
	inc	r13,#8
L1184:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	ne,L1176
	ld	r2,r13
	jr	L117E
end __findio
end findiop_
