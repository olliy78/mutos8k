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
	jr	ne,L1200
	push	@r15,#%0001
	call	_ttyname
	inc	r15,#2
	ld	r13,r2
	test	r13
	jr	ne,L1200
	push	@r15,#%0002
	call	_ttyname
	inc	r15,#2
	ld	r13,r2
	test	r13
	jr	ne,L1200
L11FA:
	xor	r2,r2
L11FC:
	jp	cret
L1200:
	push	@r15,#%002F
	push	@r15,r13
	call	_rindex
	inc	r15,#4
	ld	r12,r2
	test	r12
	jr	ne,L1216
	ld	r12,r13
	jr	L1218
L1216:
	inc	r12,#1
L1218:
	push	@r15,#%0000
	push	@r15,#D204A
	call	_open
	inc	r15,#4
	ld	r10,r2
	test	r10
	jr	mi,L11FA
	xor	r11,r11
L122E:
	push	@r15,r10
	call	L1262
	inc	r15,#2
	ld	r13,r2
	test	r2
	jr	eq,L1258
	inc	r11,#1
	push	@r15,r13
	push	@r15,r12
	call	_strcmp
	inc	r15,#4
	test	r2
	jr	ne,L122E
	push	@r15,r10
	call	_close
	inc	r15,#2
	ld	r2,r11
	jr	L11FC
L1258:
	push	@r15,r10
	call	_close
	inc	r15,#2
	jr	L11FA
L1262:
	call	csv
	ld	r13,#B2BFA
L126A:
	push	@r15,#%0001
	push	@r15,r13
	push	@r15,%0004(r14)
	call	_read
	inc	r15,#6
	cp	r2,#%0001
	jr	eq,L128E
	xor	r2,r2
L1282:
	jp	cret
L1286:
	clrb	@r13
L1288:
	ld	r2,#B2BFC
	jr	L1282
L128E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%000A
	jr	eq,L1286
	cp	r13,#B2C1A
	jr	uge,L1288
	inc	r13,#1
	jr	L126A
end _ttyslot
$SECTION BSS_B
I
B2BFA:
$REL	$+%2
B2BFC:
$REL	$+%1E
B2C1A:
$SDEFAULT
I
D204A:
BV %2F;BV %65;BV %74;BV %63;BV %2F;BV %74;BV %74;BV %79
BV %73;BV %0
end ttyslot_
