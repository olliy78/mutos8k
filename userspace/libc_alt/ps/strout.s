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
	jr	L1116
L108E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	ne,L10E4
	cp	%000C(r14),#%0030
	jr	ne,L10E4
	bitb	%0006(r11),#0
	jr	ne,L10C6
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L10C6
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L10E2
L10C6:
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
L10E2:
	dec	r12,#1
L10E4:
	bitb	%0006(r11),#0
	jr	ne,L1100
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L1100
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L1112
L1100:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L1112:
	inc	%0008(r14),#1
L1116:
	test	%0008(r14)
	jr	mi,L108E
	jr	L1160
L111E:
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L1144
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L1160
L113E:
	bitb	%0006(r11),#0
	jr	eq,L111E
L1144:
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
L1160:
	dec	r12,#1
	jr	pl,L113E
	jr	L1198
L1166:
	bitb	%0006(r11),#0
	jr	ne,L1182
	dec	%0002(r11),#1
	test	%0002(r11)
	jr	mi,L1182
	ld	r2,@r11
	inc	@r11,#1
	ld	r3,%000C(r14)
	ldb	@r2,rl3
	jr	L1194
L1182:
	push	@r15,r2
	push	@r15,r11
	push	@r15,%000C(r14)
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L1194:
	dec	%0008(r14),#1
L1198:
	test	%0008(r14)
	jr	ne,L1166
	jp	cret
end __strout
end strout_
