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
	jr	L4DD6
L4D4E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L4DA4
	cp	%000C(r14),#%0030
	jr	ne,L4DA4
	bitb	%0006(r11),#0
	jr	ne,L4D86
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L4D86
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L4DA2
L4D86:
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
L4DA2:
	dec	r12,#1
L4DA4:
	bitb	%0006(r11),#0
	jr	ne,L4DC0
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L4DC0
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L4DD2
L4DC0:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L4DD2:
	inc	%0008(r14),#1
L4DD6:
	test	%0008(r14)
	jr	mi,L4D4E
	jr	L4E20
L4DDE:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L4E04
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L4E20
L4DFE:
	bitb	%0006(r11),#0
	jr	eq,L4DDE
L4E04:
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
L4E20:
	dec	r12,#1
	jr	pl,L4DFE
	jr	L4E58
L4E26:
	bitb	%0006(r11),#0
	jr	ne,L4E42
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L4E42
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L4E54
L4E42:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L4E54:
	dec	%0008(r14),#1
L4E58:
	test	%0008(r14)
	jr	ne,L4E26
	jp	cret
end __strout
end strout_
