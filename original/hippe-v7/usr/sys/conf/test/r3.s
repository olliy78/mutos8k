	mov	$1,r2
	mov	$21,r3
	mov	$321,r4
loop0:
	sub	$6,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r0
	mov	$table,r1
	mov	r0,0(r1)
	add	$2,r0
	mov	r0,2(r1)
	add	$2,r0
	mov	r0,4(r1)
	mov	r2,*(r1)+
	mov	r3,*(r1)+
	mov	r4,*(r1)+
	sub	$6,r1
	cmp	r1,$table
	bne	ouch
	mov	*(r1)+,r5
	cmp	r5,r2
	bne	ouch
	mov	*(r1)+,r5
	cmp	r5,r3
	bne	ouch
	mov	*(r1)+,r5
	cmp	r5,r4
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
