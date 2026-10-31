	setf
	seti
loop0:
	mov	sp,r5
	clrf	-(sp)
	clrf	-(sp)
	clrf	-(sp)
	sub	$14,r5
	cmp	r5,sp
	bne	ouch
	tstf	(sp)+
	cfcc
	bne	ouch
	tstf	(sp)+
	cfcc
	bne	ouch
	tstf	(sp)+
	cfcc
	bne	ouch
	sub	$14,sp
	cmp	sp,$160000
	blt	ok
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
