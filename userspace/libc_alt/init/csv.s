csv module
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
G	csv	PR
E
csv:
	ld	r1,@r15
	dec	r15,#12
	ldm	@r15,r8,#7
	ld	r14,r15
	inc	r14,#12
	jp	@r1
end csv
G	cret	PR
E
cret:
	ld	r5,r14
	ldm	r8,%FFF4(r5),#7
	ld	r15,r5
	inc	r15,#2
	ret
end cret
end csv
