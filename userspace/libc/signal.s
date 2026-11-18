! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels and declaration order from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
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
X	cerror	PR;
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
	ld	r2,dvect(r3)
	ld	dvect(r3),r1
	rr	r1,#1
	rl	r1,#1
	jr	ule,$1
	lda	r1,tvect(r3)
$1:
	sc	#%30
	jp	ult,cerror
	bit	r4,#0
	jr	eq,$2
	ld	r2,r4
$2:
	pop	r14,@r15
	ret
tvect:
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
	calr	asyncex
asyncex:
	sub	r15,#%001E
	ldm	@r15,r0,#15
	ld	r7,%001E(r15)
	sub	r7,#tvect+%2
	ld	r2,dvect(r7)
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
dvect:
$REL	$+%28
$SDEFAULT
end signal_
