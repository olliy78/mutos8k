puts_ module
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
G	_puts	PR
E
_puts:
	call	csv
	ld	r13,%0004(r14)
	jr	L050C
L04E0:
	dec	%A+__iob,#1
	jr	mi,L04FA
	ld	r2,%8+__iob
	inc	%8+__iob,#1
	ld	r3,r12
	ldb	@r2,rl3
	jr	L050C
L04F4:
	bitb	%E+__iob,#0
	jr	eq,L04E0
L04FA:
	push	@r15,r2
	push	@r15,#%8+__iob
	push	@r15,r12
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L050C:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r12,r3
	test	r3
	jr	ne,L04F4
	bitb	%E+__iob,#0
	jr	ne,L0534
	dec	%A+__iob,#1
	jr	mi,L0534
	ld	r2,%8+__iob
	inc	%8+__iob,#1
	ldk	r3,#10
	ldb	@r2,rl3
	jr	L0548
L0534:
	push	@r15,r2
	push	@r15,#%8+__iob
	push	@r15,#%000A
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L0548:
	ld	r2,r3
	jp	cret
end _puts
end puts_
