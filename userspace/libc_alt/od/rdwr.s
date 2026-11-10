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
	jr	eq,L07E8
	jr	L07E2
L079C:
	ld	r9,%0006(r14)
L07A0:
	bitb	%0006(r12),#1
	jr	ne,L07BE
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L07BE
	ld	r2,@r12
	inc	@r12,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L07CC
L07BE:
	push	@r15,r2
	push	@r15,r12
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L07CC:
	ld	r2,r3
	ld	r11,r2
	test	r11
	jr	mi,L07E8
	ld	r2,r13
	inc	r13,#1
	ld	r3,r11
	ldb	@r2,rl3
	dec	r9,#1
	jr	ne,L07A0
	inc	r10,#1
L07E2:
	cp	r10,%0008(r14)
	jr	ult,L079C
L07E8:
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
	jr	eq,L0860
	jr	L085A
L0804:
	ld	r11,%0006(r14)
L0808:
	bitb	%0006(r12),#0
	jr	ne,L082E
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L082E
	ld	r2,@r12
	inc	@r12,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L084A
L082E:
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
L084A:
	djnz	r11,L0808
	ldb	rl2,%0006(r12)
	xorb	rh2,rh2
	and	r2,#%0020
	jr	ne,L0860
	inc	r10,#1
L085A:
	cp	r10,%0008(r14)
	jr	ult,L0804
L0860:
	ld	r2,r10
	jp	cret
end _fwrite
end rdwr_
