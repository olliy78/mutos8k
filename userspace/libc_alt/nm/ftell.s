ftell_ module
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
G	_ftell	PR
E
_ftell:
	call	csv
	dec	r15,#4
	ld	r2,%0004(r14)
	inc	r2,#2
	test	@r2
	jr	pl,L0616
	ld	r2,%0004(r14)
	inc	r2,#2
	clr	@r2
L0616:
	ld	r2,%0004(r14)
	inc	r2,#6
	bitb	@r2,#0
	jr	eq,L065A
	ld	r2,%0004(r14)
	inc	r2,#2
	ld	r3,@r2
	neg	r3
	ld	r2,r3
L062C:
	ld	r13,r2
L062E:
	push	@r15,#%0001
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	ld	r2,%0004(r14)
	inc	r2,#7
	ldb	rl0,@r2
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	%FFF0(r14),rr2
	testl	rr2
	jr	pl,L06AC
L0652:
	ldl	rr2,%FFF0(r14)
L0656:
	jp	cret
L065A:
	ld	r2,%0004(r14)
	inc	r2,#6
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%0082
	jr	eq,L06A4
	xor	r13,r13
	ld	r2,%0004(r14)
	inc	r2,#6
	bitb	@r2,#1
	jr	eq,L062E
	ld	r2,%0004(r14)
	inc	r2,#4
	ld	r3,@r2
	test	r3
	jr	eq,L062E
	ld	r2,%0004(r14)
	inc	r2,#6
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%0004
	jr	ne,L062E
	ld	r2,%0004(r14)
	ld	r3,%0004(r14)
	inc	r3,#4
	ld	r4,@r2
	sub	r4,@r3
	ld	r2,r4
	jr	L062C
L06A4:
	ldl	rr2,#%FFFFFFFF
	jr	L0656
L06AC:
	ldl	rr2,%FFF0(r14)
	ld	r5,r13
	exts	rr4
	addl	rr2,rr4
	ldl	%FFF0(r14),rr2
	jr	L0652
end _ftell
end ftell_
