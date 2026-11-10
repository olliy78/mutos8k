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
	test	B27EA
	jr	ne,L0C3A
	ld	r2,#B27EC
	set	r2,#0
	ld	B27EA,r2
	ld	r2,#B27EA
	set	r2,#0
	ld	B27EC,r2
	ld	r2,#B27EC
	ld	B27F0,r2
	ld	r2,#B27EA
	ld	B27EE,r2
L0C3A:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B27EE
L0C4E:
	clr	B27F4
L0C52:
	bit	@r13,#0
	jr	ne,L0C7C
	jr	L0C5C
L0C58:
	ld	r2,@r12
	ld	@r13,r2
L0C5C:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0C58
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0C7C
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0D32
L0C7C:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0C52
	cp	r12,B27F0
	jr	ne,L0C92
	cp	r13,#B27EA
	jr	eq,L0C98
L0C92:
	xor	r2,r2
L0C94:
	jp	cret
L0C98:
	inc	B27F4,#1
	ld	r0,B27F4
	cp	r0,#%0001
	jr	le,L0C52
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B27F4,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B27F4
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0C92
	ld	r2,B27F4
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0C92
	ld	r2,B27F0
	ld	@r2,r12
	ld	r2,B27F0
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0D12
	ld	r2,B27F0
	ld	r3,B27F0
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0D12:
	ld	r2,B27F4
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B27F0,r2
	ld	r2,B27F0
	ld	r3,#B27EA
	set	r3,#0
	ld	@r2,r3
	jr	L0C4E
L0D32:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B27EE,r2
	cp	r12,r2
	jr	ule,L0D4C
	ld	r3,@r2
	ld	B27F2,r3
	ld	r3,@r13
	ld	@r2,r3
L0D4C:
	ld	r2,B27EE
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0C94
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B27EE,r12
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
	jr	eq,L0D8A
	push	@r15,r13
	call	_free
	inc	r15,#2
L0D8A:
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
	jr	eq,L0DAE
	cp	r12,r13
	jr	ne,L0DB4
L0DAE:
	ld	r2,r12
	jp	cret
L0DB4:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0DDC
	ld	r10,r11
	jr	L0DDC
L0DD0:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0DDC:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0DD0
	cp	r12,r13
	jr	uge,L0DAE
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0DAE
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
	ld	r3,B27F2
	ld	@r2,r3
	jr	L0DAE
end _realloc
$SECTION BSS_B
I
B27EA:
$REL	$+%2
B27EC:
$REL	$+%2
B27EE:
$REL	$+%2
B27F0:
$REL	$+%2
B27F2:
$REL	$+%2
B27F4:
$REL	$+%2
$SDEFAULT
end malloc_
