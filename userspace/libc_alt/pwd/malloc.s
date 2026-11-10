malloc_ module
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
G	_malloc	PR
E
_malloc:
	call	csv
	test	B13C4
	jr	ne,L08E0
	ld	r2,#B13C6
	set	r2,#0
	ld	B13C4,r2
	ld	r2,#B13C4
	set	r2,#0
	ld	B13C6,r2
	ld	r2,#B13C6
	ld	B13CA,r2
	ld	r2,#B13C4
	ld	B13C8,r2
L08E0:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B13C8
L08F4:
	clr	B13CE
L08F8:
	bit	@r13,#0
	jr	ne,L0922
	jr	L0902
L08FE:
	ld	r2,@r12
	ld	@r13,r2
L0902:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L08FE
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0922
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L09D8
L0922:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L08F8
	cp	r12,B13CA
	jr	ne,L0938
	cp	r13,#B13C4
	jr	eq,L093E
L0938:
	xor	r2,r2
L093A:
	jp	cret
L093E:
	inc	B13CE,#1
	ld	r0,B13CE
	cp	r0,#%0001
	jr	le,L08F8
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B13CE,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B13CE
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0938
	ld	r2,B13CE
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0938
	ld	r2,B13CA
	ld	@r2,r12
	ld	r2,B13CA
	inc	r2,#2
	cp	r2,r12
	jr	eq,L09B8
	ld	r2,B13CA
	ld	r3,B13CA
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L09B8:
	ld	r2,B13CE
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B13CA,r2
	ld	r2,B13CA
	ld	r3,#B13C4
	set	r3,#0
	ld	@r2,r3
	jr	L08F4
L09D8:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B13C8,r2
	cp	r12,r2
	jr	ule,L09F2
	ld	r3,@r2
	ld	B13CC,r3
	ld	r3,@r13
	ld	@r2,r3
L09F2:
	ld	r2,B13C8
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L093A
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B13C8,r12
	ld	r2,@r12
	res	r2,#0
	ld	@r12,r2
	jp	cret
end _free
G	_realloc	PR
E
_realloc:
	call	csv
	ld	r13,%0004(r14)
	bit	%FFFE(r13),#0
	jr	eq,L0A30
	push	@r15,r13
	call	_free
	inc	r15,#2
L0A30:
	ld	r3,%FFFE(r13)
	sub	r3,r13
	exts	rr2
	div	rr2,#%0002
	ld	r2,r3
	ld	r10,r2
	push	@r15,%0006(r14)
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	test	r12
	jr	eq,L0A54
	cp	r12,r13
	jr	ne,L0A5A
L0A54:
	ld	r2,r12
	jp	cret
L0A5A:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0A82
	ld	r10,r11
	jr	L0A82
L0A76:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0A82:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0A76
	cp	r12,r13
	jr	uge,L0A54
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0A54
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	sub	r2,r13
	ld	r3,r2
	exts	rr2
	div	rr2,#%0002
	ld	r2,r3
	sla	r2,#1
	add	r2,r12
	ld	r3,B13CC
	ld	@r2,r3
	jr	L0A54
end _realloc
$SECTION BSS_B
I
B13C4:
$REL	$+%2
B13C6:
$REL	$+%2
B13C8:
$REL	$+%2
B13CA:
$REL	$+%2
B13CC:
$REL	$+%2
B13CE:
$REL	$+%2
$SDEFAULT
end malloc_
