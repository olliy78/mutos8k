flsbuf_ module
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
G	__flsbuf	PR
E
__flsbuf:
	call	csv
	ld	r13,%0006(r14)
	dec	r15,#2
	bitb	%0006(r13),#7
	jr	eq,L04E2
	bitb	%0006(r13),#0
	jr	eq,L04DA
	push	@r15,#%0001
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	push	@r15,r13
	call	_fseek
	inc	r15,#8
	resb	%0006(r13),#0
	ld	r2,%0004(r13)
	ld	@r13,r2
L04DA:
	setb	%0006(r13),#1
	resb	%0006(r13),#4
L04E2:
	bitb	%0006(r13),#2
	jr	eq,L0510
	ld	r2,%0004(r14)
	ldb	%FFF3(r14),rl2
	ldk	r10,#1
	push	@r15,r10
	ld	r2,r14
	dec	r2,#13
	push	@r15,r2
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_write
	inc	r15,#6
	ld	r11,r2
	clr	%0002(r13)
	jr	L05A2
L0510:
	ld	r12,%0004(r13)
	test	r12
	jr	ne,L056E
	cp	r13,#__iob
	jr	ne,L0548
	ld	r2,#__sibuf
L0522:
	ld	%0004(r13),r2
	ld	@r13,r2
	jr	L04E2
L052A:
	ldb	rl0,%F+__iob
	xorb	rh0,rh0
	push	@r15,r0
	call	_isatty
	inc	r15,#2
	test	r2
	jr	eq,L0542
L053C:
	setb	%0006(r13),#2
	jr	L04E2
L0542:
	ld	r2,#__sobuf
	jr	L0522
L0548:
	cp	r13,#%8+__iob
	jr	eq,L052A
	push	@r15,#%62+__doprnt
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	ld	r2,r12
	ld	%0004(r13),r12
	test	r12
	jr	eq,L053C
	setb	%0006(r13),#3
	xor	r11,r11
	ld	r10,r11
	jr	L0590
L056E:
	ld	r11,@r13
	sub	r11,r12
	ld	r2,r11
	ld	r10,r11
	jr	mi,L0590
	jr	eq,L0590
	ld	@r13,r12
	push	@r15,r11
	push	@r15,r12
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_write
	inc	r15,#6
	ld	r11,r2
L0590:
	ld	%0002(r13),#%61+__doprnt
	ld	r2,r12
	inc	r12,#1
	ld	r3,%0004(r14)
	ldb	@r2,rl3
	ld	@r13,r12
L05A2:
	cp	r10,r11
	jr	eq,L05B2
	setb	%0006(r13),#5
	ld	r2,#%FFFF
L05AE:
	jp	cret
L05B2:
	ld	r2,%0004(r14)
	jr	L05AE
end __flsbuf
G	_fflush	PR
E
_fflush:
	call	csv
	ld	r13,%0004(r14)
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0006
	cp	r2,#%0002
	jr	ne,L060A
	ld	r12,%0004(r13)
	test	r12
	jr	eq,L060A
	ld	r11,@r13
	sub	r11,r12
	jr	mi,L060A
	jr	eq,L060A
	ld	@r13,r12
	ld	%0002(r13),#%62+__doprnt
	push	@r15,r11
	push	@r15,r12
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_write
	inc	r15,#6
	cp	r2,r11
	jr	eq,L060A
	setb	%0006(r13),#5
	ld	r2,#%FFFF
L0606:
	jp	cret
L060A:
	xor	r2,r2
	jr	L0606
end _fflush
G	__cleanu	PR
E
__cleanu:
	call	csv
	ld	r13,#__iob
	jr	L0622
L0618:
	push	@r15,r13
	call	_fclose
	inc	r15,#2
	inc	r13,#8
L0622:
	cp	r13,__lastbu
	jr	ult,L0618
	jp	cret
end __cleanu
G	_fclose	PR
E
_fclose:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,#%FFFF
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0083
	jr	eq,L0684
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0040
	jr	ne,L0684
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	ld	r12,r2
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_close
	inc	r15,#2
	test	r2
	jr	pl,L0670
	ld	r12,#%FFFF
L0670:
	bitb	%0006(r13),#3
	jr	eq,L0680
	push	@r15,%0004(r13)
	call	_free
	inc	r15,#2
L0680:
	clr	%0004(r13)
L0684:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%FF00
	ldb	%0006(r13),rl2
	clr	%0002(r13)
	ld	r2,r12
	jp	cret
end _fclose
G	_fseek	PR
E
_fseek:
	call	csv
	ld	r13,%0004(r14)
	dec	r15,#4
	resb	%0006(r13),#4
	bitb	%0006(r13),#0
	jr	eq,L078A
	cp	%000A(r14),#%0002
	jr	ge,L075A
	test	%0004(r13)
	jr	eq,L075A
	bitb	%0006(r13),#2
	jr	ne,L075A
	ld	r12,%0002(r13)
	ldl	rr2,%0006(r14)
	ldl	%FFF0(r14),rr2
	test	%000A(r14)
	jr	ne,L070E
	ldl	rr2,%FFF0(r14)
	push	@r15,r2
	push	@r15,r3
	push	@r15,#%0001
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	rr4,rr2
	pop	r3,@r15
	pop	r2,@r15
	pushl	@r15,rr4
	ld	r5,r12
	exts	rr4
	popl	rr0,@r15
	subl	rr4,rr0
	addl	rr2,rr4
	ldl	%FFF0(r14),rr2
	jr	L071C
L070E:
	ldl	rr2,%0006(r14)
	ld	r5,r12
	exts	rr4
	subl	rr2,rr4
	ldl	%0006(r14),rr2
L071C:
	bitb	%0006(r13),#7
	jr	ne,L075A
	test	r12
	jr	mi,L075A
	jr	eq,L075A
	ld	r3,r12
	exts	rr2
	cpl	rr2,%FFF0(r14)
	jr	lt,L075A
	ld	r3,%0004(r13)
	sub	r3,@r13
	exts	rr2
	cpl	rr2,%FFF0(r14)
	jr	gt,L075A
	ld	r2,@r13
	add	r2,%FFF2(r14)
	ld	@r13,r2
	ld	r2,%0002(r13)
	sub	r2,%FFF2(r14)
	ld	%0002(r13),r2
L0754:
	xor	r2,r2
L0756:
	jp	cret
L075A:
	bitb	%0006(r13),#7
	jr	eq,L076A
	ld	r2,%0004(r13)
	ld	@r13,r2
	resb	%0006(r13),#0
L076A:
	push	@r15,%000A(r14)
	pushl	@r15,%0006(r14)
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	%FFF0(r14),rr2
	clr	%0002(r13)
	jr	L07CC
L078A:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0082
	jr	eq,L07CC
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	bitb	%0006(r13),#7
	jr	eq,L07B2
	clr	%0002(r13)
	resb	%0006(r13),#1
	ld	r2,%0004(r13)
	ld	@r13,r2
L07B2:
	push	@r15,%000A(r14)
	pushl	@r15,%0006(r14)
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	%FFF0(r14),rr2
L07CC:
	ldl	rr0,#%FFFFFFFF
	cpl	rr0,%FFF0(r14)
	jr	ne,L0754
	ld	r2,#%FFFF
	jr	L0756
end _fseek
end flsbuf_
