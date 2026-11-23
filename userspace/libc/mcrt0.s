! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
mcrt0_s module
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
G	_exit	L
X	_main	PR;
X	_monitor	PR;
X	_sbrk	PR;
X	_etext	PR;
X	__cleanu	PR;
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
	ld	r1,#_etext
	sub	r1,#eprolog
	inc	r1,#%7
	srl	r1,#%3
	push	@r15,#%12C
	add	r1,#%387
	push	@r15,r1
	sla	r1,#%1
	push	@r15,r1
	call	_sbrk
	inc	r15,#%2
	cp	r2,#%FFFF
	jr	z,$2
	push	@r15,r2
	inc	r2,#%6
	ld	countbas,r2
	push	@r15,#_etext
	push	@r15,#eprolog
	call	_monitor
	inc	r15,#%A
	call	_main
	inc	r15,#%4
	ld	@r15,r2
	call	_exit
$2:
	ldk	r0,#%2
	ld	r1,#text
	ld	r2,#%1C
	sc	#%4
_exit:
	push	@r15,r14
	ld	r14,r15
	call	__cleanu
	push	@r15,#%0
	call	_monitor
	inc	r15,#%2
	ld	r0,%4(r14)
	sc	#%1
eprolog:
end start
$SECTION BSS_B
I
G
_environ	L
_environ:
$REL	$+%2
G
countbas	L
countbas:
I
$REL	$+%2
$SDEFAULT
$SECTION mcrt0_s_d
I
WV	%0
text:
BV	%4E;BV	%6F;BV	%20;BV	%73;BV	%70;BV	%61;BV	%63;BV	%65;BV	%20;BV	%66;BV	%6F;BV	%72;BV	%20;BV	%6D;BV	%6F;BV	%6E;BV	%69;BV	%74;BV	%6F;BV	%72;BV	%20;BV	%62;BV	%75;BV	%66;BV	%66;BV	%65;BV	%72;BV	%A
end mcrt0_s
