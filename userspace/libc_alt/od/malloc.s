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
	test	B19DE
	jr	ne,L112E
	ld	r2,#B19E0
	set	r2,#0
	ld	B19DE,r2
	ld	r2,#B19DE
	set	r2,#0
	ld	B19E0,r2
	ld	r2,#B19E0
	ld	B19E4,r2
	ld	r2,#B19DE
	ld	B19E2,r2
L112E:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B19E2
L1142:
	clr	B19E8
L1146:
	bit	@r13,#0
	jr	ne,L1170
	jr	L1150
L114C:
	ld	r2,@r12
	ld	@r13,r2
L1150:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L114C
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L1170
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L1226
L1170:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L1146
	cp	r12,B19E4
	jr	ne,L1186
	cp	r13,#B19DE
	jr	eq,L118C
L1186:
	xor	r2,r2
L1188:
	jp	cret
L118C:
	inc	B19E8,#1
	ld	r0,B19E8
	cp	r0,#%0001
	jr	le,L1146
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B19E8,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B19E8
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L1186
	ld	r2,B19E8
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L1186
	ld	r2,B19E4
	ld	@r2,r12
	ld	r2,B19E4
	inc	r2,#2
	cp	r2,r12
	jr	eq,L1206
	ld	r2,B19E4
	ld	r3,B19E4
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L1206:
	ld	r2,B19E8
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B19E4,r2
	ld	r2,B19E4
	ld	r3,#B19DE
	set	r3,#0
	ld	@r2,r3
	jr	L1142
L1226:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B19E2,r2
	cp	r12,r2
	jr	ule,L1240
	ld	r3,@r2
	ld	B19E6,r3
	ld	r3,@r13
	ld	@r2,r3
L1240:
	ld	r2,B19E2
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L1188
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B19E2,r12
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
	jr	eq,L127E
	push	@r15,r13
	call	_free
	inc	r15,#2
L127E:
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
	jr	eq,L12A2
	cp	r12,r13
	jr	ne,L12A8
L12A2:
	ld	r2,r12
	jp	cret
L12A8:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L12D0
	ld	r10,r11
	jr	L12D0
L12C4:
	ld	r2,r8
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L12D0:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L12C4
	cp	r12,r13
	jr	uge,L12A2
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L12A2
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
	ld	r3,B19E6
	ld	@r2,r3
	jr	L12A2
end _realloc
$SECTION BSS_B
I
B19DE:
$REL	$+%2
B19E0:
$REL	$+%2
B19E2:
$REL	$+%2
B19E4:
$REL	$+%2
B19E6:
$REL	$+%2
B19E8:
$REL	$+%2
$SDEFAULT
end malloc_
