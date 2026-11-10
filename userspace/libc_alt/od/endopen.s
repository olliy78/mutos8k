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
	jr	ne,L0FDE
L0FD8:
	xor	r2,r2
L0FDA:
	jp	cret
L0FDE:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L0FF2
	xor	r3,r3
	jr	L0FF4
L0FF2:
	ldk	r3,#1
L0FF4:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L1020
	cp	r2,#%0072
	jr	eq,L106A
	cp	r2,#%0077
	jr	ne,L0FD8
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L10B8
	jr	L1080
L1020:
	test	r12
	jr	eq,L102A
	push	@r15,#%0002
	jr	L102E
L102A:
	push	@r15,#%0001
L102E:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L1056
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L1056
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L10B8
	inc	r15,#4
	ld	r11,r2
L1056:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L1084
L106A:
	test	r12
	jr	eq,L1074
	push	@r15,#%0002
	jr	L1078
L1074:
	push	@r15,#%0000
L1078:
	push	@r15,%0004(r14)
	call	_open
L1080:
	inc	r15,#4
	ld	r11,r2
L1084:
	test	r11
	jr	mi,L0FD8
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L109C
	setb	%0006(r13),#7
	jr	L10B4
L109C:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L10B0
	setb	%0006(r13),#0
	jr	L10B4
L10B0:
	setb	%0006(r13),#1
L10B4:
	ld	r2,r13
	jr	L0FDA
L10B8:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L10EC
	test	r12
	jr	mi,L10EC
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L10EC:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
