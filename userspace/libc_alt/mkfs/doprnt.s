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
L1212:
	ld	r10,r15
L1214:
	ldb	rl0,@r12
	inc	r12,#1
	testb	rl0
	jr	eq,L1228
	cpb	rl0,#%25
	jr	eq,L1228
	ldb	@r10,rl0
	inc	r10,#1
	jr	L1214
L1228:
	cp	r10,r15
	jr	eq,L1246
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
L1246:
	testb	rl0
	jp	eq,cret
	ld	r10,r15
	clr	%FFF0(r14)
	xor	r11,r11
	ld	%FFEE(r14),#%0020
	cpb	@r12,#%2D
	jr	ne,L1268
	inc	r12,#1
	ld	%FFF0(r14),#%0001
L1268:
	cpb	@r12,#%30
	jr	ne,L1274
	ld	%FFEE(r14),#%0030
L1274:
	calr	L13AE
	ld	%FFF2(r14),r1
	xor	r9,r9
	cp	r2,#%002E
	jr	ne,L1286
	calr	L13AE
	ld	r11,r1
L1286:
	xor	r6,r6
	ldk	r3,#8
	ld	r7,#D1FD8
L128E:
	pop	r4,@r7
	test	r4
	jr	ne,L129A
	ldb	@r10,rl2
	inc	r10,#1
	jr	L1380
L129A:
	pop	r5,@r7
	cp	r2,r5
	jr	ne,L128E
	jp	@r4
L12A2:
	ldb	rl1,@r12
	inc	r12,#1
	cpb	rl1,#%6F
	jr	eq,L12C2
	cpb	rl1,#%78
	jr	eq,L12C6
	cpb	rl1,#%64
	jr	eq,L12D8
	cpb	rl1,#%75
	jr	eq,L12F0
	dec	r12,#1
	jr	L12F2
L12C2:
	pop	r6,@r13
	jr	L12CA
L12C6:
	pop	r6,@r13
L12C8:
	rl	r3,#1
L12CA:
	pop	r7,@r13
	jr	L12F6
L12CE:
	pop	r7,@r13
	exts	rr6
	test	r6
	jr	mi,L12E0
	jr	L12F4
L12D8:
	pop	r6,@r13
	test	r6
	jr	pl,L12F2
	pop	r7,@r13
L12E0:
	neg	r6
	neg	r7
	jr	uge,L12E8
	dec	r6,#1
L12E8:
	ldb	@r10,#%2D
	inc	r10,#1
	jr	L12F4
L12F0:
	pop	r6,@r13
L12F2:
	pop	r7,@r13
L12F4:
	inc	r3,#2
L12F6:
	testl	rr6
	jr	eq,L1304
	test	r11
	jr	eq,L1304
	ldb	@r10,#%30
	inc	r10,#1
L1304:
	xor	r2,r2
	calr	L130A
	jr	L1380
L130A:
	ld	r4,r2
	ld	r5,r4
	divl	rq4,rr2
	push	@r15,r5
	jr	eq,L1316
	calr	L130A
L1316:
	pop	r0,@r15
	add	r0,#%0030
	cp	r0,#%0039
	jr	le,L1326
	add	r0,#%0007
L1326:
	ldb	@r10,rl0
	inc	r10,#1
	ret
L132C:
	call	pscien
	jr	L1380
L1332:
	call	pscien
	jr	L1380
L1338:
	inc	r11,#1
	test	r9
	jr	ne,L1342
	ldk	r11,#7
	ld	r9,r11
L1342:
	call	pscien
	jr	L1380
L1348:
	ld	r13,@r13
	pop	r12,@r13
	jp	L1212
L1350:
	ld	%FFEE(r14),#%0020
	pop	r0,@r13
	testb	rl0
	jr	eq,L1380
	ldb	@r10,rl0
	inc	r10,#1
	jr	L1380
L1362:
	ld	%FFEE(r14),#%0020
	pop	r2,@r13
	test	r2
	jr	ne,L1372
	ld	r2,#D201C
L1372:
	ld	r10,r2
	xorb	rl0,rl0
	cpirb	rl0,@r10,r11,eq
	jr	ne,L1382
	dec	r10,#1
	jr	L1382
L1380:
	ld	r2,r15
L1382:
	sub	r10,r2
	ld	r1,%FFF2(r14)
	sub	r1,r10
	jr	ge,L138E
	xor	r1,r1
L138E:
	test	%FFF0(r14)
	jr	ne,L1396
	neg	r1
L1396:
	push	@r15,%FFEE(r14)
	push	@r15,%0008(r14)
	push	@r15,r1
	push	@r15,r10
	push	@r15,r2
	call	__strout
	inc	r15,#10
	jp	L1212
L13AE:
	xor	r9,r9
	ld	r1,r9
L13B2:
	xorb	rh2,rh2
	ldb	rl2,@r12
	inc	r12,#1
	sub	r2,#%0030
	cp	r2,#%FFFA
	jr	ne,L13C6
	pop	r2,@r13
	jr	L13D6
L13C6:
	cp	r2,#%0009
	jr	ugt,L13D6
	inc	r9,#1
	mult	rr0,#%000A
	add	r1,r2
	jr	L13B2
L13D6:
	add	r2,#%0030
	ret
end __doprnt
I
D1FD8:
WV L12CE
BV %0;BV %64
WV L12CA
BV %0;BV %6F
WV L12C8
BV %0;BV %78
WV L132C
BV %0;BV %66
WV L1338
BV %0;BV %65
WV L1332
BV %0;BV %67
WV L1350
BV %0;BV %63
WV L1362
BV %0;BV %73
WV L12A2
BV %0;BV %6C
WV L12A2
BV %0;BV %4C
WV L12F2
BV %0;BV %75
WV L1348
BV %0;BV %72
WV L12D8
BV %0;BV %44
WV L12C2
BV %0;BV %4F
WV L12C6
BV %0;BV %58
WV L12F0
BV %0;BV %55;BV %0;BV %0;BV %0;BV %0
D201C:
BV %6E;BV %75;BV %6C;BV %6C;BV %0;BV %0
end doprnt_
