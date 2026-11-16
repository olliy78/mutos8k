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
	jr	eq,L231A
	bitb	%0006(r13),#1
	jr	eq,L2316
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L2316:
	setb	%0006(r13),#0
L231A:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L232C
	bitb	%0006(r13),#6
	jr	eq,L2344
L232C:
	ld	r2,#%FFFF
L2330:
	jp	cret
L2334:
	cp	r13,#__iob
	jr	ne,L2366
	ld	r2,#__sibuf
	jr	L235A
L2340:
	setb	%0006(r13),#2
L2344:
	test	%0004(r13)
	jr	ne,L2382
	bitb	%0006(r13),#2
	jr	eq,L2334
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B58A2
L235A:
	ld	%0004(r13),r2
	jr	L2344
L2360:
	ld	r2,#__sobuf
	jr	L235A
L2366:
	cp	r13,#%8+__iob
	jr	eq,L2360
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L2340
	setb	%0006(r13),#3
L2382:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L2394
	push	@r15,#%0001
	jr	L2398
L2394:
	push	@r15,#%0200
L2398:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L23DA
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L23D0
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L23D4
	resb	%0006(r13),#0
	jr	L23D4
L23D0:
	setb	%0006(r13),#5
L23D4:
	clr	%0002(r13)
	jr	L232C
L23DA:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L2330
end __filbuf
$SECTION BSS_B
I
B58A2:
$REL	$+%14
$SDEFAULT
end filbuf_
