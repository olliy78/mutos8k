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
	jr	eq,L03BA
	bitb	%0006(r13),#1
	jr	eq,L03B6
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L03B6:
	setb	%0006(r13),#0
L03BA:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L03CC
	bitb	%0006(r13),#6
	jr	eq,L03E4
L03CC:
	ld	r2,#%FFFF
L03D0:
	jp	cret
L03D4:
	cp	r13,#__iob
	jr	ne,L0406
	ld	r2,#__sibuf
	jr	L03FA
L03E0:
	setb	%0006(r13),#2
L03E4:
	test	%0004(r13)
	jr	ne,L0422
	bitb	%0006(r13),#2
	jr	eq,L03D4
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B1558
L03FA:
	ld	%0004(r13),r2
	jr	L03E4
L0400:
	ld	r2,#__sobuf
	jr	L03FA
L0406:
	cp	r13,#%8+__iob
	jr	eq,L0400
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L03E0
	setb	%0006(r13),#3
L0422:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0434
	push	@r15,#%0001
	jr	L0438
L0434:
	push	@r15,#%0200
L0438:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L047A
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0470
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0474
	resb	%0006(r13),#0
	jr	L0474
L0470:
	setb	%0006(r13),#5
L0474:
	clr	%0002(r13)
	jr	L03CC
L047A:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L03D0
end __filbuf
$SECTION BSS_B
I
B1558:
$REL	$+%14
$SDEFAULT
end filbuf_
