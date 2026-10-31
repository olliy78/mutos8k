	setd
	seti
	movif	$1,r0
	movif	$21,r1
	movif	$321,r2
loop0:
	sub	$30,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r5
	clrf	00(sp)
	clrf	10(sp)
	clrf	20(sp)
	cmp	sp,r5
	bne	ouch
	tstf	00(sp)
	cfcc
	bne	ouch
	tstf	10(sp)
	cfcc
	bne	ouch
	tstf	20(sp)
	cfcc
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
