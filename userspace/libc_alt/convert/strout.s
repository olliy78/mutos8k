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
	jr	L08F8
L086E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L08C6
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L08C6
	bitb	%0006(r11),#0
	jr	ne,L08A8
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L08A8
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L08C4
L08A8:
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
L08C4:
	dec	r12,#1
L08C6:
	bitb	%0006(r11),#0
	jr	ne,L08E2
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L08E2
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L08F4
L08E2:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L08F4:
	inc	%0008(r14),#1
L08F8:
	test	%0008(r14)
	jr	mi,L086E
	jr	L0942
L0900:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0926
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0942
L0920:
	bitb	%0006(r11),#0
	jr	eq,L0900
L0926:
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
L0942:
	dec	r12,#1
	jr	pl,L0920
	jr	L097A
L0948:
	bitb	%0006(r11),#0
	jr	ne,L0964
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0964
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0976
L0964:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0976:
	dec	%0008(r14),#1
L097A:
	test	%0008(r14)
	jr	ne,L0948
	jp	cret
end __strout
end strout_
