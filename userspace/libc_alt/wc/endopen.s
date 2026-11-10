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
	jr	ne,L0A50
L0A4A:
	xor	r2,r2
L0A4C:
	jp	cret
L0A50:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L0A64
	xor	r3,r3
	jr	L0A66
L0A64:
	ldk	r3,#1
L0A66:
	ld	r2,r3
	ld	r12,r2
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r2,#%0061
	jr	eq,L0A92
	cp	r2,#%0072
	jr	eq,L0ADC
	cp	r2,#%0077
	jr	ne,L0A4A
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0B2A
	jr	L0AF2
L0A92:
	test	r12
	jr	eq,L0A9C
	push	@r15,#%0002
	jr	L0AA0
L0A9C:
	push	@r15,#%0001
L0AA0:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L0AC8
	ld	r0,_errno
	cp	r0,#%0002
	jr	ne,L0AC8
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L0B2A
	inc	r15,#4
	ld	r11,r2
L0AC8:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L0AF6
L0ADC:
	test	r12
	jr	eq,L0AE6
	push	@r15,#%0002
	jr	L0AEA
L0AE6:
	push	@r15,#%0000
L0AEA:
	push	@r15,%0004(r14)
	call	_open
L0AF2:
	inc	r15,#4
	ld	r11,r2
L0AF6:
	test	r11
	jr	mi,L0A4A
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L0B0E
	setb	%0006(r13),#7
	jr	L0B26
L0B0E:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L0B22
	setb	%0006(r13),#0
	jr	L0B26
L0B22:
	setb	%0006(r13),#1
L0B26:
	ld	r2,r13
	jr	L0A4C
L0B2A:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L0B5E
	test	r12
	jr	mi,L0B5E
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L0B5E:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
