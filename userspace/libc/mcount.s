! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
mcount_ module
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
G	mcount	PR
E
mcount:
	ld	r1,@r2
	test	r1
	jr	nz,$1
	ld	r1,countbas
	test	r1
	ret	z
	inc	countbas,#%6
	ld	r0,@r15
	ld	@r1,r0
	inc	r1,#%2
	ld	@r2,r1
$1:
	inc	%0002(r1),#%1
	ret	nz
	inc	@r1,#%1
	ret
end mcount
$SECTION BSS_B
I
G
countbas	L
countbas:
I
$REL	$+%2
$SDEFAULT
end mcount_
