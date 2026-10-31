#!/usr/bin/env python3
"""tables.py -- compare the three tty tables (maptab/cchars/wchars) of reference tty.c files with MUTOS tty2.c.

MUTOS names: ttylcmap = maptab[128], ttyctl = cchars[16], ttyword = wchars[16].  `P` in a table is the parity
bit 0200.  Prints IDENTICAL, `differs at n of m positions` or `absent` per table and reference file.

Usage:
  python3 -I tools/herkunft/tables.py kernel/c/tty2.c REF/tty.c [REF2/tty.c ...]
"""
import re
import sys


def parse(path, name):
    t = open(path, encoding="latin-1").read()
    t = re.sub(r"/\*.*?\*/", "", t, flags=re.S)
    m = re.search(r"\b" + name + r"\s*\[\s*\w*\s*\]\s*=\s*\{(.*?)\}\s*;", t, re.S)
    if not m:
        return None
    vals = []
    for tok in m.group(1).split(","):
        tok = tok.strip()
        if not tok:
            continue
        v = 0
        for part in re.split(r"\+", tok):
            part = part.strip()
            if part == "P":
                v += 0x80
            elif part.startswith("'"):
                s = part[1:-1]
                v += {"\\\\": 92, "\\'": 39}.get(s, ord(s[0]) if len(s) == 1 else 0)
            else:
                v += int(part, 8) if re.fullmatch(r"0[0-7]+", part) else int(part, 0)
        vals.append(v & 0xFF)
    return vals


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    mine = {"maptab": parse(argv[1], "ttylcmap"), "cchars": parse(argv[1], "ttyctl"), "wchars": parse(argv[1], "ttyword")}
    for ref in argv[2:]:
        r = []
        for n, mv in mine.items():
            rv = parse(ref, n)
            if rv is None or mv is None:
                r.append("%s: absent" % n)
                continue
            diff = [i for i in range(min(len(rv), len(mv))) if rv[i] != mv[i]]
            r.append("%s: %s" % (n, "IDENTICAL (%d bytes)" % len(rv) if rv == mv else
                                 "differs at %d of %d positions" % (len(diff), len(mv))))
        print(ref, "|", " ; ".join(r))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
