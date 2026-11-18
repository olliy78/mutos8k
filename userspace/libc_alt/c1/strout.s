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
	jr	L6D80
L6CF8:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L6D4E
	cp	%000C(r14),#%0030
	jr	ne,L6D4E
	bitb	%0006(r11),#0
	jr	ne,L6D30
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L6D30
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L6D4C
L6D30:
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
L6D4C:
	dec	r12,#1
L6D4E:
	bitb	%0006(r11),#0
	jr	ne,L6D6A
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L6D6A
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L6D7C
L6D6A:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L6D7C:
	inc	%0008(r14),#1
L6D80:
	test	%0008(r14)
	jr	mi,L6CF8
	jr	L6DCA
L6D88:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L6DAE
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L6DCA
L6DA8:
	bitb	%0006(r11),#0
	jr	eq,L6D88
L6DAE:
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
L6DCA:
	dec	r12,#1
	jr	pl,L6DA8
	jr	L6E02
L6DD0:
	bitb	%0006(r11),#0
	jr	ne,L6DEC
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L6DEC
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L6DFE
L6DEC:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L6DFE:
	dec	%0008(r14),#1
L6E02:
	test	%0008(r14)
	jr	ne,L6DD0
	jp	cret
end __strout
end strout_
