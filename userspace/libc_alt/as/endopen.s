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
	jr	ne,L51AA
L51A4:
	xor	r2,r2
L51A6:
	jp	cret
L51AA:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L51BE
	xor	r3,r3
	jr	L51C0
L51BE:
	ldk	r3,#1
L51C0:
	ld	r12,r3
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r3,#%0061
	jr	eq,L51EA
	cp	r3,#%0072
	jr	eq,L5232
	cp	r3,#%0077
	jr	ne,L51A4
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L5280
	jr	L5248
L51EA:
	test	r12
	jr	eq,L51F4
	push	@r15,#%0002
	jr	L51F8
L51F4:
	push	@r15,#%0001
L51F8:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L521E
	cp	_errno,#%0002
	jr	ne,L521E
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L5280
	inc	r15,#4
	ld	r11,r2
L521E:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L524C
L5232:
	test	r12
	jr	eq,L523C
	push	@r15,#%0002
	jr	L5240
L523C:
	push	@r15,#%0000
L5240:
	push	@r15,%0004(r14)
	call	_open
L5248:
	inc	r15,#4
	ld	r11,r2
L524C:
	test	r11
	jr	mi,L51A4
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L5264
	setb	%0006(r13),#7
	jr	L527C
L5264:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L5278
	setb	%0006(r13),#0
	jr	L527C
L5278:
	setb	%0006(r13),#1
L527C:
	ld	r2,r13
	jr	L51A6
L5280:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L52B4
	test	r12
	jr	mi,L52B4
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L52B4:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
