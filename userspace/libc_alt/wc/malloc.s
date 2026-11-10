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
	test	B143A
	jr	ne,L0BC8
	ld	r2,#B143C
	set	r2,#0
	ld	B143A,r2
	ld	r2,#B143A
	set	r2,#0
	ld	B143C,r2
	ld	r2,#B143C
	ld	B1440,r2
	ld	r2,#B143A
	ld	B143E,r2
L0BC8:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B143E
L0BDC:
	clr	B1444
L0BE0:
	bit	@r13,#0
	jr	ne,L0C0A
	jr	L0BEA
L0BE6:
	ld	r2,@r12
	ld	@r13,r2
L0BEA:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0BE6
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0C0A
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0CC0
L0C0A:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0BE0
	cp	r12,B1440
	jr	ne,L0C20
	cp	r13,#B143A
	jr	eq,L0C26
L0C20:
	xor	r2,r2
L0C22:
	jp	cret
L0C26:
	inc	B1444,#1
	ld	r0,B1444
	cp	r0,#%0001
	jr	le,L0BE0
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1444,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1444
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0C20
	ld	r2,B1444
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0C20
	ld	r2,B1440
	ld	@r2,r12
	ld	r2,B1440
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0CA0
	ld	r2,B1440
	ld	r3,B1440
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0CA0:
	ld	r2,B1444
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1440,r2
	ld	r2,B1440
	ld	r3,#B143A
	set	r3,#0
	ld	@r2,r3
	jr	L0BDC
L0CC0:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B143E,r2
	cp	r12,r2
	jr	ule,L0CDA
	ld	r3,@r2
	ld	B1442,r3
	ld	r3,@r13
	ld	@r2,r3
L0CDA:
	ld	r2,B143E
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0C22
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B143E,r12
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
	jr	eq,L0D18
	push	@r15,r13
	call	_free
	inc	r15,#2
L0D18:
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
	jr	eq,L0D3C
	cp	r12,r13
	jr	ne,L0D42
L0D3C:
	ld	r2,r12
	jp	cret
L0D42:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0D6A
	ld	r10,r11
	jr	L0D6A
L0D5E:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0D6A:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0D5E
	cp	r12,r13
	jr	uge,L0D3C
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0D3C
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
	ld	r3,B1442
	ld	@r2,r3
	jr	L0D3C
end _realloc
$SECTION BSS_B
I
B143A:
$REL	$+%2
B143C:
$REL	$+%2
B143E:
$REL	$+%2
B1440:
$REL	$+%2
B1442:
$REL	$+%2
B1444:
$REL	$+%2
$SDEFAULT
end malloc_
