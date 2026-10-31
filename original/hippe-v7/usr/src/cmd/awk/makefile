# If you don't want the small version of awk remove the definition of 'SMALL'.
# If you have floating point hardware remove the definition of 'FLOAT'.
# If you have separate I+D space set 'SEP = -i'.

SMALL=-DSMALLAWK
FLOAT=-f
SEP=
CFLAGS=$(SMALL) $(FLOAT) -O
YFLAGS=-d

all:	awk

cp:	awk
	cp awk /bin/awk
	rm *.o awk.h proc awk proctab.c y.tab.h

cmp:	awk
	cmp awk /bin/awk
	rm *.o awk.h proc awk proctab.c y.tab.h

FILES1=awk.lx.o b.o main.o
FILES2=tran.o lib.o run.o parse.o proctab.o
SOURCE=awk.def awk.g.y awk.lx.l b.c lib.c main.c parse.c proctab.c \
	proc.c\
	run.c token.c tran.c

awk:	$(FILES1) $(FILES2) awk.g.o
	cc -c -O $(CFLAGS) token.c
	cc $(SEP) -s $(CFLAGS) awk.g.o $(FILES1) token.o $(FILES2) -lm -o awk

y.tab.h:	awk.g.o

awk.h:	y.tab.h
	-cmp -s y.tab.h awk.h || cp y.tab.h awk.h

$(FILES1):	awk.h awk.def
$(FILES2):	awk.h awk.def

token.c:	awk.h
	ed - <tokenscript
	rm temp

src:	$(SOURCE) test.a tokenscript makefile
	cp $? /usr/src/cmd/awk
	touch src

profile:	awk.g.o $(FILES1) token.o $(FILES2)
	cc -p $(SEP) awk.g.o $(FILES1) token.o $(FILES2) -lm

find:
	egrep -n "$(PAT)" *.[ylhc] awk.def

list:
	-pr $(SOURCE) makefile

lint:
	lint -spu b.c main.c token.c tran.c run.c lib.c parse.c -lm |\
		egrep -v '^(error|free|malloc)'

proctab.c:	proc
	proc > proctab.c
proc:
	cc -DDEBUG -o proc proc.c token.c
