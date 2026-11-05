perror_ module
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
G	_perror	PR
E
_perror:
	call	csv
	ld	r13,#D0D54
	ld	r0,_errno
	cp	r0,_sys_ner
	jr	ge,L082C
	ld	r2,_errno
	sla	r2,#1
	add	r2,#_sys_err
	ld	r13,@r2
L082C:
	push	@r15,%0004(r14)
	call	_strlen
	inc	r15,#2
	ld	r12,r2
	test	r12
	jr	eq,L085E
	push	@r15,r12
	push	@r15,%0004(r14)
	push	@r15,#%0002
	call	_write
	inc	r15,#6
	push	@r15,#%0002
	push	@r15,#D0D62
	push	@r15,#%0002
	call	_write
	inc	r15,#6
L085E:
	push	@r15,r13
	call	_strlen
	ld	@r15,r2
	push	@r15,r13
	push	@r15,#%0002
	call	_write
	inc	r15,#6
	push	@r15,#%0001
	push	@r15,#D0D65
	push	@r15,#%0002
	call	_write
	inc	r15,#6
	jp	cret
end _perror
I
D0D54:
BV %55;BV %6E;BV %6B;BV %6E;BV %6F;BV %77;BV %6E;BV %20
BV %65;BV %72;BV %72;BV %6F;BV %72;BV %0
D0D62:
BV %3A;BV %20;BV %0
D0D65:
BV %A;BV %0;BV %0
end perror_
