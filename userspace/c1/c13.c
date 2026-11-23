/*
 * C second pass -- tables
 */
#include "c1.h"
/*
 * Operator dope table-- see description in c0.
 */
int opdope[] {
	000000,	/* EOFC */
	000000,	/* ; */
	000000,	/* { */
	000000,	/* } */
	036000,	/* [ */
	002000,	/* ] */
	036000,	/* ( */
	002000,	/* ) */
	014201,	/* : */
	007001,	/* , */
	000000,	/* field selection */
	000000,	/* reverse field selection */
	000001,	/* temporary field selection */
	000001,	/* int->ptr */
	000001,	/* ptr->int */
	000001,	/* long->ptr */
	000001,	/* field assignment */
	000001,	/* >> unsigned */
	000001,	/* >> unsigned */
	000000,	/* 19 */
	000400,	/* name */
	000400,	/* short constant */
	000400,	/* string */
	000400,	/* float */
	000400,	/* double */
	0000400,	/* long const */
	000400,	/* long const <= 16 bits */
	012253,	/* >>= unsigned (V7: autoi; opntab name, *Annahme*) */
	012253,	/* <<= unsigned (V7: autod) */
	000000,	/* 29 */
	034203,	/* ++pre */
	034203,	/* --pre */
	034203,	/* ++post */
	034203,	/* --post */
	034220,	/* !un */
	034202,	/* &un */
	034220,	/* *un */
	034200,	/* -un */
	034220,	/* ~un */
	036001,	/* . (structure reference) */
	030101,	/* + */
	030001,	/* - */
	032101,	/* * */
	032001,	/* / */
	032001,	/* % */
	026061,	/* >> */
	026061,	/* << */
	020161,	/* & */
	016161,	/* | */
	016161,	/* ^ */
	036001,	/* -> */
	001000,	/* int -> double */
	001000,	/* double -> int */
	000001,	/* && */
	000001,	/* || */
	030001, /* &~ */
	001000,	/* double -> long */
	001000,	/* long -> double */
	001000,	/* integer -> long */
	000000,	/* long -> integer */
	022005,	/* == */
	022005,	/* != */
	024005,	/* <= */
	024005,	/* < */
	024005,	/* >= */
	024005,	/* > */
	024005,	/* <p */
	024005,	/* <=p */
	024005,	/* >p */
	024005,	/* >=p */
	012213,	/* =+ */
	012213,	/* =- */
	012213,	/* =* */
	012213,	/* =/ */
	012213,	/* =% */
	012253,	/* =>> */
	012253,	/* =<< */
	012253,	/* =& */
	012253,	/* =| */
	012253,	/* =^ */
	012213,	/* = */
	016161,	/* bitset (V7: & for tests); names from opntab, meaning *Annahme* */
	020161,	/* bitclr */
	012253,	/* bitset= */
	012253,	/* bitclr= */
	020161,	/* bittest */
	000000,	/* 86 */
	000000,	/* 87 */
	000000,	/* 88 */
	000000,	/* 89 */
	014201,	/* ? */
	000000,	/* 91 */
	000000,	/* 92 */
	000101,	/* max */
	000101,	/* maxp */
	000101,	/* min */
	000101,	/* minp */
	000001,	/* , */
	000000,	/* 98 */
	000000,	/* 99 */
	036001,	/* call */
	036000,	/* mcall */
	000000,	/* goto */
	000000,	/* jump cond */
	000000,	/* branch cond */
	000400,	/* set nregs */
	000000, /* 106 */
	000001,	/* >> unsigned (ZRSH) */
	000001,	/* << unsigned (ZLSH) */
	000000,	/* int->char */
	000000,	/* force r0 */
	000000,	/* 111 */
	000000,	/* 112 */
	000000,	/* 113 */
	000000,	/* 114 */
	000000,	/* structure assign */
	000001,	/* struct assignment setup */
	000000,	/* 117 */
	000000,	/* 118 */
	000000,	/* 119 */
	000000,	/* 120 */
	000000,	/* 121 */
	000000,	/* 122 */
	000000,	/* 123 */
	000000,	/* 124 */
	000000,	/* 125 */
	000000,	/* 126 */
	000000,	/* 127 */
	000000,	/* 128 */
	000000,	/* 129 */
	000000,	/* 130 */
	000000,	/* 131 */
	000000,	/* 132 */
	000000,	/* 133 */
	000000,	/* 134 */
	000000,	/* 135 */
	000000,	/* 136 */
	012253,	/* >>= unsigned (ASZRSH) */
	012253,	/* <<= unsigned (ASZLSH) */
};

char	*opntab[] {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	":",
	",",
	"field select",
	0,
	0,
	"int->ptr",
	"ptr->int",
	"long->ptr",
	"field assign",
	">> unsigned",
	"<< unsigned",
	0,
	"name",
	"short constant",
	"string",
	"float",
	"double",
	"long constant",
	"long constant",
	">>= unsigned",
	"<<= unsigned",
	"indirection",
	"++pre",
	"--pre",
	"++post",
	"--post",
	"!un",
	"&",
	"*",
	"-",
	"~",
	".",
	"+",
	"-",
	"*",
	"/",
	"%",
	">>",
	"<<",
	"&",
	"|",
	"^",
	"->",
	"int->double",
	"double->int",
	"&&",
	"||",
	"&~",
	"double->long",
	"long->double",
	"integer->long",
	"long->integer",
	"==",
	"!=",
	"<=",
	"<",
	">=",
	">",
	"<p",
	"<=p",
	">p",
	">=p",
	"+=",
	"-=",
	"*=",
	"/=",
	"%=",
	">>=",
	"<<=",
	"&=",
	"|=",
	"^=",
	"=",
	"bitset",
	"bitclr",
	"bitset=",
	"bitclr=",
	"bittest",
	0,
	0,
	0,
	"load byte register",
	"?",
	0,
	0,
	"\\/",
	"\\/",
	"/\\",
	"/\\",
	0,
	0,
	"call",
	"call",
	0,
	"goto",
	"jump cond",
	"branch cond",
	"set nregs",
	"load value",
	">>unsigned",
	"<<unsigned",
	"int->char",
	"force register",
	"",
	"",
	"",
	"",
	"=structure",
	"= (struct setup)",
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	">>=unsigned",
	"<<=unsigned",
};

/*
 * Strings for instruction tables.
 * Not V7: Z8000 mnemonics instead of PDP-11 ones.  The names of the
 * variables are lost with the original (Annahme: z_ prefix, so that they
 * cannot collide with struct members); order, contents and padding are
 * measured from the original data (c1 data at 83B4..8470).
 * "sdal" and "jpl"/"jmi" are not referenced by any table (as in the original).
 */
char	z_ld[]	"ld";
char	z_clr[]	"clr";
char	z_cp[]	"cp";
char	z_test[]	"test";
char	z_add[]	"add";
char	z_sub[]	"sub";
char	z_inc[]	"inc";
char	z_dec[]	"dec";
char	z_mul[]	"mul";
char	z_div[]	"div";
char	z_sra[]	"sra";
char	z_sda[]	"sda";
char	z_sla[]	"sla";
char	z_sdl[]	"sdl";
char	z_srl[]	"srl";
char	z_sll[]	"sll";
char	z_one[]	"#1";
char	z_and[]	"and";
char	z_or[]	"or";
char	z_set[]	"set";
char	z_res[]	"res";
char	z_xor[]	"xor";
char	z_neg[]	"neg";
char	z_com[]	"com";
char	z_sdal[]	"sdal";
char	z_jeq[]	"jp\teq";
char	z_jne[]	"jp\tne";
char	z_jle[]	"jp\tle";
char	z_jgt[]	"jp\tgt";
char	z_jlt[]	"jp\tlt";
char	z_jge[]	"jp\tge";
char	z_jule[]	"jp\tule";
char	z_jugt[]	"jp\tugt";
char	z_jc[]	"jp\tc";
char	z_juge[]	"jp\tuge";
char	z_jpl[]	"jp\tpl";
char	z_jmi[]	"jp\tmi";
char	z_nop[]	"!nop";
char	z_jbr[]	"jp";

/*
 * Instruction tables, accessed by
 * I (first operand) or I' (second) macros.
 * Not V7: the Z8000 table (measured from the original data at 8470..8594).
 * Operators 81..84 (TAND, LTIMES, LDIV, LMOD in V7) are bit set/clear
 * operators here (see opntab; names *Annahme*).
 */
struct instab instab[] {
	LOAD,	z_ld,	z_test,
	ASSIGN,	z_ld,	z_clr,
	EQUAL,	z_cp,	z_test,
	NEQUAL,	z_cp,	z_test,
	LESSEQ,	z_cp,	z_test,
	LESS,	z_cp,	z_test,
	GREATEQ,	z_cp,	z_test,
	GREAT,	z_cp,	z_test,
	LESSEQP,	z_cp,	z_test,
	LESSP,	z_cp,	z_test,
	GREATQP,	z_cp,	z_test,
	GREATP,	z_cp,	z_test,
	PLUS,	z_add,	z_inc,
	ASPLUS,	z_add,	z_inc,
	MINUS,	z_sub,	z_dec,
	ASMINUS,	z_sub,	z_dec,
	INCBEF,	z_add,	z_inc,
	DECBEF,	z_sub,	z_dec,
	INCAFT,	z_add,	z_inc,
	DECAFT,	z_sub,	z_dec,
	TIMES,	z_mul,	z_mul,
	ASTIMES,	z_mul,	z_mul,
	DIVIDE,	z_div,	z_div,
	ASDIV,	z_div,	z_div,
	MOD,	z_div,	z_div,
	ASMOD,	z_div,	z_div,
	PTOI,	z_div,	z_div,
	RSHIFT,	z_sda,	z_sra,
	ASRSH,	z_sda,	z_sra,
	LSHIFT,	z_sda,	z_sla,
	ASLSH,	z_sda,	z_sla,
	ZRSH,	z_sdl,	z_srl,
	ZLSH,	z_sdl,	z_sll,
	ASZRSH,	z_sdl,	z_srl,
	ASZLSH,	z_sdl,	z_sll,
	AND,	z_and,	z_one,
	ASAND,	z_and,	z_one,
	OR,	z_or,	z_one,
	ASOR,	z_or,	z_one,
	TAND,	z_set,	z_set,
	LDIV,	z_set,	z_set,
	LTIMES,	z_res,	z_res,
	LMOD,	z_res,	z_res,
	EXOR,	z_xor,	z_xor,
	ASXOR,	z_xor,	z_xor,
	NEG,	z_neg,	z_neg,
	COMPL,	z_com,	z_com,
	0,	0,	0};

/*
 * Similar table for relationals.
 * The first string is for the positive
 * test, the second for the inverted one.
 * The '200+' entries are used in tests against 0.
 */
struct instab branchtab[] {
	EQUAL,	z_jeq,	z_jne,
	NEQUAL,	z_jne,	z_jeq,
	LESSEQ,	z_jle,	z_jgt,
	LESS,	z_jlt,	z_jge,
	GREATEQ,	z_jge,	z_jlt,
	GREAT,	z_jgt,	z_jle,
	LESSEQP,	z_jule,	z_jugt,
	LESSP,	z_jc,	z_juge,
	GREATQP,	z_juge,	z_jc,
	GREATP,	z_jugt,	z_jule,
	200+EQUAL,	z_jeq,	z_jne,
	200+NEQUAL,	z_jne,	z_jeq,
	200+LESSEQ,	z_jle,	z_jgt,
	200+LESS,	z_jlt,	z_jge,
	200+GREATEQ,	z_jge,	z_jlt,
	200+GREAT,	z_jgt,	z_jle,
	200+LESSEQP,	z_jeq,	z_jne,
	200+LESSP,	z_nop,	z_jbr,
	200+GREATQP,	z_jbr,	z_nop,
	200+GREATP,	z_jne,	z_jeq,
	0,	0,	0 };
