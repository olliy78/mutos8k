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
	jr	eq,L0FB4
	ld	r0,%000A(r12)
	cp	r0,#%004B
	jr	ne,L0FD0
L0FB4:
	ld	r2,%000A(r12)
	sla	r2,#2
	add	r2,#%186E
	ld	r11,@r2
	ld	r2,%000A(r12)
	sla	r2,#2
	add	r2,#%1870
	ld	r10,@r2
L0FD0:
	push	@r15,r11
	push	@r15,r12
	call	L103A
	inc	r15,#4
	ld	r11,r2
	push	@r15,r10
	push	@r15,r12
	call	L103A
	inc	r15,#4
	ld	r10,r2
	test	%FFEE(r14)
	jr	eq,L1034
	cp	r13,r11
	jr	gt,L1000
	cp	r13,r11
	jr	ne,L1034
	ld	r0,%0004(r12)
	cp	r0,#%0002
	jr	lt,L1034
L1000:
	cp	r13,r10
	jr	lt,L1012
	cp	r13,r10
	jr	ne,L1034
	ld	r0,%0004(r12)
	cp	r0,#%0001
	jr	ge,L1034
L1012:
	ldl	rr2,%FFF0(r14)
	ld	r5,#%30+_ttyname
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
L1034:
	ld	r2,r12
	jp	cret
L103A:
	call	csv
	ld	r13,%0004(r14)
	ld	r12,%0006(r14)
	cp	r12,#%003A
	jr	lt,L1066
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
L1066:
	ld	r2,r12
	ld	r5,r12
	sub	r5,%000E(r13)
	add	r5,%000C(r13)
	add	r5,#%A6+_getpwen
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
	jr	pl,L10D4
	ldl	rr2,%FFF0(r14)
	addl	rr2,#%00015180
	ldl	%FFF0(r14),rr2
	ldl	rr2,%FFEC(r14)
	subl	rr2,#%00000001
	ldl	%FFEC(r14),rr2
L10D4:
	ld	r11,#B2070
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
	ld	B207C,r2
	testl	%FFEC(r14)
	jr	mi,L118C
	ld	r12,#%0046
L1150:
	push	@r15,r2
	push	@r15,r12
	call	_dysize
	inc	r15,#2
	ld	r3,r2
	pop	r2,@r15
	exts	rr2
	cpl	rr2,%FFEC(r14)
	jr	gt,L11C0
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
	jr	L1150
L118C:
	ld	r12,#%0046
	jr	L11BA
L1192:
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
L11BA:
	testl	%FFEC(r14)
	jr	mi,L1192
L11C0:
	ld	B207A,r12
	ld	r13,%FFEE(r14)
	ld	B207E,r13
	push	@r15,r12
	call	_dysize
	inc	r15,#2
	cp	r2,#%016E
	jr	ne,L11E0
	ld	D1980,#%001D
L11E0:
	xor	r12,r12
	jr	L11F2
L11E4:
	ld	r2,r12
	sla	r2,#1
	add	r2,#D197E
	sub	r13,@r2
	inc	r12,#1
L11F2:
	ld	r2,r12
	sla	r2,#1
	add	r2,#D197E
	ld	r0,@r2
	cp	r0,r13
	jr	le,L11E4
	ld	D1980,#%001C
	ld	r2,r11
	inc	r11,#2
	ld	r3,r13
	inc	r3,#1
	ld	@r2,r3
	ld	r2,r11
	inc	r11,#2
	ld	@r2,r12
	clr	B2080
	ld	r2,#B2070
	jp	cret
end _gmtime
G	_asctime	PR
E
_asctime:
	call	csv
	ld	r13,#B2056
	ld	r12,#D199E
L1230:
	ld	r2,r13
	inc	r13,#1
	ld	r3,r12
	inc	r12,#1
	ldb	rl4,@r3
	xorb	rh4,rh4
	ldb	@r2,rl4
	testb	rl4
	jr	ne,L1230
	ld	r2,%0004(r14)
	inc	r2,#12
	ld	r5,@r2
	mult	rr4,#%0003
	ld	r2,r5
	ld	r12,r2
	add	r12,#D19B8
	ld	r13,#B2056
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
	add	r12,#D19CE
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
	call	L1360
	inc	r15,#4
	ld	r13,r2
	dec	r11,#2
	ld	r2,r11
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L1360
	inc	r15,#4
	ld	r13,r2
	dec	r11,#2
	ld	r2,r11
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L1360
	inc	r15,#4
	ld	r13,r2
	dec	r11,#2
	ld	r2,r11
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L1360
	inc	r15,#4
	ld	r13,r2
	ld	r2,%0004(r14)
	inc	r2,#10
	ld	r0,@r2
	cp	r0,#%0064
	jr	lt,L1322
	ldb	%0001(r13),#%32
	ldb	%0002(r13),#%30
L1322:
	inc	r13,#2
	ld	r2,%0004(r14)
	inc	r2,#10
	ld	r3,@r2
	add	r3,#%0064
	push	@r15,r3
	push	@r15,r13
	call	L1360
	inc	r15,#4
	ld	r13,r2
	ld	r2,#B2056
	jp	cret
end _asctime
G	_dysize	PR
E
_dysize:
	call	csv
	ld	r2,%0004(r14)
	and	r2,#%0003
	jr	ne,L135A
	ld	r2,#%016E
L1356:
	jp	cret
L135A:
	ld	r2,#%016D
	jr	L1356
L1360:
	call	csv
	ld	r13,%0004(r14)
	inc	r13,#1
	ld	r0,%0006(r14)
	cp	r0,#%000A
	jr	lt,L1392
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
	jr	L139A
L1392:
	ld	r2,r13
	inc	r13,#1
	ldb	@r2,#%20
L139A:
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
B2056:
$REL	$+%1A
B2070:
$REL	$+%A
B207A:
$REL	$+%2
B207C:
$REL	$+%2
B207E:
$REL	$+%2
B2080:
$REL	$+%2
$SDEFAULT
I
D197E:
BV %0;BV %1F
D1980:
BV %0;BV %1C;BV %0;BV %1F;BV %0;BV %1E;BV %0;BV %1F
BV %0;BV %1E;BV %0;BV %1F;BV %0;BV %1F;BV %0;BV %1E
BV %0;BV %1F;BV %0;BV %1E;BV %0;BV %1F;BV %0;BV %5
BV %1;BV %4D;BV %0;BV %3A;BV %1;BV %2F
D199E:
BV %44;BV %61;BV %79;BV %20;BV %4D;BV %6F;BV %6E;BV %20
BV %30;BV %30;BV %20;BV %30;BV %30;BV %3A;BV %30;BV %30
BV %3A;BV %30;BV %30;BV %20;BV %31;BV %39;BV %30;BV %30
BV %A;BV %0
D19B8:
BV %53;BV %75;BV %6E;BV %4D;BV %6F;BV %6E;BV %54;BV %75
BV %65;BV %57;BV %65;BV %64;BV %54;BV %68;BV %75;BV %46
BV %72;BV %69;BV %53;BV %61;BV %74;BV %0
D19CE:
BV %4A;BV %61;BV %6E;BV %46;BV %65;BV %62;BV %4D;BV %61
BV %72;BV %41;BV %70;BV %72;BV %4D;BV %61;BV %79;BV %4A
BV %75;BV %6E;BV %4A;BV %75;BV %6C;BV %41;BV %75;BV %67
BV %53;BV %65;BV %70;BV %4F;BV %63;BV %74;BV %4E;BV %6F
BV %76;BV %44;BV %65;BV %63;BV %0;BV %0
end ctime_
