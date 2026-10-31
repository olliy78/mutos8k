	setd
	seti
	movif	$1,r0
	movif	$21,r1
	movif	$321,r2
	setl
loop0:
	sub	$14,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r0
	mov	$table,r1
	mov	r0,(r1)+
	add	$4,r0
	mov	r0,(r1)+
	add	$4,r0
	mov	r0,(r1)+
	movfi	r0,*-(r1)
	movfi	r1,*-(r1)
	movfi	r2,*-(r1)
	cmp	r1,$table
	bne	ouch
	movif	*(r1)+,r3
	cmpf	r3,r2
	cfcc
	bne	ouch
	movif	*(r1)+,r3
	cmpf	r3,r1
	cfcc
	bne	ouch
	movif	*(r1)+,r3
	cmpf	r3,r0
	cfcc
	bne	ouch
	br	loop0
ouch:
	mov	$1,r0
	sys	exit
ok:
	clr	r0
	sys	exit
.bss
table: .=.+6
