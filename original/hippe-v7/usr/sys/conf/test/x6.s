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
	movei	r0,00(sp)
	movei	r1,4(sp)
	movei	r2,10(sp)
	cmp	sp,r5
	bne	ouch
	movei	r0,r4
	cmp	r4,00(sp)
	bne	ouch
	movei	r1,r4
	cmp	r4,4(sp)
	bne	ouch
	movei	r2,r4
	cmp	r4,10(sp)
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
