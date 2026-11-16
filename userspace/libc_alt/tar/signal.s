signal_ module
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
G	_signal	PR
E
_signal:
	push	@r15,r14
	ld	r14,r15
	ldm	r0,%0004(r14),#2
	ld	r4,#%0016
	cp	r0,#%0014
	jp	ge,cerror
	ld	r3,r0
	sla	r3,#1
	ld	r2,B58F6(r3)
	ld	B58F6(r3),r1
	rr	r1,#1
	rl	r1,#1
	jr	ule,L38C6
	lda	r1,L38D6(r3)
L38C6:
	sc	#%30
	jp	ult,cerror
	bit	r4,#0
	jr	eq,L38D2
	ld	r2,r4
L38D2:
	pop	r14,@r15
	ret
L38D6:
	calr	L38FE
L38D8:
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
	calr	L38FE
L38FE:
	sub	r15,#%001E
	ldm	@r15,r0,#15
	ld	r7,%001E(r15)
	sub	r7,#L38D8
	ld	r2,B58F6(r7)
	srl	r7,#1
	push	@r15,r7
	call	@r2
	inc	r15,#2
	ldm	r0,@r15,#15
	add	r15,#%0020
	sc	#%00
end _signal
$SECTION BSS_B
I
B58F6:
$REL	$+%28
$SDEFAULT
end signal_
