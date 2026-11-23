filbuf_ module
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
G	__filbuf	PR
E
__filbuf:
	call	csv
	ld	r13,%0004(r14)
	bitb	%0006(r13),#7
	jr	eq,L4A88
	bitb	%0006(r13),#1
	jr	eq,L4A84
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L4A84:
	setb	%0006(r13),#0
L4A88:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L4A9A
	bitb	%0006(r13),#6
	jr	eq,L4AB2
L4A9A:
	ld	r2,#%FFFF
L4A9E:
	jp	cret
L4AA2:
	cp	r13,#__iob
	jr	ne,L4AD4
	ld	r2,#__sibuf
	jr	L4AC8
L4AAE:
	setb	%0006(r13),#2
L4AB2:
	test	%0004(r13)
	jr	ne,L4AF0
	bitb	%0006(r13),#2
	jr	eq,L4AA2
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#BD104
L4AC8:
	ld	%0004(r13),r2
	jr	L4AB2
L4ACE:
	ld	r2,#__sobuf
	jr	L4AC8
L4AD4:
	cp	r13,#%8+__iob
	jr	eq,L4ACE
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L4AAE
	setb	%0006(r13),#3
L4AF0:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L4B02
	push	@r15,#%0001
	jr	L4B06
L4B02:
	push	@r15,#%0200
L4B06:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L4B48
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L4B3E
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L4B42
	resb	%0006(r13),#0
	jr	L4B42
L4B3E:
	setb	%0006(r13),#5
L4B42:
	clr	%0002(r13)
	jr	L4A9A
L4B48:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L4A9E
end __filbuf
$SECTION BSS_B
I
BD104:
$REL	$+%14
$SDEFAULT
end filbuf_
