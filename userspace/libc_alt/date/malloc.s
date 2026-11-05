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
	test	B1AC2
	jr	ne,L10D4
	ld	r2,#B1AC4
	set	r2,#0
	ld	B1AC2,r2
	ld	r2,#B1AC2
	set	r2,#0
	ld	B1AC4,r2
	ld	r2,#B1AC4
	ld	B1AC8,r2
	ld	r2,#B1AC2
	ld	B1AC6,r2
L10D4:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B1AC6
L10E8:
	clr	B1ACC
L10EC:
	bit	@r13,#0
	jr	ne,L1116
	jr	L10F6
L10F2:
	ld	r2,@r12
	ld	@r13,r2
L10F6:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L10F2
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L1116
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L11CC
L1116:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L10EC
	cp	r12,B1AC8
	jr	ne,L112C
	cp	r13,#B1AC2
	jr	eq,L1132
L112C:
	xor	r2,r2
L112E:
	jp	cret
L1132:
	inc	B1ACC,#1
	ld	r0,B1ACC
	cp	r0,#%0001
	jr	le,L10EC
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B1ACC,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B1ACC
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L112C
	ld	r2,B1ACC
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L112C
	ld	r2,B1AC8
	ld	@r2,r12
	ld	r2,B1AC8
	inc	r2,#2
	cp	r2,r12
	jr	eq,L11AC
	ld	r2,B1AC8
	ld	r3,B1AC8
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L11AC:
	ld	r2,B1ACC
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B1AC8,r2
	ld	r2,B1AC8
	ld	r3,#B1AC2
	set	r3,#0
	ld	@r2,r3
	jr	L10E8
L11CC:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B1AC6,r2
	cp	r12,r2
	jr	ule,L11E6
	ld	r3,@r2
	ld	B1ACA,r3
	ld	r3,@r13
	ld	@r2,r3
L11E6:
	ld	r2,B1AC6
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L112E
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B1AC6,r12
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
	jr	eq,L1224
	push	@r15,r13
	call	_free
	inc	r15,#2
L1224:
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
	jr	eq,L1248
	cp	r12,r13
	jr	ne,L124E
L1248:
	ld	r2,r12
	jp	cret
L124E:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L1276
	ld	r10,r11
	jr	L1276
L126A:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L1276:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L126A
	cp	r12,r13
	jr	uge,L1248
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L1248
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
	ld	r3,B1ACA
	ld	@r2,r3
	jr	L1248
end _realloc
$SECTION BSS_B
I
B1AC2:
$REL	$+%2
B1AC4:
$REL	$+%2
B1AC6:
$REL	$+%2
B1AC8:
$REL	$+%2
B1ACA:
$REL	$+%2
B1ACC:
$REL	$+%2
$SDEFAULT
end malloc_
