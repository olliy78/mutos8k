filbuf_ module
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
G	__filbuf	PR
E
__filbuf:
	call	csv
	ld	r13,%0004(r14)
	bitb	%0006(r13),#7
	jr	eq,L1132
	bitb	%0006(r13),#1
	jr	eq,L112E
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L112E:
	setb	%0006(r13),#0
L1132:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L1144
	bitb	%0006(r13),#6
	jr	eq,L115C
L1144:
	ld	r2,#%FFFF
L1148:
	jp	cret
L114C:
	cp	r13,#__iob
	jr	ne,L117E
	ld	r2,#__sibuf
	jr	L1172
L1158:
	setb	%0006(r13),#2
L115C:
	test	%0004(r13)
	jr	ne,L119A
	bitb	%0006(r13),#2
	jr	eq,L114C
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B2B20
L1172:
	ld	%0004(r13),r2
	jr	L115C
L1178:
	ld	r2,#__sobuf
	jr	L1172
L117E:
	cp	r13,#%8+__iob
	jr	eq,L1178
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L1158
	setb	%0006(r13),#3
L119A:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L11AC
	push	@r15,#%0001
	jr	L11B0
L11AC:
	push	@r15,#%0200
L11B0:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L11F2
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L11E8
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L11EC
	resb	%0006(r13),#0
	jr	L11EC
L11E8:
	setb	%0006(r13),#5
L11EC:
	clr	%0002(r13)
	jr	L1144
L11F2:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L1148
end __filbuf
$SECTION BSS_B
I
B2B20:
$REL	$+%14
$SDEFAULT
end filbuf_
