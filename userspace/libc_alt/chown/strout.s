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
	jr	L0730
L06A6:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L06FE
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L06FE
	bitb	%0006(r11),#0
	jr	ne,L06E0
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L06E0
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L06FC
L06E0:
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
L06FC:
	dec	r12,#1
L06FE:
	bitb	%0006(r11),#0
	jr	ne,L071A
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L071A
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L072C
L071A:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L072C:
	inc	%0008(r14),#1
L0730:
	test	%0008(r14)
	jr	mi,L06A6
	jr	L077A
L0738:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L075E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L077A
L0758:
	bitb	%0006(r11),#0
	jr	eq,L0738
L075E:
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
L077A:
	dec	r12,#1
	jr	pl,L0758
	jr	L07B2
L0780:
	bitb	%0006(r11),#0
	jr	ne,L079C
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L079C
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L07AE
L079C:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L07AE:
	dec	%0008(r14),#1
L07B2:
	test	%0008(r14)
	jr	ne,L0780
	jp	cret
end __strout
end strout_
