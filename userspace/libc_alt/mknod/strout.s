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
	jr	L03F0
L0366:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L03BE
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L03BE
	bitb	%0006(r11),#0
	jr	ne,L03A0
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L03A0
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L03BC
L03A0:
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
L03BC:
	dec	r12,#1
L03BE:
	bitb	%0006(r11),#0
	jr	ne,L03DA
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L03DA
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L03EC
L03DA:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L03EC:
	inc	%0008(r14),#1
L03F0:
	test	%0008(r14)
	jr	mi,L0366
	jr	L043A
L03F8:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L041E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L043A
L0418:
	bitb	%0006(r11),#0
	jr	eq,L03F8
L041E:
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
L043A:
	dec	r12,#1
	jr	pl,L0418
	jr	L0472
L0440:
	bitb	%0006(r11),#0
	jr	ne,L045C
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L045C
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L046E
L045C:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L046E:
	dec	%0008(r14),#1
L0472:
	test	%0008(r14)
	jr	ne,L0440
	jp	cret
end __strout
end strout_
