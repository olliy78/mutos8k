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
	jr	L0E66
L0DDE:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0E34
	cp	%000C(r14),#%0030
	jr	ne,L0E34
	bitb	%0006(r11),#0
	jr	ne,L0E16
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0E16
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0E32
L0E16:
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
L0E32:
	dec	r12,#1
L0E34:
	bitb	%0006(r11),#0
	jr	ne,L0E50
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0E50
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0E62
L0E50:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0E62:
	inc	%0008(r14),#1
L0E66:
	test	%0008(r14)
	jr	mi,L0DDE
	jr	L0EB0
L0E6E:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0E94
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0EB0
L0E8E:
	bitb	%0006(r11),#0
	jr	eq,L0E6E
L0E94:
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
L0EB0:
	dec	r12,#1
	jr	pl,L0E8E
	jr	L0EE8
L0EB6:
	bitb	%0006(r11),#0
	jr	ne,L0ED2
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0ED2
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0EE4
L0ED2:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0EE4:
	dec	%0008(r14),#1
L0EE8:
	test	%0008(r14)
	jr	ne,L0EB6
	jp	cret
end __strout
end strout_
