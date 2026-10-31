	setf
	seti
	movif	$1,r0
	movif	$21,r1
	movif	$321,r2
loop0:
	sub	$06,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r1
	movei	r0,(r1)+
	movei	r1,(r1)+
	movei	r2,(r1)+
	sub	$06,r1
	cmp	r1,sp
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
