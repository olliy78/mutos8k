system_ module
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
G	_system	PR
E
_system:
	call	csv
	dec	r15,#2
	call	_fork
	ld	r11,r2
	test	r11
	jr	ne,L19C2
	push	@r15,#%0000
	push	@r15,%0004(r14)
	push	@r15,#D3FA7
	push	@r15,#D3FA4
	push	@r15,#D3F9C
	call	_execl
	inc	r15,#8
	ld	@r15,#%007F
	call	__exit
	inc	r15,#2
L19C2:
	push	@r15,#%0001
	push	@r15,#%0002
	call	_signal
	inc	r15,#4
	ld	r13,r2
	push	@r15,#%0001
	push	@r15,#%0003
	call	_signal
	inc	r15,#4
	ld	r12,r2
L19E2:
	ld	r2,r14
	dec	r2,#14
	push	@r15,r2
	call	_wait
	inc	r15,#2
	ld	r10,r2
	cp	r10,r11
	jr	eq,L19FA
	cp	r10,#%FFFF
	jr	ne,L19E2
L19FA:
	cp	r10,#%FFFF
	jr	ne,L1A08
	ld	r2,#%FFFF
	ld	%FFF2(r14),r2
L1A08:
	push	@r15,r13
	push	@r15,#%0002
	call	_signal
	inc	r15,#2
	ld	@r15,r12
	push	@r15,#%0003
	call	_signal
	inc	r15,#4
	ld	r2,%FFF2(r14)
	jp	cret
end _system
I
D3F9C:
BV %2F;BV %62;BV %69;BV %6E;BV %2F;BV %73;BV %68;BV %0
D3FA4:
BV %73;BV %68;BV %0
D3FA7:
BV %2D;BV %63;BV %0
end system_
