	setf
	seti
loop0:
	sub	$14,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r1
	stst	(r1)+
	stst	(r1)+
	stst	(r1)+
	sub	$14,r1
	cmp	r1,sp
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
