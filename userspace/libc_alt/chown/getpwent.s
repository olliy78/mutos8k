getpwent_ module
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
G	_setpwen	PR
E
_setpwen:
	call	csv
	test	D1162
	jr	ne,L018A
	push	@r15,#D1164
	push	@r15,#%1154
	call	_fopen
	inc	r15,#4
	ld	D1162,r2
	jr	L0194
L018A:
	push	@r15,D1162
	call	_rewind
	inc	r15,#2
L0194:
	jp	cret
end _setpwen
G	_endpwen	PR
E
_endpwen:
	call	csv
	test	D1162
	jr	eq,L01B0
	push	@r15,D1162
	call	_fclose
	inc	r15,#2
	clr	D1162
L01B0:
	jp	cret
L01B4:
	call	csv
	ld	r13,%0004(r14)
	jr	L01CA
L01BE:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%003A
	jr	eq,L01CE
	inc	r13,#1
L01CA:
	testb	@r13
	jr	ne,L01BE
L01CE:
	testb	@r13
	jr	eq,L01D8
	ld	r2,r13
	inc	r13,#1
	clrb	@r2
L01D8:
	ld	r2,r13
	jp	cret
end _endpwen
G	_getpwen	PR
E
_getpwen:
	call	csv
	test	D1162
	jr	ne,L0202
	push	@r15,#D1166
	push	@r15,#%1154
	call	_fopen
	inc	r15,#4
	ld	D1162,r2
	test	r2
	jr	ne,L0202
L01FE:
	xor	r2,r2
L0200:
	jr	L02A6
L0202:
	push	@r15,D1162
	push	@r15,#L0200
	push	@r15,#B19A8
	call	_fgets
	inc	r15,#6
	ld	r13,r2
	test	r13
	jr	eq,L01FE
	ld	B1BAA,r13
	push	@r15,r13
	call	L01B4
	inc	r15,#2
	ld	r13,r2
	ld	B1BAC,r13
	push	@r15,r13
	call	L01B4
	inc	r15,#2
	ld	r13,r2
	push	@r15,r13
	call	_atoi
	inc	r15,#2
	ld	B1BAE,r2
	push	@r15,r13
	call	L01B4
	inc	r15,#2
	ld	r13,r2
	push	@r15,r13
	call	_atoi
	inc	r15,#2
	ld	B1BB0,r2
	clr	B1BB2
	ld	r2,#D1160
	ld	B1BB4,r2
	push	@r15,r13
	call	L01B4
	inc	r15,#2
	ld	r13,r2
	ld	B1BB6,r13
	push	@r15,r13
	call	L01B4
	inc	r15,#2
	ld	r13,r2
	ld	B1BB8,r13
	push	@r15,r13
	call	L01B4
	inc	r15,#2
	ld	r13,r2
	ld	B1BBA,r13
	jr	L029C
L0290:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%000A
	jr	eq,L02A0
	inc	r13,#1
L029C:
	testb	@r13
	jr	ne,L0290
L02A0:
	clrb	@r13
	ld	r2,#B1BAA
L02A6:
	jp	cret
end _getpwen
$SECTION BSS_B
I
B19A8:
$REL	$+%202
B1BAA:
$REL	$+%2
B1BAC:
$REL	$+%2
B1BAE:
$REL	$+%2
B1BB0:
$REL	$+%2
B1BB2:
$REL	$+%2
B1BB4:
$REL	$+%2
B1BB6:
$REL	$+%2
B1BB8:
$REL	$+%2
B1BBA:
$REL	$+%2
$SDEFAULT
I
D1160:
BV %0;BV %0
D1162:
BV %0;BV %0
D1164:
BV %72;BV %0
D1166:
BV %72;BV %0
end getpwent_
