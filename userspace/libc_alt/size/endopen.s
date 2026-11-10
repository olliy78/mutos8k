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
	jr	ne,L09D6
L09D0:
	xor	r2,r2
L09D2:
	jp	cret
L09D6:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L09EA
	xor	r3,r3
	jr	L09EC
L09EA:
	ldk	r3,#1
L09EC:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L0A18
	cp	r2,#%0072
	jr	eq,L0A62
	cp	r2,#%0077
	jr	ne,L09D0
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0AB0
	jr	L0A78
L0A18:
	test	r12
	jr	eq,L0A22
	push	@r15,#%0002
	jr	L0A26
L0A22:
	push	@r15,#%0001
L0A26:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L0A4E
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L0A4E
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0AB0
	inc	r15,#4
	ld	r11,r2
L0A4E:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L0A7C
L0A62:
	test	r12
	jr	eq,L0A6C
	push	@r15,#%0002
	jr	L0A70
L0A6C:
	push	@r15,#%0000
L0A70:
	push	@r15,%0004(r14)
	call	_open
L0A78:
	inc	r15,#4
	ld	r11,r2
L0A7C:
	test	r11
	jr	mi,L09D0
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L0A94
	setb	%0006(r13),#7
	jr	L0AAC
L0A94:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L0AA8
	setb	%0006(r13),#0
	jr	L0AAC
L0AA8:
	setb	%0006(r13),#1
L0AAC:
	ld	r2,r13
	jr	L09D2
L0AB0:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%54+_fread
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L0AE4
	test	r12
	jr	mi,L0AE4
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L0AE4:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
