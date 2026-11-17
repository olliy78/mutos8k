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
	test	BB5F4
	jr	ne,L20CC
	ld	r2,#BB5F6
	set	r2,#0
	ld	BB5F4,r2
	ld	r2,#BB5F4
	set	r2,#0
	ld	BB5F6,r2
	ld	r2,#BB5F6
	ld	BB5FA,r2
	ld	r2,#BB5F4
	ld	BB5F8,r2
L20CC:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,BB5F8
L20E0:
	clr	BB5FE
L20E4:
	bit	@r13,#0
	jr	ne,L210E
	jr	L20EE
L20EA:
	ld	r2,@r12
	ld	@r13,r2
L20EE:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L20EA
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L210E
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L21C4
L210E:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L20E4
	cp	r12,BB5FA
	jr	ne,L2124
	cp	r13,#BB5F4
	jr	eq,L212A
L2124:
	xor	r2,r2
L2126:
	jp	cret
L212A:
	inc	BB5FE,#1
	ld	r0,BB5FE
	cp	r0,#%0001
	jr	le,L20E4
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	BB5FE,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,BB5FE
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L2124
	ld	r2,BB5FE
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L2124
	ld	r2,BB5FA
	ld	@r2,r12
	ld	r2,BB5FA
	inc	r2,#2
	cp	r2,r12
	jr	eq,L21A4
	ld	r2,BB5FA
	ld	r3,BB5FA
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L21A4:
	ld	r2,BB5FE
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	BB5FA,r2
	ld	r2,BB5FA
	ld	r3,#BB5F4
	set	r3,#0
	ld	@r2,r3
	jr	L20E0
L21C4:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	BB5F8,r2
	cp	r12,r2
	jr	ule,L21DE
	ld	r3,@r2
	ld	BB5FC,r3
	ld	r3,@r13
	ld	@r2,r3
L21DE:
	ld	r2,BB5F8
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L2126
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	BB5F8,r12
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
	jr	eq,L221C
	push	@r15,r13
	call	_free
	inc	r15,#2
L221C:
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
	jr	eq,L2240
	cp	r12,r13
	jr	ne,L2246
L2240:
	ld	r2,r12
	jp	cret
L2246:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L226E
	ld	r10,r11
	jr	L226E
L2262:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L226E:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L2262
	cp	r12,r13
	jr	uge,L2240
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L2240
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
	ld	r3,BB5FC
	ld	@r2,r3
	jr	L2240
end _realloc
$SECTION BSS_B
I
BB5F4:
$REL	$+%2
BB5F6:
$REL	$+%2
BB5F8:
$REL	$+%2
BB5FA:
$REL	$+%2
BB5FC:
$REL	$+%2
BB5FE:
$REL	$+%2
$SDEFAULT
end malloc_
