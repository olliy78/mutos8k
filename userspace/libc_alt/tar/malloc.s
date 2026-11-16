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
	test	B58E8
	jr	ne,L3326
	ld	r2,#B58EA
	set	r2,#0
	ld	B58E8,r2
	ld	r2,#B58E8
	set	r2,#0
	ld	B58EA,r2
	ld	r2,#B58EA
	ld	B58EE,r2
	ld	r2,#B58E8
	ld	B58EC,r2
L3326:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B58EC
L333A:
	clr	B58F2
L333E:
	bit	@r13,#0
	jr	ne,L3368
	jr	L3348
L3344:
	ld	r2,@r12
	ld	@r13,r2
L3348:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L3344
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L3368
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L341A
L3368:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L333E
	cp	r12,B58EE
	jr	ne,L337E
	cp	r13,#B58E8
	jr	eq,L3384
L337E:
	xor	r2,r2
L3380:
	jp	cret
L3384:
	inc	B58F2,#1
	cp	B58F2,#%0001
	jr	le,L333E
	ld	r3,r11
	add	r3,#%0200
	exts	rr2
	div	rr2,#%0200
	ld	r2,r3
	sla	r2,#9
	ld	B58F2,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B58F2
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L337E
	ld	r2,B58F2
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L337E
	ld	r2,B58EE
	ld	@r2,r12
	ld	r2,B58EE
	inc	r2,#2
	cp	r2,r12
	jr	eq,L33FA
	ld	r2,B58EE
	ld	r3,r2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r4
L33FA:
	ld	r2,B58F2
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B58EE,r2
	ld	r2,B58EE
	ld	r3,#B58E8
	set	r3,#0
	ld	@r2,r3
	jr	L333A
L341A:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B58EC,r2
	cp	r12,r2
	jr	ule,L3434
	ld	r3,@r2
	ld	B58F0,r3
	ld	r3,@r13
	ld	@r2,r3
L3434:
	ld	r2,B58EC
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L3380
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B58EC,r12
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
	jr	eq,L3472
	push	@r15,r13
	call	_free
	inc	r15,#2
L3472:
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
	jr	eq,L3494
	cp	r12,r13
	jr	ne,L349A
L3494:
	ld	r2,r12
	jp	cret
L349A:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L34C2
	ld	r10,r11
	jr	L34C2
L34B6:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L34C2:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L34B6
	cp	r12,r13
	jr	uge,L3494
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L3494
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
	ld	r3,B58F0
	ld	@r2,r3
	jr	L3494
end _realloc
$SECTION BSS_B
I
B58E8:
$REL	$+%2
B58EA:
$REL	$+%2
B58EC:
$REL	$+%2
B58EE:
$REL	$+%2
B58F0:
$REL	$+%2
B58F2:
$REL	$+%2
$SDEFAULT
end malloc_
