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
	jr	ne,L0F64
L0F5E:
	xor	r2,r2
L0F60:
	jp	cret
L0F64:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L0F78
	xor	r3,r3
	jr	L0F7A
L0F78:
	ldk	r3,#1
L0F7A:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L0FA6
	cp	r2,#%0072
	jr	eq,L0FF0
	cp	r2,#%0077
	jr	ne,L0F5E
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L103E
	jr	L1006
L0FA6:
	test	r12
	jr	eq,L0FB0
	push	@r15,#%0002
	jr	L0FB4
L0FB0:
	push	@r15,#%0001
L0FB4:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L0FDC
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L0FDC
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L103E
	inc	r15,#4
	ld	r11,r2
L0FDC:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L100A
L0FF0:
	test	r12
	jr	eq,L0FFA
	push	@r15,#%0002
	jr	L0FFE
L0FFA:
	push	@r15,#%0000
L0FFE:
	push	@r15,%0004(r14)
	call	_open
L1006:
	inc	r15,#4
	ld	r11,r2
L100A:
	test	r11
	jr	mi,L0F5E
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L1022
	setb	%0006(r13),#7
	jr	L103A
L1022:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L1036
	setb	%0006(r13),#0
	jr	L103A
L1036:
	setb	%0006(r13),#1
L103A:
	ld	r2,r13
	jr	L0F60
L103E:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L1072
	test	r12
	jr	mi,L1072
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L1072:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
