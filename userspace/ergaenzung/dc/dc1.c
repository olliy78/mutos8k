/* Differs from V7: dc.c is split at function boundaries into dc1.c dc2.c dc3.c (original lines 4-575); the guest cc/as hit
   'symbol table overflow' on the whole file.  Text unchanged otherwise, the three #include lines are repeated. */
#include <stdio.h>
/* Differs from V7: the MUTOS cc has unsigned char (PDP-11: signed); dc.h has a sign-extending variant of sgetc/slookc/sbackc for
   such machines (ifdef interdata), selected here. */
#define interdata 1
#include <signal.h>
#include "dc.h"
main(argc,argv)
int argc;
char *argv[];
{
	init(argc,argv);
	commnds();
}
commnds(){
	register int c;
	register struct blk *p,*q;
	long l;
	int sign;
	struct blk **ptr,*s,*t;
	struct sym *sp;
	int sk,sk1,sk2;
	int n,d;

	while(1){
		if(((c = readc())>='0' && c <= '9')|| (c>='A' && c <='F') || c == '.'){
			unreadc(c);
			p = readin();
			pushp(p);
			continue;
		}
		switch(c){
		case ' ':
		case '\n':
		case 0377:
		case EOF:
			continue;
		case 'Y':
			sdump("stk",*stkptr);
			printf("all %ld rel %ld headmor %ld\n",all,rel,headmor);
			printf("nbytes %ld\n",nbytes);
			continue;
		case '_':
			p = readin();
			savk = sunputc(p);
			chsign(p);
			sputc(p,savk);
			pushp(p);
			continue;
		case '-':
			subt();
			continue;
		case '+':
			if(eqk() != 0)continue;
			binop('+');
			continue;
		case '*':
			arg1 = pop();
			EMPTY;
			arg2 = pop();
			EMPTYR(arg1);
			sk1 = sunputc(arg1);
			sk2 = sunputc(arg2);
			binop('*');
			p = pop();
			sunputc(p);
			savk = sk1+sk2;
			if(savk>k && savk>sk1 && savk>sk2){
				sk = sk1;
				if(sk<sk2)sk = sk2;
				if(sk<k)sk = k;
				p = removc(p,savk-sk);
				savk = sk;
			}
			sputc(p,savk);
			pushp(p);
			continue;
		case '/':
casediv:
			if(dscale() != 0)continue;
			binop('/');
			if(irem != 0)release(irem);
			release(rem);
			continue;
		case '%':
			if(dscale() != 0)continue;
			binop('/');
			p = pop();
			release(p);
			if(irem == 0){
				sputc(rem,skr+k);
				pushp(rem);
				continue;
			}
			p = add0(rem,skd-(skr+k));
			q = add(p,irem);
			release(p);
			release(irem);
			sputc(q,skd);
			pushp(q);
			continue;
		case 'v':
			p = pop();
			EMPTY;
			savk = sunputc(p);
			if(length(p) == 0){
				sputc(p,savk);
				pushp(p);
				continue;
			}
			if((c = sbackc(p))<0){
				error("sqrt of neg number\n");
			}
			if(k<savk)n = savk;
			else{
				n = k*2-savk;
				savk = k;
			}
			arg1 = add0(p,n);
			arg2 = sqrt(arg1);
			sputc(arg2,savk);
			pushp(arg2);
			continue;
		case '^':
			neg = 0;
			arg1 = pop();
			EMPTY;
			if(sunputc(arg1) != 0)error("exp not an integer\n");
			arg2 = pop();
			EMPTYR(arg1);
			if(sfbeg(arg1) == 0 && sbackc(arg1)<0){
				neg++;
				chsign(arg1);
			}
			if(length(arg1)>=3){
				error("exp too big\n");
			}
			savk = sunputc(arg2);
			p = exp(arg2,arg1);
			release(arg2);
			rewind(arg1);
			c = sgetc(arg1);
			if(sfeof(arg1) == 0)
				c = sgetc(arg1)*100 + c;
			d = c*savk;
			release(arg1);
			if(neg == 0){
				if(k>=savk)n = k;
				else n = savk;
				if(n<d){
					q = removc(p,d-n);
					sputc(q,n);
					pushp(q);
				}
				else {
					sputc(p,d);
					pushp(p);
				}
			}
			else {
				sputc(p,d);
				pushp(p);
			}
			if(neg == 0)continue;
			p = pop();
			q = salloc(2);
			sputc(q,1);
			sputc(q,0);
			pushp(q);
			pushp(p);
			goto casediv;
		case 'z':
			p = salloc(2);
			n = stkptr - stkbeg;
			if(n >= 100){
				sputc(p,n/100);
				n %= 100;
			}
			sputc(p,n);
			sputc(p,0);
			pushp(p);
			continue;
		case 'Z':
			p = pop();
			EMPTY;
			n = (length(p)-1)<<1;
			fsfile(p);
			sbackc(p);
			if(sfbeg(p) == 0){
				if((c = sbackc(p))<0){
					n -= 2;
					if(sfbeg(p) == 1)n += 1;
					else {
						if((c = sbackc(p)) == 0)n += 1;
						else if(c > 90)n -= 1;
					}
				}
				else if(c < 10) n -= 1;
			}
			release(p);
			q = salloc(1);
			if(n >= 100){
				sputc(q,n%100);
				n /= 100;
			}
			sputc(q,n);
			sputc(q,0);
			pushp(q);
			continue;
		case 'i':
			p = pop();
			EMPTY;
			p = scalint(p);
			release(inbas);
			inbas = p;
			continue;
		case 'I':
			p = copy(inbas,length(inbas)+1);
			sputc(p,0);
			pushp(p);
			continue;
		case 'o':
			p = pop();
			EMPTY;
			p = scalint(p);
			sign = 0;
			n = length(p);
			q = copy(p,n);
			fsfile(q);
			l = c = sbackc(q);
			if(n != 1){
				if(c<0){
					sign = 1;
					chsign(q);
					n = length(q);
					fsfile(q);
					l = c = sbackc(q);
				}
				if(n != 1){
					while(sfbeg(q) == 0)l = l*100+sbackc(q);
				}
			}
			logo = log2(l);
			obase = l;
			release(basptr);
			if(sign == 1)obase = -l;
			basptr = p;
			outdit = bigot;
			if(n == 1 && sign == 0){
				if(c <= 16){
					outdit = hexot;
					fw = 1;
					fw1 = 0;
					ll = 70;
					release(q);
					continue;
				}
			}
			n = 0;
			if(sign == 1)n++;
			p = salloc(1);
			sputc(p,-1);
			t = add(p,q);
			n += length(t)*2;
			fsfile(t);
			if((c = sbackc(t))>9)n++;
			release(t);
			release(q);
			release(p);
			fw = n;
			fw1 = n-1;
			ll = 70;
			if(fw>=ll)continue;
			ll = (70/fw)*fw;
			continue;
		case 'O':
			p = copy(basptr,length(basptr)+1);
			sputc(p,0);
			pushp(p);
			continue;
		case '[':
			n = 0;
			p = salloc(0);
			while(1){
				if((c = readc()) == ']'){
					if(n == 0)break;
					n--;
				}
				sputc(p,c);
				if(c == '[')n++;
			}
			pushp(p);
			continue;
		case 'k':
			p = pop();
			EMPTY;
			p = scalint(p);
			if(length(p)>1){
				error("scale too big\n");
			}
			rewind(p);
			k = sfeof(p)?0:sgetc(p);
			release(scalptr);
			scalptr = p;
			continue;
		case 'K':
			p = copy(scalptr,length(scalptr)+1);
			sputc(p,0);
			pushp(p);
			continue;
		case 'X':
			p = pop();
			EMPTY;
			fsfile(p);
			n = sbackc(p);
			release(p);
			p = salloc(2);
			sputc(p,n);
			sputc(p,0);
			pushp(p);
			continue;
		case 'Q':
			p = pop();
			EMPTY;
			if(length(p)>2){
				error("Q?\n");
			}
			rewind(p);
			if((c =  sgetc(p))<0){
				error("neg Q\n");
			}
			release(p);
			while(c-- > 0){
				if(readptr == &readstk[0]){
					error("readstk?\n");
				}
				if(*readptr != 0)release(*readptr);
				readptr--;
			}
			continue;
		case 'q':
			if(readptr <= &readstk[1])exit(0);
			if(*readptr != 0)release(*readptr);
			readptr--;
			if(*readptr != 0)release(*readptr);
			readptr--;
			continue;
		case 'f':
			if(stkptr == &stack[0])printf("empty stack\n");
			else {
				for(ptr = stkptr; ptr > &stack[0];){
					print(*ptr--);
				}
			}
			continue;
		case 'p':
			if(stkptr == &stack[0])printf("empty stack\n");
			else{
				print(*stkptr);
			}
			continue;
		case 'P':
			p = pop();
			EMPTY;
			sputc(p,0);
			printf("%s",p->beg);
			release(p);
			continue;
		case 'd':
			if(stkptr == &stack[0]){
				printf("empty stack\n");
				continue;
			}
			q = *stkptr;
			n = length(q);
			p = copy(*stkptr,n);
			pushp(p);
			continue;
		case 'c':
			while(stkerr == 0){
				p = pop();
				if(stkerr == 0)release(p);
			}
			continue;
		case 'S':
			if(stkptr == &stack[0]){
				error("save: args\n");
			}
			c = readc() & 0377;
			sptr = stable[c];
			sp = stable[c] = sfree;
			sfree = sfree->next;
			if(sfree == 0)goto sempty;
			sp->next = sptr;
			p = pop();
			EMPTY;
			if(c >= ARRAYST){
				q = copy(p,PTRSZ);
				for(n = 0;n < PTRSZ-1;n++)sputc(q,0);
				release(p);
				p = q;
			}
			sp->val = p;
			continue;
sempty:
			error("symbol table overflow\n");
		case 's':
			if(stkptr == &stack[0]){
				error("save:args\n");
			}
			c = readc() & 0377;
			sptr = stable[c];
			if(sptr != 0){
				p = sptr->val;
				if(c >= ARRAYST){
					rewind(p);
					while(sfeof(p) == 0)release(getwd(p));
				}
				release(p);
			}
			else{
				sptr = stable[c] = sfree;
				sfree = sfree->next;
				if(sfree == 0)goto sempty;
				sptr->next = 0;
			}
			p = pop();
			sptr->val = p;
			continue;
		case 'l':
			load();
			continue;
		case 'L':
			c = readc() & 0377;
			sptr = stable[c];
			if(sptr == 0){
				error("L?\n");
			}
			stable[c] = sptr->next;
			sptr->next = sfree;
			sfree = sptr;
			p = sptr->val;
			if(c >= ARRAYST){
				rewind(p);
				while(sfeof(p) == 0){
					q = getwd(p);
					if(q != 0)release(q);
				}
			}
			pushp(p);
			continue;
		case ':':
			p = pop();
			EMPTY;
			q = scalint(p);
			fsfile(q);
			c = 0;
			if((sfbeg(q) == 0) && ((c = sbackc(q))<0)){
				error("neg index\n");
			}
			if(length(q)>2){
				error("index too big\n");
			}
			if(sfbeg(q) == 0)c = c*100+sbackc(q);
			if(c >= MAXIND){
				error("index too big\n");
			}
			release(q);
			n = readc() & 0377;
			sptr = stable[n];
			if(sptr == 0){
				sptr = stable[n] = sfree;
				sfree = sfree->next;
				if(sfree == 0)goto sempty;
				sptr->next = 0;
				p = salloc((c+PTRSZ)*PTRSZ);
				zero(p);
			}
			else{
				p = sptr->val;
				if(length(p)-PTRSZ < c*PTRSZ){
					q = copy(p,(c+PTRSZ)*PTRSZ);
					release(p);
					p = q;
				}
			}
			seekc(p,c*PTRSZ);
			q = lookwd(p);
			if (q!=NULL) release(q);
			s = pop();
			EMPTY;
			salterwd(p,s);
			sptr->val = p;
			continue;
		case ';':
			p = pop();
			EMPTY;
			q = scalint(p);
			fsfile(q);
			c = 0;
			if((sfbeg(q) == 0) && ((c = sbackc(q))<0)){
				error("neg index\n");
			}
			if(length(q)>2){
				error("index too big\n");
			}
			if(sfbeg(q) == 0)c = c*100+sbackc(q);
			if(c >= MAXIND){
				error("index too big\n");
			}
			release(q);
			n = readc() & 0377;
			sptr = stable[n];
			if(sptr != 0){
				p = sptr->val;
				if(length(p)-PTRSZ >= c*PTRSZ){
					seekc(p,c*PTRSZ);
					s = getwd(p);
					if(s != 0){
						q = copy(s,length(s));
						pushp(q);
						continue;
					}
				}
			}
			q = salloc(PTRSZ);
			putwd(q, (struct blk *)0);
			pushp(q);
			continue;
		case 'x':
execute:
			p = pop();
			EMPTY;
			if((readptr != &readstk[0]) && (*readptr != 0)){
				if((*readptr)->rd == (*readptr)->wt)
					release(*readptr);
				else{
					if(readptr++ == &readstk[RDSKSZ]){
						error("nesting depth\n");
					}
				}
			}
			else readptr++;
			*readptr = p;
			if(p != 0)rewind(p);
			else{
				if((c = readc()) != '\n')unreadc(c);
			}
			continue;
		case '?':
			if(++readptr == &readstk[RDSKSZ]){
				error("nesting depth\n");
			}
			*readptr = 0;
			fsave = curfile;
			curfile = stdin;
			while((c = readc()) == '!')command();
			p = salloc(0);
			sputc(p,c);
			while((c = readc()) != '\n'){
				sputc(p,c);
				if(c == '\\')sputc(p,readc());
			}
			curfile = fsave;
			*readptr = p;
			continue;
		case '!':
			if(command() == 1)goto execute;
			continue;
		case '<':
		case '>':
		case '=':
			if(cond(c) == 1)goto execute;
			continue;
		default:
			printf("%o is unimplemented\n",c);
		}
	}
}
