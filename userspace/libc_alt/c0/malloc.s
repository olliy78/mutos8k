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
	test	B97D6
	jr	ne,L58AC
	ld	r2,#B97D8
	set	r2,#0
	ld	B97D6,r2
	ld	r2,#B97D6
	set	r2,#0
	ld	B97D8,r2
	ld	r2,#B97D8
	ld	B97DC,r2
	ld	r2,#B97D6
	ld	B97DA,r2
L58AC:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B97DA
L58C0:
	clr	B97E0
L58C4:
	bit	@r13,#0
	jr	ne,L58EE
	jr	L58CE
L58CA:
	ld	r2,@r12
	ld	@r13,r2
L58CE:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L58CA
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L58EE
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L59A0
L58EE:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L58C4
	cp	r12,B97DC
	jr	ne,L5904
	cp	r13,#B97D6
	jr	eq,L590A
L5904:
	xor	r2,r2
L5906:
	jp	cret
L590A:
	inc	B97E0,#1
	cp	B97E0,#%0001
	jr	le,L58C4
	ld	r3,r11
	add	r3,#%0200
	exts	rr2
	div	rr2,#%0200
	ld	r2,r3
	sla	r2,#9
	ld	B97E0,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B97E0
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L5904
	ld	r2,B97E0
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L5904
	ld	r2,B97DC
	ld	@r2,r12
	ld	r2,B97DC
	inc	r2,#2
	cp	r2,r12
	jr	eq,L5980
	ld	r2,B97DC
	ld	r3,r2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r4
L5980:
	ld	r2,B97E0
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B97DC,r2
	ld	r2,B97DC
	ld	r3,#B97D6
	set	r3,#0
	ld	@r2,r3
	jr	L58C0
L59A0:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B97DA,r2
	cp	r12,r2
	jr	ule,L59BA
	ld	r3,@r2
	ld	B97DE,r3
	ld	r3,@r13
	ld	@r2,r3
L59BA:
	ld	r2,B97DA
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L5906
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B97DA,r12
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
	jr	eq,L59F8
	push	@r15,r13
	call	_free
	inc	r15,#2
L59F8:
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
	jr	eq,L5A1A
	cp	r12,r13
	jr	ne,L5A20
L5A1A:
	ld	r2,r12
	jp	cret
L5A20:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L5A48
	ld	r10,r11
	jr	L5A48
L5A3C:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L5A48:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L5A3C
	cp	r12,r13
	jr	uge,L5A1A
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L5A1A
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
	ld	r3,B97DE
	ld	@r2,r3
	jr	L5A1A
end _realloc
$SECTION BSS_B
I
B97D6:
$REL	$+%2
B97D8:
$REL	$+%2
B97DA:
$REL	$+%2
B97DC:
$REL	$+%2
B97DE:
$REL	$+%2
B97E0:
$REL	$+%2
$SDEFAULT
end malloc_
