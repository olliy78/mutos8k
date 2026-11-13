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
	jr	ne,L0FFA
L0FF4:
	xor	r2,r2
L0FF6:
	jp	cret
L0FFA:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L100E
	xor	r3,r3
	jr	L1010
L100E:
	ldk	r3,#1
L1010:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L103C
	cp	r2,#%0072
	jr	eq,L1086
	cp	r2,#%0077
	jr	ne,L0FF4
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L10D4
	jr	L109C
L103C:
	test	r12
	jr	eq,L1046
	push	@r15,#%0002
	jr	L104A
L1046:
	push	@r15,#%0001
L104A:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L1072
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L1072
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L10D4
	inc	r15,#4
	ld	r11,r2
L1072:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L10A0
L1086:
	test	r12
	jr	eq,L1090
	push	@r15,#%0002
	jr	L1094
L1090:
	push	@r15,#%0000
L1094:
	push	@r15,%0004(r14)
	call	_open
L109C:
	inc	r15,#4
	ld	r11,r2
L10A0:
	test	r11
	jr	mi,L0FF4
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L10B8
	setb	%0006(r13),#7
	jr	L10D0
L10B8:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L10CC
	setb	%0006(r13),#0
	jr	L10D0
L10CC:
	setb	%0006(r13),#1
L10D0:
	ld	r2,r13
	jr	L0FF6
L10D4:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L1108
	test	r12
	jr	mi,L1108
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L1108:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
