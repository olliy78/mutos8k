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
	jr	L0B8E
L0B04:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0B5C
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0B5C
	bitb	%0006(r11),#0
	jr	ne,L0B3E
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0B3E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0B5A
L0B3E:
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
L0B5A:
	dec	r12,#1
L0B5C:
	bitb	%0006(r11),#0
	jr	ne,L0B78
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0B78
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0B8A
L0B78:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0B8A:
	inc	%0008(r14),#1
L0B8E:
	test	%0008(r14)
	jr	mi,L0B04
	jr	L0BD8
L0B96:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0BBC
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0BD8
L0BB6:
	bitb	%0006(r11),#0
	jr	eq,L0B96
L0BBC:
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
L0BD8:
	dec	r12,#1
	jr	pl,L0BB6
	jr	L0C10
L0BDE:
	bitb	%0006(r11),#0
	jr	ne,L0BFA
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0BFA
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0C0C
L0BFA:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0C0C:
	dec	%0008(r14),#1
L0C10:
	test	%0008(r14)
	jr	ne,L0BDE
	jp	cret
end __strout
end strout_
