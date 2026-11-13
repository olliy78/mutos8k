fgets_ module
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
G	_fgets	PR
E
_fgets:
	call	csv
	ld	r13,%0008(r14)
	ld	r11,%0004(r14)
L072C:
	dec	%0006(r14),#1
	jr	mi,L0776
	jr	eq,L0776
	bitb	%0006(r13),#1
	jr	ne,L0752
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	mi,L0752
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L0760
L0752:
	push	@r15,r2
	push	@r15,r13
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L0760:
	ld	r2,r3
	ld	r12,r2
	test	r12
	jr	mi,L0776
	ld	r2,r11
	inc	r11,#1
	ld	r3,r12
	ldb	@r2,rl3
	cp	r12,#%000A
	jr	ne,L072C
L0776:
	test	r12
	jr	pl,L0786
	cp	r11,%0004(r14)
	jr	ne,L0786
	xor	r2,r2
L0782:
	jp	cret
L0786:
	ld	r2,r11
	inc	r11,#1
	clrb	@r2
	ld	r2,%0004(r14)
	jr	L0782
end _fgets
end fgets_
