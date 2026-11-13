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
L0BB0:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	testb	rl3
	jr	ne,L0BB0
	dec	r13,#1
	jr	L0BD8
L0BC0:
	ld	r3,r12
	exts	rr2
	div	rr2,#%000A
	add	r2,#%0030
	ldb	@r13,rl2
	ld	r3,r12
	exts	rr2
	div	rr2,#%000A
	ld	r12,r3
L0BD8:
	dec	r13,#1
	ld	r2,r13
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0058
	jr	eq,L0BC0
	inc	r13,#1
	ld	r11,#%0061
	jr	L0C02
L0BEE:
	cp	r11,#%007A
	jr	ne,L0BFC
	ld	r2,#D0FAA
L0BF8:
	jp	cret
L0BFC:
	ld	r2,r11
	ldb	@r13,rl2
	inc	r11,#1
L0C02:
	push	@r15,#%0000
	push	@r15,%0004(r14)
	call	_access
	inc	r15,#4
	cp	r2,#%FFFF
	jr	ne,L0BEE
	ld	r2,%0004(r14)
	jr	L0BF8
end _mktemp
I
D0FAA:
BV %2F;BV %0
end mktemp_
