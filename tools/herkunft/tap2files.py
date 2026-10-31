#!/usr/bin/env python3
"""tap2files.py -- split a SIMH .tap tape image into files (tape mark = record of length 0).

Output files are named file00, file01, ...  (tape file n).  For V7 `dump` files use v7dump.py on the result.

Usage:
  python3 -I tools/herkunft/tap2files.py TAP OUTDIR
"""
import os
import struct
import sys


def split(data):
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
    if len(argv) != 3:
        print(__doc__)
        return 2
    os.makedirs(argv[2], exist_ok=True)
    files = split(open(argv[1], "rb").read())
    for n, f in enumerate(files):
        open(os.path.join(argv[2], "file%02d" % n), "wb").write(f)
    print(len(files), "files")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
