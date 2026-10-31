/* stat.h -- file status structure (stat/fstat).
 *
 * Origin:   complete
 * Source:   UNIX V7 usr/sys/h/stat.h (struct stat, S_I* modes); the kernel has no separate stat.h in the guest, sys3.c
 *           declared the structure locally (layout 22 bytes, copied out by stat1 3DDC with sizeof).
 * Evidence: V7 text; the old local declaration had the same members in the same order (st_mode unsigned, others int).
 * Deviations: include guard only.
 */
#ifndef STAT_H
#define STAT_H
struct	stat
{
	dev_t	st_dev;
	ino_t	st_ino;
	unsigned short st_mode;
	short	st_nlink;
	short  	st_uid;
	short  	st_gid;
	dev_t	st_rdev;
	off_t	st_size;
	time_t	st_atime;
	time_t	st_mtime;
	time_t	st_ctime;
};

#define	S_IFMT	0170000		/* type of file */
#define		S_IFDIR	0040000	/* directory */
#define		S_IFCHR	0020000	/* character special */
#define		S_IFBLK	0060000	/* block special */
#define		S_IFREG	0100000	/* regular */
#define		S_IFMPC	0030000	/* multiplexed char special */
#define		S_IFMPB	0070000	/* multiplexed block special */
#define	S_ISUID	0004000		/* set user id on execution */
#define	S_ISGID	0002000		/* set group id on execution */
#define	S_ISVTX	0001000		/* save swapped text even after use */
#define	S_IREAD	0000400		/* read permission, owner */
#define	S_IWRITE	0000200		/* write permission, owner */
#define	S_IEXEC	0000100		/* execute/search permission, owner */
#endif
