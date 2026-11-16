mktemp_ module
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
G	_mktemp	PR
E
_mktemp:
	call	csv
	call	_getpid
	ld	r12,r2
	ld	r13,%0004(r14)
L3530:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	testb	rl3
	jr	ne,L3530
	dec	r13,#1
	jr	L3558
L3540:
	ld	r3,r12
	xor	r2,r2
	div	rr2,#%000A
	add	r2,#%0030
	ldb	@r13,rl2
	ld	r3,r12
	xor	r2,r2
	div	rr2,#%000A
	ld	r12,r3
L3558:
	dec	r13,#1
	ld	r2,r13
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0058
	jr	eq,L3540
	inc	r13,#1
	ld	r11,#%0061
	jr	L3582
L356E:
	cp	r11,#%007A
	jr	ne,L357C
	ld	r2,#D41D2
L3578:
	jp	cret
L357C:
	ld	r2,r11
	ldb	@r13,rl2
	inc	r11,#1
L3582:
	push	@r15,#%0000
	push	@r15,%0004(r14)
	call	_access
	inc	r15,#4
	cp	r2,#%FFFF
	jr	ne,L356E
	ld	r2,%0004(r14)
	jr	L3578
end _mktemp
I
D41D2:
BV %2F;BV %0
end mktemp_
