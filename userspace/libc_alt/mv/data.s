data_ module
$NONSEGMENTED
constant
	FP	:= r14
	SP	:= r15
	X	:= external
	G	:= global
	I	:= internal
	A	:= array
	PR	:= procedure
	E	:= entry
	B	:= byte
	W	:= word
	BV	:= bval
	WV	:= wval
	LV	:= lval
	L	:= label
$SECTION BSS_B
X	__sibuf	A[%200 B]
X	__sobuf	A[%200 B]
$SDEFAULT
I
G
__iob	L
__iob:
BV %1A;BV %E0;BV %0;BV %0;BV %1A;BV %E0;BV %1;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %2;BV %1
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %6;BV %2
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0;BV %0
D1AA0:
G
__lastbu	L
__lastbu:
WV __lastbu
end data_
