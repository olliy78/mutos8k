	mov	$1,r2
	mov	$21,r3
	mov	$321,r4
loop0:
	mov	$40,r0
loop1:
	mov	sp,r5
	mov	r2,-(sp)
	mov	r3,-(sp)
	mov	r4,-(sp)
	sub	$6,r5
	cmp	r5,sp
	bne	ouch
	sob	r0,loop1
	mov	$40,r0
loop2:
	mov	(sp)+,r5
	cmp	r5,r4
	bne	ouch
	mov	(sp)+,r5
	cmp	r5,r3
	bne	ouch
	mov	(sp)+,r5
	cmp	r5,r2
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
