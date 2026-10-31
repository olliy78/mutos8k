	setf
	seti
	movif	$1,r0
	movif	$21,r1
	movif	$321,r2
loop0:
	sub	$6,sp
	cmp	sp,$160000
	blt	ok
	mov	sp,r0
	mov	$table,r1
	mov	r0,(r1)+
	add	$4,r0
	mov	r0,(r1)+
	add	$4,r0
	mov	r0,(r1)+
	movei	r0,*-(r1)
	movei	r1,*-(r1)
	movei	r2,*-(r1)
	cmp	r1,$table
	bne	ouch
	movei	r2,r4
	cmp	r4,*(r1)+
	bne	ouch
	movei	r1,r4
	cmp	r4,*(r1)+
	bne	ouch
	movei	r0,r4
	cmp	r4,*(r1)+
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
