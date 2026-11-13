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
	test	B3FAC
	jr	ne,L2660
	ld	r2,#B3FAE
	set	r2,#0
	ld	B3FAC,r2
	ld	r2,#B3FAC
	set	r2,#0
	ld	B3FAE,r2
	ld	r2,#B3FAE
	ld	B3FB2,r2
	ld	r2,#B3FAC
	ld	B3FB0,r2
L2660:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B3FB0
L2674:
	clr	B3FB6
L2678:
	bit	@r13,#0
	jr	ne,L26A2
	jr	L2682
L267E:
	ld	r2,@r12
	ld	@r13,r2
L2682:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L267E
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L26A2
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L2758
L26A2:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L2678
	cp	r12,B3FB2
	jr	ne,L26B8
	cp	r13,#B3FAC
	jr	eq,L26BE
L26B8:
	xor	r2,r2
L26BA:
	jp	cret
L26BE:
	inc	B3FB6,#1
	ld	r0,B3FB6
	cp	r0,#%0001
	jr	le,L2678
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B3FB6,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B3FB6
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L26B8
	ld	r2,B3FB6
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L26B8
	ld	r2,B3FB2
	ld	@r2,r12
	ld	r2,B3FB2
	inc	r2,#2
	cp	r2,r12
	jr	eq,L2738
	ld	r2,B3FB2
	ld	r3,B3FB2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L2738:
	ld	r2,B3FB6
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B3FB2,r2
	ld	r2,B3FB2
	ld	r3,#B3FAC
	set	r3,#0
	ld	@r2,r3
	jr	L2674
L2758:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B3FB0,r2
	cp	r12,r2
	jr	ule,L2772
	ld	r3,@r2
	ld	B3FB4,r3
	ld	r3,@r13
	ld	@r2,r3
L2772:
	ld	r2,B3FB0
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L26BA
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B3FB0,r12
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
	jr	eq,L27B0
	push	@r15,r13
	call	_free
	inc	r15,#2
L27B0:
	ld	r3,%FFFE(r13)
	sub	r3,r13
	exts	rr2
	div	rr2,#%0002
	ld	r2,r3
	ld	r10,r2
L27C0:
	push	@r15,%0006(r14)
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	test	r12
	jr	eq,L27D4
	cp	r12,r13
	jr	ne,L27DA
L27D4:
	ld	r2,r12
	jp	cret
L27DA:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L2802
	ld	r10,r11
	jr	L2802
L27F6:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L2802:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L27F6
	cp	r12,r13
	jr	uge,L27D4
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L27D4
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
	ld	r3,B3FB4
	ld	@r2,r3
	jr	L27D4
end _realloc
$SECTION BSS_B
I
B3FAC:
$REL	$+%2
B3FAE:
$REL	$+%2
B3FB0:
$REL	$+%2
B3FB2:
$REL	$+%2
B3FB4:
$REL	$+%2
B3FB6:
$REL	$+%2
$SDEFAULT
end malloc_
