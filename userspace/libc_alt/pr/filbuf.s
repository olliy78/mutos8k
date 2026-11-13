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
	jr	eq,L0B2C
	bitb	%0006(r13),#1
	jr	eq,L0B28
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L0B28:
	setb	%0006(r13),#0
L0B2C:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L0B3E
	bitb	%0006(r13),#6
	jr	eq,L0B56
L0B3E:
	ld	r2,#%FFFF
L0B42:
	jp	cret
L0B46:
	cp	r13,#__iob
	jr	ne,L0B78
	ld	r2,#__sibuf
	jr	L0B6C
L0B52:
	setb	%0006(r13),#2
L0B56:
	test	%0004(r13)
	jr	ne,L0B94
	bitb	%0006(r13),#2
	jr	eq,L0B46
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B417A
L0B6C:
	ld	%0004(r13),r2
	jr	L0B56
L0B72:
	ld	r2,#__sobuf
	jr	L0B6C
L0B78:
	cp	r13,#%8+__iob
	jr	eq,L0B72
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L0B52
	setb	%0006(r13),#3
L0B94:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0BA6
	push	@r15,#%0001
	jr	L0BAA
L0BA6:
	push	@r15,#%0200
L0BAA:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L0BEC
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0BE2
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0BE6
	resb	%0006(r13),#0
	jr	L0BE6
L0BE2:
	setb	%0006(r13),#5
L0BE6:
	clr	%0002(r13)
	jr	L0B3E
L0BEC:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L0B42
end __filbuf
$SECTION BSS_B
I
B417A:
$REL	$+%14
$SDEFAULT
end filbuf_
