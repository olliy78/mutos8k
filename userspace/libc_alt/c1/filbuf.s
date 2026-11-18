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
	jr	eq,L6A32
	bitb	%0006(r13),#1
	jr	eq,L6A2E
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L6A2E:
	setb	%0006(r13),#0
L6A32:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L6A44
	bitb	%0006(r13),#6
	jr	eq,L6A5C
L6A44:
	ld	r2,#%FFFF
L6A48:
	jp	cret
L6A4C:
	cp	r13,#__iob
	jr	ne,L6A7E
	ld	r2,#%8E96
	jr	L6A72
L6A58:
	setb	%0006(r13),#2
L6A5C:
	test	%0004(r13)
	jr	ne,L6A9A
	bitb	%0006(r13),#2
	jr	eq,L6A4C
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B92B4
L6A72:
	ld	%0004(r13),r2
	jr	L6A5C
L6A78:
	ld	r2,#%1E4+__sibuf
	jr	L6A72
L6A7E:
	cp	r13,#%8+__iob
	jr	eq,L6A78
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L6A58
	setb	%0006(r13),#3
L6A9A:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L6AAC
	push	@r15,#%0001
	jr	L6AB0
L6AAC:
	push	@r15,#%0200
L6AB0:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L6AF2
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L6AE8
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L6AEC
	resb	%0006(r13),#0
	jr	L6AEC
L6AE8:
	setb	%0006(r13),#5
L6AEC:
	clr	%0002(r13)
	jr	L6A44
L6AF2:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L6A48
end __filbuf
$SECTION BSS_B
I
B92B4:
$REL	$+%14
$SDEFAULT
end filbuf_
