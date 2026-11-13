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
	jr	eq,L088C
	bitb	%0006(r13),#1
	jr	eq,L0888
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L0888:
	setb	%0006(r13),#0
L088C:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L089E
	bitb	%0006(r13),#6
	jr	eq,L08B6
L089E:
	ld	r2,#%FFFF
L08A2:
	jp	cret
L08A6:
	cp	r13,#__iob
	jr	ne,L08D8
	ld	r2,#%25B2
	jr	L08CC
L08B2:
	setb	%0006(r13),#2
L08B6:
	test	%0004(r13)
	jr	ne,L08F4
	bitb	%0006(r13),#2
	jr	eq,L08A6
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B2BD2
L08CC:
	ld	%0004(r13),r2
	jr	L08B6
L08D2:
	ld	r2,#%1F6+__sibuf
	jr	L08CC
L08D8:
	cp	r13,#%8+__iob
	jr	eq,L08D2
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L08B2
	setb	%0006(r13),#3
L08F4:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0906
	push	@r15,#%0001
	jr	L090A
L0906:
	push	@r15,#%0200
L090A:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L094C
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0942
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0946
	resb	%0006(r13),#0
	jr	L0946
L0942:
	setb	%0006(r13),#5
L0946:
	clr	%0002(r13)
	jr	L089E
L094C:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L08A2
end __filbuf
$SECTION BSS_B
I
B2BD2:
$REL	$+%14
$SDEFAULT
end filbuf_
