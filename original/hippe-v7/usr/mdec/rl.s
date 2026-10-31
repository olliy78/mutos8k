/ rl02 disk driver

.globl dno,buf,dktmp

dkinit:
	rts	pc

dkrblk:
	mov	r1,-(sp)
	mov	dno,r1
	clr	r0
	div	$20.,r0
	asl	r1
	ash	$5,r0
	mov	r0,-(sp)
	asl	*sp
	bis	(sp)+,r1
	mov	r1,-(sp)
	bic	$!77700,r0	/ r0 = cylinder address
	mov	r0,-(sp)
	sub	dktmp,r0
	mov	(sp)+,dktmp
	neg	r0
	bpl	1f
	neg	r0
	bis	$2,r0
1:
	asl	r0
	bic	$!100,r1	/ r1 = head select bit
	ash	$-2.,r1
	bis	r1,r0
	inc	r0		/ r0 = disk address for seek
	mov	$6,-(sp)	/ seek command
	inc	brnch		/ change branch to skip return after seek
2:
	mov	$174406,r1	/ maintenance register address
	mov	$-256.,(r1)	/ set word count
	mov	r0,-(r1)	/ set disk address
	mov	$buf,-(r1)	/ set base address
	mov	(sp)+,-(r1)	/ set command
3:
	tstb	(r1)
	bpl	3b		/ wait till command done
brnch:
	br	4f
4:
	br	9f		/ return afer transfer (skip after seek)
	mov	(sp)+,r0	/ r0 = disk address for transfer
	mov	$14,-(sp)	/ read command
	dec	brnch
	br	2b
9:
	mov	(sp)+,r1
	rts	pc

end:
