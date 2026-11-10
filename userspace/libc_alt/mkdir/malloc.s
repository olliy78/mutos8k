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
	test	B1360
	jr	ne,L0910
	ld	r2,#B1362
	set	r2,#0
	ld	B1360,r2
	ld	r2,#B1360
	set	r2,#0
	ld	B1362,r2
	ld	r2,#B1362
	ld	B1366,r2
	ld	r2,#B1360
	ld	B1364,r2
L0910:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1364
L0924:
	clr	B136A
L0928:
	bit	@r13,#0
	jr	ne,L0952
	jr	L0932
L092E:
	ld	r2,@r12
	ld	@r13,r2
L0932:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L092E
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0952
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0A08
L0952:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0928
	cp	r12,B1366
	jr	ne,L0968
	cp	r13,#B1360
	jr	eq,L096E
L0968:
	xor	r2,r2
L096A:
	jp	cret
L096E:
	inc	B136A,#1
	ld	r0,B136A
	cp	r0,#%0001
	jr	le,L0928
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B136A,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B136A
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L0968
	ld	r2,B136A
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0968
	ld	r2,B1366
	ld	@r2,r12
	ld	r2,B1366
	inc	r2,#2
	cp	r2,r12
	jr	eq,L09E8
	ld	r2,B1366
	ld	r3,B1366
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L09E8:
	ld	r2,B136A
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1366,r2
	ld	r2,B1366
	ld	r3,#B1360
	set	r3,#0
	ld	@r2,r3
	jr	L0924
L0A08:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1364,r2
	cp	r12,r2
	jr	ule,L0A22
	ld	r3,@r2
	ld	B1368,r3
	ld	r3,@r13
	ld	@r2,r3
L0A22:
	ld	r2,B1364
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L096A
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1364,r12
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
	jr	eq,L0A60
	push	@r15,r13
	call	_free
	inc	r15,#2
L0A60:
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
	jr	eq,L0A84
	cp	r12,r13
	jr	ne,L0A8A
L0A84:
	ld	r2,r12
	jp	cret
L0A8A:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0AB2
	ld	r10,r11
	jr	L0AB2
L0AA6:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0AB2:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0AA6
	cp	r12,r13
	jr	uge,L0A84
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0A84
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
	ld	r3,B1368
	ld	@r2,r3
	jr	L0A84
end _realloc
$SECTION BSS_B
I
B1360:
$REL	$+%2
B1362:
$REL	$+%2
B1364:
$REL	$+%2
B1366:
$REL	$+%2
B1368:
$REL	$+%2
B136A:
$REL	$+%2
$SDEFAULT
end malloc_
