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
	jr	L1C5A
L1BD0:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L1C28
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L1C28
	bitb	%0006(r11),#0
	jr	ne,L1C0A
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L1C0A
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L1C26
L1C0A:
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
L1C26:
	dec	r12,#1
L1C28:
	bitb	%0006(r11),#0
	jr	ne,L1C44
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L1C44
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L1C56
L1C44:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L1C56:
	inc	%0008(r14),#1
L1C5A:
	test	%0008(r14)
	jr	mi,L1BD0
	jr	L1CA4
L1C62:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L1C88
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L1CA4
L1C82:
	bitb	%0006(r11),#0
	jr	eq,L1C62
L1C88:
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
L1CA4:
	dec	r12,#1
	jr	pl,L1C82
	jr	L1CDC
L1CAA:
	bitb	%0006(r11),#0
	jr	ne,L1CC6
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L1CC6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L1CD8
L1CC6:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L1CD8:
	dec	%0008(r14),#1
L1CDC:
	test	%0008(r14)
	jr	ne,L1CAA
	jp	cret
end __strout
end strout_
