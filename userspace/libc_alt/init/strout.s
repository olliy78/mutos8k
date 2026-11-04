strout module
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
	jr	L090C
L0882:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L08DA
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L08DA
	bitb	%0006(r11),#0
	jr	ne,L08BC
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L08BC
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L08D8
L08BC:
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
L08D8:
	dec	r12,#1
L08DA:
	bitb	%0006(r11),#0
	jr	ne,L08F6
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L08F6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0908
L08F6:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0908:
	inc	%0008(r14),#1
L090C:
	test	%0008(r14)
	jr	mi,L0882
	jr	L0956
L0914:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L093A
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0956
L0934:
	bitb	%0006(r11),#0
	jr	eq,L0914
L093A:
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
L0956:
	dec	r12,#1
	jr	pl,L0934
	jr	L098E
L095C:
	bitb	%0006(r11),#0
	jr	ne,L0978
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0978
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L098A
L0978:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L098A:
	dec	%0008(r14),#1
L098E:
	test	%0008(r14)
	jr	ne,L095C
	jp	cret
end __strout
end strout
