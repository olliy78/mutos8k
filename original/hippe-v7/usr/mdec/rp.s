/ rp03 disk driver.

.globl dno,buf

cyl	= 0.
read	= 4
go	= 1

rpcs	= 176710
rpda	= 176724
rpca	= 176722
rpba	= 176720
dkinit:
	clr	*$rpcs		/ selects drive zero
	rts	pc

dkrblk:
	mov	r1,-(sp)
	mov	dno,r1
	div	$20.*10.,r0
/	add	$cyl,r0
	mov	r0,*$rpca
	clr	r0
	div	$10.,r0
	swab	r0
	bis	r1,r0
	mov	r0,*$rpda
	mov	$rpba,r1
	mov	$buf,(r1)
	mov	$-256.,-(r1)
	mov	$read+go,-(r1)
1:
	tstb	(r1)
	bge	1b
	mov	(sp)+,r1
	rts	pc

end:
