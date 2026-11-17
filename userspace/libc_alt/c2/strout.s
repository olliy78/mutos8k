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
	jr	L39F0
L3968:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L39BE
	cp	%000C(r14),#%0030
	jr	ne,L39BE
	bitb	%0006(r11),#0
	jr	ne,L39A0
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L39A0
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L39BC
L39A0:
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
L39BC:
	dec	r12,#1
L39BE:
	bitb	%0006(r11),#0
	jr	ne,L39DA
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L39DA
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L39EC
L39DA:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L39EC:
	inc	%0008(r14),#1
L39F0:
	test	%0008(r14)
	jr	mi,L3968
	jr	L3A3A
L39F8:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L3A1E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L3A3A
L3A18:
	bitb	%0006(r11),#0
	jr	eq,L39F8
L3A1E:
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
L3A3A:
	dec	r12,#1
	jr	pl,L3A18
	jr	L3A72
L3A40:
	bitb	%0006(r11),#0
	jr	ne,L3A5C
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L3A5C
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L3A6E
L3A5C:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L3A6E:
	dec	%0008(r14),#1
L3A72:
	test	%0008(r14)
	jr	ne,L3A40
	jp	cret
end __strout
end strout_
