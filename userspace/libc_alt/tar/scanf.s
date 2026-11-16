scanf_ module
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
G	_scanf	PR
E
_scanf:
	call	csv
	ld	r2,r14
	inc	r2,#6
	push	@r15,r2
	push	@r15,%0004(r14)
	push	@r15,#__iob
	call	__doscan
	inc	r15,#6
	jp	cret
end _scanf
G	_fscanf	PR
E
_fscanf:
	call	csv
	ld	r2,r14
	inc	r2,#8
	push	@r15,r2
	push	@r15,%0006(r14)
	push	@r15,%0004(r14)
	call	__doscan
	inc	r15,#6
	jp	cret
end _fscanf
G	_sscanf	PR
E
_sscanf:
	call	csv
	ld	r13,%0004(r14)
	dec	r15,#8
	ldb	%FFF2(r14),#%41
	ld	r2,r13
	ld	%FFF0(r14),r13
	ld	%FFEC(r14),r13
	clr	%FFEE(r14)
	jr	L1AA0
L1A9C:
	inc	%FFEE(r14),#1
L1AA0:
	ld	r2,r13
	inc	r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	testb	rl3
	jr	ne,L1A9C
	ld	r2,r14
	inc	r2,#8
	push	@r15,r2
	push	@r15,%0006(r14)
	ld	r2,r14
	add	r2,#%FFEC
	push	@r15,r2
	call	__doscan
	inc	r15,#6
	jp	cret
end _sscanf
end scanf_
