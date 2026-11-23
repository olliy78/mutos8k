"""Plan 52 W7p: functional check of our reconstructed `as` against the ORIGINAL /usr/bin/as (doc/userspace/wk_w7p.md).

  lauf --asx FILE [--libc N] [--prog NAME...] [--kern MOD...] [--only MOD...] [--nodiag]
      ONE guest session: assembles libc .s members (userspace/libc/*.s) and compiler outputs (cpp, c0, c1, c2 on the
      sources of the given programs, default echo cat cc) with /usr/bin/as and with FILE (our as, put on /mnt as asx).
      Per input X: X.o (original), X.n (ours), X.e (exit status + messages of both).  Result under
      userspace/as/work/gegen/ (not committed).  --kern adds kernel/asm/ref/MOD.s (W7u), --only limits the compiled
      modules, --nodiag leaves out the d_* minimal inputs (the /tmp disk holds ca. 250 KB: split big sets over sessions).
  auswerten
      host: byte comparison X.o / X.n, status and message comparison, first differing byte and header words.

Run with python3 -I.  The guest session takes minutes: run it in the background with a built-in timeout.
"""
import argparse
import os
import shutil
import struct
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import uspace as U       # noqa: E402
import c2gegen as G      # noqa: E402

WORK = os.path.join(U.REPO, "userspace", "as", "work", "gegen")
LIBC = os.path.join(U.REPO, "userspace", "libc")


DIAG = {
    "e0": "",
    "e1": "m1_ module\n",
    "e2": "m2_ module\n$NONSEGMENTED\nconstant\n\tFP\t:= r14\n",
    "e3": "m3_ module\n$NONSEGMENTED\nconstant\n\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n\tI\t:= internal\n",
    # W7q: pass 0 length bisect: one construct each (module header as in e3, then an entry with the construct)
    "t1": "t1_ module\n$NONSEGMENTED\nconstant\n\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n\tPR\t:= procedure\n\tE\t:= entry\n"
          "X\tcsv\tPR\nG\t_f\tPR\nE\n_f:\n\tcall\tcsv\n\tret\nend _f\nend t1_\n",
    "t2": "t2_ module\n$NONSEGMENTED\nconstant\n\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n\tPR\t:= procedure\n\tE\t:= entry\n"
          "X\tcsv\tPR\nG\t_f\tPR\nE\n_f:\n\tld\tr2,#%FFFF\n\tret\nend _f\nend t2_\n",
}
# W7s: t3 is a valid minimal case now (it was an invalid declaration); t4..t8 bisect 4-operand block instructions with a
# condition code (crt0, execle, mcrt0, doprnt)
for _n, _b in ((3, "\tld\tr4,#1\n"), (4, "\tcpir\tr0,@r7,r1,z\n"), (5, "\tcpirb\trl0,@r10,r11,eq\n"),
               (6, "\tldir\t@r2,@r3,r4\n"), (7, "\tcpsir\t@r2,@r3,r4,z\n"), (8, "\tjr\tz,_f\n")):
    DIAG["t%d" % _n] = ("t%d_ module\n$NONSEGMENTED\nconstant\n\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n"
                        "\tPR\t:= procedure\n\tE\t:= entry\nG\t_f\tPR\nE\n_f:\n%s\tret\nend _f\nend t%d_\n" % (_n, _b, _n))


ZWEI = False        # W7u: a second assembler of ours (/mnt/asy, X.m) in the same session (set by --asx2)
# W7u: where does the plain (non-c2-model) build stop?  one keyword declaration after a header of varying length
_H = "k%d_ module\n$NONSEGMENTED\nconstant\n"
for _n, _b in ((1, "\tPR\t:= procedure\n"), (2, "\tFP\t:= r14\n\tPR\t:= procedure\n"),
               (3, "\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n\tI\t:= internal\n\tPR\t:= procedure\n"),
               (4, "\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n\tI\t:= internal\n\tA\t:= array\n"),
               (5, "\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n\tI\t:= internal\n\tE\t:= entry\n"),
               (6, "\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n\tI\t:= internal\n\tW\t:= word\n"),
               (7, "\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tPR\t:= procedure\n")):
    DIAG["k%d" % _n] = (_H % _n) + _b + "end k%d_\n" % _n


def asbefehl(x, quelle):
    """Commands (a LIST: the guest tty line holds < ca. 240 characters, W7u) for one input: the original as, our as and, with
    --asx2, our second as, each in /tmp (the as temporaries go there); the messages of all runs append to X.e (in the order
    original, ours, second).  There is no exit status: the guest has no `echo` that the root shell finds, so the former
    `echo st=$?` (also an assignment for the V7 sh) never wrote anything (measured W7u)."""
    q = quelle        # "/mnt/X.s" (source disk) or "c_X.s" (compiler output in /tmp, the cwd of these commands)
    c = ["cd /tmp;/usr/bin/as -u -o %s.o %s >%s.e 2>&1;cd /mnt" % (x, q, x),
         "cd /tmp;/mnt/asx -u -o %s.n %s >>%s.e 2>&1;cd /mnt" % (x, q, x)]
    if ZWEI:
        c.append("cd /tmp;/mnt/asy -u -o %s.m %s >>%s.e 2>&1;cd /mnt" % (x, q, x))
    return c


KERN = os.path.join(U.REPO, "kernel", "asm", "ref")


def lauf(asx, libc_max, progs, kern=(), nodiag=False, only=None, asx2=None):
    global ZWEI
    ZWEI = bool(asx2)
    sys.path.insert(0, os.path.join(U.TOOLS, "kernel"))
    import gast_as
    U.pruefe()
    U.emu.build()
    q, bs, ein, rueck = {}, [], [], []
    for n in progs:
        mods, koepfe = G.quellen(n)
        q.update(koepfe)
        for f, t in mods.items():
            m = f[:-2]
            if only and m not in only:
                continue
            q[f] = t
            e = "c_%s.err" % m
            bs.append("cd /tmp;/usr/lib/cpp -I/mnt /mnt/%s ci >%s 2>&1;/usr/lib/c0 ci c1 c2 >>%s 2>&1;>ci;cd /mnt" % (f, e, e))
            bs.append("cd /tmp;/usr/lib/c1 c1 c2 c5 >>%s 2>&1;>c1;>c2;/usr/lib/c2 c5 c_%s.s >>%s 2>&1;>c5;cd /mnt" % (e, m, e))
            bs.extend(asbefehl("c_" + m, "c_%s.s" % m))
            ein.append("c_" + m)
            rueck += ["c_%s.s" % m, e]
    # minimal inputs first: they show at which construct our as stops (d_*.s)
    for x, t in ({} if nodiag else DIAG).items():
        q[x + ".s"] = t
        bs.extend(asbefehl("d_" + x, "/mnt/" + x + ".s"))
        ein.append("d_" + x)
    # W7u: the kernel's own .s files (reference disassembly, kernel/asm/ref): input k_<module>, file k_<module>.s on /mnt
    for m in kern:
        f = "k_%s.s" % m
        q[f] = open(os.path.join(KERN, m + ".s"), "rb").read()
        bs.extend(asbefehl("k_" + m, "/mnt/" + f))
        ein.append("k_" + m)
    for f in sorted(os.listdir(LIBC)):
        if f.endswith(".s") and len(ein) < libc_max:
            x = f[:-2]
            q[f] = open(os.path.join(LIBC, f), "rb").read()
            bs.extend(asbefehl("l_" + x, "/mnt/" + f))
            ein.append("l_" + x)
    q["asx"] = open(asx, "rb").read()
    if asx2:
        q["asy"] = open(asx2, "rb").read()
    for x in ein:
        rueck += [x + ".o", x + ".n", x + ".e"] + ([x + ".m"] if asx2 else [])
    # W7r: the /tmp disk (3 files per input + compiler outputs) ran out of INODES (200) after ~50 inputs ("I can not creat");
    # clear stale results of earlier runs (old .n files would otherwise be evaluated again)
    shutil.rmtree(os.path.join(WORK), ignore_errors=True)
    ar = os.path.join(WORK, "sess")
    aus = {}
    r = gast_as.gast_befehle(ar, q, bs, rueck, frist=20_000_000_000, ausgabe=aus, ausfuehrbar=("asx", "asy") if asx2 else ("asx",), tmp_inodes=500)
    print("%d s wall clock, %d inputs" % (aus.get("dauer", 0), len(ein)), flush=True)
    os.makedirs(WORK, exist_ok=True)
    for k, v in r.items():
        if v is not None:
            open(os.path.join(WORK, k), "wb").write(v)
    open(os.path.join(WORK, "inputs.txt"), "w").write("\n".join(ein) + "\n")


def kopf(b):
    """a.out header (16 bytes, 8 words big endian); field meaning *assumed*."""
    return struct.unpack(">8H", b[:16]) if len(b) >= 16 else ()


def auswerten():
    ein = open(os.path.join(WORK, "inputs.txt")).read().split()
    gleich = beide = gleich2 = 0
    ZWEI_AUS = any(os.path.exists(os.path.join(WORK, x + ".m")) for x in ein)      # a second as was run (--asx2)
    for x in ein:
        def rd(s):
            p = os.path.join(WORK, x + s)
            b = open(p, "rb").read() if os.path.exists(p) else None
            return b if (b or s == ".e") else None      # an empty .o (creat, then fatal()) is no object either
        o, n, e = rd(".o"), rd(".n"), (rd(".e") or b"").decode("latin-1")
        # messages of all runs are in X.e, one after the other (no per-run split, see asbefehl)
        m = rd(".m") if ZWEI_AUS else None
        msg = e.strip().replace("\n", " / ")[:100]
        if ZWEI_AUS:
            same2 = (o is not None and o == m) or (o is None and m is None)
            gleich2 += same2
            print("   asx2 %s: %s the original" % (x, "same as" if same2 else "DIFFERS from"))
        if o is None and n is None:
            beide += 1
            print("%s NO-OBJ (neither run made an .o) messages: %s" % (x, msg))
            continue
        same = o is not None and o == n
        gleich += same
        print("%s %s o=%s n=%s  %s" % (x, "EQUAL" if same else "DIFF", len(o) if o else None, len(n) if n else None, msg))
        if not same and o and n:
            k = next((i for i in range(min(len(o), len(n))) if o[i] != n[i]), min(len(o), len(n)))
            print("   first difference at byte %d; header o=%s n=%s" % (k, kopf(o), kopf(n)))
    print("identical %d of %d (without .o on both sides: %d)" % (gleich, len(ein), beide))
    if gleich2:
        print("asx2 identical (object or equal no-object result): %d" % gleich2)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", choices=["lauf", "auswerten"])
    ap.add_argument("--asx")
    ap.add_argument("--asx2", help="second as of ours in the same session (X.m); auswerten then reports both columns")
    ap.add_argument("--libc", type=int, default=70)
    ap.add_argument("--prog", nargs="*", default=["echo", "cat", "cc"])
    ap.add_argument("--kern", nargs="*", default=[], help="kernel/asm/ref modules to assemble (W7u)")
    ap.add_argument("--only", nargs="*", default=None, help="restrict the --prog modules to these (names without .c)")
    ap.add_argument("--nodiag", action="store_true", help="leave out the d_* minimal inputs")
    a = ap.parse_args()
    if a.cmd == "lauf":
        lauf(a.asx, a.libc, a.prog, a.kern, a.nodiag, a.only, a.asx2)
    else:
        auswerten()


if __name__ == "__main__":
    main()
