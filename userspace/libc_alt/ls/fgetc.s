fgetc_ module
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
G	_fgetc	PR
E
_fgetc:
	call	csv
	ld	r2,%0004(r14)
	inc	r2,#6
	bitb	@r2,#1
	jr	ne,L08BE
	ld	r2,%0004(r14)
	inc	r2,#2
	dec	@r2,#1
	jr	lt,L08BE
	ld	r2,%0004(r14)
	ld	r3,@r2
	inc	@r2,#1
	ld	r2,r3
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	jr	L08CE
L08BE:
	push	@r15,r2
	push	@r15,%0004(r14)
	call	__filbuf
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
L08CE:
	ld	r2,r3
	jp	cret
end _fgetc
end fgetc_
