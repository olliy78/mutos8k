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
	jr	L08E8
L085E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L08B6
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L08B6
	bitb	%0006(r11),#0
	jr	ne,L0898
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0898
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L08B4
L0898:
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
L08B4:
	dec	r12,#1
L08B6:
	bitb	%0006(r11),#0
	jr	ne,L08D2
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L08D2
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L08E4
L08D2:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L08E4:
	inc	%0008(r14),#1
L08E8:
	test	%0008(r14)
	jr	mi,L085E
	jr	L0932
L08F0:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0916
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0932
L0910:
	bitb	%0006(r11),#0
	jr	eq,L08F0
L0916:
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
L0932:
	dec	r12,#1
	jr	pl,L0910
	jr	L096A
L0938:
	bitb	%0006(r11),#0
	jr	ne,L0954
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0954
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0966
L0954:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0966:
	dec	%0008(r14),#1
L096A:
	test	%0008(r14)
	jr	ne,L0938
	jp	cret
end __strout
end strout_
