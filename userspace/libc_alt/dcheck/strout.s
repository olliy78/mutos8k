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
	jr	L07B2
L0728:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0780
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0780
	bitb	%0006(r11),#0
	jr	ne,L0762
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0762
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L077E
L0762:
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
L077E:
	dec	r12,#1
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
	inc	%0008(r14),#1
L07B2:
	test	%0008(r14)
	jr	mi,L0728
	jr	L07FC
L07BA:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L07E0
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L07FC
L07DA:
	bitb	%0006(r11),#0
	jr	eq,L07BA
L07E0:
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
L07FC:
	dec	r12,#1
	jr	pl,L07DA
	jr	L0834
L0802:
	bitb	%0006(r11),#0
	jr	ne,L081E
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L081E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0830
L081E:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0830:
	dec	%0008(r14),#1
L0834:
	test	%0008(r14)
	jr	ne,L0802
	jp	cret
end __strout
end strout_
