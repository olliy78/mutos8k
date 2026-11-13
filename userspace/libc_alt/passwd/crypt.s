crypt_ module
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
G	_setkey	PR
E
_setkey:
	call	csv
	xor	r13,r13
	jr	L1420
L13FA:
	ldb	rl2,D20DA(r13)
	xorb	rh2,rh2
	add	r2,%0004(r14)
	dec	r2,#1
	ldb	rl3,@r2
	ldb	B2C3A(r13),rl3
	ldb	rl2,D20F6(r13)
	xorb	rh2,rh2
	add	r2,%0004(r14)
	dec	r2,#1
	ldb	rl3,@r2
	ldb	B2C56(r13),rl3
	inc	r13,#1
L1420:
	cp	r13,#%001C
	jr	lt,L13FA
	xor	r13,r13
	jr	L14C4
L142A:
	xor	r11,r11
	jr	L1474
L142E:
	ldb	rl2,B2C3A
	xorb	rh2,rh2
	ld	r10,r2
	xor	r12,r12
	jr	L1444
L143A:
	ldb	rl2,B2C3B(r12)
	ldb	B2C3A(r12),rl2
	inc	r12,#1
L1444:
	cp	r12,#%001B
	jr	lt,L143A
	ld	r2,r10
	ldb	B2C55,rl2
	ldb	rl2,B2C56
	xorb	rh2,rh2
	ld	r10,r2
	xor	r12,r12
	jr	L1466
L145C:
	ldb	rl2,B2C57(r12)
	ldb	B2C56(r12),rl2
	inc	r12,#1
L1466:
	cp	r12,#%001B
	jr	lt,L145C
	ld	r2,r10
	ldb	B2C71,rl2
	inc	r11,#1
L1474:
	ldb	rl2,D2112(r13)
	xorb	rh2,rh2
	cp	r2,r11
	jr	gt,L142E
	xor	r12,r12
	jr	L14BC
L1482:
	ld	r3,r13
	mult	rr2,#%0030
	ld	r2,r3
	add	r2,r12
	add	r2,#B2C72
	ldb	rl3,D2122(r12)
	xorb	rh3,rh3
	add	r3,#B2C3A-%1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r3,r13
	mult	rr2,#%0030
	ld	r2,r3
	add	r2,r12
	add	r2,#B2C8A
	ldb	rl3,D213A(r12)
	xorb	rh3,rh3
	add	r3,#B2C3A-%1
	ldb	rl4,@r3
	ldb	@r2,rl4
	inc	r12,#1
L14BC:
	cp	r12,#%0018
	jr	lt,L1482
	inc	r13,#1
L14C4:
	cp	r13,#%0010
	jr	lt,L142A
	jp	cret
end _setkey
G	_encrypt	PR
E
_encrypt:
	call	csv
	xor	r12,r12
	jr	L14EA
L14D6:
	ldb	rl2,D205A(r12)
	xorb	rh2,rh2
	add	r2,%0004(r14)
	dec	r2,#1
	ldb	rl3,@r2
	ldb	B2FA2(r12),rl3
	inc	r12,#1
L14EA:
	cp	r12,#%0040
	jr	lt,L14D6
	xor	r9,r9
	jp	L1630
L14F6:
	test	%0006(r14)
	jr	eq,L1502
	ldk	r10,#15
	sub	r10,r9
	jr	L1504
L1502:
	ld	r10,r9
L1504:
	xor	r12,r12
	jr	L1512
L1508:
	ldb	rl2,B2FC2(r12)
	ldb	B2FE2(r12),rl2
	inc	r12,#1
L1512:
	cp	r12,#%0020
	jr	lt,L1508
	xor	r12,r12
	jr	L1546
L151C:
	ld	r3,r10
	mult	rr2,#%0030
	ld	r2,r3
	add	r2,r12
	add	r2,#B2C72
	ldb	rl3,B2F72(r12)
	xorb	rh3,rh3
	add	r3,#B2FC1
	ldb	rl4,@r2
	xorb	rh4,rh4
	ldb	rl5,@r3
	xorb	rh5,rh5
	xor	r4,r5
	ld	r2,r4
	ldb	B3022(r12),rl2
	inc	r12,#1
L1546:
	cp	r12,#%0030
	jr	lt,L151C
	xor	r12,r12
	jr	L15EC
L1550:
	ld	r3,r12
	mult	rr2,#%0006
	ld	r2,r3
	ld	r13,r2
	ld	r2,r12
	sla	r2,#6
	ldb	rl3,B3022(r13)
	xorb	rh3,rh3
	sla	r3,#5
	add	r2,r3
	ldb	rl3,B3023(r13)
	xorb	rh3,rh3
	sla	r3,#3
	add	r2,r3
	ldb	rl3,B3024(r13)
	xorb	rh3,rh3
	sla	r3,#2
	add	r2,r3
	ldb	rl3,B3025(r13)
	xorb	rh3,rh3
	sla	r3,#1
	add	r2,r3
	ldb	rl3,B3026(r13)
	xorb	rh3,rh3
	add	r2,r3
	ldb	rl3,B3027(r13)
	xorb	rh3,rh3
	sla	r3,#4
	add	r2,r3
	add	r2,#D2182
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	ld	r2,r12
	sla	r2,#2
	ld	r13,r2
	ld	r2,r11
	sra	r2,#3
	and	r2,#%0001
	ldb	B3002(r13),rl2
	ld	r2,r11
	sra	r2,#2
	and	r2,#%0001
	ldb	B3003(r13),rl2
	ld	r2,r11
	sra	r2,#1
	and	r2,#%0001
	ldb	B3004(r13),rl2
	ld	r2,r11
	and	r2,#%0001
	ldb	B3005(r13),rl2
	inc	r12,#1
L15EC:
	cp	r12,#%0008
	jr	lt,L1550
	xor	r12,r12
	jr	L1614
L15F6:
	ldb	rl2,D2382(r12)
	xorb	rh2,rh2
	add	r2,#B3001
	ldb	rl3,B2FA2(r12)
	xorb	rh3,rh3
	ldb	rl4,@r2
	xorb	rh4,rh4
	xor	r3,r4
	ld	r2,r3
	ldb	B2FC2(r12),rl2
	inc	r12,#1
L1614:
	cp	r12,#%0020
	jr	lt,L15F6
	xor	r12,r12
	jr	L1628
L161E:
	ldb	rl2,B2FE2(r12)
	ldb	B2FA2(r12),rl2
	inc	r12,#1
L1628:
	cp	r12,#%0020
	jr	lt,L161E
	inc	r9,#1
L1630:
	cp	r9,#%0010
	jp	lt,L14F6
	xor	r12,r12
	jr	L1654
L163C:
	ldb	rl2,B2FA2(r12)
	xorb	rh2,rh2
	ld	r13,r2
	ldb	rl2,B2FC2(r12)
	ldb	B2FA2(r12),rl2
	ld	r2,r13
	ldb	B2FC2(r12),rl2
	inc	r12,#1
L1654:
	cp	r12,#%0020
	jr	lt,L163C
	xor	r12,r12
	jr	L1674
L165E:
	ld	r2,%0004(r14)
	add	r2,r12
	ldb	rl3,D209A(r12)
	xorb	rh3,rh3
	add	r3,#B2FA1
	ldb	rl4,@r3
	ldb	@r2,rl4
	inc	r12,#1
L1674:
	cp	r12,#%0040
	jr	lt,L165E
	jp	cret
end _encrypt
G	_crypt	PR
E
_crypt:
	call	csv
	xor	r13,r13
	jr	L168C
L1686:
	clrb	B3052(r13)
	inc	r13,#1
L168C:
	cp	r13,#%0042
	jr	lt,L1686
	xor	r13,r13
	jr	L16C4
L1696:
	cp	r13,#%0040
	jr	ge,L16D2
	xor	r12,r12
	jr	L16B8
L16A0:
	ld	r2,r11
	ldk	r3,#6
	sub	r3,r12
	neg	r3
	sda	r2,r3
	and	r2,#%0001
	ldb	B3052(r13),rl2
	inc	r12,#1
	inc	r13,#1
L16B8:
	cp	r12,#%0007
	jr	lt,L16A0
	inc	r13,#1
	inc	%0004(r14),#1
L16C4:
	ld	r2,%0004(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	test	r3
	jr	ne,L1696
L16D2:
	push	@r15,#B3052
	call	_setkey
	inc	r15,#2
	xor	r13,r13
	jr	L16E6
L16E0:
	clrb	B3052(r13)
	inc	r13,#1
L16E6:
	cp	r13,#%0042
	jr	lt,L16E0
	xor	r13,r13
	jr	L16FA
L16F0:
	ldb	rl2,D2152(r13)
	ldb	B2F72(r13),rl2
	inc	r13,#1
L16FA:
	cp	r13,#%0030
	jr	lt,L16F0
	xor	r13,r13
	jr	L178E
L1704:
	ld	r2,%0006(r14)
	inc	%0006(r14),#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	ld	r2,r11
	ldb	B3094(r13),rl2
	cp	r11,#%005A
	jr	le,L1720
	dec	r11,#6
L1720:
	cp	r11,#%0039
	jr	le,L1728
	dec	r11,#7
L1728:
	sub	r11,#%002E
	xor	r12,r12
	jr	L1786
L1730:
	ld	r2,r11
	ld	r3,r12
	neg	r3
	sda	r2,r3
	bit	r2,#0
	jr	eq,L1784
	ld	r3,r13
	mult	rr2,#%0006
	ld	r2,r3
	add	r2,r12
	add	r2,#B2F72
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r10,r3
	ld	r3,r13
	mult	rr2,#%0006
	ld	r2,r3
	add	r2,r12
	add	r2,#B2F72
	ld	r5,r13
	mult	rr4,#%0006
	ld	r3,r5
	add	r3,r12
	add	r3,#B2F8A
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r3,r13
	mult	rr2,#%0006
	ld	r2,r3
	add	r2,r12
	add	r2,#B2F8A
	ld	r3,r10
	ldb	@r2,rl3
L1784:
	inc	r12,#1
L1786:
	cp	r12,#%0006
	jr	lt,L1730
	inc	r13,#1
L178E:
	cp	r13,#%0002
	jr	lt,L1704
	xor	r13,r13
	jr	L17A8
L1798:
	push	@r15,#%0000
	push	@r15,#B3052
	call	_encrypt
	inc	r15,#4
	inc	r13,#1
L17A8:
	cp	r13,#%0019
	jr	lt,L1798
	xor	r13,r13
	jr	L17F6
L17B2:
	xor	r11,r11
	xor	r12,r12
	jr	L17D4
L17B8:
	sla	r11,#1
	ld	r3,r13
	mult	rr2,#%0006
	ld	r2,r3
	add	r2,r12
	add	r2,#B3052
	ldb	rl3,@r2
	xorb	rh3,rh3
	or	r3,r11
	ld	r11,r3
	inc	r12,#1
L17D4:
	cp	r12,#%0006
	jr	lt,L17B8
	add	r11,#%002E
	cp	r11,#%0039
	jr	le,L17E6
	inc	r11,#7
L17E6:
	cp	r11,#%005A
	jr	le,L17EE
	inc	r11,#6
L17EE:
	ld	r2,r11
	ldb	B3096(r13),rl2
	inc	r13,#1
L17F6:
	cp	r13,#%000B
	jr	lt,L17B2
	clrb	B3096(r13)
	testb	B3095
	jr	ne,L180E
	ldb	rl2,B3094
	ldb	B3095,rl2
L180E:
	ld	r2,#B3094
	jp	cret
end _crypt
$SECTION BSS_B
I
B2C3A:
$REL	$+%1
B2C3B:
$REL	$+%1A
B2C55:
$REL	$+%1
B2C56:
$REL	$+%1
B2C57:
$REL	$+%1A
B2C71:
$REL	$+%1
B2C72:
$REL	$+%18
B2C8A:
$REL	$+%2E8
B2F72:
$REL	$+%18
B2F8A:
$REL	$+%17
B2FA1:
$REL	$+%1
B2FA2:
$REL	$+%1F
B2FC1:
$REL	$+%1
B2FC2:
$REL	$+%20
B2FE2:
$REL	$+%1F
B3001:
$REL	$+%1
B3002:
$REL	$+%1
B3003:
$REL	$+%1
B3004:
$REL	$+%1
B3005:
$REL	$+%1D
B3022:
$REL	$+%1
B3023:
$REL	$+%1
B3024:
$REL	$+%1
B3025:
$REL	$+%1
B3026:
$REL	$+%1
B3027:
$REL	$+%2B
B3052:
$REL	$+%42
B3094:
$REL	$+%1
B3095:
$REL	$+%1
B3096:
$REL	$+%E
$SDEFAULT
I
D205A:
BV %3A;BV %32;BV %2A;BV %22;BV %1A;BV %12;BV %A;BV %2
BV %3C;BV %34;BV %2C;BV %24;BV %1C;BV %14;BV %C;BV %4
BV %3E;BV %36;BV %2E;BV %26;BV %1E;BV %16;BV %E;BV %6
BV %40;BV %38;BV %30;BV %28;BV %20;BV %18;BV %10;BV %8
BV %39;BV %31;BV %29;BV %21;BV %19;BV %11;BV %9;BV %1
BV %3B;BV %33;BV %2B;BV %23;BV %1B;BV %13;BV %B;BV %3
BV %3D;BV %35;BV %2D;BV %25;BV %1D;BV %15;BV %D;BV %5
BV %3F;BV %37;BV %2F;BV %27;BV %1F;BV %17;BV %F;BV %7
D209A:
BV %28;BV %8;BV %30;BV %10;BV %38;BV %18;BV %40;BV %20
BV %27;BV %7;BV %2F;BV %F;BV %37;BV %17;BV %3F;BV %1F
BV %26;BV %6;BV %2E;BV %E;BV %36;BV %16;BV %3E;BV %1E
BV %25;BV %5;BV %2D;BV %D;BV %35;BV %15;BV %3D;BV %1D
BV %24;BV %4;BV %2C;BV %C;BV %34;BV %14;BV %3C;BV %1C
BV %23;BV %3;BV %2B;BV %B;BV %33;BV %13;BV %3B;BV %1B
BV %22;BV %2;BV %2A;BV %A;BV %32;BV %12;BV %3A;BV %1A
BV %21;BV %1;BV %29;BV %9;BV %31;BV %11;BV %39;BV %19
D20DA:
BV %39;BV %31;BV %29;BV %21;BV %19;BV %11;BV %9;BV %1
BV %3A;BV %32;BV %2A;BV %22;BV %1A;BV %12;BV %A;BV %2
BV %3B;BV %33;BV %2B;BV %23;BV %1B;BV %13;BV %B;BV %3
BV %3C;BV %34;BV %2C;BV %24
D20F6:
BV %3F;BV %37;BV %2F;BV %27;BV %1F;BV %17;BV %F;BV %7
BV %3E;BV %36;BV %2E;BV %26;BV %1E;BV %16;BV %E;BV %6
BV %3D;BV %35;BV %2D;BV %25;BV %1D;BV %15;BV %D;BV %5
BV %1C;BV %14;BV %C;BV %4
D2112:
BV %1;BV %1;BV %2;BV %2;BV %2;BV %2;BV %2;BV %2
BV %1;BV %2;BV %2;BV %2;BV %2;BV %2;BV %2;BV %1
D2122:
BV %E;BV %11;BV %B;BV %18;BV %1;BV %5;BV %3;BV %1C
BV %F;BV %6;BV %15;BV %A;BV %17;BV %13;BV %C;BV %4
BV %1A;BV %8;BV %10;BV %7;BV %1B;BV %14;BV %D;BV %2
D213A:
BV %29;BV %34;BV %1F;BV %25;BV %2F;BV %37;BV %1E;BV %28
BV %33;BV %2D;BV %21;BV %30;BV %2C;BV %31;BV %27;BV %38
BV %22;BV %35;BV %2E;BV %2A;BV %32;BV %24;BV %1D;BV %20
D2152:
BV %20;BV %1;BV %2;BV %3;BV %4;BV %5;BV %4;BV %5
BV %6;BV %7;BV %8;BV %9;BV %8;BV %9;BV %A;BV %B
BV %C;BV %D;BV %C;BV %D;BV %E;BV %F;BV %10;BV %11
BV %10;BV %11;BV %12;BV %13;BV %14;BV %15;BV %14;BV %15
BV %16;BV %17;BV %18;BV %19;BV %18;BV %19;BV %1A;BV %1B
BV %1C;BV %1D;BV %1C;BV %1D;BV %1E;BV %1F;BV %20;BV %1
D2182:
BV %E;BV %4;BV %D;BV %1;BV %2;BV %F;BV %B;BV %8
BV %3;BV %A;BV %6;BV %C;BV %5;BV %9;BV %0;BV %7
BV %0;BV %F;BV %7;BV %4;BV %E;BV %2;BV %D;BV %1
BV %A;BV %6;BV %C;BV %B;BV %9;BV %5;BV %3;BV %8
BV %4;BV %1;BV %E;BV %8;BV %D;BV %6;BV %2;BV %B
BV %F;BV %C;BV %9;BV %7;BV %3;BV %A;BV %5;BV %0
BV %F;BV %C;BV %8;BV %2;BV %4;BV %9;BV %1;BV %7
BV %5;BV %B;BV %3;BV %E;BV %A;BV %0;BV %6;BV %D
BV %F;BV %1;BV %8;BV %E;BV %6;BV %B;BV %3;BV %4
BV %9;BV %7;BV %2;BV %D;BV %C;BV %0;BV %5;BV %A
BV %3;BV %D;BV %4;BV %7;BV %F;BV %2;BV %8;BV %E
BV %C;BV %0;BV %1;BV %A;BV %6;BV %9;BV %B;BV %5
BV %0;BV %E;BV %7;BV %B;BV %A;BV %4;BV %D;BV %1
BV %5;BV %8;BV %C;BV %6;BV %9;BV %3;BV %2;BV %F
BV %D;BV %8;BV %A;BV %1;BV %3;BV %F;BV %4;BV %2
BV %B;BV %6;BV %7;BV %C;BV %0;BV %5;BV %E;BV %9
BV %A;BV %0;BV %9;BV %E;BV %6;BV %3;BV %F;BV %5
BV %1;BV %D;BV %C;BV %7;BV %B;BV %4;BV %2;BV %8
BV %D;BV %7;BV %0;BV %9;BV %3;BV %4;BV %6;BV %A
BV %2;BV %8;BV %5;BV %E;BV %C;BV %B;BV %F;BV %1
BV %D;BV %6;BV %4;BV %9;BV %8;BV %F;BV %3;BV %0
BV %B;BV %1;BV %2;BV %C;BV %5;BV %A;BV %E;BV %7
BV %1;BV %A;BV %D;BV %0;BV %6;BV %9;BV %8;BV %7
BV %4;BV %F;BV %E;BV %3;BV %B;BV %5;BV %2;BV %C
BV %7;BV %D;BV %E;BV %3;BV %0;BV %6;BV %9;BV %A
BV %1;BV %2;BV %8;BV %5;BV %B;BV %C;BV %4;BV %F
BV %D;BV %8;BV %B;BV %5;BV %6;BV %F;BV %0;BV %3
BV %4;BV %7;BV %2;BV %C;BV %1;BV %A;BV %E;BV %9
BV %A;BV %6;BV %9;BV %0;BV %C;BV %B;BV %7;BV %D
BV %F;BV %1;BV %3;BV %E;BV %5;BV %2;BV %8;BV %4
BV %3;BV %F;BV %0;BV %6;BV %A;BV %1;BV %D;BV %8
BV %9;BV %4;BV %5;BV %B;BV %C;BV %7;BV %2;BV %E
BV %2;BV %C;BV %4;BV %1;BV %7;BV %A;BV %B;BV %6
BV %8;BV %5;BV %3;BV %F;BV %D;BV %0;BV %E;BV %9
BV %E;BV %B;BV %2;BV %C;BV %4;BV %7;BV %D;BV %1
BV %5;BV %0;BV %F;BV %A;BV %3;BV %9;BV %8;BV %6
BV %4;BV %2;BV %1;BV %B;BV %A;BV %D;BV %7;BV %8
BV %F;BV %9;BV %C;BV %5;BV %6;BV %3;BV %0;BV %E
BV %B;BV %8;BV %C;BV %7;BV %1;BV %E;BV %2;BV %D
BV %6;BV %F;BV %0;BV %9;BV %A;BV %4;BV %5;BV %3
BV %C;BV %1;BV %A;BV %F;BV %9;BV %2;BV %6;BV %8
BV %0;BV %D;BV %3;BV %4;BV %E;BV %7;BV %5;BV %B
BV %A;BV %F;BV %4;BV %2;BV %7;BV %C;BV %9;BV %5
BV %6;BV %1;BV %D;BV %E;BV %0;BV %B;BV %3;BV %8
BV %9;BV %E;BV %F;BV %5;BV %2;BV %8;BV %C;BV %3
BV %7;BV %0;BV %4;BV %A;BV %1;BV %D;BV %B;BV %6
BV %4;BV %3;BV %2;BV %C;BV %9;BV %5;BV %F;BV %A
BV %B;BV %E;BV %1;BV %7;BV %6;BV %0;BV %8;BV %D
BV %4;BV %B;BV %2;BV %E;BV %F;BV %0;BV %8;BV %D
BV %3;BV %C;BV %9;BV %7;BV %5;BV %A;BV %6;BV %1
BV %D;BV %0;BV %B;BV %7;BV %4;BV %9;BV %1;BV %A
BV %E;BV %3;BV %5;BV %C;BV %2;BV %F;BV %8;BV %6
BV %1;BV %4;BV %B;BV %D;BV %C;BV %3;BV %7;BV %E
BV %A;BV %F;BV %6;BV %8;BV %0;BV %5;BV %9;BV %2
BV %6;BV %B;BV %D;BV %8;BV %1;BV %4;BV %A;BV %7
BV %9;BV %5;BV %0;BV %F;BV %E;BV %2;BV %3;BV %C
BV %D;BV %2;BV %8;BV %4;BV %6;BV %F;BV %B;BV %1
BV %A;BV %9;BV %3;BV %E;BV %5;BV %0;BV %C;BV %7
BV %1;BV %F;BV %D;BV %8;BV %A;BV %3;BV %7;BV %4
BV %C;BV %5;BV %6;BV %B;BV %0;BV %E;BV %9;BV %2
BV %7;BV %B;BV %4;BV %1;BV %9;BV %C;BV %E;BV %2
BV %0;BV %6;BV %A;BV %D;BV %F;BV %3;BV %5;BV %8
BV %2;BV %1;BV %E;BV %7;BV %4;BV %A;BV %8;BV %D
BV %F;BV %C;BV %9;BV %0;BV %3;BV %5;BV %6;BV %B
D2382:
BV %10;BV %7;BV %14;BV %15;BV %1D;BV %C;BV %1C;BV %11
BV %1;BV %F;BV %17;BV %1A;BV %5;BV %12;BV %1F;BV %A
BV %2;BV %8;BV %18;BV %E;BV %20;BV %1B;BV %3;BV %9
BV %13;BV %D;BV %1E;BV %6;BV %16;BV %B;BV %4;BV %19
end crypt_
