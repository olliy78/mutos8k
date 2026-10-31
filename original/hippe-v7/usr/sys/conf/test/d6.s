	setd
	seti
	movif	$1,r0
	movif	$21,r1
	movif	$321,r2
	movif	$4321,r3
loop0:
	sub	$40,sp
	mov	sp,r5
	cmp	sp,$160000
	blt	ok
	movf	r0,00(sp)
	movf	r1,10(sp)
	movf	r2,20(sp)
	movf	r3,30(sp)
	cmp	sp,r5
	bne	ouch
	cmpf	00(sp),r0
	cfcc
	bne	ouch
	cmpf	10(sp),r1
	cfcc
	bne	ouch
	cmpf	20(sp),r2
	cfcc
	bne	ouch
	cmpf	30(sp),r3
	cfcc
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
