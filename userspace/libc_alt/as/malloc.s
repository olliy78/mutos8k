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
	test	BD118
	jr	ne,L531E
	ld	r2,#BD11A
	set	r2,#0
	ld	BD118,r2
	ld	r2,#BD118
	set	r2,#0
	ld	BD11A,r2
	ld	r2,#BD11A
	ld	BD11E,r2
	ld	r2,#BD118
	ld	BD11C,r2
L531E:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,BD11C
L5332:
	clr	BD122
L5336:
	bit	@r13,#0
	jr	ne,L5360
	jr	L5340
L533C:
	ld	r2,@r12
	ld	@r13,r2
L5340:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L533C
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L5360
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L5412
L5360:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L5336
	cp	r12,BD11E
	jr	ne,L5376
	cp	r13,#BD118
	jr	eq,L537C
L5376:
	xor	r2,r2
L5378:
	jp	cret
L537C:
	inc	BD122,#1
	cp	BD122,#%0001
	jr	le,L5336
	ld	r3,r11
	add	r3,#%0200
	exts	rr2
	div	rr2,#%0200
	ld	r2,r3
	sla	r2,#9
	ld	BD122,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,BD122
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L5376
	ld	r2,BD122
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L5376
	ld	r2,BD11E
	ld	@r2,r12
	ld	r2,BD11E
	inc	r2,#2
	cp	r2,r12
	jr	eq,L53F2
	ld	r2,BD11E
	ld	r3,r2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r4
L53F2:
	ld	r2,BD122
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	BD11E,r2
	ld	r2,BD11E
	ld	r3,#BD118
	set	r3,#0
	ld	@r2,r3
	jr	L5332
L5412:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	BD11C,r2
	cp	r12,r2
	jr	ule,L542C
	ld	r3,@r2
	ld	BD120,r3
	ld	r3,@r13
	ld	@r2,r3
L542C:
	ld	r2,BD11C
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L5378
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	BD11C,r12
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
	jr	eq,L546A
	push	@r15,r13
	call	_free
	inc	r15,#2
L546A:
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
	jr	eq,L548C
	cp	r12,r13
	jr	ne,L5492
L548C:
	ld	r2,r12
	jp	cret
L5492:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L54BA
	ld	r10,r11
	jr	L54BA
L54AE:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L54BA:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L54AE
	cp	r12,r13
	jr	uge,L548C
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L548C
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
	ld	r3,BD120
	ld	@r2,r3
	jr	L548C
end _realloc
$SECTION BSS_B
I
BD118:
$REL	$+%2
BD11A:
$REL	$+%2
BD11C:
$REL	$+%2
BD11E:
$REL	$+%2
BD120:
$REL	$+%2
BD122:
$REL	$+%2
$SDEFAULT
end malloc_
