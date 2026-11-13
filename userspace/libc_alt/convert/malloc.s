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
	test	B1A36
	jr	ne,L0CF8
	ld	r2,#B1A38
	set	r2,#0
	ld	B1A36,r2
	ld	r2,#B1A36
	set	r2,#0
	ld	B1A38,r2
	ld	r2,#B1A38
	ld	B1A3C,r2
	ld	r2,#B1A36
	ld	B1A3A,r2
L0CF8:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1A3A
L0D0C:
	clr	B1A40
L0D10:
	bit	@r13,#0
	jr	ne,L0D3A
	jr	L0D1A
L0D16:
	ld	r2,@r12
	ld	@r13,r2
L0D1A:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0D16
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0D3A
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0DF0
L0D3A:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0D10
	cp	r12,B1A3C
	jr	ne,L0D50
	cp	r13,#B1A36
	jr	eq,L0D56
L0D50:
	xor	r2,r2
L0D52:
	jp	cret
L0D56:
	inc	B1A40,#1
	ld	r0,B1A40
	cp	r0,#%0001
	jr	le,L0D10
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1A40,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1A40
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0D50
	ld	r2,B1A40
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0D50
	ld	r2,B1A3C
	ld	@r2,r12
	ld	r2,B1A3C
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0DD0
	ld	r2,B1A3C
	ld	r3,B1A3C
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0DD0:
	ld	r2,B1A40
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1A3C,r2
	ld	r2,B1A3C
	ld	r3,#B1A36
	set	r3,#0
	ld	@r2,r3
	jr	L0D0C
L0DF0:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1A3A,r2
	cp	r12,r2
	jr	ule,L0E0A
	ld	r3,@r2
	ld	B1A3E,r3
	ld	r3,@r13
	ld	@r2,r3
L0E0A:
	ld	r2,B1A3A
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0D52
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1A3A,r12
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
	jr	eq,L0E48
	push	@r15,r13
	call	_free
	inc	r15,#2
L0E48:
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
	jr	eq,L0E6C
	cp	r12,r13
	jr	ne,L0E72
L0E6C:
	ld	r2,r12
	jp	cret
L0E72:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0E9A
	ld	r10,r11
	jr	L0E9A
L0E8E:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0E9A:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0E8E
	cp	r12,r13
	jr	uge,L0E6C
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0E6C
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
	ld	r3,B1A3E
	ld	@r2,r3
	jr	L0E6C
end _realloc
$SECTION BSS_B
I
B1A36:
$REL	$+%2
B1A38:
$REL	$+%2
B1A3A:
$REL	$+%2
B1A3C:
$REL	$+%2
B1A3E:
$REL	$+%2
B1A40:
$REL	$+%2
$SDEFAULT
end malloc_
