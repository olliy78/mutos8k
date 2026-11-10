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
	jr	eq,L0EEE
	push	@r15,#%03E8
	call	_alarm
	inc	r15,#2
	ld	r13,r2
	push	@r15,#B1A9E
	call	_setjmp
	inc	r15,#2
	test	r2
	jr	eq,L0EF2
	push	@r15,r12
	push	@r15,#%000E
	call	_signal
	inc	r15,#4
	push	@r15,r13
	call	_alarm
	inc	r15,#2
L0EEE:
	jp	cret
L0EF2:
	test	r13
	jr	eq,L0F08
	cp	r13,%0004(r14)
	jr	ule,L0F02
	sub	r13,%0004(r14)
	jr	L0F08
L0F02:
	ld	%0004(r14),r13
	ldk	r13,#1
L0F08:
	push	@r15,#L0F28
	push	@r15,#%000E
	call	_signal
	inc	r15,#4
	ld	r12,r2
	push	@r15,%0004(r14)
	call	_alarm
	inc	r15,#2
L0F22:
	call	_pause
	jr	L0F22
L0F28:
	call	csv
	push	@r15,#%0001
	push	@r15,#B1A9E
	call	_longjmp
	inc	r15,#4
	jp	cret
end _sleep
$SECTION BSS_B
I
B1A9E:
$REL	$+%6
$SDEFAULT
end sleep_
