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
	jr	L0500
L0476:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L04CE
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L04CE
	bitb	%0006(r11),#0
	jr	ne,L04B0
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L04B0
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L04CC
L04B0:
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
L04CC:
	dec	r12,#1
L04CE:
	bitb	%0006(r11),#0
	jr	ne,L04EA
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L04EA
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L04FC
L04EA:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L04FC:
	inc	%0008(r14),#1
L0500:
	test	%0008(r14)
	jr	mi,L0476
	jr	L054A
L0508:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L052E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L054A
L0528:
	bitb	%0006(r11),#0
	jr	eq,L0508
L052E:
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
L054A:
	dec	r12,#1
	jr	pl,L0528
	jr	L0582
L0550:
	bitb	%0006(r11),#0
	jr	ne,L056C
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L056C
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L057E
L056C:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L057E:
	dec	%0008(r14),#1
L0582:
	test	%0008(r14)
	jr	ne,L0550
	jp	cret
end __strout
end strout_
