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
	jr	eq,L4AA6
	bitb	%0006(r13),#1
	jr	eq,L4AA2
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L4AA2:
	setb	%0006(r13),#0
L4AA6:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L4AB8
	bitb	%0006(r13),#6
	jr	eq,L4AD0
L4AB8:
	ld	r2,#%FFFF
L4ABC:
	jp	cret
L4AC0:
	cp	r13,#__iob
	jr	ne,L4AF2
	ld	r2,#__sibuf
	jr	L4AE6
L4ACC:
	setb	%0006(r13),#2
L4AD0:
	test	%0004(r13)
	jr	ne,L4B0E
	bitb	%0006(r13),#2
	jr	eq,L4AC0
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B9772
L4AE6:
	ld	%0004(r13),r2
	jr	L4AD0
L4AEC:
	ld	r2,#__sobuf
	jr	L4AE6
L4AF2:
	cp	r13,#%8+__iob
	jr	eq,L4AEC
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L4ACC
	setb	%0006(r13),#3
L4B0E:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L4B20
	push	@r15,#%0001
	jr	L4B24
L4B20:
	push	@r15,#%0200
L4B24:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L4B66
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L4B5C
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L4B60
	resb	%0006(r13),#0
	jr	L4B60
L4B5C:
	setb	%0006(r13),#5
L4B60:
	clr	%0002(r13)
	jr	L4AB8
L4B66:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L4ABC
end __filbuf
$SECTION BSS_B
I
B9772:
$REL	$+%14
$SDEFAULT
end filbuf_
