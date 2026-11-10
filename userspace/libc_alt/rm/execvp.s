execvp_ module
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
G	_execlp	PR
E
_execlp:
	call	csv
	ld	r2,r14
	inc	r2,#6
	push	@r15,r2
	push	@r15,%0004(r14)
	call	_execvp
	inc	r15,#4
	jp	cret
end _execlp
G	_execvp	PR
E
_execvp:
	call	csv
	sub	r15,#%0280
	ldk	r12,#1
	xor	r11,r11
	push	@r15,#D166C
	call	_getenv
	inc	r15,#2
	ld	r10,r2
	test	r10
	jr	ne,L0CF2
	ld	r10,#D1671
L0CF2:
	push	@r15,#%002F
	push	@r15,%0004(r14)
	call	_index
	inc	r15,#4
	test	r2
	jr	eq,L0D0A
	ld	r2,#D1680
	jr	L0D0C
L0D0A:
	ld	r2,r10
L0D0C:
	ld	r13,r2
L0D0E:
	ld	r2,r14
	add	r2,#%FF74
	push	@r15,r2
	push	@r15,%0004(r14)
	push	@r15,r13
	call	L0DDC
	inc	r15,#6
	ld	r13,r2
	jr	L0DAA
L0D26:
	cp	r2,#%001A
	jr	eq,L0D9A
L0D2C:
	test	r13
	jr	ne,L0D0E
	test	r11
	jr	eq,L0D42
	ld	_errno,#%000D
	jr	L0D42
L0D3C:
	ld	_errno,#%0007
L0D42:
	ld	r2,#%FFFF
	jp	cret
L0D4A:
	ld	r2,#D1681
	ld	%FD74(r14),r2
	ld	r2,r14
	add	r2,#%FF74
	ld	%FD76(r14),r2
	ldk	r9,#1
	jr	L0D68
L0D60:
	cp	r9,#%00FE
	jr	ge,L0D3C
	inc	r9,#1
L0D68:
	ld	r2,r9
	sla	r2,#1
	add	r2,r14
	add	r2,#%FD76
	ld	r3,r9
	sla	r3,#1
	add	r3,%0006(r14)
	ld	r4,@r3
	ld	@r2,r4
	test	r4
	jr	ne,L0D60
	ld	r2,r14
	add	r2,#%FD74
	push	@r15,r2
	push	@r15,#D1664
	call	_execv
	inc	r15,#4
	jr	L0D42
L0D9A:
	inc	r12,#1
	cp	r12,#%0005
	jr	ugt,L0D42
	push	@r15,r12
	call	_sleep
	inc	r15,#2
L0DAA:
	push	@r15,%0006(r14)
	ld	r2,r14
	add	r2,#%FF74
	push	@r15,r2
	call	_execv
	inc	r15,#4
	ld	r2,_errno
	cp	r2,#%0007
	jr	eq,L0D42
	cp	r2,#%0008
	jr	eq,L0D4A
	cp	r2,#%000C
	jr	eq,L0D42
	cp	r2,#%000D
	jr	ne,L0D26
	inc	r11,#1
	jr	L0D2C
L0DDC:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	ld	r11,%0008(r14)
	jr	L0E0C
L0DEE:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%003A
	jr	eq,L0E10
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	eq,L0E10
	ld	r2,r11
	inc	r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
L0E0C:
	testb	@r13
	jr	ne,L0DEE
L0E10:
	ld	r0,%0008(r14)
	cp	r0,r11
	jr	eq,L0E2E
	ld	r2,r11
	inc	r11,#1
	ldb	@r2,#%2F
	jr	L0E2E
L0E22:
	ld	r2,r11
	inc	r11,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
L0E2E:
	testb	@r12
	jr	ne,L0E22
	clrb	@r11
	testb	@r13
	jr	eq,L0E40
	inc	r13,#1
	ld	r2,r13
L0E3C:
	jp	cret
L0E40:
	xor	r2,r2
	jr	L0E3C
end _execvp
I
D1664:
BV %2F;BV %62;BV %69;BV %6E;BV %2F;BV %73;BV %68;BV %0
D166C:
BV %50;BV %41;BV %54;BV %48;BV %0
D1671:
BV %3A;BV %2F;BV %62;BV %69;BV %6E;BV %3A;BV %2F;BV %75
BV %73;BV %72;BV %2F;BV %62;BV %69;BV %6E;BV %0
D1680:
BV %0
D1681:
BV %73;BV %68;BV %0
end execvp_
