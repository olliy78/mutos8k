"""Plan 52 W7p: functional check of our reconstructed `as` against the ORIGINAL /usr/bin/as (doc/userspace/wk_w7p.md).

  lauf --asx FILE [--libc N] [--prog NAME...]
      ONE guest session: assembles libc .s members (userspace/libc/*.s) and compiler outputs (cpp, c0, c1, c2 on the
      sources of the given programs, default echo cat cc) with /usr/bin/as and with FILE (our as, put on /mnt as asx).
      Per input X: X.o (original), X.n (ours), X.e (exit status + messages of both).  Result under
      userspace/as/work/gegen/ (not committed).
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
    "t3": "t3_ module\n$NONSEGMENTED\nconstant\n\tFP\t:= r14\n\tSP\t:= r15\n\tX\t:= external\n\tG\t:= global\n\tPR\t:= procedure\n\tE\t:= entry\n"
          "X\t_v\tW\nG\t_f\tPR\nE\n_f:\n\tld\t_v,r4\n\tret\nend _f\nend t3_\n",
}


def asbefehl(x, quelle):
    """Both assemblers on one input (cwd /tmp: the as temporaries go there); exit status and messages go to X.e."""
    return ("cd /tmp;/usr/bin/as -u -o %s.o %s >%s.e 2>&1;echo st=$? >>%s.e;/mnt/asx -u -o %s.n %s >>%s.e 2>&1;"
            "echo st=$? >>%s.e;cd /mnt" % (x, quelle, x, x, x, quelle, x, x))


def lauf(asx, libc_max, progs):
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
            q[f] = t
            e = "c_%s.err" % m
            bs.append("cd /tmp;/usr/lib/cpp -I/mnt /mnt/%s ci >%s 2>&1;/usr/lib/c0 ci c1 c2 >>%s 2>&1;>ci;cd /mnt" % (f, e, e))
            bs.append("cd /tmp;/usr/lib/c1 c1 c2 c5 >>%s 2>&1;>c1;>c2;/usr/lib/c2 c5 c_%s.s >>%s 2>&1;>c5;cd /mnt" % (e, m, e))
            bs.append(asbefehl("c_" + m, "c_%s.s" % m))
            ein.append("c_" + m)
            rueck += ["c_%s.s" % m, e]
    # minimal inputs first: they show at which construct our as stops (d_*.s)
    for x, t in DIAG.items():
        q[x + ".s"] = t
        bs.append(asbefehl("d_" + x, "/mnt/" + x + ".s"))
        ein.append("d_" + x)
    for f in sorted(os.listdir(LIBC)):
        if f.endswith(".s") and len(ein) < libc_max:
            x = f[:-2]
            q[f] = open(os.path.join(LIBC, f), "rb").read()
            bs.append(asbefehl("l_" + x, "/mnt/" + f))
            ein.append("l_" + x)
    q["asx"] = open(asx, "rb").read()
    for x in ein:
        rueck += [x + ".o", x + ".n", x + ".e"]
    # W7r: the /tmp disk (3 files per input + compiler outputs) ran out of INODES (200) after ~50 inputs ("I can not creat");
    # clear stale results of earlier runs (old .n files would otherwise be evaluated again)
    shutil.rmtree(os.path.join(WORK), ignore_errors=True)
    ar = os.path.join(WORK, "sess")
    aus = {}
    r = gast_as.gast_befehle(ar, q, bs, rueck, frist=20_000_000_000, ausgabe=aus, ausfuehrbar=("asx",), tmp_inodes=500)
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
    gleich = beide = 0
    for x in ein:
        def rd(s):
            p = os.path.join(WORK, x + s)
            b = open(p, "rb").read() if os.path.exists(p) else None
            return b if (b or s == ".e") else None      # an empty .o (creat, then fatal()) is no object either
        o, n, e = rd(".o"), rd(".n"), (rd(".e") or b"").decode("latin-1")
        # status/messages of both assemblers: X.e holds "<orig msgs>st=N\n<our msgs>st=N\n" (split at the first st= line)
        parts = e.split("st=")          # [msgs_o, "N\nmsgs_n", "M\n"]
        if len(parts) == 3:
            mo, mn = parts[0].strip(), parts[1].split("\n", 1)[1].strip()
            so, sn = parts[1].split("\n", 1)[0], parts[2].strip()
        else:
            mo = mn = so = sn = "?"
        if o is None and n is None:
            beide += 1
            print("%s NO-OBJ (beide ohne .o) status o=%s n=%s msgs %s  | o: %s | n: %s" % (
                x, so, sn, "equal" if mo == mn else "DIFFERENT", mo[:70].replace("\n", " / "), mn[:70].replace("\n", " / ")))
            continue
        same = o is not None and o == n
        gleich += same
        print("%s %s o=%s n=%s  %s" % (x, "EQUAL" if same else "DIFF", len(o) if o else None, len(n) if n else None,
                                       e.replace("\n", " | ")[:160]))
        if not same and o and n:
            k = next((i for i in range(min(len(o), len(n))) if o[i] != n[i]), min(len(o), len(n)))
            print("   first difference at byte %d; header o=%s n=%s" % (k, kopf(o), kopf(n)))
    print("identical %d of %d (without .o on both sides: %d)" % (gleich, len(ein), beide))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", choices=["lauf", "auswerten"])
    ap.add_argument("--asx")
    ap.add_argument("--libc", type=int, default=70)
    ap.add_argument("--prog", nargs="*", default=["echo", "cat", "cc"])
    a = ap.parse_args()
    if a.cmd == "lauf":
        lauf(a.asx, a.libc, a.prog)
    else:
        auswerten()


if __name__ == "__main__":
    main()
