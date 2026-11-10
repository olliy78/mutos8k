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
	jr	eq,L02B2
	bitb	%0006(r13),#1
	jr	eq,L02AE
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L02AE:
	setb	%0006(r13),#0
L02B2:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L02C4
	bitb	%0006(r13),#6
	jr	eq,L02DC
L02C4:
	ld	r2,#%FFFF
L02C8:
	jp	cret
L02CC:
	cp	r13,#__iob
	jr	ne,L02FE
	ld	r2,#__sibuf
	jr	L02F2
L02D8:
	setb	%0006(r13),#2
L02DC:
	test	%0004(r13)
	jr	ne,L031A
	bitb	%0006(r13),#2
	jr	eq,L02CC
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B13D2
L02F2:
	ld	%0004(r13),r2
	jr	L02DC
L02F8:
	ld	r2,#__sobuf
	jr	L02F2
L02FE:
	cp	r13,#%8+__iob
	jr	eq,L02F8
	push	@r15,#%36+_fwrite
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L02D8
	setb	%0006(r13),#3
L031A:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L032C
	push	@r15,#%0001
	jr	L0330
L032C:
	push	@r15,#%36+_fwrite
L0330:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L0372
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0368
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L036C
	resb	%0006(r13),#0
	jr	L036C
L0368:
	setb	%0006(r13),#5
L036C:
	clr	%0002(r13)
	jr	L02C4
L0372:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L02C8
end __filbuf
$SECTION BSS_B
I
B13D2:
$REL	$+%14
$SDEFAULT
end filbuf_
