"""xcc (Plan 52 W10r): the adapted cc.  Source = userspace/cc/cc.c compiled with -DXCC (everything extra sits under #ifdef XCC).

  xcc.py var                write userspace/cc/work/var/xcc/cc.c (the define line + cc.c) for `pipeline.py bau cc --quelle xcc=...`
  xcc.py tokcheck [--update]  without the define the preprocessed token stream of cc.c must equal that of git rev CC_BASE_REV
                            (md5 in userspace/cc/tokens.md5); exit 1 on a difference
  xcc.py demo XCCBIN C2XBIN               guest session: install c2x + xcc, compare xcc -S -O -X<flags> with c2gegen's c2x run, xcc -O with cc -O
"""
import hashlib
import os
import re
import subprocess
import sys
import tempfile

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import uspace as U   # noqa: E402

CCDIR = os.path.join(U.REPO, "userspace", "cc")
CC_BASE_REV = "4a695c9"     # last commit before the XCC code: the byte-identical cc reconstruction (W13)
HEADERS = ("stdio.h", "ctype.h", "signal.h")


def tokmd5(text, defs=()):
    """md5 of the cpp -P token stream (white space folded to newlines); the system headers are empty stubs so the value is host independent."""
    with tempfile.TemporaryDirectory() as t:
        for h in HEADERS:
            open(os.path.join(t, h), "w").close()
        f = os.path.join(t, "x.c")
        open(f, "w", encoding="latin-1").write(text)
        o = subprocess.run(["cpp", "-P", "-nostdinc", "-I" + t] + ["-D" + d for d in defs] + [f], capture_output=True, check=True).stdout.decode("latin-1")
    return hashlib.md5(re.sub(r"[ \t\n]+", "\n", o).encode("latin-1")).hexdigest()


def tokcheck(update=False):
    mdf = os.path.join(CCDIR, "tokens.md5")
    if update:
        txt = subprocess.run(["git", "-C", U.REPO, "show", CC_BASE_REV + ":userspace/cc/cc.c"], capture_output=True, check=True).stdout.decode("latin-1")
        open(mdf, "w").write("%s  cc.c\n" % tokmd5(txt))
    soll = open(mdf).read().split()[0]
    txt = open(os.path.join(CCDIR, "cc.c"), encoding="latin-1").read()
    ist = tokmd5(txt)
    print("cc.c %s %s" % (ist, "OK" if ist == soll else "DIFFERS (expected %s)" % soll))
    anders = tokmd5(txt, ("XCC",)) != ist
    print("with -DXCC the tokens %s" % ("differ (expected)" if anders else "are equal (XCC code missing?)"))
    return 0 if ist == soll and anders else 1


def var():
    d = os.path.join(CCDIR, "work", "var", "xcc")
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, "cc.c"), "w", encoding="latin-1").write("#define XCC 1\n" + open(os.path.join(CCDIR, "cc.c"), encoding="latin-1").read())
    print(os.path.join(d, "cc.c"))


PROGS = ("df", "rm", "wc", "echo")
REGELN = ("R1", "R4", "R38", "R2", "R7", "R10", "R30", "R32", "R43", "R63", "R5", "R42", "R64")   # all c2x groups (W10o), plus --extra R3 as in W10o/q


def installieren(usr_hfe, xccbin, c2xbin):
    """Install xcc and c2x on a COPY of the usr disk (the guest has no cp/chmod/mv/rm; makes room by dropping libc.a, mcrt0.o): /usr/bin/xcc, /usr/lib/c2x, mode 0755, mtime 1987."""
    import shutil
    d = tempfile.mkdtemp(prefix="xcc_inst_")
    os.makedirs(os.path.join(d, "bin"))
    os.makedirs(os.path.join(d, "lib"))
    shutil.copyfile(xccbin, os.path.join(d, "bin", "xcc"))
    shutil.copyfile(c2xbin, os.path.join(d, "lib", "c2x"))
    dt = U.emu.binary("k1520disktool")
    # the usr disk has only 4 KB free (xcc + c2x need ca. 28 KB): the demo compiles with -c only, so libc.a and mcrt0.o go
    subprocess.run([dt, "rm", usr_hfe, "lib/mcrt0.o", "lib/libc.a"], check=True, capture_output=True)
    subprocess.run([dt, "put", usr_hfe, d], check=True, capture_output=True)
    for n in ("bin/xcc", "lib/c2x"):
        subprocess.run([dt, "attr", usr_hfe, n, "--mode", "0755", "--mtime", "536457600"], check=True, capture_output=True)
    shutil.rmtree(d)


def demo(xccbin, c2xbin):
    """One guest session on a usr disk with xcc and c2x installed (doc/userspace/wk_w10r.md), per module
    (1) xcc -S -O -X<flags> == cpp/c0/c1 + c2x -x<flags> (the c2gegen run),  (2) xcc -S -O == cc -S -O,  (3) xcc -O -c == cc -O -c (object bytes).
    The guest has only cat/ls/sh/sync: results are copied with cat and compared on the host."""
    import shutil
    sys.path.insert(0, os.path.join(U.TOOLS, "kernel"))
    import gast_as
    import c2gegen as G
    U.pruefe()
    U.emu.build()
    usr = os.path.join(CCDIR, "work", "xcc_usr.hfe")
    shutil.copyfile(gast_as.disk(gast_as.PLATTEN["usr.hfe"]), usr)
    installieren(usr, xccbin, c2xbin)
    orig = gast_as.disk
    gast_as.disk = lambda n: usr if n == gast_as.PLATTEN["usr.hfe"] else orig(n)
    q = {}
    b = ["ls -l /usr/lib/c2x /usr/bin/xcc >/tmp/inst.txt 2>&1;cd /mnt"]
    rueck = ["inst.txt"]
    for n in PROGS:
        mods, koepfe = G.quellen(n)
        q.update(koepfe)
        fl = G.c2x_flags(n, REGELN, ("R3",))
        for f, t in mods.items():
            q[f] = t
            m, e = f[:-2], f[:-2] + ".err"
            b.append("cd /tmp;xcc -S -O -X%s -I/mnt /mnt/%s.c >%s 2>&1;cat %s.s >%s.xs;>%s.s;cd /mnt" % (fl, m, e, m, m, m))
            b.append("cd /tmp;/usr/lib/cpp -I/mnt /mnt/%s.c ci >>%s 2>&1;/usr/lib/c0 ci c1 c2 >>%s 2>&1;cd /mnt" % (m, e, e))
            b.append("cd /tmp;/usr/lib/c1 c1 c2 c5 >>%s 2>&1;/usr/lib/c2x -x%s c5 %s.ref >>%s 2>&1;>ci;>c1;>c2;>c5;cd /mnt" % (e, fl, m, e))
            b.append("cd /tmp;xcc -S -O -I/mnt /mnt/%s.c >>%s 2>&1;cat %s.s >%s.xs0;cc -S -O -I/mnt /mnt/%s.c >>%s 2>&1;cd /mnt" % (m, e, m, m, m, e))
            b.append("cd /tmp;xcc -O -c -I/mnt /mnt/%s.c >>%s 2>&1;cat %s.o >%s.xo;cc -O -c -I/mnt /mnt/%s.c >>%s 2>&1;cd /mnt" % (m, e, m, m, m, e))
            rueck += [m + x for x in (".xs", ".ref", ".xs0", ".s", ".xo", ".o", ".err")]
            print("%-6s flags -X%s" % (n + "/" + m, fl))
    ar = os.path.join(CCDIR, "work", "xcc_demo")
    aus = {}
    r = gast_as.gast_befehle(ar, q, b, rueck, frist=20_000_000_000, ausgabe=aus)
    print("%d s wall clock; log %s" % (aus.get("dauer", 0), aus.get("log")))
    print("install:", (r.get("inst.txt") or b"").decode("latin-1"))
    for n in PROGS:
        for f in G.quellen(n)[0]:
            m = f[:-2]
            g = lambda x: r.get(m + x)
            v = lambda a, c: "SAME" if g(a) and g(a) == g(c) else "DIFFERS"
            print("%-8s (1) xcc -X vs c2x: %-7s (2) xcc -S -O vs cc: %-7s (3) xcc -O -c vs cc: %-7s  s %d B, o %d B" % (
                m, v(".xs", ".ref"), v(".xs0", ".s"), v(".xo", ".o"), len(g(".xs") or b""), len(g(".o") or b"")))
            err = (g(".err") or b"<missing>").decode("latin-1").strip().replace("\n", " ")
            if err:
                print("   err:", err[:200])
            ref = os.path.join(G.WORK, n, m + ".sn")
            if os.path.exists(ref) and g(".xs"):
                print("   == W10q gegen/%s.sn: %s" % (m, open(ref, "rb").read() == g(".xs")))


if __name__ == "__main__":
    c = sys.argv[1] if len(sys.argv) > 1 else ""
    if c == "var":
        var()
    elif c == "tokcheck":
        sys.exit(tokcheck("--update" in sys.argv))
    elif c == "demo":
        demo(sys.argv[2], sys.argv[3])
    else:
        sys.exit(__doc__)
