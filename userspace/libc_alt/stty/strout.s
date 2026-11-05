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
	jr	L0AC8
L0A3E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0A96
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0A96
	bitb	%0006(r11),#0
	jr	ne,L0A78
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0A78
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0A94
L0A78:
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
L0A94:
	dec	r12,#1
L0A96:
	bitb	%0006(r11),#0
	jr	ne,L0AB2
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0AB2
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0AC4
L0AB2:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0AC4:
	inc	%0008(r14),#1
L0AC8:
	test	%0008(r14)
	jr	mi,L0A3E
	jr	L0B12
L0AD0:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0AF6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0B12
L0AF0:
	bitb	%0006(r11),#0
	jr	eq,L0AD0
L0AF6:
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
L0B12:
	dec	r12,#1
	jr	pl,L0AF0
	jr	L0B4A
L0B18:
	bitb	%0006(r11),#0
	jr	ne,L0B34
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0B34
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0B46
L0B34:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0B46:
	dec	%0008(r14),#1
L0B4A:
	test	%0008(r14)
	jr	ne,L0B18
	jp	cret
end __strout
end strout_
