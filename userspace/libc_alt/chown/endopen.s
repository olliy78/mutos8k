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
	jr	ne,L0B06
L0B00:
	xor	r2,r2
L0B02:
	jp	cret
L0B06:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L0B1A
	xor	r3,r3
	jr	L0B1C
L0B1A:
	ldk	r3,#1
L0B1C:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L0B48
	cp	r2,#%0072
	jr	eq,L0B92
	cp	r2,#%0077
	jr	ne,L0B00
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0BE0
	jr	L0BA8
L0B48:
	test	r12
	jr	eq,L0B52
	push	@r15,#%0002
	jr	L0B56
L0B52:
	push	@r15,#%0001
L0B56:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L0B7E
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L0B7E
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0BE0
	inc	r15,#4
	ld	r11,r2
L0B7E:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L0BAC
L0B92:
	test	r12
	jr	eq,L0B9C
	push	@r15,#%0002
	jr	L0BA0
L0B9C:
	push	@r15,#%0000
L0BA0:
	push	@r15,%0004(r14)
	call	_open
L0BA8:
	inc	r15,#4
	ld	r11,r2
L0BAC:
	test	r11
	jr	mi,L0B00
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L0BC4
	setb	%0006(r13),#7
	jr	L0BDC
L0BC4:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L0BD8
	setb	%0006(r13),#0
	jr	L0BDC
L0BD8:
	setb	%0006(r13),#1
L0BDC:
	ld	r2,r13
	jr	L0B02
L0BE0:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%1E+_endpwen
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L0C14
	test	r12
	jr	mi,L0C14
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L0C14:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
