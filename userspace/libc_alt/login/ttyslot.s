ttyslot_ module
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
G	_ttyslot	PR
E
_ttyslot:
	call	csv
	push	@r15,#%0000
	call	_ttyname
	inc	r15,#2
	ld	r13,r2
	test	r13
	jr	ne,L1460
	push	@r15,#%0001
	call	_ttyname
	inc	r15,#2
	ld	r13,r2
	test	r13
	jr	ne,L1460
	push	@r15,#%0002
	call	_ttyname
	inc	r15,#2
	ld	r13,r2
	test	r13
	jr	ne,L1460
L145A:
	xor	r2,r2
L145C:
	jp	cret
L1460:
	push	@r15,#%002F
	push	@r15,r13
	call	_rindex
	inc	r15,#4
	ld	r12,r2
	test	r12
	jr	ne,L1476
	ld	r12,r13
	jr	L1478
L1476:
	inc	r12,#1
L1478:
	push	@r15,#%0000
	push	@r15,#D2356
	call	_open
	inc	r15,#4
	ld	r10,r2
	test	r10
	jr	mi,L145A
	xor	r11,r11
L148E:
	push	@r15,r10
	call	L14C2
	inc	r15,#2
	ld	r13,r2
	test	r2
	jr	eq,L14B8
	inc	r11,#1
	push	@r15,r13
	push	@r15,r12
	call	_strcmp
	inc	r15,#4
	test	r2
	jr	ne,L148E
	push	@r15,r10
	call	_close
	inc	r15,#2
	ld	r2,r11
	jr	L145C
L14B8:
	push	@r15,r10
	call	_close
	inc	r15,#2
	jr	L145A
L14C2:
	call	csv
	ld	r13,#B2D0E
L14CA:
	push	@r15,#%0001
	push	@r15,r13
	push	@r15,%0004(r14)
	call	_read
	inc	r15,#6
	cp	r2,#%0001
	jr	eq,L14EE
	xor	r2,r2
L14E2:
	jp	cret
L14E6:
	clrb	@r13
L14E8:
	ld	r2,#B2D10
	jr	L14E2
L14EE:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%000A
	jr	eq,L14E6
	cp	r13,#B2D2E
	jr	uge,L14E8
	inc	r13,#1
	jr	L14CA
end _ttyslot
$SECTION BSS_B
I
B2D0E:
$REL	$+%2
B2D10:
$REL	$+%1E
B2D2E:
$SDEFAULT
I
D2356:
BV %2F;BV %65;BV %74;BV %63;BV %2F;BV %74;BV %74;BV %79
BV %73;BV %0
end ttyslot_
