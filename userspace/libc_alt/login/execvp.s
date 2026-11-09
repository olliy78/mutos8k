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
	push	@r15,#D233E
	call	_getenv
	inc	r15,#2
	ld	r10,r2
	test	r10
	jr	ne,L11DA
	ld	r10,#D2343
L11DA:
	push	@r15,#%002F
	push	@r15,%0004(r14)
	call	_index
	inc	r15,#4
	test	r2
	jr	eq,L11F2
	ld	r2,#D2352
	jr	L11F4
L11F2:
	ld	r2,r10
L11F4:
	ld	r13,r2
L11F6:
	ld	r2,r14
	add	r2,#%FF74
	push	@r15,r2
	push	@r15,%0004(r14)
	push	@r15,r13
	call	L12C4
	inc	r15,#6
	ld	r13,r2
	jr	L1292
L120E:
	cp	r2,#%001A
	jr	eq,L1282
L1214:
	test	r13
	jr	ne,L11F6
	test	r11
	jr	eq,L122A
	ld	_errno,#%000D
	jr	L122A
L1224:
	ld	_errno,#%0007
L122A:
	ld	r2,#%FFFF
	jp	cret
L1232:
	ld	r2,#D2353
	ld	%FD74(r14),r2
	ld	r2,r14
	add	r2,#%FF74
	ld	%FD76(r14),r2
	ldk	r9,#1
	jr	L1250
L1248:
	cp	r9,#%00FE
	jr	ge,L1224
	inc	r9,#1
L1250:
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
	jr	ne,L1248
	ld	r2,r14
	add	r2,#%FD74
	push	@r15,r2
	push	@r15,#D2336
	call	_execv
	inc	r15,#4
	jr	L122A
L1282:
	inc	r12,#1
	cp	r12,#%0005
	jr	ugt,L122A
	push	@r15,r12
	call	_sleep
	inc	r15,#2
L1292:
	push	@r15,%0006(r14)
	ld	r2,r14
	add	r2,#%FF74
	push	@r15,r2
	call	_execv
	inc	r15,#4
	ld	r2,_errno
	cp	r2,#%0007
	jr	eq,L122A
	cp	r2,#%0008
	jr	eq,L1232
	cp	r2,#%000C
	jr	eq,L122A
	cp	r2,#%000D
	jr	ne,L120E
	inc	r11,#1
	jr	L1214
L12C4:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	ld	r11,%0008(r14)
	jr	L12F4
L12D6:
	ldb	rl2,@r13
	xorb	rh2,rh2
	cp	r2,#%003A
	jr	eq,L12F8
	xorb	rh2,rh2
	cp	r2,#%002D
	jr	eq,L12F8
	ld	r2,r11
	inc	r11,#1
	ld	r3,r13
	inc	r13,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
L12F4:
	testb	@r13
	jr	ne,L12D6
L12F8:
	ld	r0,%0008(r14)
	cp	r0,r11
	jr	eq,L1316
	ld	r2,r11
	inc	r11,#1
	ldb	@r2,#%2F
	jr	L1316
L130A:
	ld	r2,r11
	inc	r11,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
L1316:
	testb	@r12
	jr	ne,L130A
	clrb	@r11
	testb	@r13
	jr	eq,L1328
	inc	r13,#1
	ld	r2,r13
L1324:
	jp	cret
L1328:
	xor	r2,r2
	jr	L1324
end _execvp
I
D2336:
BV %2F;BV %62;BV %69;BV %6E;BV %2F;BV %73;BV %68;BV %0
D233E:
BV %50;BV %41;BV %54;BV %48;BV %0
D2343:
BV %3A;BV %2F;BV %62;BV %69;BV %6E;BV %3A;BV %2F;BV %75
BV %73;BV %72;BV %2F;BV %62;BV %69;BV %6E;BV %0
D2352:
BV %0
D2353:
BV %73;BV %68;BV %0
end execvp_
