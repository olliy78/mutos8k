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
	jr	L0D12
L0C88:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0CE0
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0CE0
	bitb	%0006(r11),#0
	jr	ne,L0CC2
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0CC2
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0CDE
L0CC2:
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
L0CDE:
	dec	r12,#1
L0CE0:
	bitb	%0006(r11),#0
	jr	ne,L0CFC
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0CFC
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0D0E
L0CFC:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0D0E:
	inc	%0008(r14),#1
L0D12:
	test	%0008(r14)
	jr	mi,L0C88
	jr	L0D5C
L0D1A:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0D40
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0D5C
L0D3A:
	bitb	%0006(r11),#0
	jr	eq,L0D1A
L0D40:
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
L0D5C:
	dec	r12,#1
	jr	pl,L0D3A
	jr	L0D94
L0D62:
	bitb	%0006(r11),#0
	jr	ne,L0D7E
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0D7E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0D90
L0D7E:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0D90:
	dec	%0008(r14),#1
L0D94:
	test	%0008(r14)
	jr	ne,L0D62
	jp	cret
end __strout
end strout_
