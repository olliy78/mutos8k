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
	test	B18B2
	jr	ne,L097C
	ld	r2,#B18B4
	set	r2,#0
	ld	B18B2,r2
	ld	r2,#B18B2
	set	r2,#0
	ld	B18B4,r2
	ld	r2,#B18B4
	ld	B18B8,r2
	ld	r2,#B18B2
	ld	B18B6,r2
L097C:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B18B6
L0990:
	clr	B18BC
L0994:
	bit	@r13,#0
	jr	ne,L09BE
	jr	L099E
L099A:
	ld	r2,@r12
	ld	@r13,r2
L099E:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L099A
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L09BE
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0A74
L09BE:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0994
	cp	r12,B18B8
	jr	ne,L09D4
	cp	r13,#B18B2
	jr	eq,L09DA
L09D4:
	xor	r2,r2
L09D6:
	jp	cret
L09DA:
	inc	B18BC,#1
	ld	r0,B18BC
	cp	r0,#%0001
	jr	le,L0994
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B18BC,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B18BC
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L09D4
	ld	r2,B18BC
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L09D4
	ld	r2,B18B8
	ld	@r2,r12
	ld	r2,B18B8
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0A54
	ld	r2,B18B8
	ld	r3,B18B8
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0A54:
	ld	r2,B18BC
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B18B8,r2
	ld	r2,B18B8
	ld	r3,#B18B2
	set	r3,#0
	ld	@r2,r3
	jr	L0990
L0A74:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B18B6,r2
	cp	r12,r2
	jr	ule,L0A8E
	ld	r3,@r2
	ld	B18BA,r3
	ld	r3,@r13
	ld	@r2,r3
L0A8E:
	ld	r2,B18B6
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L09D6
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B18B6,r12
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
	jr	eq,L0ACC
	push	@r15,r13
	call	_free
	inc	r15,#2
L0ACC:
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
	jr	eq,L0AF0
	cp	r12,r13
	jr	ne,L0AF6
L0AF0:
	ld	r2,r12
	jp	cret
L0AF6:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
L0B00:
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0B1E
	ld	r10,r11
	jr	L0B1E
L0B12:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0B1E:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0B12
	cp	r12,r13
	jr	uge,L0AF0
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0AF0
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
	ld	r3,B18BA
	ld	@r2,r3
	jr	L0AF0
end _realloc
$SECTION BSS_B
I
B18B2:
$REL	$+%2
B18B4:
$REL	$+%2
B18B6:
$REL	$+%2
B18B8:
$REL	$+%2
B18BA:
$REL	$+%2
B18BC:
$REL	$+%2
$SDEFAULT
end malloc_
