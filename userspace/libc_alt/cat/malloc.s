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
	test	B15FE
	jr	ne,L0B7C
	ld	r2,#B1600
	set	r2,#0
	ld	B15FE,r2
	ld	r2,#B15FE
	set	r2,#0
	ld	B1600,r2
	ld	r2,#B1600
	ld	B1604,r2
	ld	r2,#B15FE
	ld	B1602,r2
L0B7C:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1602
L0B90:
	clr	B1608
L0B94:
	bit	@r13,#0
	jr	ne,L0BBE
	jr	L0B9E
L0B9A:
	ld	r2,@r12
	ld	@r13,r2
L0B9E:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0B9A
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0BBE
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0C74
L0BBE:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0B94
	cp	r12,B1604
	jr	ne,L0BD4
	cp	r13,#B15FE
	jr	eq,L0BDA
L0BD4:
	xor	r2,r2
L0BD6:
	jp	cret
L0BDA:
	inc	B1608,#1
	ld	r0,B1608
	cp	r0,#%0001
	jr	le,L0B94
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1608,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1608
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0BD4
	ld	r2,B1608
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0BD4
	ld	r2,B1604
	ld	@r2,r12
	ld	r2,B1604
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0C54
	ld	r2,B1604
	ld	r3,B1604
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0C54:
	ld	r2,B1608
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1604,r2
	ld	r2,B1604
	ld	r3,#B15FE
	set	r3,#0
	ld	@r2,r3
	jr	L0B90
L0C74:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1602,r2
	cp	r12,r2
	jr	ule,L0C8E
	ld	r3,@r2
	ld	B1606,r3
	ld	r3,@r13
	ld	@r2,r3
L0C8E:
	ld	r2,B1602
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0BD6
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1602,r12
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
	jr	eq,L0CCC
	push	@r15,r13
	call	_free
	inc	r15,#2
L0CCC:
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
	jr	eq,L0CF0
	cp	r12,r13
	jr	ne,L0CF6
L0CF0:
	ld	r2,r12
	jp	cret
L0CF6:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0D1E
	ld	r10,r11
	jr	L0D1E
L0D12:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0D1E:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0D12
	cp	r12,r13
	jr	uge,L0CF0
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0CF0
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
	ld	r3,B1606
	ld	@r2,r3
	jr	L0CF0
end _realloc
$SECTION BSS_B
I
B15FE:
$REL	$+%2
B1600:
$REL	$+%2
B1602:
$REL	$+%2
B1604:
$REL	$+%2
B1606:
$REL	$+%2
B1608:
$REL	$+%2
$SDEFAULT
end malloc_
