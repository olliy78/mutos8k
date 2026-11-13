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
	jr	eq,L0840
	bitb	%0006(r13),#1
	jr	eq,L083C
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L083C:
	setb	%0006(r13),#0
L0840:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L0852
	bitb	%0006(r13),#6
	jr	eq,L086A
L0852:
	ld	r2,#%FFFF
L0856:
	jp	cret
L085A:
	cp	r13,#__iob
	jr	ne,L088C
	ld	r2,#__sibuf
	jr	L0880
L0866:
	setb	%0006(r13),#2
L086A:
	test	%0004(r13)
	jr	ne,L08A8
	bitb	%0006(r13),#2
	jr	eq,L085A
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B1BBA
L0880:
	ld	%0004(r13),r2
	jr	L086A
L0886:
	ld	r2,#__sobuf
	jr	L0880
L088C:
	cp	r13,#%8+__iob
	jr	eq,L0886
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L0866
	setb	%0006(r13),#3
L08A8:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L08BA
	push	@r15,#%0001
	jr	L08BE
L08BA:
	push	@r15,#%0200
L08BE:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L0900
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L08F6
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L08FA
	resb	%0006(r13),#0
	jr	L08FA
L08F6:
	setb	%0006(r13),#5
L08FA:
	clr	%0002(r13)
	jr	L0852
L0900:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L0856
end __filbuf
$SECTION BSS_B
I
B1BBA:
$REL	$+%14
$SDEFAULT
end filbuf_
