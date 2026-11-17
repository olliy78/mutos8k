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
	jr	L0E80
L0DF6:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0E4E
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0E4E
	bitb	%0006(r11),#0
	jr	ne,L0E30
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0E30
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0E4C
L0E30:
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
L0E4C:
	dec	r12,#1
L0E4E:
	bitb	%0006(r11),#0
	jr	ne,L0E6A
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0E6A
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0E7C
L0E6A:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0E7C:
	inc	%0008(r14),#1
L0E80:
	test	%0008(r14)
	jr	mi,L0DF6
	jr	L0ECA
L0E88:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0EAE
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0ECA
L0EA8:
	bitb	%0006(r11),#0
	jr	eq,L0E88
L0EAE:
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
L0ECA:
	dec	r12,#1
	jr	pl,L0EA8
	jr	L0F02
L0ED0:
	bitb	%0006(r11),#0
	jr	ne,L0EEC
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0EEC
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0EFE
L0EEC:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0EFE:
	dec	%0008(r14),#1
L0F02:
	test	%0008(r14)
	jr	ne,L0ED0
	jp	cret
end __strout
end strout_
