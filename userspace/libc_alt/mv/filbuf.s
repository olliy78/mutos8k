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
	jr	eq,L09C4
	bitb	%0006(r13),#1
	jr	eq,L09C0
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L09C0:
	setb	%0006(r13),#0
L09C4:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L09D6
	bitb	%0006(r13),#6
	jr	eq,L09EE
L09D6:
	ld	r2,#%FFFF
L09DA:
	jp	cret
L09DE:
	cp	r13,#__iob
	jr	ne,L0A10
	ld	r2,#%1AE0
	jr	L0A04
L09EA:
	setb	%0006(r13),#2
L09EE:
	test	%0004(r13)
	jr	ne,L0A2C
	bitb	%0006(r13),#2
	jr	eq,L09DE
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B1F46
L0A04:
	ld	%0004(r13),r2
	jr	L09EE
L0A0A:
	ld	r2,#%19C+__sibuf
	jr	L0A04
L0A10:
	cp	r13,#%8+__iob
	jr	eq,L0A0A
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L09EA
	setb	%0006(r13),#3
L0A2C:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0A3E
	push	@r15,#%0001
	jr	L0A42
L0A3E:
	push	@r15,#%0200
L0A42:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L0A84
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0A7A
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0A7E
	resb	%0006(r13),#0
	jr	L0A7E
L0A7A:
	setb	%0006(r13),#5
L0A7E:
	clr	%0002(r13)
	jr	L09D6
L0A84:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L09DA
end __filbuf
$SECTION BSS_B
I
B1F46:
$REL	$+%14
$SDEFAULT
end filbuf_
