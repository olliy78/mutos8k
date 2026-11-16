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
	push	@r15,#D4144
	call	_getenv
	inc	r15,#2
	ld	r10,r2
	test	r10
	jr	ne,L2BBA
	ld	r10,#D4149
L2BBA:
	push	@r15,#%002F
	push	@r15,%0004(r14)
	call	_index
	inc	r15,#4
	test	r2
	jr	eq,L2BD2
	ld	r2,#D4158
	jr	L2BD4
L2BD2:
	ld	r2,r10
L2BD4:
	ld	r13,r2
L2BD6:
	ld	r2,r14
	add	r2,#%FF74
	push	@r15,r2
	push	@r15,%0004(r14)
	push	@r15,r13
	call	L2CA4
	inc	r15,#6
	ld	r13,r2
	jr	L2C72
L2BEE:
	cp	r2,#%001A
	jr	eq,L2C62
L2BF4:
	test	r13
	jr	ne,L2BD6
	test	r11
	jr	eq,L2C0A
	ld	_errno,#%000D
	jr	L2C0A
L2C04:
	ld	_errno,#%0007
L2C0A:
	ld	r2,#%FFFF
	jp	cret
L2C12:
	ld	r2,#D4159
	ld	%FD74(r14),r2
	ld	r2,r14
	add	r2,#%FF74
	ld	%FD76(r14),r2
	ldk	r9,#1
	jr	L2C30
L2C28:
	cp	r9,#%00FE
	jr	ge,L2C04
	inc	r9,#1
L2C30:
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
	jr	ne,L2C28
	ld	r2,r14
	add	r2,#%FD74
	push	@r15,r2
	push	@r15,#D413C
	call	_execv
	inc	r15,#4
	jr	L2C0A
L2C62:
	inc	r12,#1
	cp	r12,#%0005
	jr	ugt,L2C0A
	push	@r15,r12
	call	_sleep
	inc	r15,#2
L2C72:
	push	@r15,%0006(r14)
	ld	r2,r14
	add	r2,#%FF74
	push	@r15,r2
	call	_execv
	inc	r15,#4
	ld	r2,_errno
	cp	r2,#%0007
	jr	eq,L2C0A
	cp	r2,#%0008
	jr	eq,L2C12
	cp	r2,#%000C
	jr	eq,L2C0A
	cp	r2,#%000D
	jr	ne,L2BEE
	inc	r11,#1
	jr	L2BF4
L2CA4:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	ld	r11,%0008(r14)
	jr	L2CD4
L2CB6:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%003A
	jr	eq,L2CD8
	cp	r2,#%002D
	jr	eq,L2CD8
	ld	r2,r11
	inc	r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
L2CD4:
	testb	@r13
	jr	ne,L2CB6
L2CD8:
	ld	r0,%0008(r14)
	cp	r0,r11
	jr	eq,L2CF8
	ld	r2,r11
	inc	r11,#1
	ldb	@r2,#%2F
	jr	L2CF8
L2CEA:
	ld	r2,r11
	inc	r11,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
L2CF8:
	testb	@r12
	jr	ne,L2CEA
	clrb	@r11
	testb	@r13
	jr	eq,L2D0A
	inc	r13,#1
	ld	r2,r13
L2D06:
	jp	cret
L2D0A:
	xor	r2,r2
	jr	L2D06
end _execvp
I
D413C:
BV %2F;BV %62;BV %69;BV %6E;BV %2F;BV %73;BV %68;BV %0
D4144:
BV %50;BV %41;BV %54;BV %48;BV %0
D4149:
BV %3A;BV %2F;BV %62;BV %69;BV %6E;BV %3A;BV %2F;BV %75
BV %73;BV %72;BV %2F;BV %62;BV %69;BV %6E;BV %0
D4158:
BV %0
D4159:
BV %73;BV %68;BV %0
end execvp_
