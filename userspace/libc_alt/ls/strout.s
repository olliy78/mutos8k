strout_ module
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
G	__strout	PR
E
__strout:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	ld	r11,%000A(r14)
	jr	L0E46
L0DBC:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0E14
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0E14
	bitb	%0006(r11),#0
	jr	ne,L0DF6
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0DF6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0E12
L0DF6:
	push	@r15,r2
	push	@r15,r11
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	push	@r15,r3
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0E12:
	dec	r12,#1
L0E14:
	bitb	%0006(r11),#0
	jr	ne,L0E30
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0E30
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0E42
L0E30:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0E42:
	inc	%0008(r14),#1
L0E46:
	test	%0008(r14)
	jr	mi,L0DBC
	jr	L0E90
L0E4E:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0E74
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0E90
L0E6E:
	bitb	%0006(r11),#0
	jr	eq,L0E4E
L0E74:
	push	@r15,r2
	push	@r15,r11
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	push	@r15,r3
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0E90:
	dec	r12,#1
	jr	pl,L0E6E
	jr	L0EC8
L0E96:
	bitb	%0006(r11),#0
	jr	ne,L0EB2
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0EB2
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0EC4
L0EB2:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0EC4:
	dec	%0008(r14),#1
L0EC8:
	test	%0008(r14)
	jr	ne,L0E96
	jp	cret
end __strout
end strout_
