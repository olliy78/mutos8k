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
	jr	L03A8
L031E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0376
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0376
	bitb	%0006(r11),#0
	jr	ne,L0358
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0358
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%5+_printf
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0374
L0358:
	push	@r15,r2
	push	@r15,r11
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%5+_printf
	push	@r15,r3
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0374:
	dec	r12,#1
L0376:
	bitb	%0006(r11),#0
	jr	ne,L0392
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0392
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L03A4
L0392:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L03A4:
	inc	%0008(r14),#1
L03A8:
	test	%0008(r14)
	jr	mi,L031E
	jr	L03F2
L03B0:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L03D6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%5+_printf
	ld	r3,r4
	ldb	@r2,rl3
	jr	L03F2
L03D0:
	bitb	%0006(r11),#0
	jr	eq,L03B0
L03D6:
	push	@r15,r2
	push	@r15,r11
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%5+_printf
	push	@r15,r3
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L03F2:
	dec	r12,#1
	jr	pl,L03D0
	jr	L042A
L03F8:
	bitb	%0006(r11),#0
	jr	ne,L0414
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0414
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0426
L0414:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0426:
	dec	%0008(r14),#1
L042A:
	test	%0008(r14)
	jr	ne,L03F8
	jp	cret
end __strout
end strout_
