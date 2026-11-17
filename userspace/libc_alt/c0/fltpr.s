fltpr_ module
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
	push	@r15,r10
	push	@r15,r11
	test	r11
	jr	ne,L4DA8
	ld	@r15,#%0006
L4DA8:
	WV %0FD4;WV %8003
	inc	r13,#2
	dec	r15,#8
	WV %0FFC;WV %8003
	call	_gcvt
	inc	r15,#12
	jr	L4DBE
L4DBC:
	inc	r12,#1
L4DBE:
	test	@r12
	jr	ne,L4DBC
	dec	r12,#1
	ret
L4DC6:
	push	@r15,#sign
	push	@r15,#decpt
	test	r9
	jr	ne,L4DD4
	ldk	r11,#6
L4DD4:
	push	@r15,r11
	WV %0FD4;WV %8003
	dec	r15,#8
	WV %0FFC;WV %8003
	call	_fcvt
L4DE4:
	inc	r15,#14
	test	sign
	jr	eq,L4DF2
	ldb	@r10,#%2D
	inc	r10,#1
L4DF2:
	ld	r1,decpt
	ld	r4,r1
	test	r4
	jr	gt,L4E02
	ldb	@r10,#%30
L4E00:
	inc	r10,#1
L4E02:
	test	r4
	jr	le,L4E10
L4E06:
	ldb	rh3,@r2
	ldb	@r10,rh3
	inc	r2,#1
	inc	r10,#1
	djnz	r1,L4E06
L4E10:
	test	r11
	jr	eq,L4E1A
	ldb	@r10,#%2E
	inc	r10,#1
L4E1A:
	neg	r4
	jr	le,L4E2A
L4E1E:
	dec	r11,#1
	jr	lt,L4E2A
	ldb	@r10,#%30
	inc	r10,#1
	djnz	r4,L4E1E
L4E2A:
	test	r11
	jr	le,L4E38
L4E2E:
	ldb	rh3,@r2
	ldb	@r10,rh3
	inc	r10,#1
	inc	r2,#1
	djnz	r11,L4E2E
L4E38:
	ret
L4E3A:
	push	@r15,#sign
	push	@r15,#decpt
L4E42:
	push	@r15,r11
	test	r9
	jr	ne,L4E4C
	ld	@r15,#%0006
L4E4C:
	WV %0FD4;WV %8003
	dec	r15,#8
	WV %0FFC;WV %8003
	call	_ecvt
	inc	r15,#14
	test	sign
	jr	eq,L4E68
	ldb	@r10,#%2D
	inc	r10,#1
L4E68:
	cpb	@r2,#%30
	jr	ne,L4E72
	inc	decpt,#1
L4E72:
	ldb	rh3,@r2
	ldb	@r10,rh3
	inc	r2,#1
	ldb	%0001(r10),#%2E
	inc	r10,#2
	ld	r1,r11
	dec	r1,#1
	jr	le,L4E90
L4E86:
	ldb	rh3,@r2
	ldb	@r10,rh3
	inc	r2,#1
	inc	r10,#1
	djnz	r1,L4E86
L4E90:
	ldb	@r10,#%65
	inc	r10,#1
	ld	r3,decpt
	dec	r3,#1
	jr	ge,L4EA8
	ldb	@r10,#%2D
	inc	r10,#1
	neg	r3
	jr	L4EAE
L4EA8:
	ldb	@r10,#%2B
	inc	r10,#1
L4EAE:
	xor	r2,r2
	div	rr2,#%000A
	add	r3,#%0030
	ldb	@r10,rl3
	add	r2,#%0030
	ldb	%0001(r10),rl2
	inc	r10,#2
	ret
end pscien
I
D67FA:
G
sign	L
sign:
BV %0;BV %0
D67FC:
G
decpt	L
decpt:
BV %0;BV %0
end fltpr_
