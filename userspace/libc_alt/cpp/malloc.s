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
	test	B8554
	jr	ne,L2FCE
	ld	r2,#B8556
	set	r2,#0
	ld	B8554,r2
	ld	r2,#B8554
	set	r2,#0
	ld	B8556,r2
	ld	r2,#B8556
	ld	B855A,r2
	ld	r2,#B8554
	ld	B8558,r2
L2FCE:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B8558
L2FE2:
	clr	B855E
L2FE6:
	bit	@r13,#0
	jr	ne,L3010
	jr	L2FF0
L2FEC:
	ld	r2,@r12
	ld	@r13,r2
L2FF0:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L2FEC
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L3010
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L30C6
L3010:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L2FE6
	cp	r12,B855A
	jr	ne,L3026
	cp	r13,#B8554
	jr	eq,L302C
L3026:
	xor	r2,r2
L3028:
	jp	cret
L302C:
	inc	B855E,#1
	ld	r0,B855E
	cp	r0,#%0001
	jr	le,L2FE6
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B855E,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B855E
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L3026
	ld	r2,B855E
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L3026
	ld	r2,B855A
	ld	@r2,r12
	ld	r2,B855A
	inc	r2,#2
	cp	r2,r12
	jr	eq,L30A6
	ld	r2,B855A
	ld	r3,B855A
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L30A6:
	ld	r2,B855E
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B855A,r2
	ld	r2,B855A
	ld	r3,#B8554
	set	r3,#0
	ld	@r2,r3
	jr	L2FE2
L30C6:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B8558,r2
	cp	r12,r2
	jr	ule,L30E0
	ld	r3,@r2
	ld	B855C,r3
	ld	r3,@r13
	ld	@r2,r3
L30E0:
	ld	r2,B8558
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L3028
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B8558,r12
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
	jr	eq,L311E
	push	@r15,r13
	call	_free
	inc	r15,#2
L311E:
	ld	r3,%FFFE(r13)
	sub	r3,r13
	exts	rr2
	div	rr2,#%0002
	ld	r2,r3
	ld	r10,r2
	push	@r15,%0006(r14)
L3132:
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	test	r12
	jr	eq,L3142
	cp	r12,r13
	jr	ne,L3148
L3142:
	ld	r2,r12
	jp	cret
L3148:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L3170
	ld	r10,r11
	jr	L3170
L3164:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L3170:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L3164
	cp	r12,r13
	jr	uge,L3142
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L3142
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
	ld	r3,B855C
	ld	@r2,r3
	jr	L3142
end _realloc
$SECTION BSS_B
I
B8554:
$REL	$+%2
B8556:
$REL	$+%2
B8558:
$REL	$+%2
B855A:
$REL	$+%2
B855C:
$REL	$+%2
B855E:
$REL	$+%2
$SDEFAULT
end malloc_
