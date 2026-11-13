fgets_ module
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
G	_fgets	PR
E
_fgets:
	call	csv
	ld	r13,%0008(r14)
	ld	r11,%0004(r14)
L02B6:
	dec	%0006(r14),#1
	jr	mi,L0300
	jr	eq,L0300
	bitb	%0006(r13),#1
	jr	ne,L02DC
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	mi,L02DC
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L02EA
L02DC:
	push	@r15,r2
	push	@r15,r13
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L02EA:
	ld	r2,r3
	ld	r12,r2
	test	r12
	jr	mi,L0300
	ld	r2,r11
	inc	r11,#1
	ld	r3,r12
	ldb	@r2,rl3
	cp	r12,#%000A
	jr	ne,L02B6
L0300:
	test	r12
	jr	pl,L0310
	cp	r11,%0004(r14)
	jr	ne,L0310
	xor	r2,r2
L030C:
	jp	cret
L0310:
	ld	r2,r11
	inc	r11,#1
	clrb	@r2
	ld	r2,%0004(r14)
	jr	L030C
end _fgets
end fgets_
