fork_ module
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
G	_fork	PR
E
_fork:
	push	@r15,r14
	ld	r14,r15
	sc	#%02
	jr	L37A0
L379A:
	jr	uge,L37A6
	jp	cerror
L37A0:
	ld	_par_uid,r4
	xor	r4,r4
L37A6:
	ld	r2,r4
	pop	r14,@r15
	ret
end _fork
$SECTION BSS_B
I
B58F4:
G
_par_uid	L
_par_uid:
I
$REL	$+%2
$SDEFAULT
end fork_
