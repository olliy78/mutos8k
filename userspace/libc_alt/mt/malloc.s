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
	test	B14F0
	jr	ne,L0906
	ld	r2,#B14F2
	set	r2,#0
	ld	B14F0,r2
	ld	r2,#B14F0
	set	r2,#0
	ld	B14F2,r2
	ld	r2,#B14F2
	ld	B14F6,r2
	ld	r2,#B14F0
	ld	B14F4,r2
L0906:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B14F4
L091A:
	clr	B14FA
L091E:
	bit	@r13,#0
	jr	ne,L0948
	jr	L0928
L0924:
	ld	r2,@r12
	ld	@r13,r2
L0928:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0924
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0948
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L09FA
L0948:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L091E
	cp	r12,B14F6
	jr	ne,L095E
	cp	r13,#B14F0
	jr	eq,L0964
L095E:
	xor	r2,r2
L0960:
	jp	cret
L0964:
	inc	B14FA,#1
	cp	B14FA,#%0001
	jr	le,L091E
	ld	r3,r11
	add	r3,#%62+__doprnt
	exts	rr2
	div	rr2,#%62+__doprnt
	ld	r2,r3
	sla	r2,#9
	ld	B14FA,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B14FA
	sla	r2,#1
	add	r2,r12
	add	r2,#%62+__doprnt
	cp	r2,r12
	jr	ult,L095E
	ld	r2,B14FA
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L095E
	ld	r2,B14F6
	ld	@r2,r12
	ld	r2,B14F6
	inc	r2,#2
	cp	r2,r12
	jr	eq,L09DA
	ld	r2,B14F6
	ld	r3,r2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r4
L09DA:
	ld	r2,B14FA
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B14F6,r2
	ld	r2,B14F6
	ld	r3,#B14F0
	set	r3,#0
	ld	@r2,r3
	jr	L091A
L09FA:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B14F4,r2
	cp	r12,r2
	jr	ule,L0A14
	ld	r3,@r2
	ld	B14F8,r3
	ld	r3,@r13
	ld	@r2,r3
L0A14:
	ld	r2,B14F4
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0960
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B14F4,r12
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
	jr	eq,L0A52
	push	@r15,r13
	call	_free
	inc	r15,#2
L0A52:
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
	jr	eq,L0A74
	cp	r12,r13
	jr	ne,L0A7A
L0A74:
	ld	r2,r12
	jp	cret
L0A7A:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0AA2
	ld	r10,r11
	jr	L0AA2
L0A96:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0AA2:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0A96
	cp	r12,r13
	jr	uge,L0A74
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0A74
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
	ld	r3,B14F8
	ld	@r2,r3
	jr	L0A74
end _realloc
$SECTION BSS_B
I
B14F0:
$REL	$+%2
B14F2:
$REL	$+%2
B14F4:
$REL	$+%2
B14F6:
$REL	$+%2
B14F8:
$REL	$+%2
B14FA:
$REL	$+%2
$SDEFAULT
end malloc_
