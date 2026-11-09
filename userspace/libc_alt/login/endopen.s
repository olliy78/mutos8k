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
	jr	ne,L1058
L1052:
	xor	r2,r2
L1054:
	jp	cret
L1058:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L106C
	xor	r3,r3
	jr	L106E
L106C:
	ldk	r3,#1
L106E:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L109A
	cp	r2,#%0072
	jr	eq,L10E4
	cp	r2,#%0077
	jr	ne,L1052
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L1132
	jr	L10FA
L109A:
	test	r12
	jr	eq,L10A4
	push	@r15,#%0002
	jr	L10A8
L10A4:
	push	@r15,#%0001
L10A8:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L10D0
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L10D0
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L1132
	inc	r15,#4
	ld	r11,r2
L10D0:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L10FE
L10E4:
	test	r12
	jr	eq,L10EE
	push	@r15,#%0002
	jr	L10F2
L10EE:
	push	@r15,#%0000
L10F2:
	push	@r15,%0004(r14)
	call	_open
L10FA:
	inc	r15,#4
	ld	r11,r2
L10FE:
	test	r11
	jr	mi,L1052
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L1116
	setb	%0006(r13),#7
	jr	L112E
L1116:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L112A
	setb	%0006(r13),#0
	jr	L112E
L112A:
	setb	%0006(r13),#1
L112E:
	ld	r2,r13
	jr	L1054
L1132:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L1166
	test	r12
	jr	mi,L1166
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L1166:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
