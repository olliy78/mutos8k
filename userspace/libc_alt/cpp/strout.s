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
	jr	L2A80
L29F6:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L2A4E
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L2A4E
	bitb	%0006(r11),#0
	jr	ne,L2A30
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L2A30
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L2A4C
L2A30:
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
L2A4C:
	dec	r12,#1
L2A4E:
	bitb	%0006(r11),#0
	jr	ne,L2A6A
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L2A6A
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L2A7C
L2A6A:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L2A7C:
	inc	%0008(r14),#1
L2A80:
	test	%0008(r14)
	jr	mi,L29F6
	jr	L2ACA
L2A88:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L2AAE
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L2ACA
L2AA8:
	bitb	%0006(r11),#0
	jr	eq,L2A88
L2AAE:
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
L2ACA:
	dec	r12,#1
	jr	pl,L2AA8
	jr	L2B02
L2AD0:
	bitb	%0006(r11),#0
	jr	ne,L2AEC
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L2AEC
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L2AFE
L2AEC:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L2AFE:
	dec	%0008(r14),#1
L2B02:
	test	%0008(r14)
	jr	ne,L2AD0
	jp	cret
end __strout
end strout_
