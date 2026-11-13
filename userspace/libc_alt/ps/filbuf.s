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
	jr	eq,L0DC8
	bitb	%0006(r13),#1
	jr	eq,L0DC4
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L0DC4:
	setb	%0006(r13),#0
L0DC8:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L0DDA
	bitb	%0006(r13),#6
	jr	eq,L0DF2
L0DDA:
	ld	r2,#%FFFF
L0DDE:
	jp	cret
L0DE2:
	cp	r13,#__iob
	jr	ne,L0E14
	ld	r2,#__sibuf
	jr	L0E08
L0DEE:
	setb	%0006(r13),#2
L0DF2:
	test	%0004(r13)
	jr	ne,L0E30
	bitb	%0006(r13),#2
	jr	eq,L0DE2
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B57FC
L0E08:
	ld	%0004(r13),r2
	jr	L0DF2
L0E0E:
	ld	r2,#__sobuf
	jr	L0E08
L0E14:
	cp	r13,#%8+__iob
	jr	eq,L0E0E
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L0DEE
	setb	%0006(r13),#3
L0E30:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0E42
	push	@r15,#%0001
	jr	L0E46
L0E42:
	push	@r15,#%0200
L0E46:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L0E88
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0E7E
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0E82
	resb	%0006(r13),#0
	jr	L0E82
L0E7E:
	setb	%0006(r13),#5
L0E82:
	clr	%0002(r13)
	jr	L0DDA
L0E88:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L0DDE
end __filbuf
$SECTION BSS_B
I
B57FC:
$REL	$+%14
$SDEFAULT
end filbuf_
