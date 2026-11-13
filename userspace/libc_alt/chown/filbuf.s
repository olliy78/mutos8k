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
	jr	eq,L03E2
	bitb	%0006(r13),#1
	jr	eq,L03DE
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L03DE:
	setb	%0006(r13),#0
L03E2:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L03F4
	bitb	%0006(r13),#6
	jr	eq,L040C
L03F4:
	ld	r2,#%FFFF
L03F8:
	jp	cret
L03FC:
	cp	r13,#__iob
	jr	ne,L042E
	ld	r2,#__sibuf
	jr	L0422
L0408:
	setb	%0006(r13),#2
L040C:
	test	%0004(r13)
	jr	ne,L044A
	bitb	%0006(r13),#2
	jr	eq,L03FC
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B1BBC
L0422:
	ld	%0004(r13),r2
	jr	L040C
L0428:
	ld	r2,#__sobuf
	jr	L0422
L042E:
	cp	r13,#%8+__iob
	jr	eq,L0428
	push	@r15,#%22+_getpwen
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L0408
	setb	%0006(r13),#3
L044A:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L045C
	push	@r15,#%0001
	jr	L0460
L045C:
	push	@r15,#%22+_getpwen
L0460:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L04A2
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0498
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L049C
	resb	%0006(r13),#0
	jr	L049C
L0498:
	setb	%0006(r13),#5
L049C:
	clr	%0002(r13)
	jr	L03F4
L04A2:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L03F8
end __filbuf
$SECTION BSS_B
I
B1BBC:
$REL	$+%14
$SDEFAULT
end filbuf_
