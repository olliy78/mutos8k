/ c code tables for the Z8000 -- reconstructed from /usr/lib/c1 (wk_w6.md), format as V7 table.s
/ regtab efftab cctab sptab use wv lines (op, group); the groups are header lines plus template, a template shared by
/ consecutive header lines or by the bracket forms.  Group names (cr ef cc sp plus first op) are inventions.

.globl	_regtab _efftab _cctab _sptab
.data
_regtab=.
	wv 106,cr106
	wv 30,cr30
	wv 31,cr30
	wv 83,cr83
	wv 84,cr83
	wv 32,cr32
	wv 33,cr32
	wv 37,cr37
	wv 38,cr38
	wv 99,cr99
	wv 80,cr80
	wv 40,cr40
	wv 41,cr40
	wv 81,cr81
	wv 82,cr81
	wv 42,cr42
	wv 43,cr42
	wv 14,cr42
	wv 44,cr42
	wv 45,cr45
	wv 46,cr45
	wv 107,cr45
	wv 108,cr45
	wv 47,cr47
	wv 48,cr47
	wv 49,cr47
	wv 70,cr70
	wv 71,cr70
	wv 72,cr72
	wv 73,cr72
	wv 74,cr74
	wv 75,cr75
	wv 76,cr75
	wv 137,cr75
	wv 138,cr75
	wv 77,cr77
	wv 78,cr77
	wv 79,cr77
	wv 102,cr102
	wv 51,cr51
	wv 52,cr52
	wv 56,cr56
	wv 57,cr57
	wv 58,cr58
	wv 59,cr59
	wv 16,cr16
	wv 109,cr109
	wv 0
_efftab=.
	wv 30,ef30
	wv 31,ef30
	wv 32,ef30
	wv 33,ef30
	wv 83,ef30
	wv 84,ef30
	wv 42,cr42
	wv 43,cr42
	wv 80,ef80
	wv 70,ef70
	wv 71,ef70
	wv 77,ef77
	wv 78,ef77
	wv 79,ef77
	wv 75,ef75
	wv 76,ef75
	wv 137,ef75
	wv 138,ef75
	wv 16,ef16
	wv 116,ef116
	wv 0
_cctab=.
	wv 30,cc30
	wv 31,cc30
	wv 34,cc30
	wv 35,cc30
	wv 36,cc30
	wv 37,cc30
	wv 38,cc30
	wv 40,cc30
	wv 41,cc30
	wv 42,cc30
	wv 43,cc30
	wv 45,cc30
	wv 46,cc30
	wv 47,cc30
	wv 48,cc30
	wv 49,cc30
	wv 60,cc60
	wv 61,cc60
	wv 62,cc60
	wv 63,cc60
	wv 64,cc60
	wv 65,cc60
	wv 66,cc60
	wv 67,cc60
	wv 68,cc60
	wv 69,cc60
	wv 85,cc85
	wv 0
_sptab=.
	wv 106,sp106
	wv 58,sp58
	wv 52,sp52
	wv 57,sp57
	wv 0
.text

/ group at 631c
cr81:
%n,y
	F
	IB1	R,A2

/ group at 6324
cr83:
%n,y
	F
	IB1	R,A2
	ldB1	A1,R

/ group at 632c
cr102:
%a,n
	jp	A1

/ group at 6334
cr99:
%a,n
	call	A1

%n,n
	F
	call	#2R

/ group at 6342
cr106:
%z,n
	xor	R,R

%[t5a77:]
%rb*,n
	ldB1	R,A1
	xorb	\S,\S

%rb,n
	ld	R,A1

%ab,n
%	[t5a77]

%a,n
%al,n
	VldT	R,A1

%af,n
	fldB1	R,A1

%n,n
%nl,n
%nf,n
	F

/ group at 6380
cr30:
%r,y
%	[t5d5d]

%a,y
	I'B1	A1,A2
	F

%a,aw
%	[t5d74]

%a,n
%	[t5d96]

%rl*,y
%al,y
%	[t5d74]

%al,nl
%	[t5d96]

%af,af
%	[t5d84]

/ group at 63b2
cr32:
%r,y
	F
	I'	A1,A2

%a,y
	F
	I'B1	A1,A2

%r,aw
	ldB1	R,A1
	IB1	A1,A2

%a,aw
%al,c
	ldB1	R,A1
	ldB1	R1,R
	IB1	R1,A2
	ldB1	A1,R1

%af,af
	fldB1	R,A1
	fld	R1,R
	faddd	R1,A2
	fldB1	A1,R1

%a,n
	F
	S1
	I	R,R1
	exB1	R,A1

%al,n
	S1
	!exts	R1
	ldl	R,A1
	Il	R,R1
	ex	R',A1'
	ex	R+',A1+'

/ group at 63e4
cr38:
%[t5b45:]
%n,n
	F
	I	R

%nl,n
	F
	I	R+'
	I	R'

/ group at 63f2
cr37:
%n,n
%	[t5b45]

%af,n
	fnegB1	R,A1

%nf,n
	F
	fneg	R,R

%nl,n
	F
	com	R+'
	com	R'
	addl	R,#11

/ group at 640c
cr80:
%[t5b85:]
%af,z
	fclr	R
	fldB1	A1,R

%rb,r
	S
	I	A1,R

%a,n
%al,nl
%af,nf
%	[t60db]

/ group at 642c
cr16:
%r*,a
%	[t6146]

%r,a
	andB1	A1,Z
	orB1	A1,A2
	ldB1	R,A1

%a,a
%	[t6146]

%r*,n
%	[t5bcc]

%r,n
	S
	andB1	A1,Z
	orB1	R,A1
	ldB1	A1,R

%[t5bcc:]
%a,n
	S
	ldB1	N,A1
	andB1	N,Z
	orB1	R,N
	ldB1	A1,R

/ group at 6452
cr40:
%n,z
%nl,z
%nf,z
	F

%[t5bef:]
%aw,y
	ldT	R,A1
	I'BE	R,A2

%nf,cf
%	[t5c39]

%[t5bfe:]
%n,y
	F
	I'BE	R,A2

%[t5c08:]
%n,aw
	F
	I	R,A2

%[t5c10:]
%nl,c
%nl,al
	F
	IB1	R,A2

%[t5c19:]
%nf,af
	F
	VIB2	R,A2

%nl,aw
	F
	ldBF	C1,A2
	exts	A
	IB1	R,N

%[t5c39:]
%nf,ef
%n,e
%nl,el
	F
	S1
	VIBE	R,R1

%[t5c45:]
%n,n
%nl,nl
	SS
	F
	popB1	N,@
	IBE	R,N

%[t5c58:]
%nf,nf
	SS
	F
	fldd	R1,@
	inc	W,#18
	VI	R,R1

/ group at 64ba
cr47:
%n,aw
%	[t5c08]

%n,e
%e,n
%	[t5c39]

%n,n
%	[t5c45]

%al,n
	S
	!exts	R
	I	R',A1'
	I	R+',A1+'

%nl,el
%el,nl
	F
	S1
	I	R',R1'
	I	R+',R1+'

%nl,nl
	SS
	F
	popl	A,@
	I	R',C2
	I	R+',C1

/ group at 64ec
cr45:
%n,z
%nl,z
	F

%aw,y
%al,x
%	[t5bef]

%n,y
%nl,x
%	[t5bfe]

%n,r
%nl,r
	F
	IBE	R,A2'

%e,n
%el,n
%n,e
%nl,e
	F
	S1
	IBE	R,R1'

%n,n
%nl,n
	SS
	F
	pop	C1,@
	IBE	R,C1

/ group at 6542
cr42:
%n,aw
	F
	XI	U-,A2

%n,e
	F
	S1
	XI	U-,R1

%n,n
	SS
	F
	XI	U-,@
	inc	W,#12

%nl,al
	F
	XIl	Y,A2

%nl,el
	F
	S1
	XIl	Y,R1

%nl,nl
	SS
	F
	XIl	Y,@
	inc	W,#14

%nf,z
	F
	fclr	R1
	VI	R,R1

%nf,af
%	[t5c19]

%nf,ef
%	[t5c39]

%nf,nf
%	[t5c58]

/ group at 6580
cr70:
%a,z
%al,z
%af,z
	F

%[t5d4d:]
%ab,y
	F
	I'	R,A2
	ldB1	A1,R

%[t5d5d:]
%aw,y
	I'	A1,A2
	F

%al,y
%	[t5d74]

%[t5d66:]
%r,aw
	IBE	A1,A2
	ldB1	R,A1

%[t5d74:]
%a,aw
%al,al
	F
	IBE	R,A2
	ldB1	A1,R

%[t5d84:]
%af,af
	F
	VIB2	R,A2
	VldB1	A1,R

%[t5d96:]
%a,n
%al,nl
%af,nf
	F
	S1
	VIBE	R,R1
	VldB1	A1,R

/ group at 65d0
cr72:
%a,aw
	F
	XI	U-,A2
	ldB1	A1,R

%a,e
	F
	S1
	XI	U-,R1
	ldB1	A1,R

%a,n
	F
	SS
	XI	U-,@
	inc	W,#12
	ldB1	A1,R

%al,al
	F
	XIl	Y,A2
	ldl	A1,R

%al,el
	S1
	F
	XIl	Y,R1
	ldl	A1,R

%al,nl
	SS
	F
	XIl	Y,@
	inc	W,#14
	ldl	A1,R

%af,z
	fclr	R
	fldB1	A1,R

%af,af
%	[t5d84]

%nf,nf
%	[t5d96]

/ group at 6608
cr74:
%a,aw
	F
	XI	U-,A2
	ldB1	A1,R-

%a,e
	F
	S1
	XI	U-,R1
	ldB1	A1,R-

%a,n
	F
	SS
	XI	U-,@
	inc	W,#12
	ldB1	A1,R-

%al,al
	F
	XIl	Y,A2
	ldl	A1,R-

%al,el
	S1
	F
	XIl	Y,R1
	ldl	A1,R-

%al,nl
	SS
	F
	XIl	Y,@
	inc	W,#14
	ldl	A1,R-

%af,z
	F
	fclr	R1
	VI	R,R1
	VldB1	A1,R

%af,af
%	[t5d84]

%af,nf
%	[t5d96]

/ group at 6640
cr77:
%ab,aw
%	[t5d74]

%ab,n
%	[t5d96]

%r,aw
%	[t5d66]

%a,aw
%	[t5d74]

%aw,n
	S
	I	R,A1
	ld	A1,R

%al,au
	ldl	R,A1
	I	R',#10
	I	R+',A2'
	ldl	A1,R

%al,al
	ldl	R,A1
	I	R',A2'
	I	R+',A2+'
	ldl	A1,R

%al,n
	S
	!exts	R
	ldl	A,A1
	I	R',C2
	I	R+',C1
	ldl	A1,R

%al,nl
	S
	ldl	A,A1
	I	R',C2
	I	R+',C1
	ldl	A1,R

/ group at 6678
cr75:
%[t5f60:]
%r*,y
%rl*,x
	F
	I'BE	R,A2
	ldB1	A1,R

%r,y
	I'BE	A1,A2
	ldB1	R,A1

%a,y
%al,x
%	[t5f60]

%[t5f80:]
%a,r
%al,r
	F
	IBE	R,A2'
	ldB1	A1,R

%[t5f91:]
%ab,n
	S
	ld	C2,R
	ldB1	R,A1
	xorb	\S,\S
	I	R,C2
	ldB1	A1,R

%aw,n
%al,n
	S
	ld	C2,R'
	ldT	R,A1
	IBE	R,C2
	ldB1	A1,R

/ group at 66b6
cr51:
%[t5fd3:]
%z,n
	fclr	R

%nu,n
	F
	!xor	R',R'
	fldil	R,U

%n,n
	F
	!exts	U
	fldil	R,U

/ group at 66ca
cr52:
%nf,n
	F
	fldctl	A,user
	fsetmode	rz
	fldil	U,\R
	fldctl	user,A
	ld	R',R+'

/ group at 66d2
cr57:
%zl,n
%	[t5fd3]

%nl,n
	F
	fldil	R,U

/ group at 66e0
cr56:
%nf,n
	F
	fldctl	A,user
	fsetmode	rz
	fldil	U,\R
	fldctl	user,A

/ group at 66e8
cr58:
%nu,n
	F
	!xor	R',R'

%n,n
	F
	!exts	U

/ group at 66f6
cr59:
%al,n
	ld	R,A1+

%nl,n
	F
	ld	R',R+'

/ group at 6704
cr109:
%n,n
	F
	xorb	\S,\S

/ group at 670c
ef30:
%rb,y
%	[t61f0]

%a,y
	I'B1	A1,A2

%r,aw
%	[t60ec]

%a,aw
%	[t5d74]

%a,n
%	[t5d96]

%af,af
%	[t5d84]

%al,y
%	[t5d74]

/ group at 6738
ef80:
%rb,z
	xor	A1,A1

%a,z
	I'B1	A1

%af,z
%	[t5b85]

%al,z
	xor	C2,C2
	ld	C1,C2
	ldl	A1,A

%[t60db:]
%r*,r*
%rl*,rl*
%a,rb*
%rb*,a
%af,nf
	S
	VIB1	A1,R

%r,c
	IBF	A1,A2

%[t60ec:]
%r,rw*
%rw*,r
%a,c
	IB1	A1,A2

%r,r
%	[t61f0]

%rw*,a
%a,rw*
%ab,r
%r,ab
%	[t60db]

%aw,r
%r,aw
%	[t60ec]

/ group at 67b2
ef77:
%r,aw
%	[t60ec]

/ group at 67ba
ef70:
%a,z
%al,z

%ab,y
%	[t5d4d]

%a,y
	I'BE	A1,A2

%r,aw
%	[t60ec]

%rl*,y
%	[t5d74]

/ group at 67e0
ef75:
%r*,y
%rl*,x
%	[t5f60]

%r,y
	I'BE	A1,A2

%a,y
%al,x
%	[t5f60]

%ab,n
%	[t5f91]

%[t6104:]
%rw*,n
%rl*,n
	S
	ldB1	N,A1
	IBE	N,R'
	ldB1	A1,N

%rw,a
	ldB2	R,A2'
	IBE	A1,R'

%rw,n
	S
	IBE	A1,R'

%aw,r
%al,r
%	[t5f80]

%aw,n
%al,n
%	[t6104]

/ group at 6836
ef16:
%r*,a
%	[t6146]

%r,a
	andB1	A1,Z
	orB1	A1,A2

%[t6146:]
%a,a
	ldT	R,A1
	andB1	R,Z
	orB1	R,A2
	ldB1	A1,R

%r*,n
%	[t5bcc]

%r,n
	S
	andB1	A1,Z
	orB1	A1,R

/ group at 6856
ef116:
%n,a
	F
	ld	R1,A2

%n,e
	F
	S1

%n,n
	SS
	F
	pop	R1,@

/ group at 686a
cc85:
%rb,y
	bit	A1,A2

%a,y
	bitB1	A1,A2

%n,y
	F
	bitB1	R,A2

/ group at 687e
cc60:
%nf,z
	F
	fcpzx	R

%nf,ef
	F
	S1
	fcpfx	R,R1

%nf,nf
	SS
	F
	fldd	R1,@
	inc	W,#18
	fcpfx	R,R1

%rb,z
	I'	A1

%a,z
%al,z
%al,zl
	I'B1	A1

%n,z
%nl,z
	FC

%[t61f0:]
%rb,c
	I	A1,A2

%[t61f6:]
%ab,c
	F
	I	R,A2

%a,c
%	[t60ec]

%rb,rb
%rb,aw
%	[t61f0]

%a,rb
%ab,aw
%	[t61f6]

%rb,ab
	S
	I	A1,R

%ab,ab
	ldB1	N,A1
	IB1	N,A2

%rw,aw
%	[t60ec]

%a,a
%al,al
	ldT	N,A1
	IB1	N,A2

%n,aw
%	[t5c08]

%nl,c
%nl,au
	F
	xor	C2,C2
	ldBF	C1,A2
	cpl	R,A

%nl,al
%	[t5c10]

%n,e
%nl,el
%	[t5c39]

%n,n
%nl,nl
%	[t5c45]

cc30=.
%n,n
%nf,z
%nf,nf
	H

/ group at 6940
sp58:
%nu,n
	FS
	push	@,#10

/ group at 6948
sp52:
%nf,n
	F
	fldctl	A,user
	fsetmode	rz
	fldil	U,\R
	fldctl	user,A
	push	@,R'

/ group at 6950
sp57:
%nf,n
	F
	fldctl	A,user
	fsetmode	rz
	fldil	U,\R
	fldctl	user,A
	pushl	@,R

/ group at 6958
sp106:
%z,n
	push	@,#10

%rb,n
	push	@,A1

%ab,n
	ldB1	N,A1
	xorb	Q,Q
	push	@,N

%r,n
	push	@,A1

%ql,n
	F
	pushl	@,R

%aw,n
%al,n
	pushB1	@,A1

%af,n
	F
	dec	W,#18
	fldd	@,R

