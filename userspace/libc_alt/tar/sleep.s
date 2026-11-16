sleep_ module
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
G	_sleep	PR
E
_sleep:
	call	csv
	xor	r12,r12
	test	%0004(r14)
	jr	eq,L2DB8
	push	@r15,#%03E8
	call	_alarm
	inc	r15,#2
	ld	r13,r2
	push	@r15,#B58B6
	call	_setjmp
	inc	r15,#2
	test	r2
	jr	eq,L2DBC
	push	@r15,r12
	push	@r15,#%000E
	call	_signal
	inc	r15,#2
	ld	@r15,r13
	call	_alarm
	inc	r15,#2
L2DB8:
	jp	cret
L2DBC:
	test	r13
	jr	eq,L2DD2
	cp	r13,%0004(r14)
	jr	ule,L2DCC
	sub	r13,%0004(r14)
	jr	L2DD2
L2DCC:
	ld	%0004(r14),r13
	ldk	r13,#1
L2DD2:
	push	@r15,#L2DF2
	push	@r15,#%000E
	call	_signal
	inc	r15,#4
	ld	r12,r2
	push	@r15,%0004(r14)
	call	_alarm
	inc	r15,#2
L2DEC:
	call	_pause
	jr	L2DEC
L2DF2:
	call	csv
	push	@r15,#%0001
	push	@r15,#B58B6
	call	_longjmp
	inc	r15,#4
	jp	cret
end _sleep
$SECTION BSS_B
I
B58B6:
$REL	$+%6
$SDEFAULT
end sleep_
