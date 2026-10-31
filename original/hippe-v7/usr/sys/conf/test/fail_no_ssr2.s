A=1000
B=0
C=120000
	mov	$A,r2
loop0:
	sub	r2,sp
	cmp	sp,$C
	blt	ok
	mov	sp,r1
	cmp	-(sp),-(sp)
	bne	ouch
	add	$4,sp
	cmp	sp,r1
	bne	ouch
	add	$B,r2
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
