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
	jr	ne,L5738
L5732:
	xor	r2,r2
L5734:
	jp	cret
L5738:
	ld	r2,%0006(r14)
	inc	r2,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%002B
	jr	eq,L574C
	xor	r3,r3
	jr	L574E
L574C:
	ldk	r3,#1
L574E:
	ld	r12,r3
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r2,r3
	cp	r3,#%0061
	jr	eq,L5778
	cp	r3,#%0072
	jr	eq,L57C0
	cp	r3,#%0077
	jr	ne,L5732
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L580E
	jr	L57D6
L5778:
	test	r12
	jr	eq,L5782
	push	@r15,#%0002
	jr	L5786
L5782:
	push	@r15,#%0001
L5786:
	push	@r15,%0004(r14)
	call	_open
	inc	r15,#4
	ld	r11,r2
	test	r11
	jr	pl,L57AC
	cp	_errno,#%0002
	jr	ne,L57AC
	push	@r15,r12
	push	@r15,%0004(r14)
	call	L580E
	inc	r15,#4
	ld	r11,r2
L57AC:
	push	@r15,#%0002
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r11
	call	_lseek
	inc	r15,#8
	jr	L57DA
L57C0:
	test	r12
	jr	eq,L57CA
	push	@r15,#%0002
	jr	L57CE
L57CA:
	push	@r15,#%0000
L57CE:
	push	@r15,%0004(r14)
	call	_open
L57D6:
	inc	r15,#4
	ld	r11,r2
L57DA:
	test	r11
	jr	mi,L5732
	clr	%0002(r13)
	ld	r2,r11
	ldb	%0007(r13),rl2
	test	r12
	jr	eq,L57F2
	setb	%0006(r13),#7
	jr	L580A
L57F2:
	ld	r2,%0006(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	cp	r3,#%0072
	jr	ne,L5806
	setb	%0006(r13),#0
	jr	L580A
L5806:
	setb	%0006(r13),#1
L580A:
	ld	r2,r13
	jr	L5734
L580E:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,#%01B6
	push	@r15,r13
	call	_creat
	inc	r15,#4
	ld	r12,r2
	test	%0006(r14)
	jr	eq,L5842
	test	r12
	jr	mi,L5842
	push	@r15,r12
	call	_close
	ld	@r15,#%0002
	push	@r15,r13
	call	_open
	inc	r15,#4
	ld	r12,r2
L5842:
	ld	r2,r12
	jp	cret
end __endope
end endopen_
