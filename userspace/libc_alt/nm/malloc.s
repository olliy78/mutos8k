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
	test	B1BCE
	jr	ne,L10DC
	ld	r2,#B1BD0
	set	r2,#0
	ld	B1BCE,r2
	ld	r2,#B1BCE
	set	r2,#0
	ld	B1BD0,r2
	ld	r2,#B1BD0
	ld	B1BD4,r2
	ld	r2,#B1BCE
	ld	B1BD2,r2
L10DC:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1BD2
L10F0:
	clr	B1BD8
L10F4:
	bit	@r13,#0
	jr	ne,L111E
	jr	L10FE
L10FA:
	ld	r2,@r12
	ld	@r13,r2
L10FE:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L10FA
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L111E
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L11D4
L111E:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L10F4
	cp	r12,B1BD4
	jr	ne,L1134
	cp	r13,#B1BCE
	jr	eq,L113A
L1134:
	xor	r2,r2
L1136:
	jp	cret
L113A:
	inc	B1BD8,#1
	ld	r0,B1BD8
	cp	r0,#%0001
	jr	le,L10F4
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1BD8,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1BD8
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L1134
	ld	r2,B1BD8
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L1134
	ld	r2,B1BD4
	ld	@r2,r12
	ld	r2,B1BD4
	inc	r2,#2
	cp	r2,r12
	jr	eq,L11B4
	ld	r2,B1BD4
	ld	r3,B1BD4
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L11B4:
	ld	r2,B1BD8
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1BD4,r2
	ld	r2,B1BD4
	ld	r3,#B1BCE
	set	r3,#0
	ld	@r2,r3
	jr	L10F0
L11D4:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1BD2,r2
	cp	r12,r2
	jr	ule,L11EE
	ld	r3,@r2
	ld	B1BD6,r3
	ld	r3,@r13
	ld	@r2,r3
L11EE:
	ld	r2,B1BD2
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L1136
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1BD2,r12
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
	jr	eq,L122C
	push	@r15,r13
	call	_free
	inc	r15,#2
L122C:
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
	jr	eq,L1250
	cp	r12,r13
	jr	ne,L1256
L1250:
	ld	r2,r12
	jp	cret
L1256:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L127E
	ld	r10,r11
	jr	L127E
L1272:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L127E:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L1272
	cp	r12,r13
	jr	uge,L1250
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L1250
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
	ld	r3,B1BD6
	ld	@r2,r3
	jr	L1250
end _realloc
$SECTION BSS_B
I
B1BCE:
$REL	$+%2
B1BD0:
$REL	$+%2
B1BD2:
$REL	$+%2
B1BD4:
$REL	$+%2
B1BD6:
$REL	$+%2
B1BD8:
$REL	$+%2
$SDEFAULT
end malloc_
