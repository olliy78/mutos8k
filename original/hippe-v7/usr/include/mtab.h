/* Mount table description for Unix Version 7, we hadn't it
	under our Version 7 , so it may be wrong for Version 7 */

#define NMOUNT 	5		/* should be the same as in sys/param.h */

#define MTABFILE "/etc/mtab"
#define MTAB_PATH 32
#define MTAB_DEV  26

struct mnttab {
	char mt_filsys[MTAB_PATH];
	char mt_dev[MTAB_DEV];
	time_t mt_time;		/* this is not normal for Version 7 */
	char mt_unused;
	char mt_ro_flag;
};
