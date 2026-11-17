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
	jr	eq,L36A2
	bitb	%0006(r13),#1
	jr	eq,L369E
	push	@r15,r13
	call	_fflush
	inc	r15,#2
	resb	%0006(r13),#1
L369E:
	setb	%0006(r13),#0
L36A2:
	ldb	rl2,%0006(r13)
	xorb	rh2,rh2
	and	r2,#%0001
	jr	eq,L36B4
	bitb	%0006(r13),#6
	jr	eq,L36CC
L36B4:
	ld	r2,#%FFFF
L36B8:
	jp	cret
L36BC:
	cp	r13,#__iob
	jr	ne,L36EE
	ld	r2,#%513A
	jr	L36E2
L36C8:
	setb	%0006(r13),#2
L36CC:
	test	%0004(r13)
	jr	ne,L370A
	bitb	%0006(r13),#2
	jr	eq,L36BC
	ldb	rl2,%0007(r13)
	xorb	rh2,rh2
	add	r2,#B56CE
L36E2:
	ld	%0004(r13),r2
	jr	L36CC
L36E8:
	ld	r2,#%6E+__sibuf
	jr	L36E2
L36EE:
	cp	r13,#%8+__iob
	jr	eq,L36E8
	push	@r15,#%0200
	call	_malloc
	inc	r15,#2
	ld	%0004(r13),r2
	test	r2
	jr	eq,L36C8
	setb	%0006(r13),#3
L370A:
	ld	r2,%0004(r13)
	ld	@r13,r2
	bitb	%0006(r13),#2
	jr	eq,L371C
	push	@r15,#%0001
	jr	L3720
L371C:
	push	@r15,#%0200
L3720:
	push	@r15,@r13
	ldb	rl0,%0007(r13)
	xorb	rh0,rh0
	push	@r15,r0
	call	_read
	inc	r15,#6
	ld	%0002(r13),r2
	dec	%0002(r13),#1
	test	%0002(r13)
	jr	pl,L3762
	ld	r0,%0002(r13)
	cp	r0,#%FFFF
	jr	ne,L3758
	setb	%0006(r13),#4
	bitb	%0006(r13),#7
	jr	eq,L375C
	resb	%0006(r13),#0
	jr	L375C
L3758:
	setb	%0006(r13),#5
L375C:
	clr	%0002(r13)
	jr	L36B4
L3762:
	ld	r2,@r13
	inc	@r13,#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	and	r3,#%00FF
	ld	r2,r3
	jr	L36B8
end __filbuf
$SECTION BSS_B
I
B56CE:
$REL	$+%14
$SDEFAULT
end filbuf_
