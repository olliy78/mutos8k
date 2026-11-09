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
	jr	L062E
L05A4:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L05FC
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L05FC
	bitb	%0006(r11),#0
	jr	ne,L05DE
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L05DE
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L05FA
L05DE:
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
L05FA:
	dec	r12,#1
L05FC:
	bitb	%0006(r11),#0
	jr	ne,L0618
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0618
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L062A
L0618:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L062A:
	inc	%0008(r14),#1
L062E:
	test	%0008(r14)
	jr	mi,L05A4
	jr	L0678
L0636:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L065C
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0678
L0656:
	bitb	%0006(r11),#0
	jr	eq,L0636
L065C:
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
L0678:
	dec	r12,#1
	jr	pl,L0656
	jr	L06B0
L067E:
	bitb	%0006(r11),#0
	jr	ne,L069A
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L069A
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L06AC
L069A:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L06AC:
	dec	%0008(r14),#1
L06B0:
	test	%0008(r14)
	jr	ne,L067E
	jp	cret
end __strout
end strout_
