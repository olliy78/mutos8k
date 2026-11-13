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
	test	B41DA
	jr	ne,L19E8
	ld	r2,#B41DC
	set	r2,#0
	ld	B41DA,r2
	ld	r2,#B41DA
	set	r2,#0
	ld	B41DC,r2
	ld	r2,#B41DC
	ld	B41E0,r2
	ld	r2,#B41DA
	ld	B41DE,r2
L19E8:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B41DE
L19FC:
	clr	B41E4
L1A00:
	bit	@r13,#0
	jr	ne,L1A2A
	jr	L1A0A
L1A06:
	ld	r2,@r12
	ld	@r13,r2
L1A0A:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L1A06
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L1A2A
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L1AE0
L1A2A:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L1A00
	cp	r12,B41E0
	jr	ne,L1A40
	cp	r13,#B41DA
	jr	eq,L1A46
L1A40:
	xor	r2,r2
L1A42:
	jp	cret
L1A46:
	inc	B41E4,#1
	ld	r0,B41E4
	cp	r0,#%0001
	jr	le,L1A00
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B41E4,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B41E4
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L1A40
	ld	r2,B41E4
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L1A40
	ld	r2,B41E0
	ld	@r2,r12
	ld	r2,B41E0
	inc	r2,#2
	cp	r2,r12
	jr	eq,L1AC0
	ld	r2,B41E0
	ld	r3,B41E0
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L1AC0:
	ld	r2,B41E4
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B41E0,r2
	ld	r2,B41E0
	ld	r3,#B41DA
	set	r3,#0
	ld	@r2,r3
	jr	L19FC
L1AE0:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B41DE,r2
	cp	r12,r2
	jr	ule,L1AFA
	ld	r3,@r2
	ld	B41E2,r3
	ld	r3,@r13
	ld	@r2,r3
L1AFA:
	ld	r2,B41DE
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L1A42
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B41DE,r12
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
	jr	eq,L1B38
	push	@r15,r13
	call	_free
	inc	r15,#2
L1B38:
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
	jr	eq,L1B5C
	cp	r12,r13
	jr	ne,L1B62
L1B5C:
	ld	r2,r12
	jp	cret
L1B62:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L1B8A
	ld	r10,r11
	jr	L1B8A
L1B7E:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L1B8A:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L1B7E
	cp	r12,r13
	jr	uge,L1B5C
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L1B5C
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
	ld	r3,B41E2
	ld	@r2,r3
	jr	L1B5C
end _realloc
$SECTION BSS_B
I
B41DA:
$REL	$+%2
B41DC:
$REL	$+%2
B41DE:
$REL	$+%2
B41E0:
$REL	$+%2
B41E2:
$REL	$+%2
B41E4:
$REL	$+%2
$SDEFAULT
end malloc_
