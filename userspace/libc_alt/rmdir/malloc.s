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
	test	B1432
	jr	ne,L09FA
	ld	r2,#B1434
	set	r2,#0
	ld	B1432,r2
	ld	r2,#B1432
	set	r2,#0
	ld	B1434,r2
	ld	r2,#B1434
	ld	B1438,r2
	ld	r2,#B1432
	ld	B1436,r2
L09FA:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1436
L0A0E:
	clr	B143C
L0A12:
	bit	@r13,#0
	jr	ne,L0A3C
	jr	L0A1C
L0A18:
	ld	r2,@r12
	ld	@r13,r2
L0A1C:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0A18
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0A3C
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0AF2
L0A3C:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0A12
	cp	r12,B1438
	jr	ne,L0A52
	cp	r13,#B1432
	jr	eq,L0A58
L0A52:
	xor	r2,r2
L0A54:
	jp	cret
L0A58:
	inc	B143C,#1
	ld	r0,B143C
	cp	r0,#%0001
	jr	le,L0A12
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B143C,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B143C
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0A52
	ld	r2,B143C
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0A52
	ld	r2,B1438
	ld	@r2,r12
	ld	r2,B1438
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0AD2
	ld	r2,B1438
	ld	r3,B1438
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0AD2:
	ld	r2,B143C
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1438,r2
	ld	r2,B1438
	ld	r3,#B1432
	set	r3,#0
	ld	@r2,r3
	jr	L0A0E
L0AF2:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1436,r2
	cp	r12,r2
	jr	ule,L0B0C
	ld	r3,@r2
	ld	B143A,r3
	ld	r3,@r13
	ld	@r2,r3
L0B0C:
	ld	r2,B1436
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0A54
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1436,r12
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
	jr	eq,L0B4A
	push	@r15,r13
	call	_free
	inc	r15,#2
L0B4A:
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
	jr	eq,L0B6E
	cp	r12,r13
	jr	ne,L0B74
L0B6E:
	ld	r2,r12
	jp	cret
L0B74:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
L0B86:
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0B9C
	ld	r10,r11
	jr	L0B9C
L0B90:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0B9C:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0B90
	cp	r12,r13
	jr	uge,L0B6E
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0B6E
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
	ld	r3,B143A
	ld	@r2,r3
	jr	L0B6E
end _realloc
$SECTION BSS_B
I
B1432:
$REL	$+%2
B1434:
$REL	$+%2
B1436:
$REL	$+%2
B1438:
$REL	$+%2
B143A:
$REL	$+%2
B143C:
$REL	$+%2
$SDEFAULT
end malloc_
