getenv_ module
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
G	_getenv	PR
E
_getenv:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%1F6+__sobuf
L1338:
	test	@r12
	jr	eq,L1356
	ld	r2,r12
	inc	r12,#2
	push	@r15,@r2
	push	@r15,r13
	call	L135A
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	eq,L1338
	ld	r2,r11
L1352:
	jp	cret
L1356:
	xor	r2,r2
	jr	L1352
L135A:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
L1366:
	ld	r2,r12
	inc	r12,#1
	ldb	rl0,@r2
	cpb	rl0,@r13
	jr	ne,L1392
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%003D
	jr	ne,L1366
L137E:
	ld	r2,r12
	jr	L1398
L1382:
	ld	r2,r12
	dec	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%003D
	jr	ne,L1396
	jr	L137E
L1392:
	testb	@r13
	jr	eq,L1382
L1396:
	xor	r2,r2
L1398:
	jp	cret
end _getenv
end getenv_
