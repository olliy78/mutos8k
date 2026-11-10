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
	jr	L09F2
L0968:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L09C0
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L09C0
	bitb	%0006(r11),#0
	jr	ne,L09A2
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L09A2
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L09BE
L09A2:
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
L09BE:
	dec	r12,#1
L09C0:
	bitb	%0006(r11),#0
	jr	ne,L09DC
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L09DC
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L09EE
L09DC:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L09EE:
	inc	%0008(r14),#1
L09F2:
	test	%0008(r14)
	jr	mi,L0968
	jr	L0A3C
L09FA:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0A20
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0A3C
L0A1A:
	bitb	%0006(r11),#0
	jr	eq,L09FA
L0A20:
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
L0A3C:
	dec	r12,#1
	jr	pl,L0A1A
	jr	L0A74
L0A42:
	bitb	%0006(r11),#0
	jr	ne,L0A5E
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0A5E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0A70
L0A5E:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0A70:
	dec	%0008(r14),#1
L0A74:
	test	%0008(r14)
	jr	ne,L0A42
	jp	cret
end __strout
end strout_
