ctime_ module
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
G	_ctime	PR
E
_ctime:
	call	csv
	push	@r15,%0004(r14)
	call	_localti
	ld	@r15,r2
	call	_asctime
	inc	r15,#2
	jp	cret
end _ctime
G	_localti	PR
E
_localti:
	call	csv
	dec	r15,#14
	ld	r2,r14
	add	r2,#%FFE6
	push	@r15,r2
	call	_ftime
	inc	r15,#2
	ld	r2,%0004(r14)
	ldl	rr4,@r2
	ldl	%FFF0(r14),rr4
	ldl	rr2,%FFF0(r14)
	ld	r5,#%003C
	exts	rr4
	pushl	@r15,rr4
	ld	r5,%FFEC(r14)
	exts	rr4
	ldl	rr6,rr4
	multl	rq4,@r15
	inc	r15,#4
	ldl	rr4,rr6
	subl	rr2,rr4
	ldl	%FFF0(r14),rr2
	ld	r2,r14
	dec	r2,#16
	push	@r15,r2
	call	_gmtime
	inc	r15,#2
	ld	r12,r2
	ld	r13,%000E(r12)
	ld	r11,#%0077
	ld	r10,#%012F
	ld	r0,%000A(r12)
	cp	r0,#%004A
	jr	eq,L0CA4
	ld	r0,%000A(r12)
	cp	r0,#%004B
	jr	ne,L0CC0
L0CA4:
	ld	r2,%000A(r12)
	sla	r2,#2
	add	r2,#%52+_zonetab
	ld	r11,@r2
	ld	r2,%000A(r12)
	sla	r2,#2
	add	r2,#%54+_zonetab
	ld	r10,@r2
L0CC0:
	push	@r15,r11
	push	@r15,r12
	call	L0D2A
	inc	r15,#4
	ld	r11,r2
	push	@r15,r10
	push	@r15,r12
	call	L0D2A
	inc	r15,#4
	ld	r10,r2
	test	%FFEE(r14)
	jr	eq,L0D24
	cp	r13,r11
	jr	gt,L0CF0
	cp	r13,r11
	jr	ne,L0D24
	ld	r0,%0004(r12)
	cp	r0,#%0002
	jr	lt,L0D24
L0CF0:
	cp	r13,r10
	jr	lt,L0D02
	cp	r13,r10
	jr	ne,L0D24
	ld	r0,%0004(r12)
	cp	r0,#%0001
	jr	ge,L0D24
L0D02:
	ldl	rr2,%FFF0(r14)
	ld	r5,#L0E10
	exts	rr4
	addl	rr2,rr4
	ldl	%FFF0(r14),rr2
	ld	r2,r14
	dec	r2,#16
	push	@r15,r2
	call	_gmtime
	inc	r15,#2
	ld	r12,r2
	inc	%0010(r12),#1
L0D24:
	ld	r2,r12
	jp	cret
L0D2A:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	cp	r12,#%003A
	jr	lt,L0D56
	ld	r2,r12
	push	@r15,r2
	push	@r15,%000A(r13)
	call	_dysize
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
	add	r3,#%FE93
	add	r2,r3
	ld	r12,r2
L0D56:
	ld	r2,r12
	ld	r5,r12
	sub	r5,%000E(r13)
	add	r5,%000C(r13)
	add	r5,#%02BC
	exts	rr4
	div	rr4,#%0007
	ld	r3,r4
	sub	r2,r3
	jp	cret
end _localti
G	_gmtime	PR
E
_gmtime:
	call	csv
	dec	r15,#8
	ld	r2,%0004(r14)
	ldl	rr6,@r2
	extsl	rq4
	divl	rq4,#%00015180
	ldl	rr2,rr4
	ldl	%FFF0(r14),rr2
	ld	r2,%0004(r14)
	ldl	rr6,@r2
	extsl	rq4
	divl	rq4,#%00015180
	ldl	rr2,rr6
	ldl	%FFEC(r14),rr2
	testl	%FFF0(r14)
	jr	pl,L0DC4
	ldl	rr2,%FFF0(r14)
	addl	rr2,#%00015180
	ldl	%FFF0(r14),rr2
	ldl	rr2,%FFEC(r14)
	subl	rr2,#%00000001
	ldl	%FFEC(r14),rr2
L0DC4:
	ld	r11,#B1AB0
	ld	r2,r11
	inc	r11,#2
	ld	r5,#%003C
	exts	rr4
	pushl	@r15,rr4
	ldl	rr6,%FFF0(r14)
	extsl	rq4
	divl	rq4,@r15
	inc	r15,#4
	ld	r4,r5
	ld	r3,r4
	ld	@r2,r3
	ldl	rr2,%FFF0(r14)
	ld	r5,#%003C
	exts	rr4
	extsl	rq0
	divl	rq0,rr4
	ld	r2,r3
	ld	r12,r2
	ld	r2,r11
	inc	r11,#2
	ld	r5,r12
	exts	rr4
	div	rr4,#%003C
	ld	r3,r4
	ld	@r2,r3
	ld	r3,r12
	exts	rr2
	div	rr2,#%003C
	ld	r12,r3
L0E10:
	ld	r2,r11
	inc	r11,#2
	ld	@r2,r12
	ldk	r3,#7
	exts	rr2
	pushl	@r15,rr2
	ldl	rr2,%FFEC(r14)
	addl	rr2,#%00700004
	ldl	rr6,rr2
	extsl	rq4
	divl	rq4,@r15
	inc	r15,#4
	ldl	rr2,rr4
	ld	r2,r3
	ld	B1ABC,r2
	testl	%FFEC(r14)
	jr	mi,L0E7C
	ld	r12,#%0046
L0E40:
	push	@r15,r2
	push	@r15,r12
	call	_dysize
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
	exts	rr2
	cpl	rr2,%FFEC(r14)
	jr	gt,L0EB0
	ldl	rr2,%FFEC(r14)
	push	@r15,r2
	push	@r15,r3
	push	@r15,r4
	push	@r15,r12
	call	_dysize
	inc	r15,#2
	ld	r5,r2
	pop	r4,@r15
	pop	r3,@r15
	pop	r2,@r15
	exts	rr4
	subl	rr2,rr4
	ldl	%FFEC(r14),rr2
	inc	r12,#1
	jr	L0E40
L0E7C:
	ld	r12,#%0046
	jr	L0EAA
L0E82:
	ldl	rr2,%FFEC(r14)
	push	@r15,r2
	push	@r15,r3
	push	@r15,r4
	ld	r2,r12
	dec	r2,#1
	push	@r15,r2
	call	_dysize
	inc	r15,#2
	ld	r5,r2
	pop	r4,@r15
	pop	r3,@r15
	pop	r2,@r15
	exts	rr4
	addl	rr2,rr4
	ldl	%FFEC(r14),rr2
	dec	r12,#1
L0EAA:
	testl	%FFEC(r14)
	jr	mi,L0E82
L0EB0:
	ld	B1ABA,r12
	ld	r13,%FFEE(r14)
	ld	B1ABE,r13
	push	@r15,r12
	call	_dysize
	inc	r15,#2
	cp	r2,#%016E
	jr	ne,L0ED0
	ld	D1608,#%001D
L0ED0:
	xor	r12,r12
	jr	L0EE2
L0ED4:
	ld	r2,r12
	sla	r2,#1
	add	r2,#D1606
	sub	r13,@r2
	inc	r12,#1
L0EE2:
	ld	r2,r12
	sla	r2,#1
	add	r2,#D1606
	ld	r0,@r2
	cp	r0,r13
	jr	le,L0ED4
	ld	D1608,#%001C
	ld	r2,r11
	inc	r11,#2
	ld	r3,r13
	inc	r3,#1
	ld	@r2,r3
	ld	r2,r11
	inc	r11,#2
	ld	@r2,r12
	clr	B1AC0
	ld	r2,#B1AB0
	jp	cret
end _gmtime
G	_asctime	PR
E
_asctime:
	call	csv
	ld	r13,#B1A96
	ld	r12,#D1626
L0F20:
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	testb	rl4
	jr	ne,L0F20
	ld	r2,%0004(r14)
	inc	r2,#12
	ld	r5,@r2
	mult	rr4,#%0003
	ld	r2,r5
	ld	r12,r2
	add	r12,#D1640
	ld	r13,#B1A96
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	inc	r13,#1
	ld	r11,%0004(r14)
	inc	r11,#8
	ld	r3,@r11
	mult	rr2,#%0003
	ld	r2,r3
	ld	r12,r2
	add	r12,#D1656
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	ldb	@r2,rl4
	dec	r11,#2
	push	@r15,@r11
	push	@r15,r13
	call	L1050
	inc	r15,#4
	ld	r13,r2
	dec	r11,#2
	ld	r2,r11
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L1050
	inc	r15,#4
	ld	r13,r2
	dec	r11,#2
	ld	r2,r11
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L1050
	inc	r15,#4
	ld	r13,r2
	dec	r11,#2
	ld	r2,r11
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L1050
	inc	r15,#4
	ld	r13,r2
	ld	r2,%0004(r14)
	inc	r2,#10
	ld	r0,@r2
	cp	r0,#%0064
	jr	lt,L1012
	ldb	%0001(r13),#%32
	ldb	%0002(r13),#%30
L1012:
	inc	r13,#2
	ld	r2,%0004(r14)
	inc	r2,#10
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L1050
	inc	r15,#4
	ld	r13,r2
	ld	r2,#B1A96
	jp	cret
end _asctime
G	_dysize	PR
E
_dysize:
	call	csv
	ld	r2,%0004(r14)
	and	r2,#%0003
	jr	ne,L104A
	ld	r2,#%016E
L1046:
	jp	cret
L104A:
	ld	r2,#%016D
	jr	L1046
L1050:
	call	csv
	ld	r13,%0004(r14)
	inc	r13,#1
	ld	r0,%0006(r14)
	cp	r0,#%000A
	jr	lt,L1082
	ld	r2,r13
	inc	r13,#1
	ld	r5,%0006(r14)
	exts	rr4
	div	rr4,#%000A
	exts	rr4
	div	rr4,#%000A
	ld	r3,r4
	add	r3,#%0030
	ldb	@r2,rl3
	jr	L108A
L1082:
	ld	r2,r13
	inc	r13,#1
	ldb	@r2,#%20
L108A:
	ld	r2,r13
	inc	r13,#1
	ld	r5,%0006(r14)
	exts	rr4
	div	rr4,#%000A
	ld	r3,r4
	add	r3,#%0030
	ldb	@r2,rl3
	ld	r2,r13
	jp	cret
end _dysize
$SECTION BSS_B
I
B1A96:
$REL	$+%1A
B1AB0:
$REL	$+%A
B1ABA:
$REL	$+%2
B1ABC:
$REL	$+%2
B1ABE:
$REL	$+%2
B1AC0:
$REL	$+%2
$SDEFAULT
I
D1606:
BV %0;BV %1F
D1608:
BV %0;BV %1C;BV %0;BV %1F;BV %0;BV %1E;BV %0;BV %1F
BV %0;BV %1E;BV %0;BV %1F;BV %0;BV %1F;BV %0;BV %1E
BV %0;BV %1F;BV %0;BV %1E;BV %0;BV %1F;BV %0;BV %5
BV %1;BV %4D;BV %0;BV %3A;BV %1;BV %2F
D1626:
BV %44;BV %61;BV %79;BV %20;BV %4D;BV %6F;BV %6E;BV %20
BV %30;BV %30;BV %20;BV %30;BV %30;BV %3A;BV %30;BV %30
BV %3A;BV %30;BV %30;BV %20;BV %31;BV %39;BV %30;BV %30
BV %A;BV %0
D1640:
BV %53;BV %75;BV %6E;BV %4D;BV %6F;BV %6E;BV %54;BV %75
BV %65;BV %57;BV %65;BV %64;BV %54;BV %68;BV %75;BV %46
BV %72;BV %69;BV %53;BV %61;BV %74;BV %0
D1656:
BV %4A;BV %61;BV %6E;BV %46;BV %65;BV %62;BV %4D;BV %61
BV %72;BV %41;BV %70;BV %72;BV %4D;BV %61;BV %79;BV %4A
BV %75;BV %6E;BV %4A;BV %75;BV %6C;BV %41;BV %75;BV %67
BV %53;BV %65;BV %70;BV %4F;BV %63;BV %74;BV %4E;BV %6F
BV %76;BV %44;BV %65;BV %63;BV %0;BV %0
end ctime_
