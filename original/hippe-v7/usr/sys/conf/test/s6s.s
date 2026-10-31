	setf
	seti
	movif	$1,r0
	movif	$21,r1
	movif	$321,r2
loop0:
	sub	$6,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r5
	stfps	00(sp)
	stfps	2(sp)
	stfps	4(sp)
	cmp	sp,r5
	bne	ouch
	stfps	r4
	cmp	r4,00(sp)
	bne	ouch
	stfps	r4
	cmp	r4,2(sp)
	bne	ouch
	stfps	r4
	cmp	r4,4(sp)
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
