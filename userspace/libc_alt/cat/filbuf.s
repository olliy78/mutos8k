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
	jr	eq,L0296
	bitb	%0006(r13),#1
	jr	eq,L0292
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L0292:
	setb	%0006(r13),#0
L0296:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L02A8
	bitb	%0006(r13),#6
	jr	eq,L02C0
L02A8:
	ld	r2,#%FFFF
L02AC:
	jp	cret
L02B0:
	cp	r13,#__iob
	jr	ne,L02E2
	ld	r2,#__sibuf
	jr	L02D6
L02BC:
	setb	%0006(r13),#2
L02C0:
	test	%0004(r13)
	jr	ne,L02FE
	bitb	%0006(r13),#2
	jr	eq,L02B0
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B15EA
L02D6:
	ld	%0004(r13),r2
	jr	L02C0
L02DC:
	ld	r2,#__sobuf
	jr	L02D6
L02E2:
	cp	r13,#%8+__iob
	jr	eq,L02DC
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L02BC
	setb	%0006(r13),#3
L02FE:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0310
	push	@r15,#%0001
	jr	L0314
L0310:
	push	@r15,#%0200
L0314:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L0356
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L034C
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0350
	resb	%0006(r13),#0
	jr	L0350
L034C:
	setb	%0006(r13),#5
L0350:
	clr	%0002(r13)
	jr	L02A8
L0356:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L02AC
end __filbuf
$SECTION BSS_B
I
B15EA:
$REL	$+%14
$SDEFAULT
end filbuf_
