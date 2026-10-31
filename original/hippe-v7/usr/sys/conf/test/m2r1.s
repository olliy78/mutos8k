loop0:
	mov	sp,r0
	sub	$6,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r1
	clr	(r1)+
	clr	(r1)+
	clr	(r1)+
	cmp	r1,r0
	bne	ouch
	mov	sp,r1
	tst	(r1)+
	bne	ouch
	tst	(r1)+
	bne	ouch
	tst	(r1)+
	bne	ouch
	cmp	r1,r0
	beq	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
