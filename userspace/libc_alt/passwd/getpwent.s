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
	test	D1F4E
	jr	ne,L0600
	push	@r15,#D1F50
	push	@r15,#D1F40
	call	_fopen
	inc	r15,#4
	ld	D1F4E,r2
	jr	L060A
L0600:
	push	@r15,D1F4E
	call	_rewind
	inc	r15,#2
L060A:
	jp	cret
end _setpwen
G	_endpwen	PR
E
_endpwen:
	call	csv
	test	D1F4E
	jr	eq,L0626
	push	@r15,D1F4E
	call	_fclose
	inc	r15,#2
	clr	D1F4E
L0626:
	jp	cret
L062A:
	call	csv
	ld	r13,%0004(r14)
	jr	L0640
L0634:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%003A
	jr	eq,L0644
	inc	r13,#1
L0640:
	testb	@r13
	jr	ne,L0634
L0644:
	testb	@r13
	jr	eq,L064E
	ld	r2,r13
	inc	r13,#1
	clrb	@r2
L064E:
	ld	r2,r13
	jp	cret
end _endpwen
G	_getpwen	PR
E
_getpwen:
	call	csv
	test	D1F4E
	jr	ne,L0678
	push	@r15,#D1F52
	push	@r15,#D1F40
	call	_fopen
	inc	r15,#4
	ld	D1F4E,r2
	test	r2
	jr	ne,L0678
L0674:
	xor	r2,r2
	jr	L071C
L0678:
	push	@r15,D1F4E
	push	@r15,#%0200
	push	@r15,#B29BE
	call	_fgets
	inc	r15,#6
	ld	r13,r2
	test	r13
	jr	eq,L0674
	ld	B2BC0,r13
	push	@r15,r13
	call	L062A
	inc	r15,#2
	ld	r13,r2
	ld	B2BC2,r13
	push	@r15,r13
	call	L062A
	inc	r15,#2
	ld	r13,r2
	push	@r15,r13
	call	_atoi
	inc	r15,#2
	ld	B2BC4,r2
	push	@r15,r13
	call	L062A
	inc	r15,#2
	ld	r13,r2
	push	@r15,r13
	call	_atoi
	inc	r15,#2
	ld	B2BC6,r2
	clr	B2BC8
	ld	r2,#D1F4C
	ld	B2BCA,r2
	push	@r15,r13
	call	L062A
	inc	r15,#2
	ld	r13,r2
	ld	B2BCC,r13
	push	@r15,r13
	call	L062A
	inc	r15,#2
	ld	r13,r2
	ld	B2BCE,r13
	push	@r15,r13
	call	L062A
	inc	r15,#2
	ld	r13,r2
	ld	B2BD0,r13
	jr	L0712
L0706:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%000A
	jr	eq,L0716
	inc	r13,#1
L0712:
	testb	@r13
	jr	ne,L0706
L0716:
	clrb	@r13
	ld	r2,#B2BC0
L071C:
	jp	cret
end _getpwen
$SECTION BSS_B
I
B29BE:
$REL	$+%202
B2BC0:
$REL	$+%2
B2BC2:
$REL	$+%2
B2BC4:
$REL	$+%2
B2BC6:
$REL	$+%2
B2BC8:
$REL	$+%2
B2BCA:
$REL	$+%2
B2BCC:
$REL	$+%2
B2BCE:
$REL	$+%2
B2BD0:
$REL	$+%2
$SDEFAULT
I
D1F40:
BV %2F;BV %65;BV %74;BV %63;BV %2F;BV %70;BV %61;BV %73
BV %73;BV %77;BV %64;BV %0
D1F4C:
BV %0;BV %0
D1F4E:
BV %0;BV %0
D1F50:
BV %72;BV %0
D1F52:
BV %72;BV %0
end getpwent_
