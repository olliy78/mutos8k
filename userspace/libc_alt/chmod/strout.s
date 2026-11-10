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
	jr	L05CC
L0542:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L059A
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L059A
	bitb	%0006(r11),#0
	jr	ne,L057C
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L057C
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0598
L057C:
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
L0598:
	dec	r12,#1
L059A:
	bitb	%0006(r11),#0
	jr	ne,L05B6
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L05B6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L05C8
L05B6:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L05C8:
	inc	%0008(r14),#1
L05CC:
	test	%0008(r14)
	jr	mi,L0542
	jr	L0616
L05D4:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L05FA
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0616
L05F4:
	bitb	%0006(r11),#0
	jr	eq,L05D4
L05FA:
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
L0616:
	dec	r12,#1
	jr	pl,L05F4
	jr	L064E
L061C:
	bitb	%0006(r11),#0
	jr	ne,L0638
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0638
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L064A
L0638:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L064A:
	dec	%0008(r14),#1
L064E:
	test	%0008(r14)
	jr	ne,L061C
	jp	cret
end __strout
end strout_
