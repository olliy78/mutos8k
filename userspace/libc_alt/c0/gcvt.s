gcvt_ module
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
G	_gcvt	PR
E
_gcvt:
	call	csv
	dec	r15,#4
	ld	r2,r14
	dec	r2,#14
	push	@r15,r2
	ld	r2,r14
	dec	r2,#16
	push	@r15,r2
	push	@r15,%000C(r14)
	WV %4FE4;WV %8003;WV %0004
	dec	r15,#8
	WV %0FFC;WV %8003
	call	_ecvt
	inc	r15,#14
	ld	r13,r2
	ld	r12,%000E(r14)
	test	%FFF2(r14)
	jr	eq,L4F02
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%2D
L4F02:
	ld	r11,%000C(r14)
L4F06:
	dec	r11,#1
	jr	pl,L4F4C
L4F0A:
	test	%FFF0(r14)
	jr	mi,L4F1E
	ld	r2,%FFF0(r14)
	sub	r2,%000C(r14)
	cp	r2,#%0004
	jr	gt,L4F2E
L4F1E:
	test	%FFF0(r14)
	jr	pl,L4FD0
	ld	r0,%FFF0(r14)
	cp	r0,#%FFFD
	jr	ge,L4FD0
L4F2E:
	dec	%FFF0(r14),#1
	ld	r2,r12
	inc	r12,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%2E
	ldk	r11,#1
	jr	L4F72
L4F4C:
	jr	eq,L4F0A
	ld	r2,r13
	add	r2,r11
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0030
	jr	ne,L4F0A
	dec	%000C(r14),#1
	jr	L4F06
L4F62:
	ld	r2,r12
	inc	r12,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	inc	r11,#1
L4F72:
	cp	r11,%000C(r14)
	jr	lt,L4F62
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%65
	test	%FFF0(r14)
	jr	pl,L4F9A
	ld	r2,%FFF0(r14)
	neg	r2
	ld	%FFF0(r14),r2
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%2D
	jr	L4FA2
L4F9A:
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%2B
L4FA2:
	ld	r2,r12
	inc	r12,#1
	ld	r5,%FFF0(r14)
	exts	rr4
	div	rr4,#%000A
	ld	r3,r5
	add	r3,#%0030
	ldb	@r2,rl3
	ld	r2,r12
	inc	r12,#1
	ld	r5,%FFF0(r14)
	exts	rr4
	div	rr4,#%000A
	ld	r3,r4
	add	r3,#%0030
	ldb	@r2,rl3
	jr	L5050
L4FD0:
	test	%FFF0(r14)
	jr	eq,L4FD8
	jr	pl,L4FFE
L4FD8:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%0030
	jr	eq,L4FF8
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%2E
	jr	L4FF8
L4FEC:
	inc	%FFF0(r14),#1
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%30
L4FF8:
	test	%FFF0(r14)
	jr	mi,L4FEC
L4FFE:
	ldk	r11,#1
	jr	L5020
L5002:
	ld	r2,r12
	inc	r12,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	cp	r11,%FFF0(r14)
	jr	ne,L501E
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%2E
L501E:
	inc	r11,#1
L5020:
	cp	r11,%000C(r14)
	jr	le,L5002
	ld	r0,%000C(r14)
	cp	r0,%FFF0(r14)
	jr	ge,L5050
	jr	L503A
L5032:
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%30
L503A:
	ld	r2,%000C(r14)
	inc	%000C(r14),#1
	cp	r2,%FFF0(r14)
	jr	lt,L5032
	ld	r2,r12
	inc	r12,#1
	ldb	@r2,#%2E
L5050:
	ldb	rl2,%FFFF(r12)
	xorb	rh2,rh2
	cp	r2,#%002E
	jr	ne,L505E
	dec	r12,#1
L505E:
	clrb	@r12
	ld	r2,%000E(r14)
	jp	cret
end _gcvt
end gcvt_
