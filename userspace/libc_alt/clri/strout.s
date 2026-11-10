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
	jr	L04F6
L046C:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L04C4
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L04C4
	bitb	%0006(r11),#0
	jr	ne,L04A6
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L04A6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L04C2
L04A6:
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
L04C2:
	dec	r12,#1
L04C4:
	bitb	%0006(r11),#0
	jr	ne,L04E0
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L04E0
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L04F2
L04E0:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L04F2:
	inc	%0008(r14),#1
L04F6:
	test	%0008(r14)
	jr	mi,L046C
	jr	L0540
L04FE:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0524
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0540
L051E:
	bitb	%0006(r11),#0
	jr	eq,L04FE
L0524:
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
L0540:
	dec	r12,#1
	jr	pl,L051E
	jr	L0578
L0546:
	bitb	%0006(r11),#0
	jr	ne,L0562
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0562
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0574
L0562:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0574:
	dec	%0008(r14),#1
L0578:
	test	%0008(r14)
	jr	ne,L0546
	jp	cret
end __strout
end strout_
