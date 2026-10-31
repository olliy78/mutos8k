/ rk07 disk driver

.globl dno,buf,dktmp

hkcs2 = 177450
hkdc  = 177460
clear   = 40
pkack = 3
read  = 21
rk7   = 2000

dkinit:
	rts pc

dkrblk:
	mov	r1,-(sp)
	mov	dno,r1
	clr	r0
	div	$22.,r0
	mov	r1,dktmp
	mov	r0,r1
	clr	r0
	div	$3,r0
	ash	$10,r1
	bis	r1,dktmp
	mov	$hkcs2,r1
	mov	$clear,(r1)
	mov	r0,*$hkdc
	mov	dktmp,-(r1)
	mov	$buf,-(r1)
	mov	$256.,-(r1)
	mov	$rk7+pkack,-(r1)
1:	tstb	(r1)
	bpl	1b
	mov	$rk7+read,(r1)
2:	tstb	(r1)
	bpl	2b
	mov	(sp)+,r1
	rts	pc

end:
