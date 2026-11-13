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
	jr	L0EC4
L0E3A:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0E92
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0E92
	bitb	%0006(r11),#0
	jr	ne,L0E74
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0E74
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0E90
L0E74:
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
L0E90:
	dec	r12,#1
L0E92:
	bitb	%0006(r11),#0
	jr	ne,L0EAE
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0EAE
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0EC0
L0EAE:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0EC0:
	inc	%0008(r14),#1
L0EC4:
	test	%0008(r14)
	jr	mi,L0E3A
	jr	L0F0E
L0ECC:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0EF2
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0F0E
L0EEC:
	bitb	%0006(r11),#0
	jr	eq,L0ECC
L0EF2:
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
L0F0E:
	dec	r12,#1
	jr	pl,L0EEC
	jr	L0F46
L0F14:
	bitb	%0006(r11),#0
	jr	ne,L0F30
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0F30
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0F42
L0F30:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0F42:
	dec	%0008(r14),#1
L0F46:
	test	%0008(r14)
	jr	ne,L0F14
	jp	cret
end __strout
end strout_
