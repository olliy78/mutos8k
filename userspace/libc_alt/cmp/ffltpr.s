ffltpr_ module
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
G	pfloat	PR
E
pfloat:
end pfloat
G	pgen	PR
E
pgen:
end pgen
G	pscien	PR
E
pscien:
	inc	r13,#8
	ldb	@r10,#%3F
	inc	r10,#1
	ret
end pscien
end ffltpr_
