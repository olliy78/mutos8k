rew_ module
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
G	_rewind	PR
E
_rewind:
	call	csv
	ld	r13,%0004(r14)
	push	@r15,r13
	call	_fflush
	ld	@r15,#%0000
	xor	r3,r3
	exts	rr2
	pushl	@r15,rr2
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_lseek
	inc	r15,#8
	clr	%0002(r13)
	ld	r2,%0004(r13)
	ld	@r13,r2
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%FFCF
	ldb	%0006(r13),rl2
	bitb	%0006(r13),#7
	jr	eq,L0926
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%FFFC
	ldb	%0006(r13),rl2
L0926:
	jp	cret
end _rewind
end rew_
