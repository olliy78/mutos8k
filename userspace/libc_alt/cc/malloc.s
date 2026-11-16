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
	test	B23A4
	jr	ne,L1280
	ld	r2,#B23A6
	set	r2,#0
	ld	B23A4,r2
	ld	r2,#B23A4
	set	r2,#0
	ld	B23A6,r2
	ld	r2,#B23A6
	ld	B23AA,r2
	ld	r2,#B23A4
	ld	B23A8,r2
L1280:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B23A8
L1294:
	clr	B23AE
L1298:
	bit	@r13,#0
	jr	ne,L12C2
	jr	L12A2
L129E:
	ld	r2,@r12
	ld	@r13,r2
L12A2:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L129E
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L12C2
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L1378
L12C2:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L1298
	cp	r12,B23AA
	jr	ne,L12D8
	cp	r13,#B23A4
	jr	eq,L12DE
L12D8:
	xor	r2,r2
L12DA:
	jp	cret
L12DE:
	inc	B23AE,#1
	ld	r0,B23AE
	cp	r0,#%0001
	jr	le,L1298
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B23AE,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B23AE
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L12D8
	ld	r2,B23AE
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L12D8
	ld	r2,B23AA
	ld	@r2,r12
	ld	r2,B23AA
	inc	r2,#2
	cp	r2,r12
	jr	eq,L1358
	ld	r2,B23AA
	ld	r3,B23AA
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L1358:
	ld	r2,B23AE
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B23AA,r2
	ld	r2,B23AA
	ld	r3,#B23A4
	set	r3,#0
	ld	@r2,r3
	jr	L1294
L1378:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B23A8,r2
	cp	r12,r2
	jr	ule,L1392
	ld	r3,@r2
	ld	B23AC,r3
	ld	r3,@r13
	ld	@r2,r3
L1392:
	ld	r2,B23A8
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L12DA
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B23A8,r12
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
	jr	eq,L13D0
	push	@r15,r13
	call	_free
	inc	r15,#2
L13D0:
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
	jr	eq,L13F4
	cp	r12,r13
	jr	ne,L13FA
L13F4:
	ld	r2,r12
	jp	cret
L13FA:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L1422
	ld	r10,r11
	jr	L1422
L1416:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L1422:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L1416
	cp	r12,r13
	jr	uge,L13F4
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L13F4
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
	ld	r3,B23AC
	ld	@r2,r3
	jr	L13F4
end _realloc
$SECTION BSS_B
I
B23A4:
$REL	$+%2
B23A6:
$REL	$+%2
B23A8:
$REL	$+%2
B23AA:
$REL	$+%2
B23AC:
$REL	$+%2
B23AE:
$REL	$+%2
$SDEFAULT
end malloc_
