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
	jr	eq,L032C
	bitb	%0006(r13),#1
	jr	eq,L0328
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L0328:
	setb	%0006(r13),#0
L032C:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L033E
	bitb	%0006(r13),#6
	jr	eq,L0356
L033E:
	ld	r2,#%FFFF
L0342:
	jp	cret
L0346:
	cp	r13,#__iob
	jr	ne,L0378
	ld	r2,#__sibuf
	jr	L036C
L0352:
	setb	%0006(r13),#2
L0356:
	test	%0004(r13)
	jr	ne,L0394
	bitb	%0006(r13),#2
	jr	eq,L0346
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B1426
L036C:
	ld	%0004(r13),r2
	jr	L0356
L0372:
	ld	r2,#__sobuf
	jr	L036C
L0378:
	cp	r13,#%8+__iob
	jr	eq,L0372
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L0352
	setb	%0006(r13),#3
L0394:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L03A6
	push	@r15,#%0001
	jr	L03AA
L03A6:
	push	@r15,#%0200
L03AA:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L03EC
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L03E2
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L03E6
	resb	%0006(r13),#0
	jr	L03E6
L03E2:
	setb	%0006(r13),#5
L03E6:
	clr	%0002(r13)
	jr	L033E
L03EC:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L0342
end __filbuf
$SECTION BSS_B
I
B1426:
$REL	$+%14
$SDEFAULT
end filbuf_
