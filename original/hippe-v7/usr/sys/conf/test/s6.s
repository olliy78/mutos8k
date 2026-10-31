	setf
	seti
	movif	$1,r0
	movif	$21,r1
	movif	$321,r2
loop0:
	sub	$14,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r5
	stst	00(sp)
	stst	4(sp)
	stst	10(sp)
	cmp	sp,r5
	bne	ouch
	cmp	0(sp),4(sp)
	bne	ouch
	cmp	0(sp),10(sp)
	bne	ouch
	cmp	2(sp),6(sp)
	bne	ouch
	cmp	2(sp),12(sp)
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
