#include "uucp.h"

/* static char sccs[] = "@(#)imsg.c	1.1 4/11/86" ; */

extern int Debug;

char Msync = 020;

/*******
 *	imsg(msg, fn)
 *	char *msg;
 *	int fn;
 *
 *	imsg  -  this is the initial read message routine -
 *	used before a protocol is agreed upon.
 *
 *	return codes:
 *		EOF - no more messages
 *		0 - message returned
 */

imsg(msg, fn) char *msg; int fn; {
	int ret;

	DEBUG(7, "imsg %>", "");
	while((ret = read(fn, msg, 1)) == 1) {
		DEBUG(7, (*msg > 037) ? "%c" : "\%03o" , *msg & 0377);
		if(*msg == Msync) break;
	}
	DEBUG(7, "%s\n", "<");
	if(ret < 1) return(EOF);
	while(read(fn, msg, 1) == 1) {
		DEBUG(7, (*msg > 037) ? "%c" : "\%03o", *msg & 0377);
		if(*msg == '\n' || *msg == '\0') break;
		msg++;
	}
	*msg = '\0';
	return(0);
}

/***
 *	omsg(type, msg, fn)
 *	char type, *msg;
 *	int fn;
 *
 *	omsg  -  this is the initial write message routine -
 *	used before a protocol is agreed upon.
 *
 *	return code:  always 0
 */

omsg(type, msg, fn) char type, *msg; int fn; {
	char buf[BUFSIZ], *c;

	DEBUG(9, "osmg: fn = %d", fn);
	DEBUG(9, "msg = %s*", msg);
	DEBUG(9, "type = %c*", type);
	c = buf;
	*c++ = Msync;
	*c++ = type;
	while(*msg) *c++ = *msg++;
	*c++ = '\0';
	write(fn, buf, strlen(buf) + 1);
	return(0);
}
