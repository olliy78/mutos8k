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
	test	B20A2
	jr	ne,L10A2
	ld	r2,#B20A4
	set	r2,#0
	ld	B20A2,r2
	ld	r2,#B20A2
	set	r2,#0
	ld	B20A4,r2
	ld	r2,#B20A4
	ld	B20A8,r2
	ld	r2,#B20A2
	ld	B20A6,r2
L10A2:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B20A6
L10B6:
	clr	B20AC
L10BA:
	bit	@r13,#0
	jr	ne,L10E4
	jr	L10C4
L10C0:
	ld	r2,@r12
	ld	@r13,r2
L10C4:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L10C0
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L10E4
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L119A
L10E4:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L10BA
	cp	r12,B20A8
	jr	ne,L10FA
	cp	r13,#B20A2
	jr	eq,L1100
L10FA:
	xor	r2,r2
L10FC:
	jp	cret
L1100:
	inc	B20AC,#1
	ld	r0,B20AC
	cp	r0,#%0001
	jr	le,L10BA
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B20AC,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B20AC
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L10FA
	ld	r2,B20AC
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L10FA
	ld	r2,B20A8
	ld	@r2,r12
	ld	r2,B20A8
	inc	r2,#2
	cp	r2,r12
	jr	eq,L117A
	ld	r2,B20A8
	ld	r3,B20A8
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L117A:
	ld	r2,B20AC
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B20A8,r2
	ld	r2,B20A8
	ld	r3,#B20A2
	set	r3,#0
	ld	@r2,r3
	jr	L10B6
L119A:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B20A6,r2
	cp	r12,r2
	jr	ule,L11B4
	ld	r3,@r2
	ld	B20AA,r3
	ld	r3,@r13
	ld	@r2,r3
L11B4:
	ld	r2,B20A6
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L10FC
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B20A6,r12
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
	jr	eq,L11F2
	push	@r15,r13
	call	_free
	inc	r15,#2
L11F2:
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
	jr	eq,L1216
	cp	r12,r13
	jr	ne,L121C
L1216:
	ld	r2,r12
	jp	cret
L121C:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L1244
	ld	r10,r11
	jr	L1244
L1238:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L1244:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L1238
	cp	r12,r13
	jr	uge,L1216
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L1216
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
	ld	r3,B20AA
	ld	@r2,r3
	jr	L1216
end _realloc
$SECTION BSS_B
I
B20A2:
$REL	$+%2
B20A4:
$REL	$+%2
B20A6:
$REL	$+%2
B20A8:
$REL	$+%2
B20AA:
$REL	$+%2
B20AC:
$REL	$+%2
$SDEFAULT
end malloc_
