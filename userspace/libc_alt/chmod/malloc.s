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
	test	B1292
	jr	ne,L09CC
	ld	r2,#B1294
	set	r2,#0
	ld	B1292,r2
	ld	r2,#B1292
	set	r2,#0
	ld	B1294,r2
	ld	r2,#B1294
	ld	B1298,r2
	ld	r2,#B1292
	ld	B1296,r2
L09CC:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1296
L09E0:
	clr	B129C
L09E4:
	bit	@r13,#0
	jr	ne,L0A0E
	jr	L09EE
L09EA:
	ld	r2,@r12
	ld	@r13,r2
L09EE:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L09EA
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0A0E
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0AC4
L0A0E:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L09E4
	cp	r12,B1298
	jr	ne,L0A24
	cp	r13,#B1292
	jr	eq,L0A2A
L0A24:
	xor	r2,r2
L0A26:
	jp	cret
L0A2A:
	inc	B129C,#1
	ld	r0,B129C
	cp	r0,#%0001
	jr	le,L09E4
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B129C,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B129C
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0A24
	ld	r2,B129C
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0A24
	ld	r2,B1298
	ld	@r2,r12
	ld	r2,B1298
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0AA4
	ld	r2,B1298
	ld	r3,B1298
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0AA4:
	ld	r2,B129C
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1298,r2
	ld	r2,B1298
	ld	r3,#B1292
	set	r3,#0
	ld	@r2,r3
	jr	L09E0
L0AC4:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1296,r2
	cp	r12,r2
	jr	ule,L0ADE
	ld	r3,@r2
	ld	B129A,r3
	ld	r3,@r13
	ld	@r2,r3
L0ADE:
	ld	r2,B1296
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L0A26
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1296,r12
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
	jr	eq,L0B1C
	push	@r15,r13
	call	_free
	inc	r15,#2
L0B1C:
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
	jr	eq,L0B40
	cp	r12,r13
	jr	ne,L0B46
L0B40:
	ld	r2,r12
	jp	cret
L0B46:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0B6E
	ld	r10,r11
	jr	L0B6E
L0B62:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0B6E:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0B62
	cp	r12,r13
	jr	uge,L0B40
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0B40
L0B86:
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
	ld	r3,B129A
	ld	@r2,r3
	jr	L0B40
end _realloc
$SECTION BSS_B
I
B1292:
$REL	$+%2
B1294:
$REL	$+%2
B1296:
$REL	$+%2
B1298:
$REL	$+%2
B129A:
$REL	$+%2
B129C:
$REL	$+%2
$SDEFAULT
end malloc_
