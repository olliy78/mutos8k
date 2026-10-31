	setf
	seti
	movif	$1,r0
	movif	$20,r1
	movif	$300,r2
loop0:
	mov	$40,r0
loop1:
	mov	sp,r5
	movei	r0,-(sp)
	movei	r1,-(sp)
	movei	r2,-(sp)
	sub	$6,r5
	cmp	r5,sp
	bne	ouch
	sob	r0,loop1
	mov	$40,r0
loop2:
	movei	r2,r4
	cmp	(sp)+,r4
	bne	ouch
	movei	r1,r4
	cmp	(sp)+,r4
	bne	ouch
	movei	r0,r4
	cmp	(sp)+,r4
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
