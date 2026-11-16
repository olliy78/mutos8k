# Makefile of the MUTOS kernel (plan 47).  Call in the guest:  cd /tmp; /mnt/make -f /mnt/Makefile
# Sources and headers are on /mnt (drive D), objects and result on /tmp (drive A).
# Default target mutos_1216: the kernel file = lk without the 16-byte header, padded to a multiple of 512 bytes.
# Two dd calls in a pipe (an intermediate file does not fit on drive A, measured 2026-11-16: no space left).
SRC = /mnt
CFLAGS = -O -I$(SRC)
OBJS = low.o shim.o abs.o alloc.o bio.o clock.o dev0.o fio.o iget.o lp.o machdep.o main.o malloc.o nami.o pipe.o prf.o rdwri.o rk.o sig.o slp.o subr.o sys1.o sys2.o sys3.o sys4.o text.o trap.o tty.o tty2.o ureg.o conf.o sysent.o daten.o bss.o

mutos_1216: lk
	/mnt/dd if=lk ibs=16 skip=1 obs=512 | /mnt/dd of=mutos_1216 bs=512 conv=sync
lk: $(OBJS)
	ld -s -o lk $(OBJS)
low.o: $(SRC)/low.s
	as -u -o low.o $(SRC)/low.s
shim.o: $(SRC)/shim.s
	as -u -o shim.o $(SRC)/shim.s
bss.o: $(SRC)/bss.s
	as -u -o bss.o $(SRC)/bss.s
abs.o: $(SRC)/abs.s
	as -u -o abs.o $(SRC)/abs.s
slp.o: $(SRC)/slp.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/slp.c
subr.o: $(SRC)/subr.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/subr.c
sys1.o: $(SRC)/sys1.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/sys1.c
sys2.o: $(SRC)/sys2.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/sys2.c
sys3.o: $(SRC)/sys3.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/sys3.c
sys4.o: $(SRC)/sys4.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/sys4.c
text.o: $(SRC)/text.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/text.c
trap.o: $(SRC)/trap.c $(SRC)/param.h
	cc -O -Dbackup=sigret -I$(SRC) -c $(SRC)/trap.c
tty.o: $(SRC)/tty.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/tty.c
tty2.o: $(SRC)/tty2.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/tty2.c
ureg.o: $(SRC)/ureg.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/ureg.c
conf.o: $(SRC)/conf.c $(SRC)/param.h
	cc -O -Dcf_a620=ipc -Dcf_a628=buffers -Dcf_ceac=rfdbuf -I$(SRC) -c $(SRC)/conf.c
sysent.o: $(SRC)/sysent.c $(SRC)/param.h
	cc -O -I$(SRC) -c $(SRC)/sysent.c
daten.o: $(SRC)/daten.c $(SRC)/param.h $(SRC)/proc.h
	cc -O -I$(SRC) -c $(SRC)/daten.c
