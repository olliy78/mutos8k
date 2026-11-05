timezone_ module
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
G	_timezon	PR
E
_timezon:
	call	csv
	ld	r13,#_zonetab
	jr	L04E6
L04B6:
	ld	r0,@r13
	cp	r0,%0004(r14)
	jr	ne,L04E4
	test	%0006(r14)
	jr	eq,L04DE
	test	%0004(r13)
	jr	eq,L04DE
	ld	r2,%0004(r13)
	jr	L04DA
L04D0:
	test	%0002(r13)
	jr	eq,L04E4
	ld	r2,%0002(r13)
L04DA:
	jp	cret
L04DE:
	test	%0006(r14)
	jr	eq,L04D0
L04E4:
	inc	r13,#6
L04E6:
	ld	r0,@r13
	cp	r0,#%FFFF
	jr	ne,L04B6
	test	%0004(r14)
	jr	pl,L0504
	ld	r2,%0004(r14)
	neg	r2
	ld	%0004(r14),r2
	ld	r12,#D1509
	jr	L0508
L0504:
	ld	r12,#D150B
L0508:
	ld	r3,%0004(r14)
	exts	rr2
	div	rr2,#%003C
	push	@r15,r2
	ld	r3,%0004(r14)
	exts	rr2
	div	rr2,#%003C
	push	@r15,r3
	push	@r15,r12
	push	@r15,#D150D
	push	@r15,#B1A8C
	call	_sprintf
	inc	r15,#10
	ld	r2,#B1A8C
	jr	L04DA
end _timezon
$SECTION BSS_B
I
B1A8C:
$REL	$+%A
$SDEFAULT
I
D14A4:
G
_zonetab	L
_zonetab:
BV %0;BV %F0
WV D14D4
WV D14D8
BV %1;BV %2C
WV D14DC
WV D14E0
BV %1;BV %68
WV D14E4
WV D14E8
BV %1;BV %A4
WV D14EC
WV D14F0
BV %1;BV %E0
WV D14F4
WV D14F8
BV %0;BV %0
WV D14FC
BV %0;BV %0;BV %FF;BV %C4
WV D1500
WV D1504
BV %FF;BV %FF;BV %0;BV %0;BV %0;BV %0
D14D4:
BV %41;BV %53;BV %54;BV %0
D14D8:
BV %41;BV %44;BV %54;BV %0
D14DC:
BV %45;BV %53;BV %54;BV %0
D14E0:
BV %45;BV %44;BV %54;BV %0
D14E4:
BV %43;BV %53;BV %54;BV %0
D14E8:
BV %43;BV %44;BV %54;BV %0
D14EC:
BV %4D;BV %53;BV %54;BV %0
D14F0:
BV %4D;BV %44;BV %54;BV %0
D14F4:
BV %50;BV %53;BV %54;BV %0
D14F8:
BV %50;BV %44;BV %54;BV %0
D14FC:
BV %47;BV %4D;BV %54;BV %0
D1500:
BV %4D;BV %45;BV %54;BV %0
D1504:
BV %4D;BV %45;BV %53;BV %54;BV %0
D1509:
BV %2B;BV %0
D150B:
BV %2D;BV %0
D150D:
BV %47;BV %4D;BV %54;BV %25;BV %73;BV %25;BV %64;BV %3A
BV %25;BV %30;BV %32;BV %64;BV %0
end timezone_
