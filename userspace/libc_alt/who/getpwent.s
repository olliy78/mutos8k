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
	test	D1886
	jr	ne,L01C2
	push	@r15,#D1888
	push	@r15,#D1878
	call	_fopen
	inc	r15,#4
	ld	D1886,r2
	jr	L01CC
L01C2:
	push	@r15,D1886
	call	_rewind
	inc	r15,#2
L01CC:
	jp	cret
end _setpwen
G	_endpwen	PR
E
_endpwen:
	call	csv
	test	D1886
	jr	eq,L01E8
	push	@r15,D1886
	call	_fclose
	inc	r15,#2
	clr	D1886
L01E8:
	jp	cret
L01EC:
	call	csv
	ld	r13,%0004(r14)
	jr	L0202
L01F6:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%003A
	jr	eq,L0206
L0200:
	inc	r13,#1
L0202:
	testb	@r13
	jr	ne,L01F6
L0206:
	testb	@r13
	jr	eq,L0210
	ld	r2,r13
	inc	r13,#1
	clrb	@r2
L0210:
	ld	r2,r13
	jp	cret
end _endpwen
G	_getpwen	PR
E
_getpwen:
	call	csv
	test	D1886
	jr	ne,L023A
	push	@r15,#D188A
	push	@r15,#D1878
	call	_fopen
	inc	r15,#4
	ld	D1886,r2
	test	r2
	jr	ne,L023A
L0236:
	xor	r2,r2
	jr	L02DE
L023A:
	push	@r15,D1886
	push	@r15,#L0200
	push	@r15,#B1E0E
	call	_fgets
	inc	r15,#6
	ld	r13,r2
	test	r13
	jr	eq,L0236
	ld	B2010,r13
	push	@r15,r13
	call	L01EC
	inc	r15,#2
	ld	r13,r2
	ld	B2012,r13
	push	@r15,r13
	call	L01EC
	inc	r15,#2
	ld	r13,r2
	push	@r15,r13
	call	_atoi
	inc	r15,#2
	ld	B2014,r2
	push	@r15,r13
	call	L01EC
	inc	r15,#2
	ld	r13,r2
	push	@r15,r13
	call	_atoi
	inc	r15,#2
	ld	B2016,r2
	clr	B2018
	ld	r2,#D1884
	ld	B201A,r2
	push	@r15,r13
	call	L01EC
	inc	r15,#2
	ld	r13,r2
	ld	B201C,r13
	push	@r15,r13
	call	L01EC
	inc	r15,#2
	ld	r13,r2
	ld	B201E,r13
	push	@r15,r13
	call	L01EC
	inc	r15,#2
	ld	r13,r2
	ld	B2020,r13
	jr	L02D4
L02C8:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%000A
	jr	eq,L02D8
	inc	r13,#1
L02D4:
	testb	@r13
	jr	ne,L02C8
L02D8:
	clrb	@r13
	ld	r2,#B2010
L02DE:
	jp	cret
end _getpwen
$SECTION BSS_B
I
B1E0E:
$REL	$+%202
B2010:
$REL	$+%2
B2012:
$REL	$+%2
B2014:
$REL	$+%2
B2016:
$REL	$+%2
B2018:
$REL	$+%2
B201A:
$REL	$+%2
B201C:
$REL	$+%2
B201E:
$REL	$+%2
B2020:
$REL	$+%2
$SDEFAULT
I
D1878:
BV %2F;BV %65;BV %74;BV %63;BV %2F;BV %70;BV %61;BV %73
BV %73;BV %77;BV %64;BV %0
D1884:
BV %0;BV %0
D1886:
BV %0;BV %0
D1888:
BV %72;BV %0
D188A:
BV %72;BV %0
end getpwent_
