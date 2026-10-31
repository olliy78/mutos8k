	setf
	seti
loop0:
	mov	sp,r5
	stst	-(sp)
	stst	-(sp)
	stst	-(sp)
	sub	$14,r5
	cmp	r5,sp
	bne	ouch
	cmp	0(sp),4(sp)
	bne	ouch
	cmp	0(sp),10(sp)
	bne	ouch
	cmp	2(sp),6(sp)
	bne	ouch
	cmp	2(sp),12(sp)
	bne	ouch
	cmp	sp,$160000
	blt	ok
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
