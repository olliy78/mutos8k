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
	jr	L1680
L165A:
	ldb	rl2,D23E6(r13)
	xorb	rh2,rh2
	add	r2,%0004(r14)
	dec	r2,#1
	ldb	rl3,@r2
	ldb	B2D4E(r13),rl3
	ldb	rl2,D2402(r13)
	xorb	rh2,rh2
	add	r2,%0004(r14)
	dec	r2,#1
	ldb	rl3,@r2
	ldb	B2D6A(r13),rl3
	inc	r13,#1
L1680:
	cp	r13,#%001C
	jr	lt,L165A
	xor	r13,r13
	jr	L1724
L168A:
	xor	r11,r11
	jr	L16D4
L168E:
	ldb	rl2,B2D4E
	xorb	rh2,rh2
	ld	r10,r2
	xor	r12,r12
	jr	L16A4
L169A:
	ldb	rl2,B2D4F(r12)
	ldb	B2D4E(r12),rl2
	inc	r12,#1
L16A4:
	cp	r12,#%001B
	jr	lt,L169A
	ld	r2,r10
	ldb	B2D69,rl2
	ldb	rl2,B2D6A
	xorb	rh2,rh2
	ld	r10,r2
	xor	r12,r12
	jr	L16C6
L16BC:
	ldb	rl2,B2D6B(r12)
	ldb	B2D6A(r12),rl2
	inc	r12,#1
L16C6:
	cp	r12,#%001B
	jr	lt,L16BC
	ld	r2,r10
	ldb	B2D85,rl2
	inc	r11,#1
L16D4:
	ldb	rl2,D241E(r13)
	xorb	rh2,rh2
	cp	r2,r11
	jr	gt,L168E
	xor	r12,r12
	jr	L171C
L16E2:
	ld	r3,r13
	mult	rr2,#%0030
	ld	r2,r3
	add	r2,r12
	add	r2,#B2D86
	ldb	rl3,D242E(r12)
	xorb	rh3,rh3
	add	r3,#B2D4E-%1
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r3,r13
	mult	rr2,#%0030
	ld	r2,r3
	add	r2,r12
	add	r2,#B2D9E
	ldb	rl3,D2446(r12)
	xorb	rh3,rh3
	add	r3,#B2D4E-%1
	ldb	rl4,@r3
	ldb	@r2,rl4
	inc	r12,#1
L171C:
	cp	r12,#%0018
	jr	lt,L16E2
	inc	r13,#1
L1724:
	cp	r13,#%0010
	jr	lt,L168A
	jp	cret
end _setkey
G	_encrypt	PR
E
_encrypt:
	call	csv
	xor	r12,r12
	jr	L174A
L1736:
	ldb	rl2,D2366(r12)
	xorb	rh2,rh2
	add	r2,%0004(r14)
	dec	r2,#1
	ldb	rl3,@r2
	ldb	B30B6(r12),rl3
	inc	r12,#1
L174A:
	cp	r12,#%0040
	jr	lt,L1736
	xor	r9,r9
	jp	L1890
L1756:
	test	%0006(r14)
	jr	eq,L1762
	ldk	r10,#15
	sub	r10,r9
	jr	L1764
L1762:
	ld	r10,r9
L1764:
	xor	r12,r12
	jr	L1772
L1768:
	ldb	rl2,B30D6(r12)
	ldb	B30F6(r12),rl2
	inc	r12,#1
L1772:
	cp	r12,#%0020
	jr	lt,L1768
	xor	r12,r12
	jr	L17A6
L177C:
	ld	r3,r10
	mult	rr2,#%0030
	ld	r2,r3
	add	r2,r12
	add	r2,#B2D86
	ldb	rl3,B3086(r12)
	xorb	rh3,rh3
	add	r3,#B30D5
	ldb	rl4,@r2
	xorb	rh4,rh4
	ldb	rl5,@r3
	xorb	rh5,rh5
	xor	r4,r5
	ld	r2,r4
	ldb	B3136(r12),rl2
	inc	r12,#1
L17A6:
	cp	r12,#%0030
	jr	lt,L177C
	xor	r12,r12
	jr	L184C
L17B0:
	ld	r3,r12
	mult	rr2,#%0006
	ld	r2,r3
	ld	r13,r2
	ld	r2,r12
	sla	r2,#6
	ldb	rl3,B3136(r13)
	xorb	rh3,rh3
	sla	r3,#5
	add	r2,r3
	ldb	rl3,B3137(r13)
	xorb	rh3,rh3
	sla	r3,#3
	add	r2,r3
	ldb	rl3,B3138(r13)
	xorb	rh3,rh3
	sla	r3,#2
	add	r2,r3
	ldb	rl3,B3139(r13)
	xorb	rh3,rh3
	sla	r3,#1
	add	r2,r3
	ldb	rl3,B313A(r13)
	xorb	rh3,rh3
	add	r2,r3
	ldb	rl3,B313B(r13)
	xorb	rh3,rh3
	sla	r3,#4
	add	r2,r3
	add	r2,#D248E
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	ld	r2,r12
	sla	r2,#2
	ld	r13,r2
	ld	r2,r11
	sra	r2,#3
	and	r2,#%0001
	ldb	B3116(r13),rl2
	ld	r2,r11
	sra	r2,#2
	and	r2,#%0001
	ldb	B3117(r13),rl2
	ld	r2,r11
	sra	r2,#1
	and	r2,#%0001
	ldb	B3118(r13),rl2
	ld	r2,r11
	and	r2,#%0001
	ldb	B3119(r13),rl2
	inc	r12,#1
L184C:
	cp	r12,#%0008
	jr	lt,L17B0
	xor	r12,r12
	jr	L1874
L1856:
	ldb	rl2,D268E(r12)
	xorb	rh2,rh2
	add	r2,#B3115
	ldb	rl3,B30B6(r12)
	xorb	rh3,rh3
	ldb	rl4,@r2
	xorb	rh4,rh4
	xor	r3,r4
	ld	r2,r3
	ldb	B30D6(r12),rl2
	inc	r12,#1
L1874:
	cp	r12,#%0020
	jr	lt,L1856
	xor	r12,r12
	jr	L1888
L187E:
	ldb	rl2,B30F6(r12)
	ldb	B30B6(r12),rl2
	inc	r12,#1
L1888:
	cp	r12,#%0020
	jr	lt,L187E
	inc	r9,#1
L1890:
	cp	r9,#%0010
	jp	lt,L1756
	xor	r12,r12
	jr	L18B4
L189C:
	ldb	rl2,B30B6(r12)
	xorb	rh2,rh2
	ld	r13,r2
	ldb	rl2,B30D6(r12)
	ldb	B30B6(r12),rl2
	ld	r2,r13
	ldb	B30D6(r12),rl2
	inc	r12,#1
L18B4:
	cp	r12,#%0020
	jr	lt,L189C
	xor	r12,r12
	jr	L18D4
L18BE:
	ld	r2,%0004(r14)
	add	r2,r12
	ldb	rl3,D23A6(r12)
	xorb	rh3,rh3
	add	r3,#B30B5
	ldb	rl4,@r3
	ldb	@r2,rl4
	inc	r12,#1
L18D4:
	cp	r12,#%0040
	jr	lt,L18BE
	jp	cret
end _encrypt
G	_crypt	PR
E
_crypt:
	call	csv
	xor	r13,r13
	jr	L18EC
L18E6:
	clrb	B3166(r13)
	inc	r13,#1
L18EC:
	cp	r13,#%0042
	jr	lt,L18E6
	xor	r13,r13
	jr	L1924
L18F6:
	cp	r13,#%0040
	jr	ge,L1932
	xor	r12,r12
	jr	L1918
L1900:
	ld	r2,r11
	ldk	r3,#6
	sub	r3,r12
	neg	r3
	sda	r2,r3
	and	r2,#%0001
	ldb	B3166(r13),rl2
	inc	r12,#1
	inc	r13,#1
L1918:
	cp	r12,#%0007
	jr	lt,L1900
	inc	r13,#1
	inc	%0004(r14),#1
L1924:
	ld	r2,%0004(r14)
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	test	r3
	jr	ne,L18F6
L1932:
	push	@r15,#B3166
	call	_setkey
	inc	r15,#2
	xor	r13,r13
	jr	L1946
L1940:
	clrb	B3166(r13)
	inc	r13,#1
L1946:
	cp	r13,#%0042
	jr	lt,L1940
	xor	r13,r13
	jr	L195A
L1950:
	ldb	rl2,D245E(r13)
	ldb	B3086(r13),rl2
	inc	r13,#1
L195A:
	cp	r13,#%0030
	jr	lt,L1950
	xor	r13,r13
	jr	L19EE
L1964:
	ld	r2,%0006(r14)
	inc	%0006(r14),#1
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r11,r3
	ld	r2,r11
	ldb	B31A8(r13),rl2
	cp	r11,#%005A
	jr	le,L1980
	dec	r11,#6
L1980:
	cp	r11,#%0039
	jr	le,L1988
	dec	r11,#7
L1988:
	sub	r11,#%002E
	xor	r12,r12
	jr	L19E6
L1990:
	ld	r2,r11
	ld	r3,r12
	neg	r3
	sda	r2,r3
	bit	r2,#0
	jr	eq,L19E4
	ld	r3,r13
	mult	rr2,#%0006
	ld	r2,r3
	add	r2,r12
	add	r2,#B3086
	ldb	rl3,@r2
	xorb	rh3,rh3
	ld	r10,r3
	ld	r3,r13
	mult	rr2,#%0006
	ld	r2,r3
	add	r2,r12
	add	r2,#B3086
	ld	r5,r13
	mult	rr4,#%0006
	ld	r3,r5
	add	r3,r12
	add	r3,#B309E
	ldb	rl4,@r3
	ldb	@r2,rl4
	ld	r3,r13
	mult	rr2,#%0006
	ld	r2,r3
	add	r2,r12
	add	r2,#B309E
	ld	r3,r10
	ldb	@r2,rl3
L19E4:
	inc	r12,#1
L19E6:
	cp	r12,#%0006
	jr	lt,L1990
	inc	r13,#1
L19EE:
	cp	r13,#%0002
	jr	lt,L1964
	xor	r13,r13
	jr	L1A08
L19F8:
	push	@r15,#%0000
	push	@r15,#B3166
	call	_encrypt
	inc	r15,#4
	inc	r13,#1
L1A08:
	cp	r13,#%0019
	jr	lt,L19F8
	xor	r13,r13
	jr	L1A56
L1A12:
	xor	r11,r11
	xor	r12,r12
	jr	L1A34
L1A18:
	sla	r11,#1
	ld	r3,r13
	mult	rr2,#%0006
	ld	r2,r3
	add	r2,r12
	add	r2,#B3166
	ldb	rl3,@r2
	xorb	rh3,rh3
	or	r3,r11
	ld	r11,r3
	inc	r12,#1
L1A34:
	cp	r12,#%0006
	jr	lt,L1A18
	add	r11,#%002E
	cp	r11,#%0039
	jr	le,L1A46
	inc	r11,#7
L1A46:
	cp	r11,#%005A
	jr	le,L1A4E
	inc	r11,#6
L1A4E:
	ld	r2,r11
	ldb	B31AA(r13),rl2
	inc	r13,#1
L1A56:
	cp	r13,#%000B
	jr	lt,L1A12
	clrb	B31AA(r13)
	testb	B31A9
	jr	ne,L1A6E
	ldb	rl2,B31A8
	ldb	B31A9,rl2
L1A6E:
	ld	r2,#B31A8
	jp	cret
end _crypt
$SECTION BSS_B
I
B2D4E:
$REL	$+%1
B2D4F:
$REL	$+%1A
B2D69:
$REL	$+%1
B2D6A:
$REL	$+%1
B2D6B:
$REL	$+%1A
B2D85:
$REL	$+%1
B2D86:
$REL	$+%18
B2D9E:
$REL	$+%2E8
B3086:
$REL	$+%18
B309E:
$REL	$+%17
B30B5:
$REL	$+%1
B30B6:
$REL	$+%1F
B30D5:
$REL	$+%1
B30D6:
$REL	$+%20
B30F6:
$REL	$+%1F
B3115:
$REL	$+%1
B3116:
$REL	$+%1
B3117:
$REL	$+%1
B3118:
$REL	$+%1
B3119:
$REL	$+%1D
B3136:
$REL	$+%1
B3137:
$REL	$+%1
B3138:
$REL	$+%1
B3139:
$REL	$+%1
B313A:
$REL	$+%1
B313B:
$REL	$+%2B
B3166:
$REL	$+%42
B31A8:
$REL	$+%1
B31A9:
$REL	$+%1
B31AA:
$REL	$+%E
$SDEFAULT
I
D2366:
BV %3A;BV %32;BV %2A;BV %22;BV %1A;BV %12;BV %A;BV %2
BV %3C;BV %34;BV %2C;BV %24;BV %1C;BV %14;BV %C;BV %4
BV %3E;BV %36;BV %2E;BV %26;BV %1E;BV %16;BV %E;BV %6
BV %40;BV %38;BV %30;BV %28;BV %20;BV %18;BV %10;BV %8
BV %39;BV %31;BV %29;BV %21;BV %19;BV %11;BV %9;BV %1
BV %3B;BV %33;BV %2B;BV %23;BV %1B;BV %13;BV %B;BV %3
BV %3D;BV %35;BV %2D;BV %25;BV %1D;BV %15;BV %D;BV %5
BV %3F;BV %37;BV %2F;BV %27;BV %1F;BV %17;BV %F;BV %7
D23A6:
BV %28;BV %8;BV %30;BV %10;BV %38;BV %18;BV %40;BV %20
BV %27;BV %7;BV %2F;BV %F;BV %37;BV %17;BV %3F;BV %1F
BV %26;BV %6;BV %2E;BV %E;BV %36;BV %16;BV %3E;BV %1E
BV %25;BV %5;BV %2D;BV %D;BV %35;BV %15;BV %3D;BV %1D
BV %24;BV %4;BV %2C;BV %C;BV %34;BV %14;BV %3C;BV %1C
BV %23;BV %3;BV %2B;BV %B;BV %33;BV %13;BV %3B;BV %1B
BV %22;BV %2;BV %2A;BV %A;BV %32;BV %12;BV %3A;BV %1A
BV %21;BV %1;BV %29;BV %9;BV %31;BV %11;BV %39;BV %19
D23E6:
BV %39;BV %31;BV %29;BV %21;BV %19;BV %11;BV %9;BV %1
BV %3A;BV %32;BV %2A;BV %22;BV %1A;BV %12;BV %A;BV %2
BV %3B;BV %33;BV %2B;BV %23;BV %1B;BV %13;BV %B;BV %3
BV %3C;BV %34;BV %2C;BV %24
D2402:
BV %3F;BV %37;BV %2F;BV %27;BV %1F;BV %17;BV %F;BV %7
BV %3E;BV %36;BV %2E;BV %26;BV %1E;BV %16;BV %E;BV %6
BV %3D;BV %35;BV %2D;BV %25;BV %1D;BV %15;BV %D;BV %5
BV %1C;BV %14;BV %C;BV %4
D241E:
BV %1;BV %1;BV %2;BV %2;BV %2;BV %2;BV %2;BV %2
BV %1;BV %2;BV %2;BV %2;BV %2;BV %2;BV %2;BV %1
D242E:
BV %E;BV %11;BV %B;BV %18;BV %1;BV %5;BV %3;BV %1C
BV %F;BV %6;BV %15;BV %A;BV %17;BV %13;BV %C;BV %4
BV %1A;BV %8;BV %10;BV %7;BV %1B;BV %14;BV %D;BV %2
D2446:
BV %29;BV %34;BV %1F;BV %25;BV %2F;BV %37;BV %1E;BV %28
BV %33;BV %2D;BV %21;BV %30;BV %2C;BV %31;BV %27;BV %38
BV %22;BV %35;BV %2E;BV %2A;BV %32;BV %24;BV %1D;BV %20
D245E:
BV %20;BV %1;BV %2;BV %3;BV %4;BV %5;BV %4;BV %5
BV %6;BV %7;BV %8;BV %9;BV %8;BV %9;BV %A;BV %B
BV %C;BV %D;BV %C;BV %D;BV %E;BV %F;BV %10;BV %11
BV %10;BV %11;BV %12;BV %13;BV %14;BV %15;BV %14;BV %15
BV %16;BV %17;BV %18;BV %19;BV %18;BV %19;BV %1A;BV %1B
BV %1C;BV %1D;BV %1C;BV %1D;BV %1E;BV %1F;BV %20;BV %1
D248E:
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
D268E:
BV %10;BV %7;BV %14;BV %15;BV %1D;BV %C;BV %1C;BV %11
BV %1;BV %F;BV %17;BV %1A;BV %5;BV %12;BV %1F;BV %A
BV %2;BV %8;BV %18;BV %E;BV %20;BV %1B;BV %3;BV %9
BV %13;BV %D;BV %1E;BV %6;BV %16;BV %B;BV %4;BV %19
end crypt_
