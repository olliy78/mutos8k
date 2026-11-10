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
	jr	eq,L0572
	bitb	%0006(r13),#1
	jr	eq,L056E
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L056E:
	setb	%0006(r13),#0
L0572:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L0584
	bitb	%0006(r13),#6
	jr	eq,L059C
L0584:
	ld	r2,#%FFFF
L0588:
	jp	cret
L058C:
	cp	r13,#__iob
	jr	ne,L05BE
	ld	r2,#__sibuf
	jr	L05B2
L0598:
	setb	%0006(r13),#2
L059C:
	test	%0004(r13)
	jr	ne,L05DA
	bitb	%0006(r13),#2
	jr	eq,L058C
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B2022
L05B2:
	ld	%0004(r13),r2
	jr	L059C
L05B8:
	ld	r2,#__sobuf
	jr	L05B2
L05BE:
	cp	r13,#%8+__iob
	jr	eq,L05B8
	push	@r15,#%30+_endpwen
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L0598
	setb	%0006(r13),#3
L05DA:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L05EC
	push	@r15,#%0001
	jr	L05F0
L05EC:
	push	@r15,#%30+_endpwen
L05F0:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L0632
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0628
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L062C
	resb	%0006(r13),#0
	jr	L062C
L0628:
	setb	%0006(r13),#5
L062C:
	clr	%0002(r13)
	jr	L0584
L0632:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L0588
end __filbuf
$SECTION BSS_B
I
B2022:
$REL	$+%14
$SDEFAULT
end filbuf_
