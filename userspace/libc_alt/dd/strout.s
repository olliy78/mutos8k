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
	jr	L0C26
L0B9C:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0BF4
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0BF4
	bitb	%0006(r11),#0
	jr	ne,L0BD6
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0BD6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0BF2
L0BD6:
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
L0BF2:
	dec	r12,#1
L0BF4:
	bitb	%0006(r11),#0
	jr	ne,L0C10
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0C10
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0C22
L0C10:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0C22:
	inc	%0008(r14),#1
L0C26:
	test	%0008(r14)
	jr	mi,L0B9C
	jr	L0C70
L0C2E:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0C54
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0C70
L0C4E:
	bitb	%0006(r11),#0
	jr	eq,L0C2E
L0C54:
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
L0C70:
	dec	r12,#1
	jr	pl,L0C4E
	jr	L0CA8
L0C76:
	bitb	%0006(r11),#0
	jr	ne,L0C92
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0C92
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0CA4
L0C92:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0CA4:
	dec	%0008(r14),#1
L0CA8:
	test	%0008(r14)
	jr	ne,L0C76
	jp	cret
end __strout
end strout_
