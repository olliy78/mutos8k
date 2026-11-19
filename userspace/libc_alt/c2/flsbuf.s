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
	jr	eq,L3AB6
	bitb	%0006(r13),#0
	jr	eq,L3AAE
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
L3AAE:
	setb	%0006(r13),#1
	resb	%0006(r13),#4
L3AB6:
	bitb	%0006(r13),#2
	jr	eq,L3AE4
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
	jr	L3B76
L3AE4:
	ld	r12,%0004(r13)
	test	r12
	jr	ne,L3B42
	cp	r13,#__iob
	jr	ne,L3B1C
	ld	r2,#__sibuf
L3AF6:
	ld	%0004(r13),r2
	ld	@r13,r2
	jr	L3AB6
L3AFE:
	ldb	rl0,%F+__iob
	xorb	rh0,rh0
	push	@r15,r0
	call	_isatty
	inc	r15,#2
	test	r2
	jr	eq,L3B16
L3B10:
	setb	%0006(r13),#2
	jr	L3AB6
L3B16:
	ld	r2,#__sobuf
	jr	L3AF6
L3B1C:
	cp	r13,#%8+__iob
	jr	eq,L3AFE
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	ld	r2,r12
	ld	%0004(r13),r12
	test	r12
	jr	eq,L3B10
	setb	%0006(r13),#3
	xor	r11,r11
	ld	r10,r11
	jr	L3B64
L3B42:
	ld	r11,@r13
	sub	r11,r12
	ld	r2,r11
	ld	r10,r11
	jr	mi,L3B64
	jr	eq,L3B64
	ld	@r13,r12
	push	@r15,r11
	push	@r15,r12
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_write
	inc	r15,#6
	ld	r11,r2
L3B64:
	ld	%0002(r13),#%01FF
	ld	r2,r12
	inc	r12,#1
	ld	r3,%0004(r14)
	ldb	@r2,rl3
	ld	@r13,r12
L3B76:
	cp	r10,r11
	jr	eq,L3B86
	setb	%0006(r13),#5
	ld	r2,#%FFFF
L3B82:
	jp	cret
L3B86:
	ld	r2,%0004(r14)
	jr	L3B82
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
	jr	ne,L3BDE
	ld	r12,%0004(r13)
	test	r12
	jr	eq,L3BDE
	ld	r11,@r13
	sub	r11,r12
	jr	mi,L3BDE
	jr	eq,L3BDE
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
	jr	eq,L3BDE
	setb	%0006(r13),#5
	ld	r2,#%FFFF
L3BDA:
	jp	cret
L3BDE:
	xor	r2,r2
	jr	L3BDA
end _fflush
G	__cleanu	PR
E
__cleanu:
	call	csv
	ld	r13,#__iob
	jr	L3BF6
L3BEC:
	push	@r15,r13
	call	_fclose
	inc	r15,#2
	inc	r13,#8
L3BF6:
	cp	r13,__lastbu
	jr	ult,L3BEC
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
	jr	eq,L3C58
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0040
	jr	ne,L3C58
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
	jr	pl,L3C44
	ld	r12,#%FFFF
L3C44:
	bitb	%0006(r13),#3
	jr	eq,L3C54
	push	@r15,%0004(r13)
	call	_free
	inc	r15,#2
L3C54:
	clr	%0004(r13)
L3C58:
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
	jr	eq,L3D5E
	cp	%000A(r14),#%0002
	jr	ge,L3D2E
	test	%0004(r13)
	jr	eq,L3D2E
	bitb	%0006(r13),#2
	jr	ne,L3D2E
	ld	r12,%0002(r13)
	ldl	rr2,%0006(r14)
	ldl	%FFF0(r14),rr2
	test	%000A(r14)
	jr	ne,L3CE2
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
	jr	L3CF0
L3CE2:
	ldl	rr2,%0006(r14)
	ld	r5,r12
	exts	rr4
	subl	rr2,rr4
	ldl	%0006(r14),rr2
L3CF0:
	bitb	%0006(r13),#7
	jr	ne,L3D2E
	test	r12
	jr	mi,L3D2E
	jr	eq,L3D2E
	ld	r3,r12
	exts	rr2
	cpl	rr2,%FFF0(r14)
	jr	lt,L3D2E
	ld	r3,%0004(r13)
	sub	r3,@r13
	exts	rr2
	cpl	rr2,%FFF0(r14)
	jr	gt,L3D2E
	ld	r2,@r13
	add	r2,%FFF2(r14)
	ld	@r13,r2
	ld	r2,%0002(r13)
	sub	r2,%FFF2(r14)
	ld	%0002(r13),r2
L3D28:
	xor	r2,r2
L3D2A:
	jp	cret
L3D2E:
	bitb	%0006(r13),#7
	jr	eq,L3D3E
	ld	r2,%0004(r13)
	ld	@r13,r2
	resb	%0006(r13),#0
L3D3E:
	push	@r15,%000A(r14)
	pushl	@r15,%0006(r14)
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	%FFF0(r14),rr2
	clr	%0002(r13)
	jr	L3DA0
L3D5E:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0082
	jr	eq,L3DA0
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	bitb	%0006(r13),#7
	jr	eq,L3D86
	clr	%0002(r13)
	resb	%0006(r13),#1
	ld	r2,%0004(r13)
	ld	@r13,r2
L3D86:
	push	@r15,%000A(r14)
	pushl	@r15,%0006(r14)
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	%FFF0(r14),rr2
L3DA0:
	ldl	rr0,#%FFFFFFFF
	cpl	rr0,%FFF0(r14)
	jr	ne,L3D28
	ld	r2,#%FFFF
	jr	L3D2A
end _fseek
end flsbuf_
