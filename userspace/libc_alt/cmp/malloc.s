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
	test	B1644
	jr	ne,L0D06
	ld	r2,#B1646
	set	r2,#0
	ld	B1644,r2
	ld	r2,#B1644
	set	r2,#0
	ld	B1646,r2
	ld	r2,#B1646
	ld	B164A,r2
	ld	r2,#B1644
	ld	B1648,r2
L0D06:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1648
L0D1A:
	clr	B164E
L0D1E:
	bit	@r13,#0
	jr	ne,L0D48
	jr	L0D28
L0D24:
	ld	r2,@r12
	ld	@r13,r2
L0D28:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0D24
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0D48
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0DFE
L0D48:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0D1E
	cp	r12,B164A
	jr	ne,L0D5E
	cp	r13,#B1644
	jr	eq,L0D64
L0D5E:
	xor	r2,r2
L0D60:
	jp	cret
L0D64:
	inc	B164E,#1
	ld	r0,B164E
	cp	r0,#%0001
	jr	le,L0D1E
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B164E,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B164E
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0D5E
	ld	r2,B164E
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0D5E
	ld	r2,B164A
	ld	@r2,r12
	ld	r2,B164A
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0DDE
	ld	r2,B164A
	ld	r3,B164A
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0DDE:
	ld	r2,B164E
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B164A,r2
	ld	r2,B164A
	ld	r3,#B1644
	set	r3,#0
	ld	@r2,r3
	jr	L0D1A
L0DFE:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1648,r2
	cp	r12,r2
	jr	ule,L0E18
	ld	r3,@r2
	ld	B164C,r3
	ld	r3,@r13
	ld	@r2,r3
L0E18:
	ld	r2,B1648
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0D60
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1648,r12
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
	jr	eq,L0E56
	push	@r15,r13
	call	_free
	inc	r15,#2
L0E56:
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
	jr	eq,L0E7A
	cp	r12,r13
	jr	ne,L0E80
L0E7A:
	ld	r2,r12
	jp	cret
L0E80:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0EA8
	ld	r10,r11
	jr	L0EA8
L0E9C:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0EA8:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0E9C
	cp	r12,r13
	jr	uge,L0E7A
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0E7A
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
	ld	r3,B164C
	ld	@r2,r3
	jr	L0E7A
end _realloc
$SECTION BSS_B
I
B1644:
$REL	$+%2
B1646:
$REL	$+%2
B1648:
$REL	$+%2
B164A:
$REL	$+%2
B164C:
$REL	$+%2
B164E:
$REL	$+%2
$SDEFAULT
end malloc_
