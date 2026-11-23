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
	test	B92C8
	jr	ne,L72B2
	ld	r2,#B92CA
	set	r2,#0
	ld	B92C8,r2
	ld	r2,#B92C8
	set	r2,#0
	ld	B92CA,r2
	ld	r2,#B92CA
	ld	B92CE,r2
	ld	r2,#B92C8
	ld	B92CC,r2
L72B2:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B92CC
L72C6:
	clr	B92D2
L72CA:
	bit	@r13,#0
	jr	ne,L72F4
	jr	L72D4
L72D0:
	ld	r2,@r12
	ld	@r13,r2
L72D4:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L72D0
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L72F4
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L73A6
L72F4:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L72CA
	cp	r12,B92CE
	jr	ne,L730A
	cp	r13,#B92C8
	jr	eq,L7310
L730A:
	xor	r2,r2
L730C:
	jp	cret
L7310:
	inc	B92D2,#1
	cp	B92D2,#%0001
	jr	le,L72CA
	ld	r3,r11
	add	r3,#%0200
	exts	rr2
	div	rr2,#%0200
	ld	r2,r3
	sla	r2,#9
	ld	B92D2,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B92D2
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L730A
	ld	r2,B92D2
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L730A
	ld	r2,B92CE
	ld	@r2,r12
	ld	r2,B92CE
	inc	r2,#2
	cp	r2,r12
	jr	eq,L7386
	ld	r2,B92CE
	ld	r3,r2
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r4
L7386:
	ld	r2,B92D2
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B92CE,r2
	ld	r2,B92CE
	ld	r3,#B92C8
	set	r3,#0
	ld	@r2,r3
	jr	L72C6
L73A6:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B92CC,r2
	cp	r12,r2
	jr	ule,L73C0
	ld	r3,@r2
	ld	B92D0,r3
	ld	r3,@r13
	ld	@r2,r3
L73C0:
	ld	r2,B92CC
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L730C
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B92CC,r12
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
	jr	eq,L73FE
	push	@r15,r13
	call	_free
	inc	r15,#2
L73FE:
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
	jr	eq,L7420
	cp	r12,r13
	jr	ne,L7426
L7420:
	ld	r2,r12
	jp	cret
L7426:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L744E
	ld	r10,r11
	jr	L744E
L7442:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L744E:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L7442
	cp	r12,r13
	jr	uge,L7420
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L7420
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
	ld	r3,B92D0
	ld	@r2,r3
	jr	L7420
end _realloc
$SECTION BSS_B
I
B92C8:
$REL	$+%2
B92CA:
$REL	$+%2
B92CC:
$REL	$+%2
B92CE:
$REL	$+%2
B92D0:
$REL	$+%2
B92D2:
$REL	$+%2
$SDEFAULT
end malloc_
