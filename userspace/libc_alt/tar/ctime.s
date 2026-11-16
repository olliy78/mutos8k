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
	subl	rr2,rr6
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
	cp	%000A(r12),#%004A
	jr	eq,L2EFA
	cp	%000A(r12),#%004B
	jr	ne,L2F16
L2EFA:
	ld	r2,%000A(r12)
	sla	r2,#2
	add	r2,#%A2+__sctab
	ld	r11,@r2
	ld	r2,%000A(r12)
	sla	r2,#2
	add	r2,#%A4+__sctab
	ld	r10,@r2
L2F16:
	push	@r15,r11
	push	@r15,r12
	call	L2F7C
	inc	r15,#4
	ld	r11,r2
	push	@r15,r10
	push	@r15,r12
	call	L2F7C
	inc	r15,#4
	ld	r10,r2
	test	%FFEE(r14)
	jr	eq,L2F76
	cp	r13,r11
	jr	gt,L2F44
	cp	r13,r11
	jr	ne,L2F76
	cp	%0004(r12),#%0002
	jr	lt,L2F76
L2F44:
	cp	r13,r10
	jr	lt,L2F54
	cp	r13,r10
	jr	ne,L2F76
	cp	%0004(r12),#%0001
	jr	ge,L2F76
L2F54:
	ldl	rr2,%FFF0(r14)
	ld	r5,#%0E10
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
L2F76:
	ld	r2,r12
	jp	cret
L2F7C:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	cp	r12,#%003A
	jr	lt,L2FA6
	push	@r15,r12
	push	@r15,%000A(r13)
	call	_dysize
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
	add	r3,#%FE93
	add	r2,r3
	ld	r12,r2
L2FA6:
	ld	r2,r12
	ld	r5,r12
	sub	r5,%000E(r13)
	add	r5,%000C(r13)
	add	r5,#%02BC
	exts	rr4
	div	rr4,#%0007
	ld	r3,r4
	sub	r2,r4
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
	ldl	%FFF0(r14),rr4
	ld	r2,%0004(r14)
	ldl	rr6,@r2
	extsl	rq4
	divl	rq4,#%00015180
	ldl	rr2,rr6
	ldl	%FFEC(r14),rr6
	testl	%FFF0(r14)
	jr	pl,L3012
	ldl	rr2,%FFF0(r14)
	addl	rr2,#%00015180
	ldl	%FFF0(r14),rr2
	ldl	rr2,rr6
	subl	rr2,#%00000001
	ldl	%FFEC(r14),rr2
L3012:
	ld	r11,#B58D6
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
	ld	r3,r5
	ld	@r2,r5
	ldl	rr2,%FFF0(r14)
	ld	r5,#%003C
	exts	rr4
	extsl	rq0
	divl	rq0,rr4
	ld	r12,r3
	ld	r2,r11
	inc	r11,#2
	ld	r5,r12
	exts	rr4
	div	rr4,#%003C
	ld	@r2,r4
	ld	r3,r12
	exts	rr2
	div	rr2,#%003C
	ld	r12,r3
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
	ld	B58E2,r3
	testl	%FFEC(r14)
	jr	mi,L30C6
	ld	r12,#%0046
L308A:
	push	@r15,r2
	push	@r15,r12
	call	_dysize
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
	exts	rr2
	cpl	rr2,%FFEC(r14)
	jr	gt,L30FA
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
	jr	L308A
L30C6:
	ld	r12,#%0046
	jr	L30F4
L30CC:
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
L30F4:
	testl	%FFEC(r14)
	jr	mi,L30CC
L30FA:
	ld	B58E0,r12
	ld	r13,%FFEE(r14)
	ld	B58E4,r13
	push	@r15,r12
	call	_dysize
	inc	r15,#2
	cp	r2,#%016E
	jr	ne,L311A
	ld	D415E,#%001D
L311A:
	xor	r12,r12
	jr	L312C
L311E:
	ld	r2,r12
	sla	r2,#1
	add	r2,#D415C
	sub	r13,@r2
	inc	r12,#1
L312C:
	ld	r2,r12
	sla	r2,#1
	add	r2,#D415C
	ld	r0,@r2
	cp	r0,r13
	jr	le,L311E
	ld	D415E,#%001C
	ld	r2,r11
	inc	r11,#2
	ld	r3,r13
	inc	r3,#1
	ld	@r2,r3
	ld	r2,r11
	inc	r11,#2
	ld	@r2,r12
	clr	B58E6
	ld	r2,#B58D6
	jp	cret
end _gmtime
G	_asctime	PR
E
_asctime:
	call	csv
	ld	r13,#B58BC
	ld	r12,#D417C
L316A:
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	testb	rl4
	jr	ne,L316A
	ld	r2,%0004(r14)
	inc	r2,#12
	ld	r5,@r2
	mult	rr4,#%0003
	ld	r12,r5
	add	r12,#D4196
	ld	r13,#B58BC
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	inc	r13,#1
	ld	r11,%0004(r14)
	inc	r11,#8
	ld	r3,@r11
	mult	rr2,#%0003
	ld	r12,r3
	add	r12,#D41AC
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	dec	r11,#2
	push	@r15,@r11
	push	@r15,r13
	call	L32A4
	inc	r15,#4
	ld	r13,r2
	dec	r11,#2
	ld	r2,r11
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L32A4
	inc	r15,#4
	ld	r13,r2
	dec	r11,#2
	ld	r2,r11
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L32A4
	inc	r15,#4
	ld	r13,r2
	dec	r11,#2
	ld	r2,r11
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L32A4
	inc	r15,#4
	ld	r13,r2
	ld	r2,%0004(r14)
	inc	r2,#10
	cp	@r2,#%0064
	jr	lt,L3262
	ldb	%0001(r13),#%32
	ldb	%0002(r13),#%30
L3262:
	inc	r13,#2
	ld	r2,%0004(r14)
	inc	r2,#10
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L32A4
	inc	r15,#4
	ld	r13,r2
	ld	r2,#B58BC
	jp	cret
end _asctime
G	_dysize	PR
E
_dysize:
	call	csv
	ld	r3,%0004(r14)
	exts	rr2
	div	rr2,#%0004
	test	r2
	jr	ne,L329E
	ld	r2,#%016E
L329A:
	jp	cret
L329E:
	ld	r2,#%016D
	jr	L329A
L32A4:
	call	csv
	ld	r13,%0004(r14)
	inc	r13,#1
	cp	%0006(r14),#%000A
	jr	lt,L32D4
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
	jr	L32DC
L32D4:
	ld	r2,r13
	inc	r13,#1
	ldb	@r2,#%20
L32DC:
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
B58BC:
$REL	$+%1A
B58D6:
$REL	$+%A
B58E0:
$REL	$+%2
B58E2:
$REL	$+%2
B58E4:
$REL	$+%2
B58E6:
$REL	$+%2
$SDEFAULT
I
D415C:
BV %0;BV %1F
D415E:
BV %0;BV %1C;BV %0;BV %1F;BV %0;BV %1E;BV %0;BV %1F
BV %0;BV %1E;BV %0;BV %1F;BV %0;BV %1F;BV %0;BV %1E
BV %0;BV %1F;BV %0;BV %1E;BV %0;BV %1F;BV %0;BV %5
BV %1;BV %4D;BV %0;BV %3A;BV %1;BV %2F
D417C:
BV %44;BV %61;BV %79;BV %20;BV %4D;BV %6F;BV %6E;BV %20
BV %30;BV %30;BV %20;BV %30;BV %30;BV %3A;BV %30;BV %30
BV %3A;BV %30;BV %30;BV %20;BV %31;BV %39;BV %30;BV %30
BV %A;BV %0
D4196:
BV %53;BV %75;BV %6E;BV %4D;BV %6F;BV %6E;BV %54;BV %75
BV %65;BV %57;BV %65;BV %64;BV %54;BV %68;BV %75;BV %46
BV %72;BV %69;BV %53;BV %61;BV %74;BV %0
D41AC:
BV %4A;BV %61;BV %6E;BV %46;BV %65;BV %62;BV %4D;BV %61
BV %72;BV %41;BV %70;BV %72;BV %4D;BV %61;BV %79;BV %4A
BV %75;BV %6E;BV %4A;BV %75;BV %6C;BV %41;BV %75;BV %67
BV %53;BV %65;BV %70;BV %4F;BV %63;BV %74;BV %4E;BV %6F
BV %76;BV %44;BV %65;BV %63;BV %0;BV %0
end ctime_
