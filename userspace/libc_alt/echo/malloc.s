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
	test	B0C6A
	jr	ne,L04D0
	ld	r2,#B0C6C
	set	r2,#0
	ld	B0C6A,r2
	ld	r2,#B0C6A
	set	r2,#0
	ld	B0C6C,r2
	ld	r2,#B0C6C
	ld	B0C70,r2
	ld	r2,#B0C6A
	ld	B0C6E,r2
L04D0:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B0C6E
L04E4:
	clr	B0C74
L04E8:
	bit	@r13,#0
	jr	ne,L0512
	jr	L04F2
L04EE:
	ld	r2,@r12
	ld	@r13,r2
L04F2:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L04EE
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L0512
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L05C8
L0512:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L04E8
	cp	r12,B0C70
	jr	ne,L0528
	cp	r13,#B0C6A
	jr	eq,L052E
L0528:
	xor	r2,r2
L052A:
	jp	cret
L052E:
	inc	B0C74,#1
	ld	r0,B0C74
	cp	r0,#%0001
	jr	le,L04E8
	ld	r2,r11
	add	r2,#%A4+__flsbuf
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B0C74,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B0C74
	sla	r2,#1
	add	r2,r12
	add	r2,#%A4+__flsbuf
	cp	r2,r12
	jr	ult,L0528
	ld	r2,B0C74
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L0528
	ld	r2,B0C70
	ld	@r2,r12
	ld	r2,B0C70
	inc	r2,#2
	cp	r2,r12
	jr	eq,L05A8
	ld	r2,B0C70
	ld	r3,B0C70
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L05A8:
	ld	r2,B0C74
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B0C70,r2
	ld	r2,B0C70
	ld	r3,#B0C6A
	set	r3,#0
	ld	@r2,r3
	jr	L04E4
L05C8:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B0C6E,r2
	cp	r12,r2
	jr	ule,L05E2
	ld	r3,@r2
	ld	B0C72,r3
	ld	r3,@r13
	ld	@r2,r3
L05E2:
	ld	r2,B0C6E
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L052A
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B0C6E,r12
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
	jr	eq,L0620
	push	@r15,r13
	call	_free
	inc	r15,#2
L0620:
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
	jr	eq,L0644
	cp	r12,r13
	jr	ne,L064A
L0644:
	ld	r2,r12
	jp	cret
L064A:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0672
	ld	r10,r11
	jr	L0672
L0666:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0672:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0666
	cp	r12,r13
	jr	uge,L0644
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0644
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
	ld	r3,B0C72
	ld	@r2,r3
	jr	L0644
end _realloc
$SECTION BSS_B
I
B0C6A:
$REL	$+%2
B0C6C:
$REL	$+%2
B0C6E:
$REL	$+%2
B0C70:
$REL	$+%2
B0C72:
$REL	$+%2
B0C74:
$REL	$+%2
$SDEFAULT
end malloc_
