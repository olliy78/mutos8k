endopen_ module
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
G	__endope	PR
E
__endope:
	call	csv
	ld	r13,%0008(r14)
	test	r13
	jr	ne,L7154
L714E:
	xor	r2,r2
L7150:
	jp	cret
L7154:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L7168
	xor	r3,r3
	jr	L716A
L7168:
	ldk	r3,#1
L716A:
	ld	r12,r3
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r3,#%0061
	jr	eq,L7194
	cp	r3,#%0072
	jr	eq,L71DC
	cp	r3,#%0077
	jr	ne,L714E
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L722A
	jr	L71F2
L7194:
	test	r12
	jr	eq,L719E
	push	@r15,#%0002
	jr	L71A2
L719E:
	push	@r15,#%0001
L71A2:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L71C8
	cp	_errno,#%0002
	jr	ne,L71C8
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L722A
	inc	r15,#4
	ld	r11,r2
L71C8:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L71F6
L71DC:
	test	r12
	jr	eq,L71E6
	push	@r15,#%0002
	jr	L71EA
L71E6:
	push	@r15,#%0000
L71EA:
	push	@r15,%0004(r14)
	call	_open
L71F2:
	inc	r15,#4
	ld	r11,r2
L71F6:
	test	r11
	jr	mi,L714E
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L720E
	setb	%0006(r13),#7
	jr	L7226
L720E:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L7222
	setb	%0006(r13),#0
	jr	L7226
L7222:
	setb	%0006(r13),#1
L7226:
	ld	r2,r13
	jr	L7150
L722A:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L725E
	test	r12
	jr	mi,L725E
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L725E:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
