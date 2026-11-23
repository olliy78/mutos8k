! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
sbrk_ module
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
X	_end	PR;
G	_sbrk	PR
E
_sbrk:
	push	@r15,r14
	ld	r14,r15
	ld	r0,%0004(r14)
	ld	r1,nd
	or	r0,r0
	jp	eq,$1
	add	r0,r1
	sc	#%11
	jp	ult,cerror
	ld	nd,r0
$1:
	ld	r2,r1
	pop	r14,@r15
	ret
end _sbrk
G	_brk	PR
E
_brk:
	push	@r15,r14
	ld	r14,r15
	ld	r0,%0004(r14)
	sc	#%11
	jp	ult,cerror
	ld	nd,r0
	xor	r2,r2
	pop	r14,@r15
	ret
end _brk
I
nd:
WV _end
end sbrk_
