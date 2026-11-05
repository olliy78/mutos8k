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
	test	B1AC6
	jr	ne,L0F3A
	ld	r2,#B1AC8
	set	r2,#0
	ld	B1AC6,r2
	ld	r2,#B1AC6
	set	r2,#0
	ld	B1AC8,r2
	ld	r2,#B1AC8
	ld	B1ACC,r2
	ld	r2,#B1AC6
	ld	B1ACA,r2
L0F3A:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1ACA
L0F4E:
	clr	B1AD0
L0F52:
	bit	@r13,#0
	jr	ne,L0F7C
	jr	L0F5C
L0F58:
	ld	r2,@r12
	ld	@r13,r2
L0F5C:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0F58
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0F7C
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L1032
L0F7C:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0F52
	cp	r12,B1ACC
	jr	ne,L0F92
	cp	r13,#B1AC6
	jr	eq,L0F98
L0F92:
	xor	r2,r2
L0F94:
	jp	cret
L0F98:
	inc	B1AD0,#1
	ld	r0,B1AD0
	cp	r0,#%0001
	jr	le,L0F52
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1AD0,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1AD0
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0F92
	ld	r2,B1AD0
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0F92
	ld	r2,B1ACC
	ld	@r2,r12
	ld	r2,B1ACC
	inc	r2,#2
	cp	r2,r12
	jr	eq,L1012
	ld	r2,B1ACC
	ld	r3,B1ACC
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L1012:
	ld	r2,B1AD0
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1ACC,r2
	ld	r2,B1ACC
	ld	r3,#B1AC6
	set	r3,#0
	ld	@r2,r3
	jr	L0F4E
L1032:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1ACA,r2
	cp	r12,r2
	jr	ule,L104C
	ld	r3,@r2
	ld	B1ACE,r3
	ld	r3,@r13
	ld	@r2,r3
L104C:
	ld	r2,B1ACA
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0F94
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1ACA,r12
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
	jr	eq,L108A
	push	@r15,r13
	call	_free
	inc	r15,#2
L108A:
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
	jr	eq,L10AE
	cp	r12,r13
	jr	ne,L10B4
L10AE:
	ld	r2,r12
	jp	cret
L10B4:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L10DC
	ld	r10,r11
	jr	L10DC
L10D0:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L10DC:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L10D0
	cp	r12,r13
	jr	uge,L10AE
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L10AE
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
	ld	r3,B1ACE
	ld	@r2,r3
	jr	L10AE
end _realloc
$SECTION BSS_B
I
B1AC6:
$REL	$+%2
B1AC8:
$REL	$+%2
B1ACA:
$REL	$+%2
B1ACC:
$REL	$+%2
B1ACE:
$REL	$+%2
B1AD0:
$REL	$+%2
$SDEFAULT
end malloc_
