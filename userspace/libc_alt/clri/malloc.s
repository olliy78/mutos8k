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
	test	B13EA
	jr	ne,L0968
	ld	r2,#B13EC
	set	r2,#0
	ld	B13EA,r2
	ld	r2,#B13EA
	set	r2,#0
	ld	B13EC,r2
	ld	r2,#B13EC
	ld	B13F0,r2
	ld	r2,#B13EA
	ld	B13EE,r2
L0968:
	ld	r2,%0004(r14)
	inc	r2,#3
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	ld	r13,B13EE
L097C:
	clr	B13F4
L0980:
	bit	@r13,#0
	jr	ne,L09AA
	jr	L098A
L0986:
	ld	r2,@r12
	ld	@r13,r2
L098A:
	ld	r12,@r13
	ld	r2,r12
	bit	@r2,#0
	jr	eq,L0986
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r12
	jr	ugt,L09AA
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	cp	r2,r13
	jr	uge,L0A60
L09AA:
	ld	r12,r13
	ld	r13,@r13
	res	r13,#0
	cp	r13,r12
	jr	ugt,L0980
	cp	r12,B13F0
	jr	ne,L09C0
	cp	r13,#B13EA
	jr	eq,L09C6
L09C0:
	xor	r2,r2
L09C2:
	jp	cret
L09C6:
	inc	B13F4,#1
	ld	r0,B13F4
	cp	r0,#%0001
	jr	le,L0980
	ld	r2,r11
	add	r2,#%0200
	ld	r3,#%FFF7
	sda	r2,r3
	sla	r2,#9
	ld	B13F4,r2
	push	@r15,#%0000
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	ld	r2,B13F4
	sla	r2,#1
	add	r2,r12
	add	r2,#%0200
	cp	r2,r12
	jr	ult,L09C0
	ld	r2,B13F4
	sla	r2,#1
	push	@r15,r2
	call	_sbrk
	inc	r15,#2
	ld	r12,r2
	cp	r12,#%FFFF
	jr	eq,L09C0
	ld	r2,B13F0
	ld	@r2,r12
	ld	r2,B13F0
	inc	r2,#2
	cp	r2,r12
	jr	eq,L0A40
	ld	r2,B13F0
	ld	r3,B13F0
	ld	r4,@r3
	set	r4,#0
	ld	r3,r4
	ld	@r2,r3
L0A40:
	ld	r2,B13F4
	sla	r2,#1
	add	r2,r12
	dec	r2,#2
	ld	@r12,r2
	ld	B13F0,r2
	ld	r2,B13F0
	ld	r3,#B13EA
	set	r3,#0
	ld	@r2,r3
	jr	L097C
L0A60:
	ld	r2,r11
	sla	r2,#1
	add	r2,r13
	ld	B13EE,r2
	cp	r12,r2
	jr	ule,L0A7A
	ld	r3,@r2
	ld	B13F2,r3
	ld	r3,@r13
	ld	@r2,r3
L0A7A:
	ld	r2,B13EE
	set	r2,#0
	ld	@r13,r2
	ld	r2,r13
	inc	r2,#2
	jr	L09C2
end _malloc
G	_free	PR
E
_free:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,r13
	dec	r12,#2
	ld	B13EE,r12
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
	jr	eq,L0AB8
	push	@r15,r13
	call	_free
	inc	r15,#2
L0AB8:
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
	jr	eq,L0ADC
	cp	r12,r13
	jr	ne,L0AE2
L0ADC:
	ld	r2,r12
	jp	cret
L0AE2:
	ld	r9,r13
	ld	r8,r12
	ld	r2,%0006(r14)
	inc	r2,#1
	ld	r3,#%FFFF
	sdl	r2,r3
	ld	r11,r2
	cp	r11,r10
	jr	uge,L0B0A
	ld	r10,r11
	jr	L0B0A
L0AFE:
	ld	r2,r8
L0B00:
	inc	r8,#2
	ld	r3,r9
	inc	r9,#2
	ld	r4,@r3
	ld	@r2,r4
L0B0A:
	ld	r2,r10
	dec	r10,#1
	test	r2
	jr	ne,L0AFE
	cp	r12,r13
	jr	uge,L0ADC
	ld	r2,r11
	sll	r2,#1
	add	r2,r12
	cp	r2,r13
	jr	ult,L0ADC
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
	ld	r3,B13F2
	ld	@r2,r3
	jr	L0ADC
end _realloc
$SECTION BSS_B
I
B13EA:
$REL	$+%2
B13EC:
$REL	$+%2
B13EE:
$REL	$+%2
B13F0:
$REL	$+%2
B13F2:
$REL	$+%2
B13F4:
$REL	$+%2
$SDEFAULT
end malloc_
