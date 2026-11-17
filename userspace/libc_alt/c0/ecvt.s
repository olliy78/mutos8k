ecvt_ module
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
G	_ecvt	PR
E
_ecvt:
	call	csv
	push	@r15,#%0001
	push	@r15,%0010(r14)
	push	@r15,%000E(r14)
	push	@r15,%000C(r14)
	WV %4FE4;WV %8003;WV %0004
	dec	r15,#8
	WV %0FFC;WV %8003
	call	L50BC
	inc	r15,#16
	jp	cret
end _ecvt
G	_fcvt	PR
E
_fcvt:
	call	csv
	push	@r15,#%0000
	push	@r15,%0010(r14)
	push	@r15,%000E(r14)
	push	@r15,%000C(r14)
	WV %4FE4;WV %8003;WV %0004
	dec	r15,#8
	WV %0FFC;WV %8003
	call	L50BC
	inc	r15,#16
	jp	cret
L50BC:
	call	csv
	dec	r15,#16
	test	%000C(r14)
	jr	pl,L50CC
	clr	%000C(r14)
L50CC:
	cp	%000C(r14),#%004F
	jr	lt,L50DA
	ld	%000C(r14),#%004E
L50DA:
	xor	r13,r13
	ld	r2,%0010(r14)
	clr	@r2
	ld	r12,#B9786
	WV %4FE4;WV %8003;WV %0004
	WV %8E00;WV %0020
	jr	ge,L5106
	ld	r2,%0010(r14)
	ld	@r2,#%0001
	WV %4FE4;WV %8093;WV %0004
	WV %4FEC;WV %8003;WV %0004
L5106:
	ld	r2,r14
	add	r2,#%FFEC
	push	@r15,r2
	WV %4FE4;WV %8003;WV %0004
	dec	r15,#8
	WV %0FFC;WV %8003
	call	_modf
	inc	r15,#10
	WV %4FEC;WV %8003;WV %0004
	ld	r11,#B97D6
	WV %4FE4;WV %8003;WV %FFEC
	WV %8E00;WV %0020
	jr	eq,L51B2
	jr	L5190
L5138:
	ld	r2,r14
	add	r2,#%FFEC
	push	@r15,r2
	WV %4FE4;WV %8003;WV %FFEC
	WV %4F04;WV %40A3;WV D67FE
	dec	r15,#8
	WV %0FFC;WV %8003
	call	_modf
	inc	r15,#10
	WV %4FEC;WV %8003;WV %FFE4
	dec	r11,#1
	ld	r2,r11
	WV %4FE4;WV %8203;WV %FFE4
	WV %4F04;WV %4283;WV D6806
	WV %4F04;WV %42B3;WV D67FE
	WV %8F50;WV %C001
	WV %8E04;WV %C642
	WV %8F20;WV %8421
	WV %8F58;WV %C001
	ld	r4,r5
	ld	r3,r5
	add	r3,#%0030
	ldb	@r2,rl3
	inc	r13,#1
L5190:
	WV %4FE4;WV %8003;WV %FFEC
	WV %8E00;WV %0020
	jr	ne,L5138
L519C:
	cp	r11,#B97D6
	jr	uge,L51EC
	ld	r2,r12
	inc	r12,#1
	ld	r3,r11
	inc	r11,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	jr	L519C
L51B2:
	WV %4FE4;WV %8003;WV %0004
	WV %8E00;WV %0020
	jr	le,L51EC
	jr	L51CE
L51C0:
	WV %4FE4;WV %8003;WV %FFE4
	WV %4FEC;WV %8003;WV %0004
	dec	r13,#1
L51CE:
	WV %4FE4;WV %8003;WV %0004
	WV %4F04;WV %40B3;WV D67FE
	WV %4FEC;WV %8003;WV %FFE4
	WV %4F04;WV %8103;WV D680E
	WV %8E00;WV %4120
	jr	lt,L51C0
L51EC:
	ld	r11,%000C(r14)
	add	r11,#B9786
	test	%0012(r14)
	jr	ne,L51FC
	add	r11,r13
L51FC:
	ld	r2,%000E(r14)
	ld	@r2,r13
	cp	r11,#B9786
	jr	uge,L5214
	clrb	B9786
L520C:
	ld	r2,#B9786
	jp	cret
L5214:
	cp	r12,r11
	jr	ugt,L5276
	cp	r12,#B97D6
	jr	uge,L5276
	WV %4FE4;WV %8003;WV %0004
	WV %4F04;WV %40B3;WV D67FE
	WV %4FEC;WV %8003;WV %0004
	ld	r2,r14
	add	r2,#%FFE4
	push	@r15,r2
	WV %4FE4;WV %8003;WV %0004
	dec	r15,#8
	WV %0FFC;WV %8003
	call	_modf
	inc	r15,#10
	WV %4FEC;WV %8003;WV %0004
	ld	r2,r12
	inc	r12,#1
	WV %4FE4;WV %8203;WV %FFE4
	WV %8F50;WV %C001
	WV %8E04;WV %C642
	WV %8F20;WV %8421
	WV %8F58;WV %C001
	ld	r4,r5
	ld	r3,r5
	add	r3,#%0030
	ldb	@r2,rl3
	jr	L5214
L5276:
	cp	r11,#B97D6
	jr	ult,L5282
	clrb	B97D5
	jr	L520C
L5282:
	ld	r12,r11
	ldb	rl2,@r11
	xorb	rh2,rh2
	inc	r2,#5
	ldb	@r11,rl2
	jr	L52BC
L528E:
	dec	r11,#1
	ld	r2,r11
	incb	@r2,#1
	jr	L52BC
L5296:
	ldb	@r11,#%30
	cp	r11,#B9786
	jr	ugt,L528E
	ldb	@r11,#%31
	ld	r2,%000E(r14)
	inc	@r2,#1
	test	%0012(r14)
	jr	ne,L52BC
	cp	r12,#B9786
	jr	ule,L52BA
	ldb	@r12,#%30
L52BA:
	inc	r12,#1
L52BC:
	ldb	rl2,@r11
	xorb	rh2,rh2
	cp	r2,#%0039
	jr	ugt,L5296
	clrb	@r12
	jr	L520C
end _fcvt
$SECTION BSS_B
I
B9786:
$REL	$+%4F
B97D5:
$REL	$+%1
B97D6:
$SDEFAULT
I
D67FE:
BV %40;BV %24;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
D6806:
BV %3F;BV %9E;BV %B8;BV %51;BV %EB;BV %85;BV %1E;BV %B8
D680E:
BV %3F;BV %F0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
end ecvt_
