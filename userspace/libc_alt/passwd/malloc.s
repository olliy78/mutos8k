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
	test	B30A4
	jr	ne,L1844
	ld	r2,#B30A6
	set	r2,#0
	ld	B30A4,r2
	ld	r2,#B30A4
	set	r2,#0
	ld	B30A6,r2
	ld	r2,#B30A6
	ld	B30AA,r2
	ld	r2,#B30A4
	ld	B30A8,r2
L1844:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B30A8
L1858:
	clr	B30AE
L185C:
	bit	@r13,#0
	jr	ne,L1886
	jr	L1866
L1862:
	ld	r2,@r12
	ld	@r13,r2
L1866:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L1862
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L1886
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L193C
L1886:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L185C
	cp	r12,B30AA
	jr	ne,L189C
	cp	r13,#B30A4
	jr	eq,L18A2
L189C:
	xor	r2,r2
L189E:
	jp	cret
L18A2:
	inc	B30AE,#1
	ld	r0,B30AE
	cp	r0,#%0001
	jr	le,L185C
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B30AE,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B30AE
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L189C
	ld	r2,B30AE
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L189C
	ld	r2,B30AA
	ld	@r2,r12
	ld	r2,B30AA
	inc	r2,#2
	cp	r2,r12
	jr	eq,L191C
	ld	r2,B30AA
	ld	r3,B30AA
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L191C:
	ld	r2,B30AE
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B30AA,r2
	ld	r2,B30AA
	ld	r3,#B30A4
	set	r3,#0
	ld	@r2,r3
	jr	L1858
L193C:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B30A8,r2
	cp	r12,r2
	jr	ule,L1956
	ld	r3,@r2
	ld	B30AC,r3
	ld	r3,@r13
	ld	@r2,r3
L1956:
	ld	r2,B30A8
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L189E
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B30A8,r12
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
	jr	eq,L1994
	push	@r15,r13
	call	_free
	inc	r15,#2
L1994:
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
	jr	eq,L19B8
	cp	r12,r13
	jr	ne,L19BE
L19B8:
	ld	r2,r12
	jp	cret
L19BE:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L19E6
	ld	r10,r11
	jr	L19E6
L19DA:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L19E6:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L19DA
	cp	r12,r13
	jr	uge,L19B8
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L19B8
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	sub	r2,r13
L1A08:
	ld	r3,r2
	exts	rr2
	div	rr2,#%0002
	ld	r2,r3
L1A12:
	sla	r2,#1
	add	r2,r12
	ld	r3,B30AC
	ld	@r2,r3
	jr	L19B8
end _realloc
$SECTION BSS_B
I
B30A4:
$REL	$+%2
B30A6:
$REL	$+%2
B30A8:
$REL	$+%2
B30AA:
$REL	$+%2
B30AC:
$REL	$+%2
B30AE:
$REL	$+%2
$SDEFAULT
end malloc_
