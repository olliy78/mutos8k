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
	test	B56E2
	jr	ne,L3F22
	ld	r2,#B56E4
	set	r2,#0
	ld	B56E2,r2
	ld	r2,#B56E2
	set	r2,#0
	ld	B56E4,r2
	ld	r2,#B56E4
	ld	B56E8,r2
	ld	r2,#B56E2
	ld	B56E6,r2
L3F22:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B56E6
L3F36:
	clr	B56EC
L3F3A:
	bit	@r13,#0
	jr	ne,L3F64
	jr	L3F44
L3F40:
	ld	r2,@r12
	ld	@r13,r2
L3F44:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L3F40
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L3F64
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L4016
L3F64:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L3F3A
	cp	r12,B56E8
	jr	ne,L3F7A
	cp	r13,#B56E2
	jr	eq,L3F80
L3F7A:
	xor	r2,r2
L3F7C:
	jp	cret
L3F80:
	inc	B56EC,#1
	cp	B56EC,#%0001
	jr	le,L3F3A
	ld	r3,r11
	add	r3,#%0200
	exts	rr2
	div	rr2,#%0200
	ld	r2,r3
	sla	r2,#9
	ld	B56EC,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B56EC
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L3F7A
	ld	r2,B56EC
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L3F7A
	ld	r2,B56E8
	ld	@r2,r12
	ld	r2,B56E8
	inc	r2,#2
	cp	r2,r12
	jr	eq,L3FF6
	ld	r2,B56E8
	ld	r3,r2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r4
L3FF6:
	ld	r2,B56EC
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B56E8,r2
	ld	r2,B56E8
	ld	r3,#B56E2
	set	r3,#0
	ld	@r2,r3
	jr	L3F36
L4016:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B56E6,r2
	cp	r12,r2
	jr	ule,L4030
	ld	r3,@r2
	ld	B56EA,r3
	ld	r3,@r13
	ld	@r2,r3
L4030:
	ld	r2,B56E6
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L3F7C
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B56E6,r12
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
	jr	eq,L406E
	push	@r15,r13
	call	_free
	inc	r15,#2
L406E:
	ld	r3,%FFFE(r13)
	sub	r3,r13
	exts	rr2
	div	rr2,#%0002
	ld	r10,r3
	push	@r15,%0006(r14)
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	test	r12
	jr	eq,L4090
	cp	r12,r13
	jr	ne,L4096
L4090:
	ld	r2,r12
	jp	cret
L4096:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L40BE
	ld	r10,r11
	jr	L40BE
L40B2:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L40BE:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L40B2
	cp	r12,r13
	jr	uge,L4090
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L4090
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
	ld	r3,B56EA
	ld	@r2,r3
	jr	L4090
end _realloc
$SECTION BSS_B
I
B56E2:
$REL	$+%2
B56E4:
$REL	$+%2
B56E6:
$REL	$+%2
B56E8:
$REL	$+%2
B56EA:
$REL	$+%2
B56EC:
$REL	$+%2
$SDEFAULT
end malloc_
