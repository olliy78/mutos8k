	mov	$1,r2
	mov	$21,r3
	mov	$321,r4
loop0:
	sub	$6,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r5
	mov	r2,00(sp)
	mov	r3,02(sp)
	mov	r4,04(sp)
	cmp	r5,sp
	bne	ouch
	mov	00(sp),r5
	cmp	r5,r2
	bne	ouch
	mov	02(sp),r5
	cmp	r5,r3
	bne	ouch
	mov	04(sp),r5
	cmp	r5,r4
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
