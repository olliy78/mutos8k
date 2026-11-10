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
	jr	eq,L046A
	bitb	%0006(r13),#1
	jr	eq,L0466
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L0466:
	setb	%0006(r13),#0
L046A:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L047C
	bitb	%0006(r13),#6
	jr	eq,L0494
L047C:
	ld	r2,#%FFFF
L0480:
	jp	cret
L0484:
	cp	r13,#__iob
	jr	ne,L04B6
	ld	r2,#__sibuf
	jr	L04AA
L0490:
	setb	%0006(r13),#2
L0494:
	test	%0004(r13)
	jr	ne,L04D2
	bitb	%0006(r13),#2
	jr	eq,L0484
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B1630
L04AA:
	ld	%0004(r13),r2
	jr	L0494
L04B0:
	ld	r2,#__sobuf
	jr	L04AA
L04B6:
	cp	r13,#%8+__iob
	jr	eq,L04B0
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L0490
	setb	%0006(r13),#3
L04D2:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L04E4
	push	@r15,#%0001
	jr	L04E8
L04E4:
	push	@r15,#%0200
L04E8:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L052A
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0520
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0524
	resb	%0006(r13),#0
	jr	L0524
L0520:
	setb	%0006(r13),#5
L0524:
	clr	%0002(r13)
	jr	L047C
L052A:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L0480
end __filbuf
$SECTION BSS_B
I
B1630:
$REL	$+%14
$SDEFAULT
end filbuf_
