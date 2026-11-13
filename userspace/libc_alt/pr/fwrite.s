fwrite_ module
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
G	_fwrite	PR
E
_fwrite:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%000A(r14)
	xor	r10,r10
	test	%0006(r14)
	jr	eq,L0A48
	jr	L0A42
L09EC:
	ld	r11,%0006(r14)
L09F0:
	bitb	%0006(r12),#0
	jr	ne,L0A16
	dec	%0002(r12),#1
	test	%0002(r12)
	jr	mi,L0A16
L0A00:
	ld	r2,@r12
	inc	@r12,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
L0A0A:
	xorb	rh4,rh4
	and	r4,#%00FF
	ld	r3,r4
	ldb	@r2,rl3
	jr	L0A32
L0A16:
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
L0A32:
	djnz	r11,L09F0
	ldb	rl2,%0006(r12)
	xorb	rh2,rh2
	and	r2,#%0020
	jr	ne,L0A48
	inc	r10,#1
L0A42:
	cp	r10,%0008(r14)
	jr	ult,L09EC
L0A48:
	ld	r2,r10
	jp	cret
end _fwrite
end fwrite_
