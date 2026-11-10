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
	jr	L07B8
L072E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L0786
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L0786
	bitb	%0006(r11),#0
	jr	ne,L0768
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0768
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0784
L0768:
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
L0784:
	dec	r12,#1
L0786:
	bitb	%0006(r11),#0
	jr	ne,L07A2
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L07A2
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L07B4
L07A2:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L07B4:
	inc	%0008(r14),#1
L07B8:
	test	%0008(r14)
	jr	mi,L072E
	jr	L0802
L07C0:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L07E6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0802
L07E0:
	bitb	%0006(r11),#0
	jr	eq,L07C0
L07E6:
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
L0802:
	dec	r12,#1
	jr	pl,L07E0
	jr	L083A
L0808:
	bitb	%0006(r11),#0
	jr	ne,L0824
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0824
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0836
L0824:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0836:
	dec	%0008(r14),#1
L083A:
	test	%0008(r14)
	jr	ne,L0808
	jp	cret
end __strout
end strout_
