#!/usr/bin/env python3
"""mapnames.py -- rename the identifiers of a Hippe/Nijmegen/V7 tty.c into the vocabulary of MUTOS kernel/c/tty2.c.

The MUTOS names were assigned freely during decompilation (ttyrub, ttycol, bitset, ...); the original names are
ttywipe, ttyretype, ttybit, ...  Comments and #define/#include lines are removed, flag macros become numbers,
so the result can be compared with herkunft.py / devdiff.py.

Usage:
  python3 -I tools/herkunft/mapnames.py SRC_tty.c DST_tty.c
"""
import re
import sys

REN = {
    "ttyblock": "ttflow", "ttybit": "bitset", "zapc": "unputc", "ttyretype": "ttycol", "ttywipe": "ttyrub",
    "ttyspcl": "ttyspec", "ttstart": "ttkick", "ttychars": "ttinit", "ttioccomm": "ttioctl", "wflushtty": "ttywait",
    "flushtty": "ttyflush", "t_rawq": "t_inq", "t_xstate": "t_lstate", "t_lnum": "t_cnt2c", "t_length": "t_page",
    "t_nldly": "t_dnl", "t_crdly": "t_dcr", "t_htdly": "t_dtab", "t_vtdly": "t_dvt", "TTSTOP": "0x100",
    "TBLOCK": "0x400", "XPAGE1": "2", "XPAGE2": "4", "XPAGE": "1", "XLITRL": "8", "XERASE": "0x10", "SCOPE": "0x100",
    "INDCTL": "0x200", "cchars": "ttyctl", "wchars": "ttyword", "maptab": "ttylcmap", "isspcl": "ttyspec",
    "TTYHOG": "256",
}


def main(argv):
    if len(argv) != 3:
        print(__doc__)
        return 2
    t = open(argv[1], encoding="latin-1").read()
    t = re.sub(r"/\*.*?\*/", "", t, flags=re.S)
    t = re.sub(r"^\s*#\s*(define|include).*$", "", t, flags=re.M)
    for k in sorted(REN, key=len, reverse=True):
        t = re.sub(r"\b" + k + r"\b", REN[k], t)
    open(argv[2], "w", encoding="latin-1").write(t)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
