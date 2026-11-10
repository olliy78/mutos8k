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
	jr	L053A
L04B0:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0508
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0508
	bitb	%0006(r11),#0
	jr	ne,L04EA
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L04EA
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0506
L04EA:
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
L0506:
	dec	r12,#1
L0508:
	bitb	%0006(r11),#0
	jr	ne,L0524
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0524
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0536
L0524:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0536:
	inc	%0008(r14),#1
L053A:
	test	%0008(r14)
	jr	mi,L04B0
	jr	L0584
L0542:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0568
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0584
L0562:
	bitb	%0006(r11),#0
	jr	eq,L0542
L0568:
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
L0584:
	dec	r12,#1
	jr	pl,L0562
	jr	L05BC
L058A:
	bitb	%0006(r11),#0
	jr	ne,L05A6
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L05A6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L05B8
L05A6:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L05B8:
	dec	%0008(r14),#1
L05BC:
	test	%0008(r14)
	jr	ne,L058A
	jp	cret
end __strout
end strout_
