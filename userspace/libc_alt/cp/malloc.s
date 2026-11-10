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
	test	B1436
	jr	ne,L0914
	ld	r2,#B1438
	set	r2,#0
	ld	B1436,r2
	ld	r2,#B1436
	set	r2,#0
	ld	B1438,r2
	ld	r2,#B1438
	ld	B143C,r2
	ld	r2,#B1436
	ld	B143A,r2
L0914:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B143A
L0928:
	clr	B1440
L092C:
	bit	@r13,#0
	jr	ne,L0956
	jr	L0936
L0932:
	ld	r2,@r12
	ld	@r13,r2
L0936:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0932
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0956
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0A0C
L0956:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L092C
	cp	r12,B143C
	jr	ne,L096C
	cp	r13,#B1436
	jr	eq,L0972
L096C:
	xor	r2,r2
L096E:
	jp	cret
L0972:
	inc	B1440,#1
	ld	r0,B1440
	cp	r0,#%0001
	jr	le,L092C
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1440,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1440
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L096C
	ld	r2,B1440
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L096C
	ld	r2,B143C
	ld	@r2,r12
	ld	r2,B143C
	inc	r2,#2
	cp	r2,r12
	jr	eq,L09EC
	ld	r2,B143C
	ld	r3,B143C
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L09EC:
	ld	r2,B1440
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B143C,r2
	ld	r2,B143C
	ld	r3,#B1436
	set	r3,#0
	ld	@r2,r3
	jr	L0928
L0A0C:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B143A,r2
	cp	r12,r2
	jr	ule,L0A26
	ld	r3,@r2
	ld	B143E,r3
	ld	r3,@r13
	ld	@r2,r3
L0A26:
	ld	r2,B143A
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L096E
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B143A,r12
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
	jr	eq,L0A64
	push	@r15,r13
	call	_free
	inc	r15,#2
L0A64:
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
	jr	eq,L0A88
	cp	r12,r13
	jr	ne,L0A8E
L0A88:
	ld	r2,r12
	jp	cret
L0A8E:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0AB6
	ld	r10,r11
	jr	L0AB6
L0AAA:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0AB6:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0AAA
	cp	r12,r13
	jr	uge,L0A88
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0A88
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
	ld	r3,B143E
	ld	@r2,r3
	jr	L0A88
end _realloc
$SECTION BSS_B
I
B1436:
$REL	$+%2
B1438:
$REL	$+%2
B143A:
$REL	$+%2
B143C:
$REL	$+%2
B143E:
$REL	$+%2
B1440:
$REL	$+%2
$SDEFAULT
end malloc_
