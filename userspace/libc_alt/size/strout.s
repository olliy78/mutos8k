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
	jr	L0600
L0576:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L05CE
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L05CE
	bitb	%0006(r11),#0
	jr	ne,L05B0
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L05B0
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L05CC
L05B0:
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
L05CC:
	dec	r12,#1
L05CE:
	bitb	%0006(r11),#0
	jr	ne,L05EA
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L05EA
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L05FC
L05EA:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L05FC:
	inc	%0008(r14),#1
L0600:
	test	%0008(r14)
	jr	mi,L0576
	jr	L064A
L0608:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L062E
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L064A
L0628:
	bitb	%0006(r11),#0
	jr	eq,L0608
L062E:
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
L064A:
	dec	r12,#1
	jr	pl,L0628
	jr	L0682
L0650:
	bitb	%0006(r11),#0
	jr	ne,L066C
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L066C
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L067E
L066C:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L067E:
	dec	%0008(r14),#1
L0682:
	test	%0008(r14)
	jr	ne,L0650
	jp	cret
end __strout
end strout_
