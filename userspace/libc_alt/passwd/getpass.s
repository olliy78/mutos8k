getpass_ module
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
G	_getpass	PR
E
_getpass:
	call	csv
	dec	r15,#12
	push	@r15,#D1F3B
	push	@r15,#D1F32
	call	_fopen
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	ne,L04E8
	ld	r11,#__iob
	jr	L04F4
L04E8:
	push	@r15,#%0000
	push	@r15,r11
	call	_setbuf
	inc	r15,#4
L04F4:
	push	@r15,#%0001
	push	@r15,#%0002
	call	_signal
	inc	r15,#4
	ld	r9,r2
	ld	r2,r14
	add	r2,#%FFE8
	push	@r15,r2
	ldb	rl0,%0007(r11)
	xorb	rh0,rh0
	push	@r15,r0
	call	_gtty
	inc	r15,#4
	ld	r10,%FFEC(r14)
	res	%FFEC(r14),#3
	ld	r2,r14
	add	r2,#%FFE8
	push	@r15,r2
	ldb	rl0,%0007(r11)
	xorb	rh0,rh0
	push	@r15,r0
	call	_stty
	inc	r15,#4
	push	@r15,%0004(r14)
	push	@r15,#%10+__iob
	call	_fprintf
	inc	r15,#4
	ld	r13,#B29B4
L054A:
	bitb	%0006(r11),#1
	jr	ne,L0568
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0568
	ld	r2,@r11
	inc	@r11,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L0576
L0568:
	push	@r15,r2
	push	@r15,r11
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L0576:
	ld	r2,r3
	ld	r12,r2
	cp	r12,#%000A
	jr	eq,L0596
	cp	r12,#%FFFF
	jr	eq,L0596
	cp	r13,#B29BC
	jr	uge,L054A
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	ldb	@r2,rl3
	jr	L054A
L0596:
	clrb	@r13
	push	@r15,#D1F3D
	push	@r15,#%10+__iob
	call	_fprintf
	inc	r15,#4
	ld	%FFEC(r14),r10
	ld	r2,r14
	add	r2,#%FFE8
	push	@r15,r2
	ldb	rl0,%0007(r11)
	xorb	rh0,rh0
	push	@r15,r0
	call	_stty
	inc	r15,#4
	push	@r15,r9
	push	@r15,#%0002
	call	_signal
	inc	r15,#4
	cp	r11,#__iob
	jr	eq,L05DA
	push	@r15,r11
	call	_fclose
	inc	r15,#2
L05DA:
	ld	r2,#B29B4
	jp	cret
end _getpass
$SECTION BSS_B
I
B29B4:
$REL	$+%8
B29BC:
$REL	$+%2
$SDEFAULT
I
D1F32:
BV %2F;BV %64;BV %65;BV %76;BV %2F;BV %74;BV %74;BV %79
BV %0
D1F3B:
BV %72;BV %0
D1F3D:
BV %A;BV %0;BV %0
end getpass_
