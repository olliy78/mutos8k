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
	test	B13C6
	jr	ne,L09A0
	ld	r2,#B13C8
	set	r2,#0
	ld	B13C6,r2
	ld	r2,#B13C6
	set	r2,#0
	ld	B13C8,r2
	ld	r2,#B13C8
	ld	B13CC,r2
	ld	r2,#B13C6
	ld	B13CA,r2
L09A0:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B13CA
L09B4:
	clr	B13D0
L09B8:
	bit	@r13,#0
	jr	ne,L09E2
	jr	L09C2
L09BE:
	ld	r2,@r12
	ld	@r13,r2
L09C2:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L09BE
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L09E2
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0A98
L09E2:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L09B8
	cp	r12,B13CC
	jr	ne,L09F8
	cp	r13,#B13C6
	jr	eq,L09FE
L09F8:
	xor	r2,r2
L09FA:
	jp	cret
L09FE:
	inc	B13D0,#1
	ld	r0,B13D0
	cp	r0,#%0001
	jr	le,L09B8
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B13D0,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B13D0
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L09F8
	ld	r2,B13D0
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L09F8
	ld	r2,B13CC
	ld	@r2,r12
	ld	r2,B13CC
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0A78
	ld	r2,B13CC
	ld	r3,B13CC
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0A78:
	ld	r2,B13D0
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B13CC,r2
	ld	r2,B13CC
	ld	r3,#B13C6
	set	r3,#0
	ld	@r2,r3
	jr	L09B4
L0A98:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B13CA,r2
	cp	r12,r2
	jr	ule,L0AB2
	ld	r3,@r2
	ld	B13CE,r3
	ld	r3,@r13
	ld	@r2,r3
L0AB2:
	ld	r2,B13CA
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L09FA
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B13CA,r12
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
	jr	eq,L0AF0
	push	@r15,r13
	call	_free
	inc	r15,#2
L0AF0:
	ld	r3,%FFFE(r13)
	sub	r3,r13
	exts	rr2
	div	rr2,#%0002
	ld	r2,r3
	ld	r10,r2
L0B00:
	push	@r15,%0006(r14)
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	test	r12
	jr	eq,L0B14
	cp	r12,r13
	jr	ne,L0B1A
L0B14:
	ld	r2,r12
	jp	cret
L0B1A:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0B42
	ld	r10,r11
	jr	L0B42
L0B36:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0B42:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0B36
	cp	r12,r13
	jr	uge,L0B14
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0B14
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
	ld	r3,B13CE
	ld	@r2,r3
	jr	L0B14
end _realloc
$SECTION BSS_B
I
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
B13D0:
$REL	$+%2
$SDEFAULT
end malloc_
