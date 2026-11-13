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
	test	B156C
	jr	ne,L0C30
	ld	r2,#B156E
	set	r2,#0
	ld	B156C,r2
	ld	r2,#B156C
	set	r2,#0
	ld	B156E,r2
	ld	r2,#B156E
	ld	B1572,r2
	ld	r2,#B156C
	ld	B1570,r2
L0C30:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1570
L0C44:
	clr	B1576
L0C48:
	bit	@r13,#0
	jr	ne,L0C72
	jr	L0C52
L0C4E:
	ld	r2,@r12
	ld	@r13,r2
L0C52:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0C4E
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0C72
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0D28
L0C72:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0C48
	cp	r12,B1572
	jr	ne,L0C88
	cp	r13,#B156C
	jr	eq,L0C8E
L0C88:
	xor	r2,r2
L0C8A:
	jp	cret
L0C8E:
	inc	B1576,#1
	ld	r0,B1576
	cp	r0,#%0001
	jr	le,L0C48
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1576,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1576
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0C88
	ld	r2,B1576
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0C88
	ld	r2,B1572
	ld	@r2,r12
	ld	r2,B1572
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0D08
	ld	r2,B1572
	ld	r3,B1572
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0D08:
	ld	r2,B1576
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1572,r2
	ld	r2,B1572
	ld	r3,#B156C
	set	r3,#0
	ld	@r2,r3
	jr	L0C44
L0D28:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1570,r2
	cp	r12,r2
	jr	ule,L0D42
	ld	r3,@r2
	ld	B1574,r3
	ld	r3,@r13
	ld	@r2,r3
L0D42:
	ld	r2,B1570
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0C8A
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1570,r12
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
	jr	eq,L0D80
	push	@r15,r13
	call	_free
	inc	r15,#2
L0D80:
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
	jr	eq,L0DA4
	cp	r12,r13
	jr	ne,L0DAA
L0DA4:
	ld	r2,r12
	jp	cret
L0DAA:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0DD2
	ld	r10,r11
	jr	L0DD2
L0DC6:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0DD2:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0DC6
	cp	r12,r13
	jr	uge,L0DA4
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0DA4
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
	ld	r3,B1574
	ld	@r2,r3
	jr	L0DA4
end _realloc
$SECTION BSS_B
I
B156C:
$REL	$+%2
B156E:
$REL	$+%2
B1570:
$REL	$+%2
B1572:
$REL	$+%2
B1574:
$REL	$+%2
B1576:
$REL	$+%2
$SDEFAULT
end malloc_
