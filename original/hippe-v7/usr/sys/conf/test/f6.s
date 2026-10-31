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
	movf	r0,00(sp)
	movf	r1,4(sp)
	movf	r2,10(sp)
	cmp	sp,r5
	bne	ouch
	cmpf	00(sp),r0
	cfcc
	bne	ouch
	cmpf	4(sp),r1
	cfcc
	bne	ouch
	cmpf	10(sp),r2
	cfcc
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
