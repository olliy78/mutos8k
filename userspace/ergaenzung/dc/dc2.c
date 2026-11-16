/* Differs from V7: dc.c is split at function boundaries into dc1.c dc2.c dc3.c (original lines 576-1245); the guest cc/as hit
   'symbol table overflow' on the whole file.  Text unchanged otherwise, the three #include lines are repeated. */
#include <stdio.h>
/* Differs from V7: the MUTOS cc has unsigned char (PDP-11: signed); dc.h has a sign-extending variant of sgetc/slookc/sbackc for
   such machines (ifdef interdata), selected here. */
#define interdata 1
#include <signal.h>
#include "dc.h"
struct blk *
div(ddivd,ddivr)
struct blk *ddivd,*ddivr;
{
	int divsign,remsign,offset,divcarry;
	int carry, dig,magic,d,dd;
	long c,td,cc;
	struct blk *ps;
	register struct blk *p,*divd,*divr;

	rem = 0;
	p = salloc(0);
	if(length(ddivr) == 0){
		pushp(ddivr);
		errorrt("divide by 0\n");
	}
	divsign = remsign = 0;
	divr = ddivr;
	fsfile(divr);
	if(sbackc(divr) == -1){
		divr = copy(ddivr,length(ddivr));
		chsign(divr);
		divsign = ~divsign;
	}
	divd = copy(ddivd,length(ddivd));
	fsfile(divd);
	if(sfbeg(divd) == 0 && sbackc(divd) == -1){
		chsign(divd);
		divsign = ~divsign;
		remsign = ~remsign;
	}
	offset = length(divd) - length(divr);
	if(offset < 0)goto ddone;
	seekc(p,offset+1);
	sputc(divd,0);
	magic = 0;
	fsfile(divr);
	c = sbackc(divr);
	if(c<10)magic++;
	c = c*100 + (sfbeg(divr)?0:sbackc(divr));
	if(magic>0){
		c = (c*100 +(sfbeg(divr)?0:sbackc(divr)))*2;
		c /= 25;
	}
	while(offset >= 0){
		fsfile(divd);
		td = sbackc(divd)*100;
		dd = sfbeg(divd)?0:sbackc(divd);
		td = (td+dd)*100;
		dd = sfbeg(divd)?0:sbackc(divd);
		td = td+dd;
		cc = c;
		if(offset == 0)td += 1;
		else cc += 1;
		if(magic != 0)td = td<<3;
		dig = td/cc;
		rewind(divr);
		rewind(divxyz);
		carry = 0;
		while(sfeof(divr) == 0){
			d = sgetc(divr)*dig+carry;
			carry = d / 100;
			salterc(divxyz,d%100);
		}
		salterc(divxyz,carry);
		rewind(divxyz);
		seekc(divd,offset);
		carry = 0;
		while(sfeof(divd) == 0){
			d = slookc(divd);
			d = d-(sfeof(divxyz)?0:sgetc(divxyz))-carry;
			carry = 0;
			if(d < 0){
				d += 100;
				carry = 1;
			}
			salterc(divd,d);
		}
		divcarry = carry;
		sbackc(p);
		salterc(p,dig);
		sbackc(p);
		if(--offset >= 0)divd->wt--;
	}
	if(divcarry != 0){
		salterc(p,dig-1);
		salterc(divd,-1);
		ps = add(divr,divd);
		release(divd);
		divd = ps;
	}

	rewind(p);
	divcarry = 0;
	while(sfeof(p) == 0){
		d = slookc(p)+divcarry;
		divcarry = 0;
		if(d >= 100){
			d -= 100;
			divcarry = 1;
		}
		salterc(p,d);
	}
	if(divcarry != 0)salterc(p,divcarry);
	fsfile(p);
	while(sfbeg(p) == 0){
		if(sbackc(p) == 0)truncate(p);
		else break;
	}
	if(divsign < 0)chsign(p);
	fsfile(divd);
	while(sfbeg(divd) == 0){
		if(sbackc(divd) == 0)truncate(divd);
		else break;
	}
ddone:
	if(remsign<0)chsign(divd);
	if(divr != ddivr)release(divr);
	rem = divd;
	return(p);
}
dscale(){
	register struct blk *dd,*dr;
	register struct blk *r;
	int c;

	dr = pop();
	EMPTYS;
	dd = pop();
	EMPTYSR(dr);
	fsfile(dd);
	skd = sunputc(dd);
	fsfile(dr);
	skr = sunputc(dr);
	if(sfbeg(dr) == 1 || (sfbeg(dr) == 0 && sbackc(dr) == 0)){
		sputc(dr,skr);
		pushp(dr);
		errorrt("divide by 0\n");
	}
	c = k-skd+skr;
	if(c < 0)r = removr(dd,-c);
	else {
		r = add0(dd,c);
		irem = 0;
	}
	arg1 = r;
	arg2 = dr;
	savk = k;
	return(0);
}
struct blk *
removr(p,n)
struct blk *p;
{
	int nn;
	register struct blk *q,*s,*r;

	rewind(p);
	nn = (n+1)/2;
	q = salloc(nn);
	while(n>1){
		sputc(q,sgetc(p));
		n -= 2;
	}
	r = salloc(2);
	while(sfeof(p) == 0)sputc(r,sgetc(p));
	release(p);
	if(n == 1){
		s = div(r,tenptr);
		release(r);
		rewind(rem);
		if(sfeof(rem) == 0)sputc(q,sgetc(rem));
		release(rem);
		irem = q;
		return(s);
	}
	irem = q;
	return(r);
}
struct blk *
sqrt(p)
struct blk *p;
{
	struct blk *t;
	struct blk *r,*q,*s;
	int c,n,nn;

	n = length(p);
	fsfile(p);
	c = sbackc(p);
	if((n&1) != 1)c = c*100+(sfbeg(p)?0:sbackc(p));
	n = (n+1)>>1;
	r = salloc(n);
	zero(r);
	seekc(r,n);
	nn=1;
	while((c -= nn)>=0)nn+=2;
	c=(nn+1)>>1;
	fsfile(r);
	sbackc(r);
	if(c>=100){
		c -= 100;
		salterc(r,c);
		sputc(r,1);
	}
	else salterc(r,c);
	while(1){
		q = div(p,r);
		s = add(q,r);
		release(q);
		release(rem);
		q = div(s,sqtemp);
		release(s);
		release(rem);
		s = copy(r,length(r));
		chsign(s);
		t = add(s,q);
		release(s);
		fsfile(t);
		nn = sfbeg(t)?0:sbackc(t);
		if(nn>=0)break;
		release(r);
		release(t);
		r = q;
	}
	release(t);
	release(q);
	release(p);
	return(r);
}
struct blk *
exp(base,ex)
struct blk *base,*ex;
{
	register struct blk *r,*e,*p;
	struct blk *e1,*t,*cp;
	int temp,c,n;
	r = salloc(1);
	sputc(r,1);
	p = copy(base,length(base));
	e = copy(ex,length(ex));
	fsfile(e);
	if(sfbeg(e) != 0)goto edone;
	temp=0;
	c = sbackc(e);
	if(c<0){
		temp++;
		chsign(e);
	}
	while(length(e) != 0){
		e1=div(e,sqtemp);
		release(e);
		e = e1;
		n = length(rem);
		release(rem);
		if(n != 0){
			e1=mult(p,r);
			release(r);
			r = e1;
		}
		t = copy(p,length(p));
		cp = mult(p,t);
		release(p);
		release(t);
		p = cp;
	}
	if(temp != 0){
		if((c = length(base)) == 0){
			goto edone;
		}
		if(c>1)create(r);
		else{
			rewind(base);
			if((c = sgetc(base))<=1){
				create(r);
				sputc(r,c);
			}
			else create(r);
		}
	}
edone:
	release(p);
	release(e);
	return(r);
}
init(argc,argv)
int argc;
char *argv[];
{
	register struct sym *sp;

	if (signal(SIGINT, SIG_IGN) != SIG_IGN)
		signal(SIGINT,onintr);
	setbuf(stdout,(char *)NULL);
	svargc = --argc;
	svargv = argv;
	while(svargc>0 && svargv[1][0] == '-'){
		switch(svargv[1][1]){
		default:
			dbg=1;
		}
		svargc--;
		svargv++;
	}
	ifile=1;
	if(svargc<=0)curfile = stdin;
	else if((curfile = fopen(svargv[1],"r")) == NULL){
		printf("can't open file %s\n",svargv[1]);
		exit(1);
		}
	dummy = malloc(1);
	scalptr = salloc(1);
	sputc(scalptr,0);
	basptr = salloc(1);
	sputc(basptr,10);
	obase=10;
	log10=log2(10L);
	ll=70;
	fw=1;
	fw1=0;
	tenptr = salloc(1);
	sputc(tenptr,10);
	obase=10;
	inbas = salloc(1);
	sputc(inbas,10);
	sqtemp = salloc(1);
	sputc(sqtemp,2);
	chptr = salloc(0);
	strptr = salloc(0);
	divxyz = salloc(0);
	stkbeg = stkptr = &stack[0];
	stkend = &stack[STKSZ];
	stkerr = 0;
	readptr = &readstk[0];
	k=0;
	sp = sptr = &symlst[0];
	while(sptr < &symlst[TBLSZ]){
		sptr->next = ++sp;
		sptr++;
	}
	sptr->next=0;
	sfree = &symlst[0];
	return;
}
onintr(){

	signal(SIGINT,onintr);
	while(readptr != &readstk[0]){
		if(*readptr != 0){release(*readptr);}
		readptr--;
	}
	curfile = stdin;
	commnds();
}
pushp(p)
struct blk *p;
{
	if(stkptr == stkend){
		printf("out of stack space\n");
		return;
	}
	stkerr=0;
	*++stkptr = p;
	return;
}
struct blk *
pop(){
	if(stkptr == stack){
		stkerr=1;
		return(0);
	}
	return(*stkptr--);
}
struct blk *
readin(){
	register struct blk *p,*q;
	int dp,dpct;
	register int c;

	dp = dpct=0;
	p = salloc(0);
	while(1){
		c = readc();
		switch(c){
		case '.':
			if(dp != 0){
				unreadc(c);
				break;
			}
			dp++;
			continue;
		case '\\':
			readc();
			continue;
		default:
			if(c >= 'A' && c <= 'F')c = c - 'A' + 10;
			else if(c >= '0' && c <= '9')c -= '0';
			else goto gotnum;
			if(dp != 0){
				if(dpct >= 99)continue;
				dpct++;
			}
			create(chptr);
			if(c != 0)sputc(chptr,c);
			q = mult(p,inbas);
			release(p);
			p = add(chptr,q);
			release(q);
		}
	}
gotnum:
	unreadc(c);
	if(dp == 0){
		sputc(p,0);
		return(p);
	}
	else{
		q = scale(p,dpct);
		return(q);
	}
}
struct blk *
add0(p,ct)
int ct;
struct blk *p;
{
		/* returns pointer to struct with ct 0's & p */
	register struct blk *q,*t;

	q = salloc(length(p)+(ct+1)/2);
	while(ct>1){
		sputc(q,0);
		ct -= 2;
	}
	rewind(p);
	while(sfeof(p) == 0){
		sputc(q,sgetc(p));
	}
	release(p);
	if(ct == 1){
		t = mult(tenptr,q);
		release(q);
		return(t);
	}
	return(q);
}
struct blk *
mult(p,q)
struct blk *p,*q;
{
	register struct blk *mp,*mq,*mr;
	int sign,offset,carry;
	int cq,cp,mt,mcr;

	offset = sign = 0;
	fsfile(p);
	mp = p;
	if(sfbeg(p) == 0){
		if(sbackc(p)<0){
			mp = copy(p,length(p));
			chsign(mp);
			sign = ~sign;
		}
	}
	fsfile(q);
	mq = q;
	if(sfbeg(q) == 0){
		if(sbackc(q)<0){
			mq = copy(q,length(q));
			chsign(mq);
			sign = ~sign;
		}
	}
	mr = salloc(length(mp)+length(mq));
	zero(mr);
	rewind(mq);
	while(sfeof(mq) == 0){
		cq = sgetc(mq);
		rewind(mp);
		rewind(mr);
		mr->rd += offset;
		carry=0;
		while(sfeof(mp) == 0){
			cp = sgetc(mp);
			mcr = sfeof(mr)?0:slookc(mr);
			mt = cp*cq + carry + mcr;
			carry = mt/100;
			salterc(mr,mt%100);
		}
		offset++;
		if(carry != 0){
			mcr = sfeof(mr)?0:slookc(mr);
			salterc(mr,mcr+carry);
		}
	}
	if(sign < 0){
		chsign(mr);
	}
	if(mp != p)release(mp);
	if(mq != q)release(mq);
	return(mr);
}
chsign(p)
struct blk *p;
{
	register int carry;
	register char ct;

	carry=0;
	rewind(p);
	while(sfeof(p) == 0){
		ct=100-slookc(p)-carry;
		carry=1;
		if(ct>=100){
			ct -= 100;
			carry=0;
		}
		salterc(p,ct);
	}
	if(carry != 0){
		sputc(p,-1);
		fsfile(p);
		sbackc(p);
		ct = sbackc(p);
		if(ct == 99){
			truncate(p);
			sputc(p,-1);
		}
	}
	else{
		fsfile(p);
		ct = sbackc(p);
		if(ct == 0)truncate(p);
	}
	return;
}
readc(){
loop:
	if((readptr != &readstk[0]) && (*readptr != 0)){
		if(sfeof(*readptr) == 0)return(lastchar = sgetc(*readptr));
		release(*readptr);
		readptr--;
		goto loop;
	}
	lastchar = getc(curfile);
	if(lastchar != EOF)return(lastchar);
	if(readptr != &readptr[0]){
		readptr--;
		if(*readptr == 0)curfile = stdin;
		goto loop;
	}
	if(curfile != stdin){
		fclose(curfile);
		curfile = stdin;
		goto loop;
	}
	exit(0);
}
unreadc(c)
char c;
{

	if((readptr != &readstk[0]) && (*readptr != 0)){
		sungetc(*readptr,c);
	}
	else ungetc(c,curfile);
	return;
}
binop(c)
char c;
{
	register struct blk *r;

	switch(c){
	case '+':
		r = add(arg1,arg2);
		break;
	case '*':
		r = mult(arg1,arg2);
		break;
	case '/':
		r = div(arg1,arg2);
		break;
	}
	release(arg1);
	release(arg2);
	sputc(r,savk);
	pushp(r);
	return;
}
print(hptr)
struct blk *hptr;
{
	int sc;
	register struct blk *p,*q,*dec;
	int dig,dout,ct;

	rewind(hptr);
	while(sfeof(hptr) == 0){
		if(sgetc(hptr)>99){
			rewind(hptr);
			while(sfeof(hptr) == 0){
				printf("%c",sgetc(hptr));
			}
			printf("\n");
			return;
		}
	}
	fsfile(hptr);
	sc = sbackc(hptr);
	if(sfbeg(hptr) != 0){
		printf("0\n");
		return;
	}
	count = ll;
	p = copy(hptr,length(hptr));
	sunputc(p);
	fsfile(p);
	if(sbackc(p)<0){
		chsign(p);
		OUTC('-');
	}
	if((obase == 0) || (obase == -1)){
		oneot(p,sc,'d');
		return;
	}
	if(obase == 1){
		oneot(p,sc,'1');
		return;
	}
	if(obase == 10){
		tenot(p,sc);
		return;
	}
	create(strptr);
	dig = log10*sc;
	dout = ((dig/10) + dig) /logo;
	dec = getdec(p,sc);
	p = removc(p,sc);
	while(length(p) != 0){
		q = div(p,basptr);
		release(p);
		p = q;
		(*outdit)(rem,0);
	}
	release(p);
	fsfile(strptr);
	while(sfbeg(strptr) == 0)OUTC(sbackc(strptr));
	if(sc == 0){
		release(dec);
		printf("\n");
		return;
	}
	create(strptr);
	OUTC('.');
	ct=0;
	do{
		q = mult(basptr,dec);
		release(dec);
		dec = getdec(q,sc);
		p = removc(q,sc);
		(*outdit)(p,1);
	}while(++ct < dout);
	release(dec);
	rewind(strptr);
	while(sfeof(strptr) == 0)OUTC(sgetc(strptr));
	printf("\n");
	return;
}
