rdwr_ module
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
G	_fread	PR
E
_fread:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%000A(r14)
	xor	r10,r10
	test	%0006(r14)
	jr	eq,L040C
	jr	L0406
L03C0:
	ld	r9,%0006(r14)
L03C4:
	bitb	%0006(r12),#1
	jr	ne,L03E2
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L03E2
	ld	r2,@r12
	inc	@r12,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L03F0
L03E2:
	push	@r15,r2
	push	@r15,r12
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L03F0:
	ld	r2,r3
	ld	r11,r2
	test	r11
	jr	mi,L040C
	ld	r2,r13
	inc	r13,#1
	ld	r3,r11
	ldb	@r2,rl3
	dec	r9,#1
	jr	ne,L03C4
	inc	r10,#1
L0406:
	cp	r10,%0008(r14)
	jr	ult,L03C0
L040C:
	ld	r2,r10
	jp	cret
end _fread
G	_fwrite	PR
E
_fwrite:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%000A(r14)
	xor	r10,r10
	test	%0006(r14)
	jr	eq,L0484
	jr	L047E
L0428:
	ld	r11,%0006(r14)
L042C:
	bitb	%0006(r12),#0
	jr	ne,L0452
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L0452
	ld	r2,@r12
	inc	@r12,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L046E
L0452:
	push	@r15,r2
	push	@r15,r12
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
L046E:
	djnz	r11,L042C
	ldb	rl2,%0006(r12)
	xorb	rh2,rh2
	and	r2,#%0020
	jr	ne,L0484
	inc	r10,#1
L047E:
	cp	r10,%0008(r14)
	jr	ult,L0428
L0484:
	ld	r2,r10
	jp	cret
end _fwrite
end rdwr_
