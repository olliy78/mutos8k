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
	jr	L1040
L103A:
	jr	uge,L1046
	jp	cerror
L1040:
	ld	_par_uid,r4
	xor	r4,r4
L1046:
	ld	r2,r4
	pop	r14,@r15
	ret
end _fork
$SECTION BSS_B
I
B1C5A:
G
_par_uid	L
_par_uid:
I
$REL	$+%2
$SDEFAULT
end fork_
