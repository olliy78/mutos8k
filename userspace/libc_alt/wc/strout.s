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
	jr	L067A
L05F0:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0648
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0648
	bitb	%0006(r11),#0
	jr	ne,L062A
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L062A
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0646
L062A:
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
L0646:
	dec	r12,#1
L0648:
	bitb	%0006(r11),#0
	jr	ne,L0664
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0664
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0676
L0664:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0676:
	inc	%0008(r14),#1
L067A:
	test	%0008(r14)
	jr	mi,L05F0
	jr	L06C4
L0682:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L06A8
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L06C4
L06A2:
	bitb	%0006(r11),#0
	jr	eq,L0682
L06A8:
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
L06C4:
	dec	r12,#1
	jr	pl,L06A2
	jr	L06FC
L06CA:
	bitb	%0006(r11),#0
	jr	ne,L06E6
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L06E6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L06F8
L06E6:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L06F8:
	dec	%0008(r14),#1
L06FC:
	test	%0008(r14)
	jr	ne,L06CA
	jp	cret
end __strout
end strout_
