	mov	$1,r2
	mov	$21,r3
	mov	$321,r4
loop0:
	sub	$6,sp
	cmp	sp,$120000
	blt	ok
	mov	sp,r1
	mov	r2,(r1)+
	mov	r3,(r1)+
	mov	r4,(r1)+
	sub	$6,r1
	cmp	r1,sp
	bne	ouch
	cmp	(r1)+,r2
	bne	ouch
	cmp	(r1)+,r3
	bne	ouch
	cmp	(r1)+,r4
	bne	ouch
	sub	$6,r1
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
