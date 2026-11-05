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
	jr	eq,L0AAE
	bitb	%0006(r13),#1
	jr	eq,L0AAA
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L0AAA:
	setb	%0006(r13),#0
L0AAE:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L0AC0
	bitb	%0006(r13),#6
	jr	eq,L0AD8
L0AC0:
	ld	r2,#%FFFF
L0AC4:
	jp	cret
L0AC8:
	cp	r13,#__iob
	jr	ne,L0AFA
	ld	r2,#%2A68
	jr	L0AEE
L0AD4:
	setb	%0006(r13),#2
L0AD8:
	test	%0004(r13)
	jr	ne,L0B16
	bitb	%0006(r13),#2
	jr	eq,L0AC8
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B2EE2
L0AEE:
	ld	%0004(r13),r2
	jr	L0AD8
L0AF4:
	ld	r2,#%188+__sibuf
	jr	L0AEE
L0AFA:
	cp	r13,#%8+__iob
	jr	eq,L0AF4
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L0AD4
	setb	%0006(r13),#3
L0B16:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L0B28
	push	@r15,#%0001
	jr	L0B2C
L0B28:
	push	@r15,#%0200
L0B2C:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L0B6E
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L0B64
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L0B68
	resb	%0006(r13),#0
	jr	L0B68
L0B64:
	setb	%0006(r13),#5
L0B68:
	clr	%0002(r13)
	jr	L0AC0
L0B6E:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L0AC4
end __filbuf
$SECTION BSS_B
I
B2EE2:
$REL	$+%14
$SDEFAULT
end filbuf_
