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
	jr	ne,L0C96
L0C90:
	xor	r2,r2
L0C92:
	jp	cret
L0C96:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L0CAA
	xor	r3,r3
	jr	L0CAC
L0CAA:
	ldk	r3,#1
L0CAC:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L0CD8
	cp	r2,#%0072
	jr	eq,L0D22
	cp	r2,#%0077
	jr	ne,L0C90
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0D70
	jr	L0D38
L0CD8:
	test	r12
	jr	eq,L0CE2
	push	@r15,#%0002
	jr	L0CE6
L0CE2:
	push	@r15,#%0001
L0CE6:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L0D0E
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L0D0E
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0D70
	inc	r15,#4
	ld	r11,r2
L0D0E:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L0D3C
L0D22:
	test	r12
	jr	eq,L0D2C
	push	@r15,#%0002
	jr	L0D30
L0D2C:
	push	@r15,#%0000
L0D30:
	push	@r15,%0004(r14)
	call	_open
L0D38:
	inc	r15,#4
	ld	r11,r2
L0D3C:
	test	r11
	jr	mi,L0C90
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L0D54
	setb	%0006(r13),#7
	jr	L0D6C
L0D54:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L0D68
	setb	%0006(r13),#0
	jr	L0D6C
L0D68:
	setb	%0006(r13),#1
L0D6C:
	ld	r2,r13
	jr	L0C92
L0D70:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%12+_setpwen
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L0DA4
	test	r12
	jr	mi,L0DA4
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L0DA4:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
