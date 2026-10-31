/ rk05 disk driver

.globl dno,buf
read = 5
rkda = 177412

dkinit:
	rts pc

dkrblk:
	mov	r1,-(sp)
	mov	dno,r1
	div	$12.,r0
	ash	$4.,r0
	bis	r1,r0
	mov	$rkda+2,r1
	mov	r0,-(r1)
	mov	$buf,-(r1)
	mov	$-256.,-(r1)
	mov	$read,-(r1)
1:
	tstb	(r1)
	bge	1b
	mov	(sp)+,r1
	rts	pc

end:
