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
	jr	eq,L0598
	bitb	%0006(r13),#1
	jr	eq,L0594
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L0594:
	setb	%0006(r13),#0
L0598:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L05AA
	bitb	%0006(r13),#6
	jr	eq,L05C2
L05AA:
	ld	r2,#%FFFF
L05AE:
	jp	cret
L05B2:
	cp	r13,#__iob
	jr	ne,L05E4
	ld	r2,#__sibuf
	jr	L05D8
L05BE:
	setb	%0006(r13),#2
L05C2:
	test	%0004(r13)
	jr	ne,L0600
	bitb	%0006(r13),#2
	jr	eq,L05B2
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B1A8A
L05D8:
	ld	%0004(r13),r2
	jr	L05C2
L05DE:
	ld	r2,#__sobuf
	jr	L05D8
L05E4:
	cp	r13,#%8+__iob
	jr	eq,L05DE
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L05BE
	setb	%0006(r13),#3
L0600:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0612
	push	@r15,#%0001
	jr	L0616
L0612:
	push	@r15,#%0200
L0616:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L0658
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L064E
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0652
	resb	%0006(r13),#0
	jr	L0652
L064E:
	setb	%0006(r13),#5
L0652:
	clr	%0002(r13)
	jr	L05AA
L0658:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L05AE
end __filbuf
$SECTION BSS_B
I
B1A8A:
$REL	$+%14
$SDEFAULT
end filbuf_
