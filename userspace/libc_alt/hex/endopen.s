endopen_ module
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
G	__endope	PR
E
__endope:
	call	csv
	ld	r13,%0008(r14)
	test	r13
	jr	ne,L0AE0
L0ADA:
	xor	r2,r2
L0ADC:
	jp	cret
L0AE0:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L0AF4
	xor	r3,r3
	jr	L0AF6
L0AF4:
	ldk	r3,#1
L0AF6:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L0B22
	cp	r2,#%0072
	jr	eq,L0B6C
	cp	r2,#%0077
	jr	ne,L0ADA
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0BBA
	jr	L0B82
L0B22:
	test	r12
	jr	eq,L0B2C
	push	@r15,#%0002
	jr	L0B30
L0B2C:
	push	@r15,#%0001
L0B30:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L0B58
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L0B58
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0BBA
	inc	r15,#4
	ld	r11,r2
L0B58:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L0B86
L0B6C:
	test	r12
	jr	eq,L0B76
	push	@r15,#%0002
	jr	L0B7A
L0B76:
	push	@r15,#%0000
L0B7A:
	push	@r15,%0004(r14)
	call	_open
L0B82:
	inc	r15,#4
	ld	r11,r2
L0B86:
	test	r11
	jr	mi,L0ADA
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L0B9E
	setb	%0006(r13),#7
	jr	L0BB6
L0B9E:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L0BB2
	setb	%0006(r13),#0
	jr	L0BB6
L0BB2:
	setb	%0006(r13),#1
L0BB6:
	ld	r2,r13
	jr	L0ADC
L0BBA:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L0BEE
	test	r12
	jr	mi,L0BEE
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L0BEE:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
