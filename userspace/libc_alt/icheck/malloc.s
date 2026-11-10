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
	test	B300C
	jr	ne,L12AA
	ld	r2,#B300E
	set	r2,#0
	ld	B300C,r2
	ld	r2,#B300C
	set	r2,#0
	ld	B300E,r2
	ld	r2,#B300E
	ld	B3012,r2
	ld	r2,#B300C
	ld	B3010,r2
L12AA:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B3010
L12BE:
	clr	B3016
L12C2:
	bit	@r13,#0
	jr	ne,L12EC
	jr	L12CC
L12C8:
	ld	r2,@r12
	ld	@r13,r2
L12CC:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L12C8
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L12EC
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L13A2
L12EC:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L12C2
	cp	r12,B3012
	jr	ne,L1302
	cp	r13,#B300C
	jr	eq,L1308
L1302:
	xor	r2,r2
L1304:
	jp	cret
L1308:
	inc	B3016,#1
	ld	r0,B3016
	cp	r0,#%0001
	jr	le,L12C2
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B3016,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B3016
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L1302
	ld	r2,B3016
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L1302
	ld	r2,B3012
	ld	@r2,r12
	ld	r2,B3012
	inc	r2,#2
	cp	r2,r12
	jr	eq,L1382
	ld	r2,B3012
	ld	r3,B3012
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L1382:
	ld	r2,B3016
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B3012,r2
	ld	r2,B3012
	ld	r3,#B300C
	set	r3,#0
	ld	@r2,r3
	jr	L12BE
L13A2:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B3010,r2
	cp	r12,r2
	jr	ule,L13BC
	ld	r3,@r2
	ld	B3014,r3
	ld	r3,@r13
	ld	@r2,r3
L13BC:
	ld	r2,B3010
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L1304
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B3010,r12
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
	jr	eq,L13FA
	push	@r15,r13
	call	_free
	inc	r15,#2
L13FA:
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
	jr	eq,L141E
	cp	r12,r13
	jr	ne,L1424
L141E:
	ld	r2,r12
	jp	cret
L1424:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L144C
	ld	r10,r11
	jr	L144C
L1440:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L144C:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L1440
	cp	r12,r13
	jr	uge,L141E
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L141E
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
	ld	r3,B3014
	ld	@r2,r3
	jr	L141E
end _realloc
$SECTION BSS_B
I
B300C:
$REL	$+%2
B300E:
$REL	$+%2
B3010:
$REL	$+%2
B3012:
$REL	$+%2
B3014:
$REL	$+%2
B3016:
$REL	$+%2
$SDEFAULT
end malloc_
