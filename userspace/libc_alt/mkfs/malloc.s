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
	test	B2B34
	jr	ne,L1A42
	ld	r2,#B2B36
	set	r2,#0
	ld	B2B34,r2
	ld	r2,#B2B34
	set	r2,#0
	ld	B2B36,r2
	ld	r2,#B2B36
	ld	B2B3A,r2
	ld	r2,#B2B34
	ld	B2B38,r2
L1A42:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B2B38
L1A56:
	clr	B2B3E
L1A5A:
	bit	@r13,#0
	jr	ne,L1A84
	jr	L1A64
L1A60:
	ld	r2,@r12
	ld	@r13,r2
L1A64:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L1A60
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L1A84
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L1B3A
L1A84:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L1A5A
	cp	r12,B2B3A
	jr	ne,L1A9A
	cp	r13,#B2B34
	jr	eq,L1AA0
L1A9A:
	xor	r2,r2
L1A9C:
	jp	cret
L1AA0:
	inc	B2B3E,#1
	ld	r0,B2B3E
	cp	r0,#%0001
	jr	le,L1A5A
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B2B3E,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B2B3E
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L1A9A
	ld	r2,B2B3E
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L1A9A
	ld	r2,B2B3A
	ld	@r2,r12
	ld	r2,B2B3A
	inc	r2,#2
	cp	r2,r12
	jr	eq,L1B1A
	ld	r2,B2B3A
	ld	r3,B2B3A
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L1B1A:
	ld	r2,B2B3E
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B2B3A,r2
	ld	r2,B2B3A
	ld	r3,#B2B34
	set	r3,#0
	ld	@r2,r3
	jr	L1A56
L1B3A:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B2B38,r2
	cp	r12,r2
	jr	ule,L1B54
	ld	r3,@r2
	ld	B2B3C,r3
	ld	r3,@r13
	ld	@r2,r3
L1B54:
	ld	r2,B2B38
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L1A9C
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B2B38,r12
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
	jr	eq,L1B92
	push	@r15,r13
	call	_free
	inc	r15,#2
L1B92:
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
	jr	eq,L1BB6
	cp	r12,r13
	jr	ne,L1BBC
L1BB6:
	ld	r2,r12
	jp	cret
L1BBC:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L1BE4
	ld	r10,r11
	jr	L1BE4
L1BD8:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L1BE4:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L1BD8
	cp	r12,r13
	jr	uge,L1BB6
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L1BB6
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
	ld	r3,B2B3C
	ld	@r2,r3
	jr	L1BB6
end _realloc
$SECTION BSS_B
I
B2B34:
$REL	$+%2
B2B36:
$REL	$+%2
B2B38:
$REL	$+%2
B2B3A:
$REL	$+%2
B2B3C:
$REL	$+%2
B2B3E:
$REL	$+%2
$SDEFAULT
end malloc_
