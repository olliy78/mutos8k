DEV=

all:	rk rl rp hp rm hk6 hk7

rk:	bootstrap.s rk.s
	make DEV=rk uboot

hk6:	bootstrap.s hk6.s
	make DEV=hk6 uboot

hk7:	bootstrap.s hk7.s
	make DEV=hk7 uboot

rl:	bootstrap.s rl.s
	make DEV=rl uboot

rp:	bootstrap.s rp.s
	make DEV=rp uboot

hp:	bootstrap.s hp.s
	make DEV=hp uboot

rm:	bootstrap.s hp.s
	make DEV=rm uboot

uboot:
	as bootstrap.s $(DEV).s
	strip a.out
	dd bs=1 skip=16 < a.out > $(DEV)uboot
	rm a.out
