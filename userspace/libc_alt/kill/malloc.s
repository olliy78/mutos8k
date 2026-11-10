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
	test	B12D2
	jr	ne,L081A
	ld	r2,#B12D4
	set	r2,#0
	ld	B12D2,r2
	ld	r2,#B12D2
	set	r2,#0
	ld	B12D4,r2
	ld	r2,#B12D4
	ld	B12D8,r2
	ld	r2,#B12D2
	ld	B12D6,r2
L081A:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B12D6
L082E:
	clr	B12DC
L0832:
	bit	@r13,#0
	jr	ne,L085C
	jr	L083C
L0838:
	ld	r2,@r12
	ld	@r13,r2
L083C:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0838
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L085C
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0912
L085C:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0832
	cp	r12,B12D8
	jr	ne,L0872
	cp	r13,#B12D2
	jr	eq,L0878
L0872:
	xor	r2,r2
L0874:
	jp	cret
L0878:
	inc	B12DC,#1
	ld	r0,B12DC
	cp	r0,#%0001
	jr	le,L0832
	ld	r2,r11
	add	r2,#%D6+__doprnt
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B12DC,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B12DC
	sla	r2,#1
	add	r2,r12
	add	r2,#%D6+__doprnt
	cp	r2,r12
	jr	ult,L0872
	ld	r2,B12DC
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0872
	ld	r2,B12D8
	ld	@r2,r12
	ld	r2,B12D8
	inc	r2,#2
	cp	r2,r12
	jr	eq,L08F2
	ld	r2,B12D8
	ld	r3,B12D8
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L08F2:
	ld	r2,B12DC
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B12D8,r2
	ld	r2,B12D8
	ld	r3,#B12D2
	set	r3,#0
	ld	@r2,r3
	jr	L082E
L0912:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B12D6,r2
	cp	r12,r2
	jr	ule,L092C
	ld	r3,@r2
	ld	B12DA,r3
	ld	r3,@r13
	ld	@r2,r3
L092C:
	ld	r2,B12D6
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0874
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B12D6,r12
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
	jr	eq,L096A
	push	@r15,r13
	call	_free
	inc	r15,#2
L096A:
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
	jr	eq,L098E
	cp	r12,r13
	jr	ne,L0994
L098E:
	ld	r2,r12
	jp	cret
L0994:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L09BC
	ld	r10,r11
	jr	L09BC
L09B0:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L09BC:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L09B0
	cp	r12,r13
	jr	uge,L098E
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L098E
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
	ld	r3,B12DA
	ld	@r2,r3
	jr	L098E
end _realloc
$SECTION BSS_B
I
B12D2:
$REL	$+%2
B12D4:
$REL	$+%2
B12D6:
$REL	$+%2
B12D8:
$REL	$+%2
B12DA:
$REL	$+%2
B12DC:
$REL	$+%2
$SDEFAULT
end malloc_
