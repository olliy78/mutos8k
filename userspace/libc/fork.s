! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
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
X	cerror	PR;
G	_fork	PR
E
_fork:
	push	@r15,r14
	ld	r14,r15
	sc	#%02
	jr	$1
	jr	uge,$2
	jp	cerror
$1:
	ld	_par_uid,r4
	xor	r4,r4
$2:
	ld	r2,r4
	pop	r14,@r15
	ret
end _fork
$SECTION BSS_B
I
G
_par_uid	L
_par_uid:
I
$REL	$+%2
$SDEFAULT
end fork_
