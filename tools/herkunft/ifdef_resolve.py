#!/usr/bin/env python3
"""ifdef_resolve.py -- resolve #ifdef/#ifndef/#else/#endif for a fixed set of defined macros and copy a source tree.

Only .c and .h files are processed (others are skipped).  `#if`/`#elif` lines with expressions are kept as
text (treated as true).  Used to turn a switch-driven historic kernel (Hippe/Nijmegen `m.h` options) into
the "effective" source of one configuration, and to strip MUTOS dead `#ifdef DISKMON` text.

Usage:
  python3 -I tools/herkunft/ifdef_resolve.py SRC DST [MACRO ...]
  e.g. Hippe default configuration (m.h): ... PROC_MAX EXIT LRUI _1140 TUDUMP DELTAB
SRC is read recursively, DST is created (it must not be inside SRC).
"""
import os
import re
import sys


def resolve(lines, defs):
    rx = re.compile(r"^\s*#\s*(ifdef|ifndef|else|endif|if|elif)\b\s*(\S*)")
    out, stack, active = [], [], True  # stack: (active_before, condition)
    for ln in lines:
        m = rx.match(ln)
        if m:
            d, a = m.groups()
            if d in ("ifdef", "ifndef"):
                c = (a in defs) if d == "ifdef" else (a not in defs)
                stack.append((active, c))
                active = active and c
                continue
            if d in ("if", "elif"):
                stack.append((active, True))  # unknown expression: keep the text
                if active:
                    out.append(ln)
                continue
            if d == "else" and stack:
                pa, c = stack[-1]
                active = pa and not c
                continue
            if d == "endif" and stack:
                pa, _c = stack.pop()
                active = pa
                continue
        if active:
            out.append(ln)
    return out


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    src, dst, defs = argv[1], argv[2], set(argv[3:])
    for root, _dirs, files in os.walk(src):
        for f in files:
            if not f.endswith((".c", ".h")):
                continue
            p = os.path.join(root, f)
            try:
                text = open(p, encoding="latin-1").read().split("\n")
            except OSError:
                continue
            q = os.path.join(dst, os.path.relpath(p, src))
            os.makedirs(os.path.dirname(q), exist_ok=True)
            with open(q, "w", encoding="latin-1") as fh:
                fh.write("\n".join(resolve(text, defs)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
