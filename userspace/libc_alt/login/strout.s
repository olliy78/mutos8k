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
	jr	L0C82
L0BF8:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0C50
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0C50
	bitb	%0006(r11),#0
	jr	ne,L0C32
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0C32
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0C4E
L0C32:
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
L0C4E:
	dec	r12,#1
L0C50:
	bitb	%0006(r11),#0
	jr	ne,L0C6C
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0C6C
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0C7E
L0C6C:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0C7E:
	inc	%0008(r14),#1
L0C82:
	test	%0008(r14)
	jr	mi,L0BF8
	jr	L0CCC
L0C8A:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0CB0
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0CCC
L0CAA:
	bitb	%0006(r11),#0
	jr	eq,L0C8A
L0CB0:
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
L0CCC:
	dec	r12,#1
	jr	pl,L0CAA
	jr	L0D04
L0CD2:
	bitb	%0006(r11),#0
	jr	ne,L0CEE
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0CEE
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0D00
L0CEE:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0D00:
	dec	%0008(r14),#1
L0D04:
	test	%0008(r14)
	jr	ne,L0CD2
	jp	cret
end __strout
end strout_
