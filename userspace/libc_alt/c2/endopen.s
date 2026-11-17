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
	jr	ne,L3DC4
L3DBE:
	xor	r2,r2
L3DC0:
	jp	cret
L3DC4:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L3DD8
	xor	r3,r3
	jr	L3DDA
L3DD8:
	ldk	r3,#1
L3DDA:
	ld	r12,r3
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r3,#%0061
	jr	eq,L3E04
	cp	r3,#%0072
	jr	eq,L3E4C
	cp	r3,#%0077
	jr	ne,L3DBE
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L3E9A
	jr	L3E62
L3E04:
	test	r12
	jr	eq,L3E0E
	push	@r15,#%0002
	jr	L3E12
L3E0E:
	push	@r15,#%0001
L3E12:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L3E38
	cp	_errno,#%0002
	jr	ne,L3E38
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L3E9A
	inc	r15,#4
	ld	r11,r2
L3E38:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L3E66
L3E4C:
	test	r12
	jr	eq,L3E56
	push	@r15,#%0002
	jr	L3E5A
L3E56:
	push	@r15,#%0000
L3E5A:
	push	@r15,%0004(r14)
	call	_open
L3E62:
	inc	r15,#4
	ld	r11,r2
L3E66:
	test	r11
	jr	mi,L3DBE
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L3E7E
	setb	%0006(r13),#7
	jr	L3E96
L3E7E:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L3E92
	setb	%0006(r13),#0
	jr	L3E96
L3E92:
	setb	%0006(r13),#1
L3E96:
	ld	r2,r13
	jr	L3DC0
L3E9A:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L3ECE
	test	r12
	jr	mi,L3ECE
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L3ECE:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
