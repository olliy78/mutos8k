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
G	__doprnt	PR
E
__doprnt:
	call	csv
	sub	r15,#%0086
	ld	r12,%0004(r14)
	ld	r13,%0006(r14)
L013A:
	ld	r10,r15
L013C:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L0150
	cpb	rl0,#%25
	jr	eq,L0150
	ldb	@r10,rl0
	inc	r10,#1
	jr	L013C
L0150:
	cp	r10,r15
	jr	eq,L016E
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
L016E:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L0190
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L0190:
	cpb	@r12,#%30
	jr	ne,L019C
	ld	%FFEE(r14),#%0030
L019C:
	calr	L02D4
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L01AE
	calr	L02D4
	ld	r11,r1
L01AE:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D0B4C
L01B6:
	pop	r4,@r7
	test	r4
	jr	ne,L01C2
	ldb	@r10,rl2
	inc	r10,#1
	jr	L02A6
L01C2:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L01B6
	jp	@r4
L01CA:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L01EA
	cpb	rl1,#%78
	jr	eq,L01EE
	cpb	rl1,#%64
	jr	eq,L0200
	cpb	rl1,#%75
	jr	eq,L0218
	dec	r12,#1
	jr	L021A
L01EA:
	pop	r6,@r13
	jr	L01F2
L01EE:
	pop	r6,@r13
L01F0:
	rl	r3,#1
L01F2:
	pop	r7,@r13
	jr	L021E
L01F6:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L0208
	jr	L021C
L0200:
	pop	r6,@r13
	test	r6
	jr	pl,L021A
	pop	r7,@r13
L0208:
	neg	r6
	neg	r7
	jr	uge,L0210
	dec	r6,#1
L0210:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L021C
L0218:
	pop	r6,@r13
L021A:
	pop	r7,@r13
L021C:
	inc	r3,#2
L021E:
	testl	rr6
	jr	eq,L022C
	test	r11
	jr	eq,L022C
	ldb	@r10,#%30
	inc	r10,#1
L022C:
	xor	r2,r2
	calr	L0232
	jr	L02A6
L0232:
	extsl	rq4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L023C
	calr	L0232
L023C:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L024C
	add	r0,#%0007
L024C:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L0252:
	call	pscien
	jr	L02A6
L0258:
	call	pscien
	jr	L02A6
L025E:
	inc	r11,#1
	test	r9
	jr	ne,L0268
	ldk	r11,#7
	ld	r9,r11
L0268:
	call	pscien
	jr	L02A6
L026E:
	ld	r13,@r13
	pop	r12,@r13
	jp	L013A
L0276:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L02A6
	ldb	@r10,rl0
	inc	r10,#1
	jr	L02A6
L0288:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L0298
	ld	r2,#D0B90
L0298:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L02A8
	dec	r10,#1
	jr	L02A8
L02A6:
	ld	r2,r15
L02A8:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L02B4
	xor	r1,r1
L02B4:
	test	%FFF0(r14)
	jr	ne,L02BC
	neg	r1
L02BC:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L013A
L02D4:
	xor	r9,r9
	ld	r1,r9
L02D8:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L02EC
	pop	r2,@r13
	jr	L02FC
L02EC:
	cp	r2,#%0009
	jr	ugt,L02FC
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L02D8
L02FC:
	add	r2,#%0030
	ret
end __doprnt
I
D0B4C:
WV L01F6
BV %0;BV %64
WV L01F2
BV %0;BV %6F
WV L01F0
BV %0;BV %78
WV L0252
BV %0;BV %66
WV L025E
BV %0;BV %65
WV L0258
BV %0;BV %67
WV L0276
BV %0;BV %63
WV L0288
BV %0;BV %73
WV L01CA
BV %0;BV %6C
WV L01CA
BV %0;BV %4C
WV L021A
BV %0;BV %75
WV L026E
BV %0;BV %72
WV L0200
BV %0;BV %44
WV L01EA
BV %0;BV %4F
WV L01EE
BV %0;BV %58
WV L0218
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D0B90:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
