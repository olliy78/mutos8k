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
	jr	ne,L0A04
L09FE:
	xor	r2,r2
L0A00:
	jp	cret
L0A04:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L0A18
	xor	r3,r3
	jr	L0A1A
L0A18:
	ldk	r3,#1
L0A1A:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L0A46
	cp	r2,#%0072
	jr	eq,L0A90
	cp	r2,#%0077
	jr	ne,L09FE
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0ADE
	jr	L0AA6
L0A46:
	test	r12
	jr	eq,L0A50
	push	@r15,#%0002
	jr	L0A54
L0A50:
	push	@r15,#%0001
L0A54:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L0A7C
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L0A7C
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0ADE
	inc	r15,#4
	ld	r11,r2
L0A7C:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L0AAA
L0A90:
	test	r12
	jr	eq,L0A9A
	push	@r15,#%0002
	jr	L0A9E
L0A9A:
	push	@r15,#%0000
L0A9E:
	push	@r15,%0004(r14)
	call	_open
L0AA6:
	inc	r15,#4
	ld	r11,r2
L0AAA:
	test	r11
	jr	mi,L09FE
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L0AC2
	setb	%0006(r13),#7
	jr	L0ADA
L0AC2:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L0AD6
	setb	%0006(r13),#0
	jr	L0ADA
L0AD6:
	setb	%0006(r13),#1
L0ADA:
	ld	r2,r13
	jr	L0A00
L0ADE:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L0B12
	test	r12
	jr	mi,L0B12
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L0B12:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
