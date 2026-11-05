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
	jr	eq,L098C
	jr	L0986
L0940:
	ld	r9,%0006(r14)
L0944:
	bitb	%0006(r12),#1
	jr	ne,L0962
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L0962
	ld	r2,@r12
	inc	@r12,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L0970
L0962:
	push	@r15,r2
	push	@r15,r12
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L0970:
	ld	r2,r3
	ld	r11,r2
	test	r11
	jr	mi,L098C
	ld	r2,r13
	inc	r13,#1
	ld	r3,r11
	ldb	@r2,rl3
	dec	r9,#1
	jr	ne,L0944
	inc	r10,#1
L0986:
	cp	r10,%0008(r14)
	jr	ult,L0940
L098C:
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
	jr	eq,L0A04
	jr	L09FE
L09A8:
	ld	r11,%0006(r14)
L09AC:
	bitb	%0006(r12),#0
	jr	ne,L09D2
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L09D2
	ld	r2,@r12
	inc	@r12,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L09EE
L09D2:
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
L09EE:
	djnz	r11,L09AC
	ldb	rl2,%0006(r12)
	xorb	rh2,rh2
	and	r2,#%0020
	jr	ne,L0A04
	inc	r10,#1
L09FE:
	cp	r10,%0008(r14)
	jr	ult,L09A8
L0A04:
	ld	r2,r10
	jp	cret
end _fwrite
end rdwr_
