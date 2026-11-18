! RECONSTRUCTED (W8): instruction text from the program image variant in userspace/libc_alt, labels, declaration order and data placement from the shipped libc.a member, not V7 text (the V7 sources are PDP-11 assembler) !
doprnt_ module
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
X	csv	PR;
X	cret	PR;
X	pfloat	PR;
X	pscien	PR;
X	pgen	PR;
X	__strout	PR;
G	__doprnt	PR
E
__doprnt:
	call	csv
	sub	r15,#%0086
	ld	r12,%0004(r14)
	ld	r13,%0006(r14)
loop:
	ld	r10,r15
$1:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,$2
	cpb	rl0,#%25
	jr	eq,$2
	ldb	@r10,rl0
	inc	r10,#1
	jr	$1
$2:
	cp	r10,r15
	jr	eq,$3
	ld	r8,r0
	ld	r1,r15
	push	@r15,%0008(r14)
	push	@r15,#%0000
	sub	r10,r1
	push	@r15,r10
	push	@r15,r1
	call	__strout
	inc	r15,#8
	ld	r0,r8
$3:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,$4
	inc	r12,#1
	ld	%FFF0(r14),#%0001
$4:
	cpb	@r12,#%30
	jr	ne,$5
	ld	%FFEE(r14),#%0030
$5:
	calr	gnum
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,$6
	calr	gnum
	ld	r11,r1
$6:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#swtab
$7:
	pop	r4,@r7
	test	r4
	jr	ne,$8
	ldb	@r10,rl2
	inc	r10,#1
	jr	prbuf
$8:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,$7
	jp	@r4
$DATA
I
swtab:
WV decimal
BV %0;BV %64
WV octal
BV %0;BV %6F
WV hex
BV %0;BV %78
WV float
BV %0;BV %66
WV scien
BV %0;BV %65
WV general
BV %0;BV %67
WV charac
BV %0;BV %63
WV string
BV %0;BV %73
WV longorun
BV %0;BV %6C
WV longorun
BV %0;BV %4C
WV unsigned
BV %0;BV %75
WV remote
BV %0;BV %72
WV lang
BV %0;BV %44
WV loct
BV %0;BV %4F
WV lhex
BV %0;BV %58
WV lunsigne
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
$CODE
longorun:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,loct
	cpb	rl1,#%78
	jr	eq,lhex
	cpb	rl1,#%64
	jr	eq,lang
	cpb	rl1,#%75
	jr	eq,lunsigne
	dec	r12,#1
	jr	unsigned
loct:
	pop	r6,@r13
	jr	octal
lhex:
	pop	r6,@r13
hex:
	rl	r3,#1
octal:
	pop	r7,@r13
	jr	compute
decimal:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,$13
	jr	$15
lang:
	pop	r6,@r13
	test	r6
	jr	pl,unsigned
	pop	r7,@r13
$13:
	neg	r6
	neg	r7
	jr	uge,$14
	dec	r6,#1
$14:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	$15
lunsigne:
	pop	r6,@r13
unsigned:
	pop	r7,@r13
$15:
	inc	r3,#2
compute:
	testl	rr6
	jr	eq,$16
	test	r11
	jr	eq,$16
	ldb	@r10,#%30
	inc	r10,#1
$16:
	xor	r2,r2
	calr	$17
	jr	prbuf
$17:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,$19
	calr	$17
$19:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,$18
	add	r0,#%0007
$18:
	ldb	@r10,rl0
	inc	r10,#1
	ret
float:
	call	pfloat
	jr	prbuf
general:
	call	pgen
	jr	prbuf
scien:
	inc	r11,#1
	test	r9
	jr	ne,$10
	ldk	r11,#7
	ld	r9,r11
$10:
	call	pscien
	jr	prbuf
remote:
	ld	r13,@r13
	pop	r12,@r13
	jp	loop
charac:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,prbuf
	ldb	@r10,rl0
	inc	r10,#1
	jr	prbuf
string:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,$11
	ld	r2,#nullstri
$11:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,prstr
	dec	r10,#1
	jr	prstr
prbuf:
	ld	r2,r15
$DATA
I
nullstri:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
$CODE
end __doprnt
I	prstr	PR
E
prstr:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,$1
	xor	r1,r1
$1:
	test	%FFF0(r14)
	jr	ne,$2
	neg	r1
$2:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	loop
end prstr
I	gnum	PR
E
gnum:
	xor	r9,r9
	ld	r1,r9
$1:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,$2
	pop	r2,@r13
	jr	$4
$2:
	cp	r2,#%0009
	jr	ugt,$4
$3:
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	$1
$4:
	add	r2,#%0030
	ret
end gnum
end doprnt_
