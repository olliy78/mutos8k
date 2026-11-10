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
	test	B13DE
	jr	ne,L093A
	ld	r2,#B13E0
	set	r2,#0
	ld	B13DE,r2
	ld	r2,#B13DE
	set	r2,#0
	ld	B13E0,r2
	ld	r2,#B13E0
	ld	B13E4,r2
	ld	r2,#B13DE
	ld	B13E2,r2
L093A:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B13E2
L094E:
	clr	B13E8
L0952:
	bit	@r13,#0
	jr	ne,L097C
	jr	L095C
L0958:
	ld	r2,@r12
	ld	@r13,r2
L095C:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0958
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L097C
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0A32
L097C:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0952
	cp	r12,B13E4
	jr	ne,L0992
	cp	r13,#B13DE
	jr	eq,L0998
L0992:
	xor	r2,r2
L0994:
	jp	cret
L0998:
	inc	B13E8,#1
	ld	r0,B13E8
	cp	r0,#%0001
	jr	le,L0952
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B13E8,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B13E8
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0992
	ld	r2,B13E8
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0992
	ld	r2,B13E4
	ld	@r2,r12
	ld	r2,B13E4
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0A12
	ld	r2,B13E4
	ld	r3,B13E4
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0A12:
	ld	r2,B13E8
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B13E4,r2
	ld	r2,B13E4
	ld	r3,#B13DE
	set	r3,#0
	ld	@r2,r3
	jr	L094E
L0A32:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B13E2,r2
	cp	r12,r2
	jr	ule,L0A4C
	ld	r3,@r2
	ld	B13E6,r3
	ld	r3,@r13
	ld	@r2,r3
L0A4C:
	ld	r2,B13E2
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0994
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B13E2,r12
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
	jr	eq,L0A8A
	push	@r15,r13
	call	_free
	inc	r15,#2
L0A8A:
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
	jr	eq,L0AAE
	cp	r12,r13
	jr	ne,L0AB4
L0AAE:
	ld	r2,r12
	jp	cret
L0AB4:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0ADC
	ld	r10,r11
	jr	L0ADC
L0AD0:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0ADC:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0AD0
	cp	r12,r13
	jr	uge,L0AAE
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0AAE
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	sub	r2,r13
	ld	r3,r2
L0B00:
	exts	rr2
	div	rr2,#%0002
	ld	r2,r3
	sla	r2,#1
	add	r2,r12
	ld	r3,B13E6
	ld	@r2,r3
	jr	L0AAE
end _realloc
$SECTION BSS_B
I
B13DE:
$REL	$+%2
B13E0:
$REL	$+%2
B13E2:
$REL	$+%2
B13E4:
$REL	$+%2
B13E6:
$REL	$+%2
B13E8:
$REL	$+%2
$SDEFAULT
end malloc_
