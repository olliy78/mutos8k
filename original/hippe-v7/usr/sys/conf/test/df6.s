	setd
	seti
	movif	$1,r0
	movif	$21,r1
	movif	$321,r2
loop0:
	sub	$14,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r5
	movfo	r0,00(sp)
	movfo	r1,4(sp)
	movfo	r2,10(sp)
	cmp	sp,r5
	bne	ouch
	movof	00(sp),r3
	cmpf	r3,r0
	cfcc
	bne	ouch
	movof	4(sp),r3
	cmpf	r3,r1
	cfcc
	bne	ouch
	movof	10(sp),r3
	cmpf	r3,r2
	cfcc
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
