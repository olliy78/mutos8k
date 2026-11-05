sprintf_ module
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
G	_sprintf	PR
E
_sprintf:
	call	csv
	dec	r15,#8
	ldb	%FFF2(r14),#%42
	ld	r2,%0004(r14)
	ld	%FFEC(r14),r2
	ld	%FFEE(r14),#%7FFF
	ld	r2,r14
	add	r2,#%FFEC
	push	@r15,r2
	ld	r2,r14
	inc	r2,#8
	push	@r15,r2
	push	@r15,%0006(r14)
	call	__doprnt
	inc	r15,#6
	bitb	%FFF2(r14),#0
	jr	ne,L05B0
	dec	%FFEE(r14),#1
	jr	mi,L05B0
	ld	r2,%FFEC(r14)
	inc	%FFEC(r14),#1
	clrb	@r2
	jr	L05C8
L05B0:
	push	@r15,r2
	ld	r2,r14
	add	r2,#%FFEC
	push	@r15,r2
	push	@r15,#%0000
	call	__flsbuf
	inc	r15,#4
	ld	r3,r2
	pop	r2,@r15
L05C8:
	ld	r2,%0004(r14)
	jp	cret
end _sprintf
end sprintf_
