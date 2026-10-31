/ rp0456 disk driver.

.globl dno,buf

drive	= 0
cyl	= 0.
read	= 70
preset	= 20
go	= 1
fmt22	= 10000

hpcs1	= 176700
hpda	= hpcs1+6
hpcs2	= hpcs1+10
hpds	= hpcs1+12
hpof	= hpcs1+32
hpca	= hpcs1+34

dkinit:
	mov	$drive,*$hpcs2
	mov	$preset+go,*$hpcs1
	mov	$fmt22,*$hpof
	rts	pc

dkrblk:
	mov	r1,-(sp)
	mov	dno,r1
	div	$22.*19.,r0
	add	$cyl,r0
	mov	r0,*$hpca
	clr	r0
	div	$22.,r0
	swab	r0
	bis	r1,r0
	mov	$hpda,r1
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
