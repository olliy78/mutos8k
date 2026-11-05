fprintf_ module
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
G	_fprintf	PR
E
_fprintf:
	call	csv
	push	@r15,%0004(r14)
	ld	r2,r14
	inc	r2,#8
	push	@r15,r2
	push	@r15,%0006(r14)
	call	__doprnt
	inc	r15,#6
	ld	r2,%0004(r14)
	inc	r2,#6
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%0020
	jr	eq,L0892
	ld	r2,#%FFFF
L088E:
	jp	cret
L0892:
	xor	r2,r2
	jr	L088E
end _fprintf
end fprintf_
