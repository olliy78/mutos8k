! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
execle_ module
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
G	_execle	PR
E
_execle:
	push	@r15,r14
	ld	r14,r15
	ld	r0,%0004(r14)
	ld	r1,r14
	inc	r1,#%6
	ld	r2,r1
	xor	r3,r3
	ld	r4,r3
	cpir	r4,@r2,r3,z
	sc	#%3B
	jp	cerror
end _execle
end execle_
