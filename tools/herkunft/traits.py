#!/usr/bin/env python3
"""traits.py -- count files of source trees that contain the "foreign" kernel traits found in MUTOS (AP H6).

Each trait is a regular expression (applied to whole files, DOTALL where noted) with an optional file-name
filter.  Output: one row per trait, one column per tree = number of matching files.

Usage:
  python3 -I tools/herkunft/traits.py hippe=SCR/h6_hippe/usr/sys v7=original/unix-v7/usr/sys u92=SCR/h6_unsw92/sys
  python3 -I tools/herkunft/traits.py --list            # print the trait table (id, file filter, regex)
  python3 -I tools/herkunft/traits.py --json out.json label=dir ...
  python3 -I tools/herkunft/traits.py --aout KERNEL_A_OUT [...]   # symbol / string traits of PDP-11 kernel binaries

Trees are searched recursively (.c .h .s .m .conf files; others are ignored).  A tree directory may be a
raw dump root; non-existent directories give a column of "-".
"""
import argparse
import json
import os
import re
import sys

# (id, description, file-name regex, content regex)  -- content regexes are compiled with re.S (DOTALL) and re.M
TRAITS = [
    ("T01", "malloc: panic(map overflow)", r"\.c$", r"panic\(\s*\"map overflow"),
    ("T02", "seek: off<0 -> EINVAL, off=0", r"sys2\.c$", r"off\s*<\s*0\)\s*\{?\s*u\.u_error\s*=\s*EINVAL;\s*uap->off\s*=\s*0"),
    ("T03", "sumount: i_count test", r"sys3\.c$", r"if\s*\(\s*ip->i_count\s*\)\s*\{?\s*u\.u_error\s*=\s*EBUSY"),
    ("T04", "LRUI: i_lrt (inode age)", r"\.[ch]$", r"\bi_lrt\b"),
    ("T05", "breada: bfreelist.av_forw test", r"bio\.c$", r"bfreelist\.av_forw\s*!=\s*&bfreelist"),
    ("T06", "exit: one loop, wakeup(&proc[1]) once", r"sys1\.c$", r"if\s*\(\s*i\s*\)\s*wakeup\(\s*&proc\[1\]\s*\)"),
    ("T07", "exece: B_AGE on discarded arg blocks", r"sys1\.c$", r"B_AGE"),
    ("T08", "PROC_MAX: max_proc / MAX_PROC", r"\.[ch]$", r"\b(MAX_PROC|max_proc)\b"),
    ("T09", "alloc: s_tfree-- in alloc()", r"alloc\.c$", r"s_tfree--"),
    ("T10", "smount: d_open error -> out1", r"sys3\.c$", r"d_open\)\(dev[^;]*;\s*if\s*\(\s*u\.u_error\s*\)\s*\{?\s*(brelse\(bp\);\s*)?goto\s+out1"),
    ("T11", "tty: cchars+wchars tables", r"tty\.c$", r"\bcchars\b.*\bwchars\b"),
    ("T12", "tty: ttyretype/ttywipe", r"tty\.c$", r"\b(ttyretype|ttywipe)\b"),
    ("T13", "param: NPROC 30", r"param\.h$", r"define\s+NPROC\s+30\b"),
    ("T14", "param: NINODE 50", r"param\.h$", r"define\s+NINODE\s+50\b"),
    ("T15", "param: MAPSIZ (NPROC/2)", r"param\.h$", r"define\s+MAPSIZ\s+\(?NPROC/2"),
    ("T16", "switch XBUF", r"\.[ch]$", r"^\s*#\s*(ifn?def|if)\s+XBUF\b"),
    ("T17", "switch LRUI", r"\.[ch]$", r"^\s*#\s*(ifn?def|if)\s+LRUI\b"),
    ("T18", "switch EXIT", r"\.[ch]$", r"^\s*#\s*(ifn?def|if)\s+EXIT\b"),
    ("T19", "switch PROC_MAX", r"\.[ch]$", r"^\s*#\s*(ifn?def|if)\s+PROC_MAX\b"),
    ("T20", "switch SYSACCT/INSTRM/SEPID", r"\.[ch]$", r"^\s*#\s*(ifn?def|if)\s+(SYSACCT|INSTRM|SEPID)\b"),
    ("T21", "clock: sflag1 (30 s update)", r"\.c$", r"\bsflag1\b"),
    ("T22", "setregs: u_exname", r"\.[ch]$", r"\bu_exname\b"),
]
EXTS = (".c", ".h", ".s", ".m")

# symbols of the Hippe/Nijmegen line (names are 8 characters significant in the a.out symbol table, with `_`)
SYMBOLS = ["max_proc", "ttywipe", "ttyretype", "zapc", "ttybit", "ttychars", "ttyspcl", "wchars", "cchars", "maptab",
           "io_info", "bfreelist", "getxfile", "clkstart", "sflag1", "nosys"]
STRINGS = [b"map overflow", b"Out of swap", b"Timeout table overflow", b"Inode table overflow"]


def aout_symbols(path):
    """Symbol names of a non-stripped PDP-11 a.out (12-byte nlist entries) or None."""
    import struct
    d = open(path, "rb").read()
    if len(d) < 16:
        return None, d
    mg, t, da, _b, sy = struct.unpack("<5H", d[:10])
    if mg not in (0o407, 0o410, 0o411, 0o405) or sy == 0:
        return None, d
    off = 16 + t + da
    names = {d[off + 12 * i:off + 12 * i + 8].split(b"\0")[0].decode("latin-1") for i in range(sy // 12)}
    return names, d


def aout_report(paths):
    print("%-40s " % "kernel" + " ".join("%8s" % s[:8] for s in SYMBOLS) + "  " + " ".join(s.decode()[:10] for s in STRINGS))
    for p in paths:
        try:
            names, d = aout_symbols(p)
        except OSError:
            print("%-40s (not found)" % p[-40:])
            continue
        if names is None:
            print("%-40s (stripped or not a PDP-11 a.out)" % p[-40:])
            continue
        print("%-40s " % p[-40:] + " ".join("%8s" % ("yes" if ("_" + s)[:8] in names else "-") for s in SYMBOLS) + "  "
              + " ".join("%10s" % ("yes" if s in d else "-") for s in STRINGS))


def scan(root):
    """{trait id: count of files} for one tree, plus the file count."""
    counts = {t[0]: 0 for t in TRAITS}
    files = 0
    comp = [(t[0], re.compile(t[2]), re.compile(t[3], re.S | re.M)) for t in TRAITS]
    for d, _dirs, names in os.walk(root):
        for n in names:
            if not n.endswith(EXTS):
                continue
            p = os.path.join(d, n)
            try:
                text = open(p, "rb").read().decode("latin-1")
            except OSError:
                continue
            files += 1
            for tid, fr, cr in comp:
                if fr.search(n) and cr.search(text):
                    counts[tid] += 1
    return counts, files


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("trees", nargs="*", help="label=dir")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--aout", action="store_true", help="arguments are kernel binaries, not source trees")
    ap.add_argument("--json")
    a = ap.parse_args(argv)
    if a.aout:
        aout_report(a.trees)
        return 0
    if a.list:
        for t in TRAITS:
            print("%s  %-40s %-12s %s" % t)
        return 0
    labels, res = [], {}
    for spec in a.trees:
        lab, d = spec.split("=", 1)
        labels.append(lab)
        res[lab] = scan(d) if os.path.isdir(d) else None
    print("%-4s %-38s " % ("id", "trait") + " ".join("%6s" % l[:6] for l in labels))
    for t in TRAITS:
        print("%-4s %-38s " % (t[0], t[1]) + " ".join("%6s" % ("-" if res[l] is None else res[l][0][t[0]]) for l in labels))
    print("%-4s %-38s " % ("", "files scanned") + " ".join("%6s" % ("-" if res[l] is None else res[l][1]) for l in labels))
    if a.json:
        json.dump({l: (None if res[l] is None else res[l][0]) for l in labels}, open(a.json, "w"), indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main())
