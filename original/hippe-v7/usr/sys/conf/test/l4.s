	setd
	seti
	movif	$1,r0
	movif	$20,r1
	movif	$300,r2
	setl
loop0:
	mov	$40,r0
loop1:
	mov	sp,r5
	movfi	r0,-(sp)
	movfi	r1,-(sp)
	movfi	r2,-(sp)
	sub	$14,r5
	cmp	r5,sp
	bne	ouch
	sob	r0,loop1
	mov	$40,r0
loop2:
	movif	(sp)+,r3
	cmpf	r3,r2
	cfcc
	bne	ouch
	movif	(sp)+,r3
	cmpf	r3,r1
	cfcc
	bne	ouch
	movif	(sp)+,r3
	cmpf	r3,r0
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
