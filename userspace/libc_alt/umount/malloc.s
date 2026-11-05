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
	test	B1802
	jr	ne,L08B6
	ld	r2,#B1804
	set	r2,#0
	ld	B1802,r2
	ld	r2,#B1802
	set	r2,#0
	ld	B1804,r2
	ld	r2,#B1804
	ld	B1808,r2
	ld	r2,#B1802
	ld	B1806,r2
L08B6:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1806
L08CA:
	clr	B180C
L08CE:
	bit	@r13,#0
	jr	ne,L08F8
	jr	L08D8
L08D4:
	ld	r2,@r12
	ld	@r13,r2
L08D8:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L08D4
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L08F8
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L09AE
L08F8:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L08CE
	cp	r12,B1808
	jr	ne,L090E
	cp	r13,#B1802
	jr	eq,L0914
L090E:
	xor	r2,r2
L0910:
	jp	cret
L0914:
	inc	B180C,#1
	ld	r0,B180C
	cp	r0,#%0001
	jr	le,L08CE
	ld	r2,r11
	add	r2,#%44+__doprnt
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B180C,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B180C
	sla	r2,#1
	add	r2,r12
	add	r2,#%44+__doprnt
	cp	r2,r12
	jr	ult,L090E
	ld	r2,B180C
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L090E
	ld	r2,B1808
	ld	@r2,r12
	ld	r2,B1808
	inc	r2,#2
	cp	r2,r12
	jr	eq,L098E
	ld	r2,B1808
	ld	r3,B1808
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L098E:
	ld	r2,B180C
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1808,r2
	ld	r2,B1808
	ld	r3,#B1802
	set	r3,#0
	ld	@r2,r3
	jr	L08CA
L09AE:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1806,r2
	cp	r12,r2
	jr	ule,L09C8
	ld	r3,@r2
	ld	B180A,r3
	ld	r3,@r13
	ld	@r2,r3
L09C8:
	ld	r2,B1806
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0910
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1806,r12
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
	jr	eq,L0A06
	push	@r15,r13
	call	_free
	inc	r15,#2
L0A06:
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
	jr	eq,L0A2A
	cp	r12,r13
	jr	ne,L0A30
L0A2A:
	ld	r2,r12
	jp	cret
L0A30:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0A58
	ld	r10,r11
	jr	L0A58
L0A4C:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0A58:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0A4C
	cp	r12,r13
	jr	uge,L0A2A
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0A2A
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
	ld	r3,B180A
	ld	@r2,r3
	jr	L0A2A
end _realloc
$SECTION BSS_B
I
B1802:
$REL	$+%2
B1804:
$REL	$+%2
B1806:
$REL	$+%2
B1808:
$REL	$+%2
B180A:
$REL	$+%2
B180C:
$REL	$+%2
$SDEFAULT
end malloc_
