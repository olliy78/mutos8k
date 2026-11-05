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
	jr	eq,L08EA
	bitb	%0006(r13),#1
	jr	eq,L08E6
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L08E6:
	setb	%0006(r13),#0
L08EA:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L08FC
	bitb	%0006(r13),#6
	jr	eq,L0914
L08FC:
	ld	r2,#%FFFF
L0900:
	jp	cret
L0904:
	cp	r13,#__iob
	jr	ne,L0936
	ld	r2,#%26D4
	jr	L092A
L0910:
	setb	%0006(r13),#2
L0914:
	test	%0004(r13)
	jr	ne,L0952
	bitb	%0006(r13),#2
	jr	eq,L0904
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B2CF4
L092A:
	ld	%0004(r13),r2
	jr	L0914
L0930:
	ld	r2,#%1F6+__sibuf
	jr	L092A
L0936:
	cp	r13,#%8+__iob
	jr	eq,L0930
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L0910
	setb	%0006(r13),#3
L0952:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0964
	push	@r15,#%0001
	jr	L0968
L0964:
	push	@r15,#%0200
L0968:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L09AA
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L09A0
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L09A4
	resb	%0006(r13),#0
	jr	L09A4
L09A0:
	setb	%0006(r13),#5
L09A4:
	clr	%0002(r13)
	jr	L08FC
L09AA:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L0900
end __filbuf
$SECTION BSS_B
I
B2CF4:
$REL	$+%14
$SDEFAULT
end filbuf_
