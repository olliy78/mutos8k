! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
crt0_s module
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
X	_exit	PR;
X	_main	PR;
G	start	PR
E
start:
	ld	r6,@r15
	ld	r7,r15
	inc	r7,#%2
	ld	r2,@r7
	clr	-%2(r2)
	pushl	@r15,rr6
	subl	rr0,rr0
	cpir	r0,@r7,r1,z
	cp	r7,r2
	jr	nz,$1
	dec	r7,#%2
$1:
	ld	%4(r15),r7
	ld	_environ,r7
	call	_main
	inc	r15,#%4
	ld	@r15,r2
	call	_exit
	sc	#%1
end start
$SECTION BSS_B
I
G
_environ	L
_environ:
I
$REL	$+%2
$SDEFAULT
$SECTION crt0_s_d
I
WV	%0
end crt0_s
