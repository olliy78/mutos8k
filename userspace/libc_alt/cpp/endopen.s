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
	jr	ne,L2E56
L2E50:
	xor	r2,r2
L2E52:
	jp	cret
L2E56:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L2E6A
	xor	r3,r3
	jr	L2E6C
L2E6A:
	ldk	r3,#1
L2E6C:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L2E98
	cp	r2,#%0072
	jr	eq,L2EE2
	cp	r2,#%0077
	jr	ne,L2E50
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L2F30
	jr	L2EF8
L2E98:
	test	r12
	jr	eq,L2EA2
	push	@r15,#%0002
	jr	L2EA6
L2EA2:
	push	@r15,#%0001
L2EA6:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L2ECE
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L2ECE
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L2F30
	inc	r15,#4
	ld	r11,r2
L2ECE:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L2EFC
L2EE2:
	test	r12
	jr	eq,L2EEC
	push	@r15,#%0002
	jr	L2EF0
L2EEC:
	push	@r15,#%0000
L2EF0:
	push	@r15,%0004(r14)
	call	_open
L2EF8:
	inc	r15,#4
	ld	r11,r2
L2EFC:
	test	r11
	jr	mi,L2E50
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L2F14
	setb	%0006(r13),#7
	jr	L2F2C
L2F14:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L2F28
	setb	%0006(r13),#0
	jr	L2F2C
L2F28:
	setb	%0006(r13),#1
L2F2C:
	ld	r2,r13
	jr	L2E52
L2F30:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L2F64
	test	r12
	jr	mi,L2F64
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L2F64:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
