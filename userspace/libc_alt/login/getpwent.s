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
	test	D2244
	jr	ne,L065E
	push	@r15,#D2246
	push	@r15,#D2236
	call	_fopen
	inc	r15,#4
	ld	D2244,r2
	jr	L0668
L065E:
	push	@r15,D2244
	call	_rewind
	inc	r15,#2
L0668:
	jp	cret
end _setpwen
G	_endpwen	PR
E
_endpwen:
	call	csv
	test	D2244
	jr	eq,L0684
	push	@r15,D2244
	call	_fclose
	inc	r15,#2
	clr	D2244
L0684:
	jp	cret
L0688:
	call	csv
	ld	r13,%0004(r14)
	jr	L069E
L0692:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%003A
	jr	eq,L06A2
	inc	r13,#1
L069E:
	testb	@r13
	jr	ne,L0692
L06A2:
	testb	@r13
	jr	eq,L06AC
	ld	r2,r13
	inc	r13,#1
	clrb	@r2
L06AC:
	ld	r2,r13
	jp	cret
end _endpwen
G	_getpwen	PR
E
_getpwen:
	call	csv
	test	D2244
	jr	ne,L06D6
	push	@r15,#D2248
	push	@r15,#D2236
	call	_fopen
	inc	r15,#4
	ld	D2244,r2
	test	r2
	jr	ne,L06D6
L06D2:
	xor	r2,r2
	jr	L077A
L06D6:
	push	@r15,D2244
	push	@r15,#%0200
	push	@r15,#B2AE0
	call	_fgets
	inc	r15,#6
	ld	r13,r2
	test	r13
	jr	eq,L06D2
	ld	B2CE2,r13
	push	@r15,r13
	call	L0688
	inc	r15,#2
	ld	r13,r2
	ld	B2CE4,r13
	push	@r15,r13
	call	L0688
	inc	r15,#2
	ld	r13,r2
	push	@r15,r13
	call	_atoi
	inc	r15,#2
	ld	B2CE6,r2
	push	@r15,r13
	call	L0688
	inc	r15,#2
	ld	r13,r2
	push	@r15,r13
	call	_atoi
	inc	r15,#2
	ld	B2CE8,r2
	clr	B2CEA
	ld	r2,#D2242
	ld	B2CEC,r2
	push	@r15,r13
	call	L0688
	inc	r15,#2
	ld	r13,r2
	ld	B2CEE,r13
	push	@r15,r13
	call	L0688
	inc	r15,#2
	ld	r13,r2
	ld	B2CF0,r13
	push	@r15,r13
	call	L0688
	inc	r15,#2
	ld	r13,r2
	ld	B2CF2,r13
	jr	L0770
L0764:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%000A
	jr	eq,L0774
	inc	r13,#1
L0770:
	testb	@r13
	jr	ne,L0764
L0774:
	clrb	@r13
	ld	r2,#B2CE2
L077A:
	jp	cret
end _getpwen
$SECTION BSS_B
I
B2AE0:
$REL	$+%202
B2CE2:
$REL	$+%2
B2CE4:
$REL	$+%2
B2CE6:
$REL	$+%2
B2CE8:
$REL	$+%2
B2CEA:
$REL	$+%2
B2CEC:
$REL	$+%2
B2CEE:
$REL	$+%2
B2CF0:
$REL	$+%2
B2CF2:
$REL	$+%2
$SDEFAULT
I
D2236:
BV %2F;BV %65;BV %74;BV %63;BV %2F;BV %70;BV %61;BV %73
BV %73;BV %77;BV %64;BV %0
D2242:
BV %0;BV %0
D2244:
BV %0;BV %0
D2246:
BV %72;BV %0
D2248:
BV %72;BV %0
end getpwent_
