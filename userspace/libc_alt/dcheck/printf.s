printf_ module
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
G	_printf	PR
E
_printf:
	call	csv
	push	@r15,#%8+__iob
	ld	r2,r14
	inc	r2,#6
	push	@r15,r2
	push	@r15,%0004(r14)
	call	__doprnt
	inc	r15,#6
	ldb	rl2,%E+__iob
	xorb	rh2,rh2
	and	r2,#%0020
	jr	eq,L052E
	ld	r2,#%FFFF
L052A:
	jp	cret
L052E:
	xor	r2,r2
	jr	L052A
end _printf
end printf_
