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
	test	B5810
	jr	ne,L1514
	ld	r2,#B5812
	set	r2,#0
	ld	B5810,r2
	ld	r2,#B5810
	set	r2,#0
	ld	B5812,r2
	ld	r2,#B5812
	ld	B5816,r2
	ld	r2,#B5810
	ld	B5814,r2
L1514:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B5814
L1528:
	clr	B581A
L152C:
	bit	@r13,#0
	jr	ne,L1556
	jr	L1536
L1532:
	ld	r2,@r12
	ld	@r13,r2
L1536:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L1532
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L1556
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L1608
L1556:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L152C
	cp	r12,B5816
	jr	ne,L156C
	cp	r13,#B5810
	jr	eq,L1572
L156C:
	xor	r2,r2
L156E:
	jp	cret
L1572:
	inc	B581A,#1
	cp	B581A,#%0001
	jr	le,L152C
	ld	r3,r11
	add	r3,#%0200
	exts	rr2
	div	rr2,#%0200
	ld	r2,r3
	sla	r2,#9
	ld	B581A,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B581A
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L156C
	ld	r2,B581A
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L156C
	ld	r2,B5816
	ld	@r2,r12
	ld	r2,B5816
	inc	r2,#2
	cp	r2,r12
	jr	eq,L15E8
	ld	r2,B5816
	ld	r3,r2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r4
L15E8:
	ld	r2,B581A
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B5816,r2
	ld	r2,B5816
	ld	r3,#B5810
	set	r3,#0
	ld	@r2,r3
	jr	L1528
L1608:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B5814,r2
	cp	r12,r2
	jr	ule,L1622
	ld	r3,@r2
	ld	B5818,r3
	ld	r3,@r13
	ld	@r2,r3
L1622:
	ld	r2,B5814
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L156E
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B5814,r12
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
	jr	eq,L1660
	push	@r15,r13
	call	_free
	inc	r15,#2
L1660:
	ld	r3,%FFFE(r13)
	sub	r3,r13
	exts	rr2
	div	rr2,#%0002
	ld	r10,r3
	push	@r15,%0006(r14)
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	test	r12
	jr	eq,L1682
	cp	r12,r13
	jr	ne,L1688
L1682:
	ld	r2,r12
	jp	cret
L1688:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L16B0
	ld	r10,r11
	jr	L16B0
L16A4:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L16B0:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L16A4
	cp	r12,r13
	jr	uge,L1682
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L1682
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
	ld	r3,B5818
	ld	@r2,r3
	jr	L1682
end _realloc
$SECTION BSS_B
I
B5810:
$REL	$+%2
B5812:
$REL	$+%2
B5814:
$REL	$+%2
B5816:
$REL	$+%2
B5818:
$REL	$+%2
B581A:
$REL	$+%2
$SDEFAULT
end malloc_
