#!/usr/bin/env python3
"""v7dump.py -- extract a Seventh Edition `dump` image (PDP-11, restor format) into a directory tree.

The V7 tape (TUHS Research/Keith_Bostic_v7/v7.tap.gz) holds the root and /usr file systems as `dump` files
(tape file 5 and 6).  Header records are 512 bytes: c_type, c_date, c_ddate, c_volume, c_tapea, c_inumber,
c_magic (60011), c_checksum, c_dinode (64 bytes), c_count, c_addr[]; a set c_addr[i] byte means that block i
of the segment follows on the tape.  Only regular files and directories are restored; no ownership or mode.

Usage:
  python3 -I tools/herkunft/v7dump.py DUMPFILE OUTDIR          # OUTDIR must be new and empty
  python3 -I tools/herkunft/v7dump.py --tap TAP OUTDIR_PREFIX  # split a SIMH .tap into files, extract files 5 and 6

File times are not restored (the directory is a scratch copy).  Run the result through `chmod -R u+rwX`
if needed and never execute anything from it.
"""
import os
import struct
import sys

MAGIC = 60011
TS_TAPE, TS_INODE, TS_BITS, TS_ADDR, TS_END, TS_CLRI = 1, 2, 3, 4, 5, 6
BS = 512


def parse(data):
    """Return {ino: (mode, size, bytes)} for the inodes on the dump."""
    inodes = {}
    pos, n = 0, len(data)
    cur = None
    while pos + BS <= n:
        h = data[pos:pos + BS]
        t, = struct.unpack("<h", h[0:2])
        magic, = struct.unpack("<h", h[18:20])
        if magic & 0xFFFF != MAGIC:
            raise ValueError("bad magic at %d" % pos)
        ino, = struct.unpack("<H", h[16:18])
        cnt, = struct.unpack("<h", h[86:88])
        addr = h[88:88 + max(cnt, 0)]
        pos += BS
        if t == TS_END:
            break
        if t in (TS_TAPE,):
            continue
        if t in (TS_CLRI, TS_BITS):
            pos += BS * cnt
            continue
        if t == TS_INODE:
            mode, = struct.unpack("<H", h[22:24])
            # di_size is a PDP-11 long: high word first
            hi, lo = struct.unpack("<HH", h[22 + 8:22 + 12])
            size = (hi << 16) | lo
            cur = {"ino": ino, "mode": mode, "size": size, "blocks": {}, "next": 0}
            inodes[ino] = cur
        if cur is None:
            continue
        for i in range(cnt):
            if addr[i]:
                cur["blocks"][cur["next"] + i] = data[pos:pos + BS]
                pos += BS
        cur["next"] += cnt
    out = {}
    for ino, c in inodes.items():
        nb = (c["size"] + BS - 1) // BS
        buf = b"".join(c["blocks"].get(i, b"\0" * BS) for i in range(nb))[:c["size"]]
        out[ino] = (c["mode"], c["size"], buf)
    return out


def extract(data, outdir):
    inodes = parse(data)
    os.makedirs(outdir, exist_ok=False)
    cnt = 0

    def walk(ino, path, depth=0):
        nonlocal cnt
        if depth > 20 or ino not in inodes:
            return
        mode, size, buf = inodes[ino]
        fmt = mode & 0o170000
        if fmt == 0o040000:
            os.makedirs(path, exist_ok=True)
            for i in range(0, len(buf) - 15, 16):
                e, = struct.unpack("<H", buf[i:i + 2])
                name = buf[i + 2:i + 16].split(b"\0")[0].decode("latin-1")
                if e and name not in (".", "..") and "/" not in name and name:
                    walk(e, os.path.join(path, name), depth + 1)
        elif fmt == 0o100000:
            with open(path, "wb") as f:
                f.write(buf)
            cnt += 1

    walk(2, outdir)
    return cnt


def split_tap(tap, outprefix):
    data = open(tap, "rb").read()
    pos, files, cur = 0, [], bytearray()
    while pos + 4 <= len(data):
        ln = struct.unpack("<I", data[pos:pos + 4])[0] & 0x00FFFFFF
        pos += 4
        if ln == 0:
            if cur:
                files.append(bytes(cur))
                cur = bytearray()
            continue
        cur += data[pos:pos + ln]
        pos += ln + (ln & 1) + 4
    if cur:
        files.append(bytes(cur))
    return files


def main(argv):
    if len(argv) == 4 and argv[1] == "--tap":
        files = split_tap(argv[2], argv[3])
        for k in (5, 6):
            print("file %d: %d files" % (k, extract(files[k], "%s_f%d" % (argv[3], k))))
        return 0
    if len(argv) != 3:
        print(__doc__)
        return 2
    print(extract(open(argv[1], "rb").read(), argv[2]), "files")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
