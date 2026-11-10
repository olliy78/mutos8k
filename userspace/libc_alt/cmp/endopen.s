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
	jr	ne,L0B8E
L0B88:
	xor	r2,r2
L0B8A:
	jp	cret
L0B8E:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L0BA2
	xor	r3,r3
	jr	L0BA4
L0BA2:
	ldk	r3,#1
L0BA4:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L0BD0
	cp	r2,#%0072
	jr	eq,L0C1A
	cp	r2,#%0077
	jr	ne,L0B88
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0C68
	jr	L0C30
L0BD0:
	test	r12
	jr	eq,L0BDA
	push	@r15,#%0002
	jr	L0BDE
L0BDA:
	push	@r15,#%0001
L0BDE:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L0C06
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L0C06
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0C68
	inc	r15,#4
	ld	r11,r2
L0C06:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L0C34
L0C1A:
	test	r12
	jr	eq,L0C24
	push	@r15,#%0002
	jr	L0C28
L0C24:
	push	@r15,#%0000
L0C28:
	push	@r15,%0004(r14)
	call	_open
L0C30:
	inc	r15,#4
	ld	r11,r2
L0C34:
	test	r11
	jr	mi,L0B88
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L0C4C
	setb	%0006(r13),#7
	jr	L0C64
L0C4C:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L0C60
	setb	%0006(r13),#0
	jr	L0C64
L0C60:
	setb	%0006(r13),#1
L0C64:
	ld	r2,r13
	jr	L0B8A
L0C68:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L0C9C
	test	r12
	jr	mi,L0C9C
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L0C9C:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
