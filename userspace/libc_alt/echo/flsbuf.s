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
	jr	eq,L0196
	bitb	%0006(r13),#0
	jr	eq,L018E
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
L018E:
	setb	%0006(r13),#1
	resb	%0006(r13),#4
L0196:
	bitb	%0006(r13),#2
	jr	eq,L01C4
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
	jr	L0258
L01C4:
	ld	r12,%0004(r13)
	test	r12
	jr	ne,L0222
	cp	r13,#__iob
	jr	ne,L01FC
	ld	r2,#__sibuf
L01D6:
	ld	%0004(r13),r2
	ld	@r13,r2
	jr	L0196
L01DE:
	ldb	rl0,%F+__iob
	xorb	rh0,rh0
	push	@r15,r0
	call	_isatty
	inc	r15,#2
	test	r2
	jr	eq,L01F6
L01F0:
	setb	%0006(r13),#2
	jr	L0196
L01F6:
	ld	r2,#__sobuf
	jr	L01D6
L01FC:
	cp	r13,#%8+__iob
L0200:
	jr	eq,L01DE
	push	@r15,#L0200
	call	_malloc
	inc	r15,#2
	ld	r12,r2
	ld	r2,r12
	ld	%0004(r13),r2
	test	r2
	jr	eq,L01F0
	setb	%0006(r13),#3
	xor	r11,r11
	ld	r10,r11
	jr	L0246
L0222:
	ld	r11,@r13
	sub	r11,r12
	ld	r2,r11
	ld	r10,r2
	test	r10
	jr	mi,L0246
	jr	eq,L0246
	ld	@r13,r12
	push	@r15,r11
	push	@r15,r12
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_write
	inc	r15,#6
	ld	r11,r2
L0246:
	ld	%0002(r13),#L01FF
	ld	r2,r12
	inc	r12,#1
	ld	r3,%0004(r14)
	ldb	@r2,rl3
	ld	@r13,r12
L0258:
	cp	r10,r11
	jr	eq,L0268
	setb	%0006(r13),#5
	ld	r2,#%FFFF
L0264:
	jp	cret
L0268:
	ld	r2,%0004(r14)
	jr	L0264
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
	jr	ne,L02C0
	ld	r12,%0004(r13)
	test	r12
	jr	eq,L02C0
	ld	r11,@r13
	sub	r11,r12
	jr	mi,L02C0
	jr	eq,L02C0
	ld	@r13,r12
	ld	%0002(r13),#L0200
	push	@r15,r11
	push	@r15,r12
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_write
	inc	r15,#6
	cp	r2,r11
	jr	eq,L02C0
	setb	%0006(r13),#5
	ld	r2,#%FFFF
L02BC:
	jp	cret
L02C0:
	xor	r2,r2
	jr	L02BC
end _fflush
G	__cleanu	PR
E
__cleanu:
	call	csv
	ld	r13,#__iob
	jr	L02D8
L02CE:
	push	@r15,r13
	call	_fclose
	inc	r15,#2
	inc	r13,#8
L02D8:
	cp	r13,__lastbu
	jr	ult,L02CE
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
	jr	eq,L033A
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0040
	jr	ne,L033A
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
	jr	pl,L0326
	ld	r12,#%FFFF
L0326:
	bitb	%0006(r13),#3
	jr	eq,L0336
	push	@r15,%0004(r13)
	call	_free
	inc	r15,#2
L0336:
	clr	%0004(r13)
L033A:
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
	jr	eq,L0440
	ld	r0,%000A(r14)
	cp	r0,#%0002
	jr	ge,L0410
	test	%0004(r13)
	jr	eq,L0410
	bitb	%0006(r13),#2
	jr	ne,L0410
	ld	r12,%0002(r13)
	ldl	rr2,%0006(r14)
	ldl	%FFF0(r14),rr2
	test	r0
	jr	ne,L03C4
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
	jr	L03D2
L03C4:
	ldl	rr2,%0006(r14)
	ld	r5,r12
	exts	rr4
	subl	rr2,rr4
	ldl	%0006(r14),rr2
L03D2:
	bitb	%0006(r13),#7
	jr	ne,L0410
	test	r12
	jr	mi,L0410
	jr	eq,L0410
	ld	r3,r12
	exts	rr2
	cpl	rr2,%FFF0(r14)
	jr	lt,L0410
	ld	r3,%0004(r13)
	sub	r3,@r13
	exts	rr2
	cpl	rr2,%FFF0(r14)
	jr	gt,L0410
	ld	r2,@r13
	add	r2,%FFF2(r14)
	ld	@r13,r2
	ld	r2,%0002(r13)
	sub	r2,%FFF2(r14)
	ld	%0002(r13),r2
L040A:
	xor	r2,r2
L040C:
	jp	cret
L0410:
	bitb	%0006(r13),#7
	jr	eq,L0420
	ld	r2,%0004(r13)
	ld	@r13,r2
	resb	%0006(r13),#0
L0420:
	push	@r15,%000A(r14)
	pushl	@r15,%0006(r14)
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	%FFF0(r14),rr2
	clr	%0002(r13)
	jr	L0482
L0440:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0082
	jr	eq,L0482
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	bitb	%0006(r13),#7
	jr	eq,L0468
	clr	%0002(r13)
	resb	%0006(r13),#1
	ld	r2,%0004(r13)
	ld	@r13,r2
L0468:
	push	@r15,%000A(r14)
	pushl	@r15,%0006(r14)
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	ldl	%FFF0(r14),rr2
L0482:
	ldl	rr0,#%FFFFFFFF
	cpl	rr0,%FFF0(r14)
	jr	ne,L040A
	ld	r2,#%FFFF
	jr	L040C
end _fseek
end flsbuf_
