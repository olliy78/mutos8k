! RECONSTRUCTED (W8): text and data of the shipped libc.a member as data words (no source with these instructions), labels from its symbol table !
fltpr_ module
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
X	csv	PR;
X	cret	PR;
X	_gcvt	PR;
X	_fcvt	PR;
X	_ecvt	PR;
G	pfloat	L
G	pscien	L
G	pgen	PR
E
pgen:
	WV	%93FA
	WV	%93FB
	WV	%8DB4
	WV	%EE02
	WV	%DF5
	WV	%6
$1:
	WV	%FD4
	WV	%8003
	WV	%A9D7
	WV	%ABF7
	WV	%FFC
	WV	%8003
	WV	%5F00
	WV	_gcvt
	WV	%A9FB
$2:
	WV	%CA4
	WV	%9E06
	WV	%A9A0
	WV	%E8FC
pfloat:
	WV	%DF9
	WV	sign
	WV	%DF9
	WV	decpt
	WV	%8D94
	WV	%EE01
	WV	%BDB6
$4:
	WV	%93FB
	WV	%FD4
	WV	%8003
	WV	%A9D7
	WV	%ABF7
	WV	%FFC
	WV	%8003
	WV	%5F00
	WV	_fcvt
	WV	%A9FD
	WV	%4D04
	WV	sign
	WV	%E603
	WV	%CA5
	WV	%2D2D
	WV	%A9A0
$5:
	WV	%6101
	WV	decpt
	WV	%A114
	WV	%8D44
	WV	%EA03
	WV	%CA5
	WV	%3030
	WV	%A9A0
$6:
	WV	%8D44
	WV	%E205
$8:
	WV	%2023
	WV	%2EA3
	WV	%A920
	WV	%A9A0
	WV	%F185
$7:
	WV	%8DB4
	WV	%E603
	WV	%CA5
	WV	%2E2E
	WV	%A9A0
$9:
	WV	%8D42
	WV	%E206
$11:
	WV	%ABB0
	WV	%E104
	WV	%CA5
	WV	%3030
	WV	%A9A0
	WV	%F486
$12:
	WV	%8DB4
	WV	%E205
$13:
	WV	%2023
	WV	%2EA3
	WV	%A9A0
	WV	%A920
	WV	%FB85
$14:
	WV	%9E08
pscien:
	WV	%DF9
	WV	sign
	WV	%DF9
	WV	decpt
	WV	%93FB
	WV	%8D94
	WV	%EE02
	WV	%DF5
	WV	%6
$15:
	WV	%FD4
	WV	%8003
	WV	%A9D7
	WV	%ABF7
	WV	%FFC
	WV	%8003
	WV	%5F00
	WV	_ecvt
	WV	%A9FD
	WV	%4D04
	WV	sign
	WV	%E603
	WV	%CA5
	WV	%2D2D
	WV	%A9A0
$16:
	WV	%C21
	WV	%3030
	WV	%EE02
	WV	%6900
	WV	decpt
$17:
	WV	%2023
	WV	%2EA3
	WV	%A920
	WV	%4CA5
	WV	%1
	WV	%2E2E
	WV	%A9A1
	WV	%A1B1
	WV	%AB10
	WV	%E205
$18:
	WV	%2023
	WV	%2EA3
	WV	%A920
	WV	%A9A0
	WV	%F185
$19:
	WV	%CA5
	WV	%6565
	WV	%A9A0
	WV	%6103
	WV	decpt
	WV	%AB30
	WV	%E905
	WV	%CA5
	WV	%2D2D
	WV	%A9A0
	WV	%8D32
	WV	%E803
$20:
	WV	%CA5
	WV	%2B2B
	WV	%A9A0
$21:
	WV	%B03
	WV	%64
	WV	%E108
	WV	%8922
	WV	%1B02
	WV	%64
	WV	%103
	WV	%30
	WV	%2EAB
	WV	%A9A0
	WV	%A123
$22:
	WV	%8922
	WV	%1B02
	WV	%A
	WV	%103
	WV	%30
	WV	%2EAB
	WV	%102
	WV	%30
	WV	%6EAA
	WV	%1
	WV	%A9A1
	WV	%9E08
end pgen
I
G
sign	L
sign:
I
WV	%0
G
decpt	L
decpt:
I
WV	%0
end fltpr_
