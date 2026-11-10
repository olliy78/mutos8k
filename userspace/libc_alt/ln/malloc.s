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
	test	B14DC
	jr	ne,L094E
	ld	r2,#B14DE
	set	r2,#0
	ld	B14DC,r2
	ld	r2,#B14DC
	set	r2,#0
	ld	B14DE,r2
	ld	r2,#B14DE
	ld	B14E2,r2
	ld	r2,#B14DC
	ld	B14E0,r2
L094E:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B14E0
L0962:
	clr	B14E6
L0966:
	bit	@r13,#0
	jr	ne,L0990
	jr	L0970
L096C:
	ld	r2,@r12
	ld	@r13,r2
L0970:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L096C
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0990
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0A46
L0990:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0966
	cp	r12,B14E2
	jr	ne,L09A6
	cp	r13,#B14DC
	jr	eq,L09AC
L09A6:
	xor	r2,r2
L09A8:
	jp	cret
L09AC:
	inc	B14E6,#1
	ld	r0,B14E6
	cp	r0,#%0001
	jr	le,L0966
	ld	r2,r11
	add	r2,#%16+_sprintf
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B14E6,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B14E6
	sla	r2,#1
	add	r2,r12
	add	r2,#%16+_sprintf
	cp	r2,r12
	jr	ult,L09A6
	ld	r2,B14E6
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L09A6
	ld	r2,B14E2
	ld	@r2,r12
	ld	r2,B14E2
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0A26
	ld	r2,B14E2
	ld	r3,B14E2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0A26:
	ld	r2,B14E6
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B14E2,r2
	ld	r2,B14E2
	ld	r3,#B14DC
	set	r3,#0
	ld	@r2,r3
	jr	L0962
L0A46:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B14E0,r2
	cp	r12,r2
	jr	ule,L0A60
	ld	r3,@r2
	ld	B14E4,r3
	ld	r3,@r13
	ld	@r2,r3
L0A60:
	ld	r2,B14E0
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L09A8
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B14E0,r12
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
	jr	eq,L0A9E
	push	@r15,r13
	call	_free
	inc	r15,#2
L0A9E:
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
	jr	eq,L0AC2
	cp	r12,r13
	jr	ne,L0AC8
L0AC2:
	ld	r2,r12
	jp	cret
L0AC8:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0AF0
	ld	r10,r11
	jr	L0AF0
L0AE4:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0AF0:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0AE4
	cp	r12,r13
	jr	uge,L0AC2
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0AC2
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
	ld	r3,B14E4
	ld	@r2,r3
	jr	L0AC2
end _realloc
$SECTION BSS_B
I
B14DC:
$REL	$+%2
B14DE:
$REL	$+%2
B14E0:
$REL	$+%2
B14E2:
$REL	$+%2
B14E4:
$REL	$+%2
B14E6:
$REL	$+%2
$SDEFAULT
end malloc_
