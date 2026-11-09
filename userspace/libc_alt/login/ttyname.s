ttyname_ module
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
G	_ttyname	PR
E
_ttyname:
	call	csv
	sub	r15,#%004C
	push	@r15,%0004(r14)
	call	_isatty
	inc	r15,#2
	test	r2
	jr	eq,L15DC
	ld	r2,r14
	add	r2,#%FFD6
	push	@r15,r2
	push	@r15,%0004(r14)
	call	_fstat
	inc	r15,#4
	test	r2
	jr	mi,L15DC
	ld	r2,%FFDA(r14)
	and	r2,#%F000
	cp	r2,#%8+_signal
	jr	ne,L15DC
	push	@r15,#%0000
	push	@r15,#D2360
	call	_open
	inc	r15,#4
	ld	r13,r2
	test	r13
	jr	mi,L15DC
L1550:
	push	@r15,#%0010
	ld	r2,r14
	add	r2,#%FFA8
	push	@r15,r2
	push	@r15,r13
	call	_read
	inc	r15,#6
	cp	r2,#%0010
	jr	ne,L15D4
	test	%FFA8(r14)
	jr	eq,L1550
	ld	r0,%FFA8(r14)
	cp	r0,%FFD8(r14)
	jr	ne,L1550
	push	@r15,#D2360
	push	@r15,#B2D2E
	call	_strcpy
	inc	r15,#4
	ld	r2,r14
	add	r2,#%FFAA
	push	@r15,r2
	push	@r15,#B2D2E
	call	_strcat
	inc	r15,#4
	ld	r2,r14
	add	r2,#%FFB8
	push	@r15,r2
	push	@r15,#B2D2E
	call	_stat
	inc	r15,#4
	test	r2
	jr	mi,L1550
	ld	r0,%FFB8(r14)
	cp	r0,%FFD6(r14)
	jr	ne,L1550
	ld	r0,%FFBA(r14)
	cp	r0,%FFD8(r14)
	jr	ne,L1550
	push	@r15,r13
	call	_close
	inc	r15,#2
	ld	r2,#B2D2E
L15D0:
	jp	cret
L15D4:
	push	@r15,r13
	call	_close
	inc	r15,#2
L15DC:
	xor	r2,r2
	jr	L15D0
end _ttyname
$SECTION BSS_B
I
B2D2E:
$REL	$+%20
$SDEFAULT
I
D2360:
BV %2F;BV %64;BV %65;BV %76;BV %2F;BV %0
end ttyname_
