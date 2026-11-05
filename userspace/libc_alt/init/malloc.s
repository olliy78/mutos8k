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
	test	B1C4E
	jr	ne,L0D0C
	ld	r2,#B1C50
	set	r2,#0
	ld	B1C4E,r2
	ld	r2,#B1C4E
	set	r2,#0
	ld	B1C50,r2
	ld	r2,#B1C50
	ld	B1C54,r2
	ld	r2,#B1C4E
	ld	B1C52,r2
L0D0C:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1C52
L0D20:
	clr	B1C58
L0D24:
	bit	@r13,#0
	jr	ne,L0D4E
	jr	L0D2E
L0D2A:
	ld	r2,@r12
	ld	@r13,r2
L0D2E:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0D2A
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0D4E
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0E04
L0D4E:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0D24
	cp	r12,B1C54
	jr	ne,L0D64
	cp	r13,#B1C4E
	jr	eq,L0D6A
L0D64:
	xor	r2,r2
L0D66:
	jp	cret
L0D6A:
	inc	B1C58,#1
	ld	r0,B1C58
	cp	r0,#%0001
	jr	le,L0D24
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1C58,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1C58
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0D64
	ld	r2,B1C58
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0D64
	ld	r2,B1C54
	ld	@r2,r12
	ld	r2,B1C54
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0DE4
	ld	r2,B1C54
	ld	r3,B1C54
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0DE4:
	ld	r2,B1C58
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1C54,r2
	ld	r2,B1C54
	ld	r3,#B1C4E
	set	r3,#0
	ld	@r2,r3
	jr	L0D20
L0E04:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1C52,r2
	cp	r12,r2
	jr	ule,L0E1E
	ld	r3,@r2
	ld	B1C56,r3
	ld	r3,@r13
	ld	@r2,r3
L0E1E:
	ld	r2,B1C52
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0D66
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1C52,r12
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
	jr	eq,L0E5C
	push	@r15,r13
	call	_free
	inc	r15,#2
L0E5C:
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
	jr	eq,L0E80
	cp	r12,r13
	jr	ne,L0E86
L0E80:
	ld	r2,r12
	jp	cret
L0E86:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0EAE
	ld	r10,r11
	jr	L0EAE
L0EA2:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0EAE:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0EA2
	cp	r12,r13
	jr	uge,L0E80
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0E80
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
	ld	r3,B1C56
	ld	@r2,r3
	jr	L0E80
end _realloc
$SECTION BSS_B
I
B1C4E:
$REL	$+%2
B1C50:
$REL	$+%2
B1C52:
$REL	$+%2
B1C54:
$REL	$+%2
B1C56:
$REL	$+%2
B1C58:
$REL	$+%2
$SDEFAULT
end malloc_
