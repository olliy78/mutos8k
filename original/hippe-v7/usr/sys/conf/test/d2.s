	setd
	seti
	movif	$1,r0
	movif	$21,r1
	movif	$321,r2
	movif	$4321,r3
loop0:
	sub	$40,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r1
	movf	r0,(r1)+
	movf	r1,(r1)+
	movf	r2,(r1)+
	movf	r3,(r1)+
	sub	$40,r1
	cmp	sp,r1
	bne	ouch
	cmpf	(r1)+,r0
	cfcc
	bne	ouch
	cmpf	(r1)+,r1
	cfcc
	bne	ouch
	cmpf	(r1)+,r2
	cfcc
	bne	ouch
	cmpf	(r1)+,r3
	cfcc
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
