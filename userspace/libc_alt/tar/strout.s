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
	jr	L2668
L25E0:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L2636
	cp	%000C(r14),#%0030
	jr	ne,L2636
	bitb	%0006(r11),#0
	jr	ne,L2618
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L2618
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L2634
L2618:
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
L2634:
	dec	r12,#1
L2636:
	bitb	%0006(r11),#0
	jr	ne,L2652
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L2652
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L2664
L2652:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L2664:
	inc	%0008(r14),#1
L2668:
	test	%0008(r14)
	jr	mi,L25E0
	jr	L26B2
L2670:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L2696
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L26B2
L2690:
	bitb	%0006(r11),#0
	jr	eq,L2670
L2696:
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
L26B2:
	dec	r12,#1
	jr	pl,L2690
	jr	L26EA
L26B8:
	bitb	%0006(r11),#0
	jr	ne,L26D4
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L26D4
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L26E6
L26D4:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L26E6:
	dec	%0008(r14),#1
L26EA:
	test	%0008(r14)
	jr	ne,L26B8
	jp	cret
end __strout
end strout_
