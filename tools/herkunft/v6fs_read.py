#!/usr/bin/env python3
"""v6fs_read.py IMAGE OUTDIR -- extract a UNIX V6 file system image (PDP-11, little endian, 512-byte blocks), read only.

Used for the LSX disk images (TUHS Distributions/USDL/LSX/lsxfs.tar.bz2, doc/herkunft/speicher.md).  Standard library only;
run with `python3 -I`.  Handles small files (8 direct blocks), large files (flag 0x1000: 7 indirect + 1 double indirect).
Special files are skipped.
"""
import os
import struct
import sys

BS = 512


def main(argv):
    img = open(argv[1], "rb").read()
    out = argv[2]

    def blk(n):
        return img[n * BS:(n + 1) * BS]

    def words(b):
        return struct.unpack("<%dH" % (len(b) // 2), b)

    def inode(n):
        off = 2 * BS + (n - 1) * 32
        flags, _nlink, _uid, _gid, s0, s1 = struct.unpack("<HBBBBH", img[off:off + 8])
        return {"flags": flags, "size": (s0 << 16) | s1, "addr": struct.unpack("<8H", img[off + 8:off + 24])}

    def data(ino):
        nb = (ino["size"] + BS - 1) // BS
        if ino["flags"] & 0x1000:
            lst = []
            for k, ind in enumerate(ino["addr"]):
                if not ind:
                    continue
                for w in words(blk(ind)):
                    if k < 7:
                        lst.append(w)
                    elif w:
                        lst.extend(words(blk(w)))
        else:
            lst = list(ino["addr"])
        raw = b"".join(blk(x) if x else b"\0" * BS for x in lst[:nb])
        return raw[:ino["size"]]

    def walk(n, path):
        ino = inode(n)
        kind = ino["flags"] & 0o60000
        if kind == 0o40000:
            os.makedirs(path, exist_ok=True)
            d = data(ino)
            for i in range(0, len(d) - 15, 16):
                num = struct.unpack("<H", d[i:i + 2])[0]
                name = d[i + 2:i + 16].split(b"\0")[0].decode("latin-1")
                if num and name not in (".", ".."):
                    walk(num, os.path.join(path, name))
        elif kind == 0:
            with open(path, "wb") as f:
                f.write(data(ino))

    walk(1, out)


if __name__ == "__main__":
    main(sys.argv)
