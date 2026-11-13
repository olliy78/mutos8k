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
	jr	L070A
L0680:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L06D8
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L06D8
	bitb	%0006(r11),#0
	jr	ne,L06BA
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L06BA
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L06D6
L06BA:
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
L06D6:
	dec	r12,#1
L06D8:
	bitb	%0006(r11),#0
	jr	ne,L06F4
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L06F4
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0706
L06F4:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0706:
	inc	%0008(r14),#1
L070A:
	test	%0008(r14)
	jr	mi,L0680
	jr	L0754
L0712:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0738
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0754
L0732:
	bitb	%0006(r11),#0
	jr	eq,L0712
L0738:
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
L0754:
	dec	r12,#1
	jr	pl,L0732
	jr	L078C
L075A:
	bitb	%0006(r11),#0
	jr	ne,L0776
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0776
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0788
L0776:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0788:
	dec	%0008(r14),#1
L078C:
	test	%0008(r14)
	jr	ne,L075A
	jp	cret
end __strout
end strout_
