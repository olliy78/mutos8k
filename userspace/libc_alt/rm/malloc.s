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
	test	B1AA4
	jr	ne,L0F6C
	ld	r2,#B1AA6
	set	r2,#0
	ld	B1AA4,r2
	ld	r2,#B1AA4
	set	r2,#0
	ld	B1AA6,r2
	ld	r2,#B1AA6
	ld	B1AAA,r2
	ld	r2,#B1AA4
	ld	B1AA8,r2
L0F6C:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1AA8
L0F80:
	clr	B1AAE
L0F84:
	bit	@r13,#0
	jr	ne,L0FAE
	jr	L0F8E
L0F8A:
	ld	r2,@r12
	ld	@r13,r2
L0F8E:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0F8A
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0FAE
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L1064
L0FAE:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0F84
	cp	r12,B1AAA
	jr	ne,L0FC4
	cp	r13,#B1AA4
	jr	eq,L0FCA
L0FC4:
	xor	r2,r2
L0FC6:
	jp	cret
L0FCA:
	inc	B1AAE,#1
	ld	r0,B1AAE
	cp	r0,#%0001
	jr	le,L0F84
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1AAE,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1AAE
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0FC4
	ld	r2,B1AAE
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0FC4
	ld	r2,B1AAA
	ld	@r2,r12
	ld	r2,B1AAA
	inc	r2,#2
	cp	r2,r12
	jr	eq,L1044
	ld	r2,B1AAA
	ld	r3,B1AAA
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L1044:
	ld	r2,B1AAE
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1AAA,r2
	ld	r2,B1AAA
	ld	r3,#B1AA4
	set	r3,#0
	ld	@r2,r3
	jr	L0F80
L1064:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1AA8,r2
	cp	r12,r2
	jr	ule,L107E
	ld	r3,@r2
	ld	B1AAC,r3
	ld	r3,@r13
	ld	@r2,r3
L107E:
	ld	r2,B1AA8
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0FC6
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1AA8,r12
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
	jr	eq,L10BC
	push	@r15,r13
	call	_free
	inc	r15,#2
L10BC:
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
	jr	eq,L10E0
	cp	r12,r13
	jr	ne,L10E6
L10E0:
	ld	r2,r12
	jp	cret
L10E6:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L110E
	ld	r10,r11
	jr	L110E
L1102:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L110E:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L1102
	cp	r12,r13
	jr	uge,L10E0
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L10E0
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
	ld	r3,B1AAC
	ld	@r2,r3
	jr	L10E0
end _realloc
$SECTION BSS_B
I
B1AA4:
$REL	$+%2
B1AA6:
$REL	$+%2
B1AA8:
$REL	$+%2
B1AAA:
$REL	$+%2
B1AAC:
$REL	$+%2
B1AAE:
$REL	$+%2
$SDEFAULT
end malloc_
