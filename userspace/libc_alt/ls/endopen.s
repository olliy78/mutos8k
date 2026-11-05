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
	jr	ne,L121C
L1216:
	xor	r2,r2
L1218:
	jp	cret
L121C:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L1230
	xor	r3,r3
	jr	L1232
L1230:
	ldk	r3,#1
L1232:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L125E
	cp	r2,#%0072
	jr	eq,L12A8
	cp	r2,#%0077
	jr	ne,L1216
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L12F6
	jr	L12BE
L125E:
	test	r12
	jr	eq,L1268
	push	@r15,#%0002
	jr	L126C
L1268:
	push	@r15,#%0001
L126C:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L1294
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L1294
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L12F6
	inc	r15,#4
	ld	r11,r2
L1294:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L12C2
L12A8:
	test	r12
	jr	eq,L12B2
	push	@r15,#%0002
	jr	L12B6
L12B2:
	push	@r15,#%0000
L12B6:
	push	@r15,%0004(r14)
	call	_open
L12BE:
	inc	r15,#4
	ld	r11,r2
L12C2:
	test	r11
	jr	mi,L1216
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L12DA
	setb	%0006(r13),#7
	jr	L12F2
L12DA:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L12EE
	setb	%0006(r13),#0
	jr	L12F2
L12EE:
	setb	%0006(r13),#1
L12F2:
	ld	r2,r13
	jr	L1218
L12F6:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L132A
	test	r12
	jr	mi,L132A
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L132A:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
