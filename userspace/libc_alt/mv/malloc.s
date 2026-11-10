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
	test	B1F5A
	jr	ne,L1112
	ld	r2,#B1F5C
	set	r2,#0
	ld	B1F5A,r2
	ld	r2,#B1F5A
	set	r2,#0
	ld	B1F5C,r2
	ld	r2,#B1F5C
	ld	B1F60,r2
	ld	r2,#B1F5A
	ld	B1F5E,r2
L1112:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1F5E
L1126:
	clr	B1F64
L112A:
	bit	@r13,#0
	jr	ne,L1154
	jr	L1134
L1130:
	ld	r2,@r12
	ld	@r13,r2
L1134:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L1130
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L1154
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L120A
L1154:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L112A
	cp	r12,B1F60
	jr	ne,L116A
	cp	r13,#B1F5A
	jr	eq,L1170
L116A:
	xor	r2,r2
L116C:
	jp	cret
L1170:
	inc	B1F64,#1
	ld	r0,B1F64
	cp	r0,#%0001
	jr	le,L112A
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1F64,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1F64
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L116A
	ld	r2,B1F64
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L116A
	ld	r2,B1F60
	ld	@r2,r12
	ld	r2,B1F60
	inc	r2,#2
	cp	r2,r12
	jr	eq,L11EA
	ld	r2,B1F60
	ld	r3,B1F60
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L11EA:
	ld	r2,B1F64
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1F60,r2
	ld	r2,B1F60
	ld	r3,#B1F5A
	set	r3,#0
	ld	@r2,r3
	jr	L1126
L120A:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1F5E,r2
	cp	r12,r2
	jr	ule,L1224
	ld	r3,@r2
	ld	B1F62,r3
	ld	r3,@r13
	ld	@r2,r3
L1224:
	ld	r2,B1F5E
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L116C
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1F5E,r12
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
	jr	eq,L1262
	push	@r15,r13
	call	_free
	inc	r15,#2
L1262:
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
	jr	eq,L1286
	cp	r12,r13
	jr	ne,L128C
L1286:
	ld	r2,r12
	jp	cret
L128C:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L12B4
	ld	r10,r11
	jr	L12B4
L12A8:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L12B4:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L12A8
	cp	r12,r13
	jr	uge,L1286
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L1286
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
	ld	r3,B1F62
	ld	@r2,r3
	jr	L1286
end _realloc
$SECTION BSS_B
I
B1F5A:
$REL	$+%2
B1F5C:
$REL	$+%2
B1F5E:
$REL	$+%2
B1F60:
$REL	$+%2
B1F62:
$REL	$+%2
B1F64:
$REL	$+%2
$SDEFAULT
end malloc_
