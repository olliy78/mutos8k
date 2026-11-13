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
	test	B2DE0
	jr	ne,L1AD2
	ld	r2,#B2DE2
	set	r2,#0
	ld	B2DE0,r2
	ld	r2,#B2DE0
	set	r2,#0
	ld	B2DE2,r2
	ld	r2,#B2DE2
	ld	B2DE6,r2
	ld	r2,#B2DE0
	ld	B2DE4,r2
L1AD2:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B2DE4
L1AE6:
	clr	B2DEA
L1AEA:
	bit	@r13,#0
	jr	ne,L1B14
	jr	L1AF4
L1AF0:
	ld	r2,@r12
	ld	@r13,r2
L1AF4:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L1AF0
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L1B14
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L1BCA
L1B14:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L1AEA
	cp	r12,B2DE6
	jr	ne,L1B2A
	cp	r13,#B2DE0
	jr	eq,L1B30
L1B2A:
	xor	r2,r2
L1B2C:
	jp	cret
L1B30:
	inc	B2DEA,#1
	ld	r0,B2DEA
	cp	r0,#%0001
	jr	le,L1AEA
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B2DEA,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B2DEA
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L1B2A
	ld	r2,B2DEA
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L1B2A
	ld	r2,B2DE6
	ld	@r2,r12
	ld	r2,B2DE6
	inc	r2,#2
	cp	r2,r12
	jr	eq,L1BAA
	ld	r2,B2DE6
	ld	r3,B2DE6
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L1BAA:
	ld	r2,B2DEA
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B2DE6,r2
	ld	r2,B2DE6
	ld	r3,#B2DE0
	set	r3,#0
	ld	@r2,r3
	jr	L1AE6
L1BCA:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B2DE4,r2
	cp	r12,r2
	jr	ule,L1BE4
	ld	r3,@r2
	ld	B2DE8,r3
	ld	r3,@r13
	ld	@r2,r3
L1BE4:
	ld	r2,B2DE4
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L1B2C
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B2DE4,r12
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
	jr	eq,L1C22
	push	@r15,r13
	call	_free
	inc	r15,#2
L1C22:
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
	jr	eq,L1C46
	cp	r12,r13
	jr	ne,L1C4C
L1C46:
	ld	r2,r12
	jp	cret
L1C4C:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L1C74
	ld	r10,r11
	jr	L1C74
L1C68:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L1C74:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L1C68
	cp	r12,r13
	jr	uge,L1C46
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L1C46
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
	ld	r3,B2DE8
	ld	@r2,r3
	jr	L1C46
end _realloc
$SECTION BSS_B
I
B2DE0:
$REL	$+%2
B2DE2:
$REL	$+%2
B2DE4:
$REL	$+%2
B2DE6:
$REL	$+%2
B2DE8:
$REL	$+%2
B2DEA:
$REL	$+%2
$SDEFAULT
end malloc_
