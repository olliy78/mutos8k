! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
cuexit_ module
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
X	__cleanu	PR;
G	_exit	PR
E
_exit:
	push	@r15,r14
	ld	r14,r15
	call	__cleanu
	ld	r0,%0004(r14)
	sc	#%01
end _exit
end cuexit_
