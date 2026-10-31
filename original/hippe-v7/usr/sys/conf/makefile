# set `M' to the machine assist required, `smch', `m40' or `mch'
# set `SEPID = -i' if you have it and only if using 'mch'
M = m40
SEPID=

unix:	l.o $(M).o c.o ../sys/LIB1 ../dev/LIB2
	ld -o unix -X $(SEPID) l.o $(M).o c.o ../sys/LIB1 ../dev/LIB2
	@size unix

LIB12:
	cd ../sys; mklib
	cd ../dev; mklib

smch.o:	smch.s
	as -o smch.o smch.s

m40.o:	m40.s
	as -o m40.o m40.s

mch.o:	mch.s
	as -o mch.o mch.s

smch.s:	m.h smch.c
	cc -P smch.c; mv smch.i smch.s

mch.s:	m.h mch.c
	cc -P mch.c; mv mch.i mch.s

l.s c.c: m.h ../h/*.h conf
	mkconf $(SEPID) conf

all:	LIB12 rk rl1 rl2

rk:
	mkconf $(SEPID) rkconf
	make unix
	mv unix rkunix

rl1:
	mkconf $(SEPID) rl1conf
	make unix
	mv unix rl1unix

rl2:
	mkconf $(SEPID) rl2conf
	make unix
	mv unix rl2unix

hk6:
	@echo Have you recompiled system and standalone hk drivers for this!!!
	mkconf $(SEPID) hk6conf
	make unix
	mv unix hk6unix

hk7:
	mkconf $(SEPID) hk7conf
	make unix
	mv unix hk7unix

clean:
	@rm -f l.s l.o c.c c.o smch.s mch.s smch.o m40.o mch.o

tests:
	cd test; run *.s
