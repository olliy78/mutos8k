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
	jr	eq,L13D6
	push	@r15,#%03E8
	call	_alarm
	inc	r15,#2
	ld	r13,r2
	push	@r15,#B2D08
	call	_setjmp
	inc	r15,#2
	test	r2
	jr	eq,L13DA
	push	@r15,r12
	push	@r15,#%000E
	call	_signal
	inc	r15,#4
	push	@r15,r13
	call	_alarm
	inc	r15,#2
L13D6:
	jp	cret
L13DA:
	test	r13
	jr	eq,L13F0
	cp	r13,%0004(r14)
	jr	ule,L13EA
	sub	r13,%0004(r14)
	jr	L13F0
L13EA:
	ld	%0004(r14),r13
	ldk	r13,#1
L13F0:
	push	@r15,#L1410
	push	@r15,#%000E
	call	_signal
	inc	r15,#4
	ld	r12,r2
	push	@r15,%0004(r14)
	call	_alarm
	inc	r15,#2
L140A:
	call	_pause
	jr	L140A
L1410:
	call	csv
	push	@r15,#%0001
	push	@r15,#B2D08
	call	_longjmp
	inc	r15,#4
	jp	cret
end _sleep
$SECTION BSS_B
I
B2D08:
$REL	$+%6
$SDEFAULT
end sleep_
