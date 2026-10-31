	setd
	seti
	movif	$1,r0
	movif	$20,r1
	movif	$300,r2
	movif	$4321,r3
loop0:
	mov	$40,r0
loop1:
	mov	sp,r5
	movf	r0,-(sp)
	movf	r1,-(sp)
	movf	r2,-(sp)
	movf	r3,-(sp)
	sub	$40,r5
	cmp	r5,sp
	bne	ouch
	sob	r0,loop1
	mov	$40,r0
loop2:
	cmpf	(sp)+,r3
	cfcc
	bne	ouch
	cmpf	(sp)+,r2
	cfcc
	bne	ouch
	cmpf	(sp)+,r1
	cfcc
	bne	ouch
	cmpf	(sp)+,r0
	cfcc
	bne	ouch
	sob	r0,loop2
	sub	$12,sp
	cmp	sp,$160000
	blt	ok
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
