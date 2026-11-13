getlogin_ module
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
G	_getlogi	PR
E
_getlogi:
	call	csv
	call	_ttyslot
	ld	r13,r2
	test	r2
	jr	eq,L1194
	push	@r15,#%0000
	push	@r15,#D2040
	call	_open
	inc	r15,#4
	ld	r12,r2
	test	r12
	jr	mi,L1194
	push	@r15,#%0000
	ld	r3,r13
	mult	rr2,#%0014
	push	@r15,r3
	push	@r15,#%0000
	push	@r15,r12
	call	_lseek
	inc	r15,#8
	push	@r15,#%0014
	push	@r15,#B2BE6
	push	@r15,r12
	call	_read
	inc	r15,#6
	cp	r2,#%0014
	jr	eq,L119A
L1194:
	xor	r2,r2
L1196:
	jp	cret
L119A:
	push	@r15,r12
	call	_close
	inc	r15,#2
	ldb	B2BF6,#%20
	ld	r11,#B2BEE
L11AC:
	ld	r2,r11
	inc	r11,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0020
	jr	ne,L11AC
	dec	r11,#1
	ld	r2,r11
	clrb	@r2
	ld	r2,#B2BEE
	jr	L1196
end _getlogi
$SECTION BSS_B
I
B2BE6:
$REL	$+%8
B2BEE:
$REL	$+%8
B2BF6:
$REL	$+%4
$SDEFAULT
I
D2040:
BV %2F;BV %65;BV %74;BV %63;BV %2F;BV %75;BV %74;BV %6D
BV %70;BV %0
end getlogin_
