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
	jr	eq,L08BA
	bitb	%0006(r13),#1
	jr	eq,L08B6
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L08B6:
	setb	%0006(r13),#0
L08BA:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L08CC
	bitb	%0006(r13),#6
	jr	eq,L08E4
L08CC:
	ld	r2,#%FFFF
L08D0:
	jp	cret
L08D4:
	cp	r13,#__iob
	jr	ne,L0906
	ld	r2,#__sibuf
	jr	L08FA
L08E0:
	setb	%0006(r13),#2
L08E4:
	test	%0004(r13)
	jr	ne,L0922
	bitb	%0006(r13),#2
	jr	eq,L08D4
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B19CA
L08FA:
	ld	%0004(r13),r2
	jr	L08E4
L0900:
	ld	r2,#__sobuf
	jr	L08FA
L0906:
	cp	r13,#%8+__iob
	jr	eq,L0900
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L08E0
	setb	%0006(r13),#3
L0922:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0934
	push	@r15,#%0001
	jr	L0938
L0934:
	push	@r15,#%0200
L0938:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L097A
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0970
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0974
	resb	%0006(r13),#0
	jr	L0974
L0970:
	setb	%0006(r13),#5
L0974:
	clr	%0002(r13)
	jr	L08CC
L097A:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L08D0
end __filbuf
$SECTION BSS_B
I
B19CA:
$REL	$+%14
$SDEFAULT
end filbuf_
