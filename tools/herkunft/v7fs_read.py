#!/usr/bin/env python3
"""v7fs_read.py -- extract the regular files of a V7 file system image (PDP-11 byte order, 512-byte blocks).

Used for the TUHS "7th_Edition_Y2K" RK05 image (a boot disk without kernel sources).  Only regular files and
directories are restored.  Single and double indirect blocks are followed (128 four-byte entries each).

Usage:
  python3 -I tools/herkunft/v7fs_read.py IMAGE OUTDIR [OFFSET_BLOCKS]
"""
import os
import struct
import sys


class Fs:
    def __init__(self, img, base=0):
        self.img, self.base = img, base * 512

    def blk(self, n):
        o = self.base + n * 512
        return self.img[o:o + 512]

    def inode(self, n):
        o = (n - 1) * 64
        b = self.blk(2 + o // 512)[o % 512:o % 512 + 64]
        mode, = struct.unpack("<H", b[0:2])
        hi, lo = struct.unpack("<HH", b[8:12])
        a = b[12:52]
        # 3-byte block numbers: byte 0 is the high byte, bytes 1..2 the low word (PDP-11 layout)
        addr = [(a[3 * i] << 16) | a[3 * i + 1] | (a[3 * i + 2] << 8) for i in range(13)]
        return mode, (hi << 16) | lo, addr

    def indirect(self, b):
        """V7: 128 entries of 4 bytes (PDP-11 long: high word first, each word little endian)."""
        t = self.blk(b)
        return [(struct.unpack("<H", t[4 * i:4 * i + 2])[0] << 16) | struct.unpack("<H", t[4 * i + 2:4 * i + 4])[0]
                for i in range(128)]

    def data(self, n):
        mode, size, addr = self.inode(n)
        bl = list(addr[:10])
        if addr[10]:
            bl += self.indirect(addr[10])
        if addr[11]:
            for x in self.indirect(addr[11]):
                bl += self.indirect(x) if x else [0] * 128
        d = b"".join(self.blk(b) if b else b"\0" * 512 for b in bl[:(size + 511) // 512])
        return mode, d[:size]

    def walk(self, n, path, depth=0):
        if depth > 15:
            return 0
        mode, d = self.data(n)
        kind, cnt = mode & 0o170000, 0
        if kind == 0o040000:
            os.makedirs(path, exist_ok=True)
            for i in range(0, len(d) - 15, 16):
                e, = struct.unpack("<H", d[i:i + 2])
                nm = d[i + 2:i + 16].split(b"\0")[0].decode("latin-1")
                if e and nm and nm not in (".", "..") and "/" not in nm:
                    cnt += self.walk(e, os.path.join(path, nm), depth + 1)
        elif kind == 0o100000:
            with open(path, "wb") as f:
                f.write(d)
            cnt = 1
        return cnt


def main(argv):
    if len(argv) not in (3, 4):
        print(__doc__)
        return 2
    fs = Fs(open(argv[1], "rb").read(), int(argv[3]) if len(argv) == 4 else 0)
    print(fs.walk(2, argv[2]), "files")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
