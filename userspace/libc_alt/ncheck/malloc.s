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
	test	B7862
	jr	ne,L0E7A
	ld	r2,#B7864
	set	r2,#0
	ld	B7862,r2
	ld	r2,#B7862
	set	r2,#0
	ld	B7864,r2
	ld	r2,#B7864
	ld	B7868,r2
	ld	r2,#B7862
	ld	B7866,r2
L0E7A:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B7866
L0E8E:
	clr	B786C
L0E92:
	bit	@r13,#0
	jr	ne,L0EBC
	jr	L0E9C
L0E98:
	ld	r2,@r12
	ld	@r13,r2
L0E9C:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0E98
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0EBC
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0F72
L0EBC:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0E92
	cp	r12,B7868
	jr	ne,L0ED2
	cp	r13,#B7862
	jr	eq,L0ED8
L0ED2:
	xor	r2,r2
L0ED4:
	jp	cret
L0ED8:
	inc	B786C,#1
	ld	r0,B786C
	cp	r0,#%0001
	jr	le,L0E92
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B786C,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B786C
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0ED2
	ld	r2,B786C
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0ED2
	ld	r2,B7868
	ld	@r2,r12
	ld	r2,B7868
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0F52
	ld	r2,B7868
	ld	r3,B7868
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0F52:
	ld	r2,B786C
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B7868,r2
	ld	r2,B7868
	ld	r3,#B7862
	set	r3,#0
	ld	@r2,r3
	jr	L0E8E
L0F72:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B7866,r2
	cp	r12,r2
	jr	ule,L0F8C
	ld	r3,@r2
	ld	B786A,r3
	ld	r3,@r13
	ld	@r2,r3
L0F8C:
	ld	r2,B7866
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0ED4
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B7866,r12
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
	jr	eq,L0FCA
	push	@r15,r13
	call	_free
	inc	r15,#2
L0FCA:
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
	jr	eq,L0FEE
	cp	r12,r13
	jr	ne,L0FF4
L0FEE:
	ld	r2,r12
	jp	cret
L0FF4:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L101C
	ld	r10,r11
	jr	L101C
L1010:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L101C:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L1010
	cp	r12,r13
	jr	uge,L0FEE
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0FEE
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
	ld	r3,B786A
	ld	@r2,r3
	jr	L0FEE
end _realloc
$SECTION BSS_B
I
B7862:
$REL	$+%2
B7864:
$REL	$+%2
B7866:
$REL	$+%2
B7868:
$REL	$+%2
B786A:
$REL	$+%2
B786C:
$REL	$+%2
$SDEFAULT
end malloc_
