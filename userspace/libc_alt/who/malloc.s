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
	test	B2082
	jr	ne,L13E4
	ld	r2,#B2084
	set	r2,#0
	ld	B2082,r2
	ld	r2,#B2082
	set	r2,#0
	ld	B2084,r2
	ld	r2,#B2084
	ld	B2088,r2
	ld	r2,#B2082
	ld	B2086,r2
L13E4:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B2086
L13F8:
	clr	B208C
L13FC:
	bit	@r13,#0
	jr	ne,L1426
	jr	L1406
L1402:
	ld	r2,@r12
	ld	@r13,r2
L1406:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L1402
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L1426
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L14DC
L1426:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L13FC
	cp	r12,B2088
	jr	ne,L143C
	cp	r13,#B2082
	jr	eq,L1442
L143C:
	xor	r2,r2
L143E:
	jp	cret
L1442:
	inc	B208C,#1
	ld	r0,B208C
	cp	r0,#%0001
	jr	le,L13FC
	ld	r2,r11
	add	r2,#%30+_endpwen
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B208C,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B208C
	sla	r2,#1
	add	r2,r12
	add	r2,#%30+_endpwen
	cp	r2,r12
	jr	ult,L143C
	ld	r2,B208C
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L143C
	ld	r2,B2088
	ld	@r2,r12
	ld	r2,B2088
	inc	r2,#2
	cp	r2,r12
	jr	eq,L14BC
	ld	r2,B2088
	ld	r3,B2088
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L14BC:
	ld	r2,B208C
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B2088,r2
	ld	r2,B2088
	ld	r3,#B2082
	set	r3,#0
	ld	@r2,r3
	jr	L13F8
L14DC:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B2086,r2
	cp	r12,r2
	jr	ule,L14F6
	ld	r3,@r2
	ld	B208A,r3
	ld	r3,@r13
	ld	@r2,r3
L14F6:
	ld	r2,B2086
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L143E
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B2086,r12
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
	jr	eq,L1534
	push	@r15,r13
	call	_free
	inc	r15,#2
L1534:
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
	jr	eq,L1558
	cp	r12,r13
	jr	ne,L155E
L1558:
	ld	r2,r12
	jp	cret
L155E:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L1586
	ld	r10,r11
	jr	L1586
L157A:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L1586:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L157A
	cp	r12,r13
	jr	uge,L1558
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L1558
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
	ld	r3,B208A
	ld	@r2,r3
	jr	L1558
end _realloc
$SECTION BSS_B
I
B2082:
$REL	$+%2
B2084:
$REL	$+%2
B2086:
$REL	$+%2
B2088:
$REL	$+%2
B208A:
$REL	$+%2
B208C:
$REL	$+%2
$SDEFAULT
end malloc_
