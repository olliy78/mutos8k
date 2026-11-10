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
	jr	L04D2
L0448:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L04A0
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L04A0
	bitb	%0006(r11),#0
	jr	ne,L0482
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0482
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L049E
L0482:
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
L049E:
	dec	r12,#1
L04A0:
	bitb	%0006(r11),#0
	jr	ne,L04BC
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L04BC
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L04CE
L04BC:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L04CE:
	inc	%0008(r14),#1
L04D2:
	test	%0008(r14)
	jr	mi,L0448
	jr	L051C
L04DA:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0500
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L051C
L04FA:
	bitb	%0006(r11),#0
	jr	eq,L04DA
L0500:
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
L051C:
	dec	r12,#1
	jr	pl,L04FA
	jr	L0554
L0522:
	bitb	%0006(r11),#0
	jr	ne,L053E
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L053E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0550
L053E:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0550:
	dec	%0008(r14),#1
L0554:
	test	%0008(r14)
	jr	ne,L0522
	jp	cret
end __strout
end strout_
