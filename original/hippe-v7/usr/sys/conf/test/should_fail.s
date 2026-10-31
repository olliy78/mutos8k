_loop0:
	sub	$6,sp
	cmp	sp,$120000
	blt	_ok
	mov	sp,r1
	clr	(sp)+
	clr	(sp)+
	clr	(sp)+
	sub	$6,sp
	cmp	r1,sp
	bne	_ouch
	tst	(sp)+
	bne	_ouch
	tst	(sp)+
	bne	_ouch
	tst	(sp)+
	bne	_ouch
	sub	$6,sp
	br	_loop0
_ouch:
	mov	$1,r0
	sys	exit
_ok:
	clr	r0
	sys	exit
