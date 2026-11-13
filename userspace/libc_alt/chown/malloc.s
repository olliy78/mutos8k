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
	test	B1BD0
	jr	ne,L0D6C
	ld	r2,#B1BD2
	set	r2,#0
	ld	B1BD0,r2
	ld	r2,#B1BD0
	set	r2,#0
	ld	B1BD2,r2
	ld	r2,#B1BD2
	ld	B1BD6,r2
	ld	r2,#B1BD0
	ld	B1BD4,r2
L0D6C:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1BD4
L0D80:
	clr	B1BDA
L0D84:
	bit	@r13,#0
	jr	ne,L0DAE
	jr	L0D8E
L0D8A:
	ld	r2,@r12
	ld	@r13,r2
L0D8E:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0D8A
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0DAE
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0E64
L0DAE:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0D84
	cp	r12,B1BD6
	jr	ne,L0DC4
	cp	r13,#B1BD0
	jr	eq,L0DCA
L0DC4:
	xor	r2,r2
L0DC6:
	jp	cret
L0DCA:
	inc	B1BDA,#1
	ld	r0,B1BDA
	cp	r0,#%0001
	jr	le,L0D84
	ld	r2,r11
	add	r2,#%22+_getpwen
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1BDA,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1BDA
	sla	r2,#1
	add	r2,r12
	add	r2,#%22+_getpwen
	cp	r2,r12
	jr	ult,L0DC4
	ld	r2,B1BDA
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0DC4
	ld	r2,B1BD6
	ld	@r2,r12
	ld	r2,B1BD6
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0E44
	ld	r2,B1BD6
	ld	r3,B1BD6
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0E44:
	ld	r2,B1BDA
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1BD6,r2
	ld	r2,B1BD6
	ld	r3,#B1BD0
	set	r3,#0
	ld	@r2,r3
	jr	L0D80
L0E64:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1BD4,r2
	cp	r12,r2
	jr	ule,L0E7E
	ld	r3,@r2
	ld	B1BD8,r3
	ld	r3,@r13
	ld	@r2,r3
L0E7E:
	ld	r2,B1BD4
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0DC6
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1BD4,r12
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
	jr	eq,L0EBC
	push	@r15,r13
	call	_free
	inc	r15,#2
L0EBC:
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
	jr	eq,L0EE0
	cp	r12,r13
	jr	ne,L0EE6
L0EE0:
	ld	r2,r12
	jp	cret
L0EE6:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0F0E
	ld	r10,r11
	jr	L0F0E
L0F02:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0F0E:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0F02
	cp	r12,r13
	jr	uge,L0EE0
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0EE0
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
	ld	r3,B1BD8
	ld	@r2,r3
	jr	L0EE0
end _realloc
$SECTION BSS_B
I
B1BD0:
$REL	$+%2
B1BD2:
$REL	$+%2
B1BD4:
$REL	$+%2
B1BD6:
$REL	$+%2
B1BD8:
$REL	$+%2
B1BDA:
$REL	$+%2
$SDEFAULT
end malloc_
