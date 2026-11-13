fread_ module
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
	jr	eq,L09D0
	jr	L09CA
L0984:
	ld	r9,%0006(r14)
L0988:
	bitb	%0006(r12),#1
	jr	ne,L09A6
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L09A6
	ld	r2,@r12
	inc	@r12,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L09B4
L09A6:
	push	@r15,r2
	push	@r15,r12
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L09B4:
	ld	r2,r3
	ld	r11,r2
	test	r11
	jr	mi,L09D0
	ld	r2,r13
	inc	r13,#1
	ld	r3,r11
	ldb	@r2,rl3
	dec	r9,#1
	jr	ne,L0988
	inc	r10,#1
L09CA:
	cp	r10,%0008(r14)
	jr	ult,L0984
L09D0:
	ld	r2,r10
	jp	cret
end _fread
end fread_
