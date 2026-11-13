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
	jr	ne,L129A
L1294:
	xor	r2,r2
L1296:
	jp	cret
L129A:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L12AE
	xor	r3,r3
	jr	L12B0
L12AE:
	ldk	r3,#1
L12B0:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L12DC
	cp	r2,#%0072
	jr	eq,L1326
	cp	r2,#%0077
	jr	ne,L1294
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L1374
	jr	L133C
L12DC:
	test	r12
	jr	eq,L12E6
	push	@r15,#%0002
	jr	L12EA
L12E6:
	push	@r15,#%0001
L12EA:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L1312
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L1312
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L1374
	inc	r15,#4
	ld	r11,r2
L1312:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L1340
L1326:
	test	r12
	jr	eq,L1330
	push	@r15,#%0002
	jr	L1334
L1330:
	push	@r15,#%0000
L1334:
	push	@r15,%0004(r14)
	call	_open
L133C:
	inc	r15,#4
	ld	r11,r2
L1340:
	test	r11
	jr	mi,L1294
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L1358
	setb	%0006(r13),#7
	jr	L1370
L1358:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L136C
	setb	%0006(r13),#0
	jr	L1370
L136C:
	setb	%0006(r13),#1
L1370:
	ld	r2,r13
	jr	L1296
L1374:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L13A8
	test	r12
	jr	mi,L13A8
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L13A8:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
