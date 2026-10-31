/*
 * Mount structure.
 * One allocated on every mount.
 * Used to find the super block.
 */
struct	mount
{
	dev_t	m_dev;		/* device mounted */
#ifdef XBUF
	struct filsys m_sup;	/* actual superblock */
#else
	struct buf *m_bufp;	/* pointer to superblock */
#endif XBUF
	struct inode *m_inodp;	/* pointer to mounted on inode */
};
extern struct mount mount[];
