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
	jr	ne,L1858
L1852:
	xor	r2,r2
L1854:
	jp	cret
L1858:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L186C
	xor	r3,r3
	jr	L186E
L186C:
	ldk	r3,#1
L186E:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L189A
	cp	r2,#%0072
	jr	eq,L18E4
	cp	r2,#%0077
	jr	ne,L1852
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L1932
	jr	L18FA
L189A:
	test	r12
	jr	eq,L18A4
	push	@r15,#%0002
	jr	L18A8
L18A4:
	push	@r15,#%0001
L18A8:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L18D0
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L18D0
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L1932
	inc	r15,#4
	ld	r11,r2
L18D0:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L18FE
L18E4:
	test	r12
	jr	eq,L18EE
	push	@r15,#%0002
	jr	L18F2
L18EE:
	push	@r15,#%0000
L18F2:
	push	@r15,%0004(r14)
	call	_open
L18FA:
	inc	r15,#4
	ld	r11,r2
L18FE:
	test	r11
	jr	mi,L1852
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L1916
	setb	%0006(r13),#7
	jr	L192E
L1916:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L192A
	setb	%0006(r13),#0
	jr	L192E
L192A:
	setb	%0006(r13),#1
L192E:
	ld	r2,r13
	jr	L1854
L1932:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L1966
	test	r12
	jr	mi,L1966
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L1966:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
