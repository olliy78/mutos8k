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
	jr	L0514
L048A:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L04E2
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L04E2
	bitb	%0006(r11),#0
	jr	ne,L04C4
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L04C4
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L04E0
L04C4:
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
L04E0:
	dec	r12,#1
L04E2:
	bitb	%0006(r11),#0
	jr	ne,L04FE
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L04FE
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0510
L04FE:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0510:
	inc	%0008(r14),#1
L0514:
	test	%0008(r14)
	jr	mi,L048A
	jr	L055E
L051C:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0542
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L055E
L053C:
	bitb	%0006(r11),#0
	jr	eq,L051C
L0542:
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
L055E:
	dec	r12,#1
	jr	pl,L053C
	jr	L0596
L0564:
	bitb	%0006(r11),#0
	jr	ne,L0580
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0580
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0592
L0580:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0592:
	dec	%0008(r14),#1
L0596:
	test	%0008(r14)
	jr	ne,L0564
	jp	cret
end __strout
end strout_
