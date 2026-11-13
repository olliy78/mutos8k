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
	test	B1EDA
	jr	ne,L1264
	ld	r2,#B1EDC
	set	r2,#0
	ld	B1EDA,r2
	ld	r2,#B1EDA
	set	r2,#0
	ld	B1EDC,r2
	ld	r2,#B1EDC
	ld	B1EE0,r2
	ld	r2,#B1EDA
	ld	B1EDE,r2
L1264:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1EDE
L1278:
	clr	B1EE4
L127C:
	bit	@r13,#0
	jr	ne,L12A6
	jr	L1286
L1282:
	ld	r2,@r12
	ld	@r13,r2
L1286:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L1282
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L12A6
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L1358
L12A6:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L127C
	cp	r12,B1EE0
	jr	ne,L12BC
	cp	r13,#B1EDA
	jr	eq,L12C2
L12BC:
	xor	r2,r2
L12BE:
	jp	cret
L12C2:
	inc	B1EE4,#1
	cp	B1EE4,#%0001
	jr	le,L127C
	ld	r3,r11
	add	r3,#%0200
	exts	rr2
	div	rr2,#%0200
	ld	r2,r3
	sla	r2,#9
	ld	B1EE4,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1EE4
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L12BC
	ld	r2,B1EE4
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L12BC
	ld	r2,B1EE0
	ld	@r2,r12
	ld	r2,B1EE0
	inc	r2,#2
	cp	r2,r12
	jr	eq,L1338
	ld	r2,B1EE0
	ld	r3,r2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r4
L1338:
	ld	r2,B1EE4
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1EE0,r2
	ld	r2,B1EE0
	ld	r3,#B1EDA
	set	r3,#0
	ld	@r2,r3
	jr	L1278
L1358:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1EDE,r2
	cp	r12,r2
	jr	ule,L1372
	ld	r3,@r2
	ld	B1EE2,r3
	ld	r3,@r13
	ld	@r2,r3
L1372:
	ld	r2,B1EDE
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L12BE
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1EDE,r12
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
	jr	eq,L13B0
	push	@r15,r13
	call	_free
	inc	r15,#2
L13B0:
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
	jr	eq,L13D2
	cp	r12,r13
	jr	ne,L13D8
L13D2:
	ld	r2,r12
	jp	cret
L13D8:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L1400
	ld	r10,r11
	jr	L1400
L13F4:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L1400:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L13F4
	cp	r12,r13
	jr	uge,L13D2
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L13D2
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
	ld	r3,B1EE2
	ld	@r2,r3
	jr	L13D2
end _realloc
$SECTION BSS_B
I
B1EDA:
$REL	$+%2
B1EDC:
$REL	$+%2
B1EDE:
$REL	$+%2
B1EE0:
$REL	$+%2
B1EE2:
$REL	$+%2
B1EE4:
$REL	$+%2
$SDEFAULT
end malloc_
