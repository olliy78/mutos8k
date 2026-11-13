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
	ld	B581C,r2
	ld	r2,%0008(r14)
	ld	B581E,r2
	ld	r3,%0006(r14)
	mult	rr2,r2
	ld	r2,r3
	add	r2,%0004(r14)
	push	@r15,r2
	push	@r15,%0004(r14)
	call	L1740
	inc	r15,#4
	jp	cret
L1740:
	call	csv
	dec	r15,#4
	ld	r11,B581E
L174A:
	ld	r2,%0006(r14)
	sub	r2,%0004(r14)
	ld	%FFF0(r14),r2
	cp	r2,r11
	! jr ule,L1858 !
	WV %E37F
	ld	r3,r2
	ld	r4,r11
	sla	r4,#1
	xor	r2,r2
	div	rr2,r4
	mult	rr2,r11
	ld	r2,r3
	ld	%FFF0(r14),r3
	ld	r9,%0004(r14)
	add	r9,r3
	ld	r8,r9
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	sub	r12,r11
	jr	L17AA
L1782:
	sub	r9,r11
	push	@r15,r9
	push	@r15,r13
	call	L185C
	inc	r15,#4
	jr	L17AA
L1790:
	push	@r15,r9
	push	@r15,r13
	ld	r2,B581C
	call	@r2
	inc	r15,#4
	ld	%FFF2(r14),r2
	test	r2
	jr	eq,L1782
	test	r2
	jr	pl,L1800
L17A8:
	add	r13,r11
L17AA:
	cp	r13,r9
	jr	ult,L1790
	jr	L1800
L17B0:
	push	@r15,r12
	add	r8,r11
	push	@r15,r8
	call	L185C
	inc	r15,#4
	jr	L1800
L17BE:
	push	@r15,r12
	add	r8,r11
	push	@r15,r8
	push	@r15,r13
	call	L188A
	inc	r15,#6
	add	r9,r11
	ld	r13,r9
	jr	L1800
L17D2:
	push	@r15,r12
	push	@r15,r8
	ld	r2,B581C
	call	@r2
	inc	r15,#4
	ld	%FFF2(r14),r2
	test	r2
	jr	eq,L17B0
	test	r2
	jr	mi,L17FE
	jr	eq,L17FE
	cp	r13,r9
	jr	eq,L17BE
	push	@r15,r12
	push	@r15,r13
	call	L185C
	inc	r15,#4
	sub	r12,r11
	jr	L17A8
L17FE:
	sub	r12,r11
L1800:
	cp	r12,r8
	jr	ugt,L17D2
	cp	r13,r9
	jr	ne,L1844
	ld	r2,r9
	sub	r2,%0004(r14)
	ld	r3,%0006(r14)
	sub	r3,r8
	cp	r2,r3
	jr	lt,L182E
	push	@r15,%0006(r14)
	ld	r2,r8
	add	r2,r11
	push	@r15,r2
	call	L1740
	inc	r15,#4
	ld	%0006(r14),r9
	jr	L174A
L182E:
	push	@r15,r9
	push	@r15,%0004(r14)
	call	L1740
	inc	r15,#4
	ld	r2,r8
	add	r2,r11
	ld	%0004(r14),r2
	jr	L174A
L1844:
	push	@r15,r13
	sub	r9,r11
	push	@r15,r9
	push	@r15,r12
	call	L188A
	inc	r15,#6
	sub	r8,r11
	ld	r12,r8
	jr	L17AA
L1858:
	jp	cret
L185C:
	call	csv
	ld	r10,B581E
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
L186C:
	ldb	rl2,@r13
	xorb	rh2,rh2
	ld	r11,r2
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r12
	xorb	rh3,rh3
	ldb	@r2,rl3
	ld	r2,r12
	inc	r12,#1
	ld	r3,r11
	ldb	@r2,rl3
	djnz	r10,L186C
	jp	cret
L188A:
	call	csv
	ld	r9,B581E
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	ld	r11,%0008(r14)
L189E:
	ldb	rl2,@r13
	xorb	rh2,rh2
	ld	r10,r2
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r11
	xorb	rh3,rh3
	ldb	@r2,rl3
	ld	r2,r11
	inc	r11,#1
	ldb	rl3,@r12
	xorb	rh3,rh3
	ldb	@r2,rl3
	ld	r2,r12
	inc	r12,#1
	ld	r3,r10
	ldb	@r2,rl3
	djnz	r9,L189E
	jp	cret
end _qsort
$SECTION BSS_B
I
B581C:
$REL	$+%2
B581E:
$REL	$+%2
$SDEFAULT
end qsort_
