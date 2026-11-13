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
	jr	L05A0
L0516:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L056E
	ld	r0,%000C(r14)
	cp	r0,#%0030
	jr	ne,L056E
	bitb	%0006(r11),#0
	jr	ne,L0550
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L0550
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L056C
L0550:
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
L056C:
	dec	r12,#1
L056E:
	bitb	%0006(r11),#0
	jr	ne,L058A
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L058A
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L059C
L058A:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L059C:
	inc	%0008(r14),#1
L05A0:
	test	%0008(r14)
	jr	mi,L0516
	jr	L05EA
L05A8:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L05CE
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L05EA
L05C8:
	bitb	%0006(r11),#0
	jr	eq,L05A8
L05CE:
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
L05EA:
	dec	r12,#1
	jr	pl,L05C8
	jr	L0622
L05F0:
	bitb	%0006(r11),#0
	jr	ne,L060C
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L060C
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L061E
L060C:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L061E:
	dec	%0008(r14),#1
L0622:
	test	%0008(r14)
	jr	ne,L05F0
	jp	cret
end __strout
end strout_
