	setf
	seti
loop0:
	mov	sp,r5
	stfps	-(sp)
	stfps	-(sp)
	stfps	-(sp)
	sub	$6,r5
	cmp	r5,sp
	bne	ouch
	stfps	r4
	cmp	r4,(sp)+
	bne	ouch
	cmp	r4,(sp)+
	bne	ouch
	cmp	r4,(sp)+
	bne	ouch
	sub	$6,sp
	cmp	sp,$160000
	blt	ok
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
