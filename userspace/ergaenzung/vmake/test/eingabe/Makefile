NAME = world
GREET = hello $(NAME)
.SUFFIXES: .sa .sb
.sa.sb:
	cat $< >$@

all: prog data.sb
	cat prog data.sb
prog: obj1 obj2
	cat obj1 obj2 >prog
obj1:
	cat s1.sa >obj1
obj2:
	cat s2.sa >obj2
data.sb:
list: s1.sa s2.sa
	cat $? >$@
show:
	cat $(GREET)
	@cat quiet
	-cat nofile
bad:
	sh ex3
	cat s2.sa
badi:
	-sh ex3
	cat s1.sa
