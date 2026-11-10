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
	jr	L05FA
L0570:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L05C8
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L05C8
	bitb	%0006(r11),#0
	jr	ne,L05AA
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L05AA
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L05C6
L05AA:
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
L05C6:
	dec	r12,#1
L05C8:
	bitb	%0006(r11),#0
	jr	ne,L05E4
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L05E4
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L05F6
L05E4:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L05F6:
	inc	%0008(r14),#1
L05FA:
	test	%0008(r14)
	jr	mi,L0570
	jr	L0644
L0602:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0628
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0644
L0622:
	bitb	%0006(r11),#0
	jr	eq,L0602
L0628:
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
L0644:
	dec	r12,#1
	jr	pl,L0622
	jr	L067C
L064A:
	bitb	%0006(r11),#0
	jr	ne,L0666
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0666
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L0678
L0666:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0678:
	dec	%0008(r14),#1
L067C:
	test	%0008(r14)
	jr	ne,L064A
	jp	cret
end __strout
end strout_
