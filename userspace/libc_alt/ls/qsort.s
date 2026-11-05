qsort_ module
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
G	_qsort	PR
E
_qsort:
	call	csv
	ld	r2,%000A(r14)
	ld	B2F2E,r2
	ld	r2,%0008(r14)
	ld	B2F30,r2
	ld	r3,%0006(r14)
	mult	rr2,r2
	ld	r2,r3
	add	r2,%0004(r14)
	push	@r15,r2
	push	@r15,%0004(r14)
	call	L1A4C
	inc	r15,#4
	jp	cret
L1A4C:
	call	csv
	dec	r15,#4
	ld	r11,B2F30
L1A56:
	ld	r2,%0006(r14)
	sub	r2,%0004(r14)
	ld	%FFF0(r14),r2
	cp	r2,r11
	jp	ule,L1B68
	ld	r3,%FFF0(r14)
	ld	r4,r11
	sla	r4,#1
	exts	rr2
	div	rr2,r4
	mult	rr2,r11
	ld	r2,r3
	ld	%FFF0(r14),r2
	ld	r9,%0004(r14)
	add	r9,r2
	ld	r8,r9
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	sub	r12,r11
	jr	L1ABA
L1A92:
	sub	r9,r11
	push	@r15,r9
	push	@r15,r13
	call	L1B6C
	inc	r15,#4
	jr	L1ABA
L1AA0:
	push	@r15,r9
	push	@r15,r13
	ld	r2,B2F2E
	call	@r2
	inc	r15,#4
	ld	%FFF2(r14),r2
	test	r2
	jr	eq,L1A92
	test	r2
	jr	pl,L1B10
L1AB8:
	add	r13,r11
L1ABA:
	cp	r13,r9
	jr	ult,L1AA0
	jr	L1B10
L1AC0:
	push	@r15,r12
	add	r8,r11
	push	@r15,r8
	call	L1B6C
	inc	r15,#4
	jr	L1B10
L1ACE:
	push	@r15,r12
	add	r8,r11
	push	@r15,r8
	push	@r15,r13
	call	L1B9A
	inc	r15,#6
	add	r9,r11
	ld	r13,r9
	jr	L1B10
L1AE2:
	push	@r15,r12
	push	@r15,r8
	ld	r2,B2F2E
	call	@r2
	inc	r15,#4
	ld	%FFF2(r14),r2
	test	r2
	jr	eq,L1AC0
	test	r2
	jr	mi,L1B0E
	jr	eq,L1B0E
	cp	r13,r9
	jr	eq,L1ACE
	push	@r15,r12
	push	@r15,r13
	call	L1B6C
	inc	r15,#4
	sub	r12,r11
	jr	L1AB8
L1B0E:
	sub	r12,r11
L1B10:
	cp	r12,r8
	jr	ugt,L1AE2
	cp	r13,r9
	jr	ne,L1B54
	ld	r2,r9
	sub	r2,%0004(r14)
	ld	r3,%0006(r14)
	sub	r3,r8
	cp	r2,r3
	jr	lt,L1B3E
	push	@r15,%0006(r14)
	ld	r2,r8
	add	r2,r11
	push	@r15,r2
	call	L1A4C
	inc	r15,#4
	ld	%0006(r14),r9
	jr	L1A56
L1B3E:
	push	@r15,r9
	push	@r15,%0004(r14)
	call	L1A4C
	inc	r15,#4
	ld	r2,r8
	add	r2,r11
	ld	%0004(r14),r2
	! jr L1A56 !
	WV %E881
L1B54:
	push	@r15,r13
	sub	r9,r11
	push	@r15,r9
	push	@r15,r12
	call	L1B9A
	inc	r15,#6
	sub	r8,r11
	ld	r12,r8
	jr	L1ABA
L1B68:
	jp	cret
L1B6C:
	call	csv
	ld	r10,B2F30
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
L1B7C:
	ldb	rl0,@r13
	xorb	rh0,rh0
	ld	r11,r0
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r12
	ldb	@r2,rl3
	ld	r2,r12
	inc	r12,#1
	ld	r3,r11
	ldb	@r2,rl3
	dec	r10,#1
	jr	ne,L1B7C
	jp	cret
L1B9A:
	call	csv
	ld	r9,B2F30
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	ld	r11,%0008(r14)
L1BAE:
	ldb	rl2,@r13
	xorb	rh2,rh2
	ld	r10,r2
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r11
	ldb	@r2,rl3
	ld	r2,r11
	inc	r11,#1
	ldb	rl3,@r12
	ldb	@r2,rl3
	ld	r2,r12
	inc	r12,#1
	ld	r3,r10
	ldb	@r2,rl3
	djnz	r9,L1BAE
	jp	cret
end _qsort
$SECTION BSS_B
I
B2F2E:
$REL	$+%2
B2F30:
$REL	$+%2
$SDEFAULT
end qsort_
