! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
chown_ module
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
G	_chown	PR
E
_chown:
	push	@r15,r14
	ld	r14,r15
	ldm	r0,%0004(r14),#3
	sc	#%10
	jp	ult,cerror
	xor	r2,r2
	pop	r14,@r15
	ret
end _chown
end chown_
