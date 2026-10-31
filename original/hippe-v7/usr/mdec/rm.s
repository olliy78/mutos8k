/ rm023 disk driver.

.globl dno,buf

drive	= 0
cyl	= 0.
read	= 70
preset	= 20
go	= 1
fmt22	= 10000

rmcs1	= 176700
rmda	= rmcs1+6
rmcs2	= rmcs1+10
rmds	= rmcs1+12
rmof	= rmcs1+32
rmca	= rmcs1+34

dkinit:
	mov	$drive,*$rmcs2
	mov	$preset+go,*$rmcs1
	mov	$fmt22,*$rmof
	rts	pc

dkrblk:
	mov	r1,-(sp)
	mov	dno,r1
	div	$22.*19.,r0
	add	$cyl,r0
	mov	r0,*$rmca
	clr	r0
	div	$22.,r0
	swab	r0
	bis	r1,r0
	mov	$rmda,r1
	mov	r0,(r1)
	mov	$buf,-(r1)
	mov	$-256.,-(r1)
	mov	$read+go,-(r1)
1:
	tstb	(r1)
	bge	1b
	mov	(sp)+,r1
	rts	pc

end:
