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
	jr	eq,L6E46
	bitb	%0006(r13),#0
	jr	eq,L6E3E
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
L6E3E:
	setb	%0006(r13),#1
	resb	%0006(r13),#4
L6E46:
	bitb	%0006(r13),#2
	jr	eq,L6E74
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
	jr	L6F06
L6E74:
	ld	r12,%0004(r13)
	test	r12
	jr	ne,L6ED2
	cp	r13,#__iob
	jr	ne,L6EAC
	ld	r2,#%8E96
L6E86:
	ld	%0004(r13),r2
	ld	@r13,r2
	jr	L6E46
L6E8E:
	ldb	rl0,%F+__iob
	xorb	rh0,rh0
	push	@r15,r0
	call	_isatty
	inc	r15,#2
	test	r2
	jr	eq,L6EA6
L6EA0:
	setb	%0006(r13),#2
	jr	L6E46
L6EA6:
	ld	r2,#%1E4+__sibuf
	jr	L6E86
L6EAC:
	cp	r13,#%8+__iob
	jr	eq,L6E8E
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	ld	r2,r12
	ld	%0004(r13),r12
	test	r12
	jr	eq,L6EA0
	setb	%0006(r13),#3
	xor	r11,r11
	ld	r10,r11
	jr	L6EF4
L6ED2:
	ld	r11,@r13
	sub	r11,r12
	ld	r2,r11
	ld	r10,r11
	jr	mi,L6EF4
	jr	eq,L6EF4
	ld	@r13,r12
	push	@r15,r11
	push	@r15,r12
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_write
	inc	r15,#6
	ld	r11,r2
L6EF4:
	ld	%0002(r13),#%01FF
	ld	r2,r12
	inc	r12,#1
	ld	r3,%0004(r14)
	ldb	@r2,rl3
	ld	@r13,r12
L6F06:
	cp	r10,r11
	jr	eq,L6F16
	setb	%0006(r13),#5
	ld	r2,#%FFFF
L6F12:
	jp	cret
L6F16:
	ld	r2,%0004(r14)
	jr	L6F12
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
	jr	ne,L6F6E
	ld	r12,%0004(r13)
	test	r12
	jr	eq,L6F6E
	ld	r11,@r13
	sub	r11,r12
	jr	mi,L6F6E
	jr	eq,L6F6E
	ld	@r13,r12
	ld	%0002(r13),#%0200
	push	@r15,r11
	push	@r15,r12
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_write
	inc	r15,#6
	cp	r2,r11
	jr	eq,L6F6E
	setb	%0006(r13),#5
	ld	r2,#%FFFF
L6F6A:
	jp	cret
L6F6E:
	xor	r2,r2
	jr	L6F6A
end _fflush
G	__cleanu	PR
E
__cleanu:
	call	csv
	ld	r13,#__iob
	jr	L6F86
L6F7C:
	push	@r15,r13
	call	_fclose
	inc	r15,#2
	inc	r13,#8
L6F86:
	cp	r13,__lastbu
	jr	ult,L6F7C
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
	jr	eq,L6FE8
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0040
	jr	ne,L6FE8
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
	jr	pl,L6FD4
	ld	r12,#%FFFF
L6FD4:
	bitb	%0006(r13),#3
	jr	eq,L6FE4
	push	@r15,%0004(r13)
	call	_free
	inc	r15,#2
L6FE4:
	clr	%0004(r13)
L6FE8:
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
	jr	eq,L70EE
	cp	%000A(r14),#%0002
	jr	ge,L70BE
	test	%0004(r13)
	jr	eq,L70BE
	bitb	%0006(r13),#2
	jr	ne,L70BE
	ld	r12,%0002(r13)
	ldl	rr2,%0006(r14)
	ldl	%FFF0(r14),rr2
	test	%000A(r14)
	jr	ne,L7072
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
	jr	L7080
L7072:
	ldl	rr2,%0006(r14)
	ld	r5,r12
	exts	rr4
	subl	rr2,rr4
	ldl	%0006(r14),rr2
L7080:
	bitb	%0006(r13),#7
	jr	ne,L70BE
	test	r12
	jr	mi,L70BE
	jr	eq,L70BE
	ld	r3,r12
	exts	rr2
	cpl	rr2,%FFF0(r14)
	jr	lt,L70BE
	ld	r3,%0004(r13)
	sub	r3,@r13
	exts	rr2
	cpl	rr2,%FFF0(r14)
	jr	gt,L70BE
	ld	r2,@r13
	add	r2,%FFF2(r14)
	ld	@r13,r2
	ld	r2,%0002(r13)
	sub	r2,%FFF2(r14)
	ld	%0002(r13),r2
L70B8:
	xor	r2,r2
L70BA:
	jp	cret
L70BE:
	bitb	%0006(r13),#7
	jr	eq,L70CE
	ld	r2,%0004(r13)
	ld	@r13,r2
	resb	%0006(r13),#0
L70CE:
	push	@r15,%000A(r14)
	pushl	@r15,%0006(r14)
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	%FFF0(r14),rr2
	clr	%0002(r13)
	jr	L7130
L70EE:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0082
	jr	eq,L7130
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	bitb	%0006(r13),#7
	jr	eq,L7116
	clr	%0002(r13)
	resb	%0006(r13),#1
	ld	r2,%0004(r13)
	ld	@r13,r2
L7116:
	push	@r15,%000A(r14)
	pushl	@r15,%0006(r14)
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	%FFF0(r14),rr2
L7130:
	ldl	rr0,#%FFFFFFFF
	cpl	rr0,%FFF0(r14)
	jr	ne,L70B8
	ld	r2,#%FFFF
	jr	L70BA
end _fseek
end flsbuf_
