"""Plan 52 W5e: Gegenprobe of the c2 rule model against the ORIGINAL /usr/lib/c2 (doc/userspace/wk_w5e.md).

The rule model (uspace.c2_emu_s and the program-bound sets) rewrites the text that `cc -O -S` delivers.  That text is
ALREADY the output of the shipped /usr/lib/c2.  So the model is a map "shipped c2 output -> output of the c2 that built
the original program".  This tool measures what the shipped c2 does:

  lauf  NAME...   guest: cpp, c0, c1 by hand, then the shipped c2 on c1's output.  Per module NAME/MOD.s0 = c1 output
                  (unoptimized) and NAME/MOD.s = shipped c2 output, under userspace/c2/work/gegen/ (not committed).
                  Several small single-file programs share one session; multi-file programs get their own.
  auswerten NAME... host: model on MOD.s (rule counts, with the program's real C2_AUS and with every rule on), line
                  differences, opcode histograms s0 / s / model.  Writes userspace/c2/gegenprobe.tsv.

Run with python3 -I.  Guest runs take minutes: the caller runs them in the foreground, one at a time.
"""
import argparse
import os
import re
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import uspace as U       # noqa: E402
import pipeline as P     # noqa: E402

WORK = os.path.join(U.REPO, "userspace", "c2", "work", "gegen")
# programs whose original is byte-identical to the PLAIN cc -O build (measured here: mt; sync, rm, pstat have no active rule)
KEIN_MODELL = {"mt"}
LIMIT = 14_000           # source bytes per shared session (the /tmp disk holds ca. 250 KB)


KERN_C = os.path.join(U.REPO, "kernel", "c")
KERN_H = os.path.join(U.REPO, "kernel", "h")


def quellen(name):
    """(modules {file.c: text}, headers {name: bytes}) of program NAME (single file = one module named NAME.c).
    W10f: NAME = k_MOD is the kernel module kernel/c/MOD.c with all of kernel/h as headers (the guest module is MOD.c)."""
    if name.startswith("k_"):
        txt = open(os.path.join(KERN_C, name[2:] + ".c"), encoding="latin-1").read()
        hs = {h: open(os.path.join(KERN_H, h), "rb").read() for h in os.listdir(KERN_H) if h.endswith(".h")}
        return {name[2:] + ".c": txt}, hs
    class A:
        quelle = None
        variante = "neu"
        libc = "disk"
        kopf = None
    v, koepfe = P.quellen_lesen(name, A)
    t = v["neu"]
    if isinstance(t, dict):
        return t, koepfe
    return {name + ".c": t}, koepfe


def verfuegbar(namen):
    erg = []
    for n in namen:
        if n.startswith("k_"):
            if os.path.isfile(os.path.join(KERN_C, n[2:] + ".c")):
                erg.append(n)
            else:
                print("unknown:", n)
            continue
        try:
            _pl, _pf, q, _h = P.info(n)
        except SystemExit:
            print("unknown:", n)
            continue
        p = os.path.join(U.REPO, q)
        if os.path.isdir(p) and not any(f.endswith(".c") for f in os.listdir(p)):
            print("no sources:", n)
            continue
        if not os.path.exists(p):
            print("no sources:", n)
            continue
        erg.append(n)
    return erg


def befehle(mods, c2x=None, c2o=False, s0=False, kurz=False):
    """Guest commands for the modules (names without .c).  Every command ends in /mnt, none is longer than ca. 200 characters."""
    b = []
    for m in mods:
        e = m + ".err"
        if s0:   # W10c: the c1 output is already on /mnt as MOD.s0 (kept from an earlier run): only the c2 runs
            b.append("cd /tmp;cat /mnt/%s.s0 >c5;cd /mnt" % m)
        else:
            b.append("cd /tmp;/usr/lib/cpp -I/mnt /mnt/%s.c ci >%s 2>&1;/usr/lib/c0 ci c1 c2 >>%s 2>&1;>ci;cd /mnt" % (m, e, e))
            b.append("cd /tmp;/usr/lib/c1 c1 c2 c5 >>%s 2>&1;>c1;>c2;cat c5 >%s.s0;cd /mnt" % (e, m))   # c1 output = unoptimized text
        if c2x and kurz:   # W10f: one run each of the shipped c2 (MOD.s) and c2x (MOD.sn), no repeat runs (-xpush acceptance)
            b.append("cd /tmp;/usr/lib/c2 c5 %s.s >>%s 2>&1;/mnt/c2x c5 %s.sn >>%s 2>&1;>c5;cd /mnt" % (m, e, m, e))
        elif c2x:   # also run the given c2 binary (on /mnt) on the same c1 output: MOD.sn
            # /tmp is small: every repeat run is compared in the guest with cmp and deleted when identical (the file is then
            # missing in the result and MOD.cmp is empty for it); a file that stays is the one that differs
            b.append("cd /tmp;/usr/lib/c2 c5 %s.s >>%s 2>&1;/mnt/c2x c5 %s.sn >>%s 2>&1;cmp %s.s %s.sn >%s.cmp 2>&1;cd /mnt" % (m, e, m, e, m, m, m))
            b.append("cd /tmp;/mnt/c2x c5 %s.sm >>%s 2>&1;cmp %s.sn %s.sm >>%s.cmp 2>&1&&rm %s.sm;cd /mnt" % (m, e, m, m, m, m))
            # our c2 with the shell redirecting stdout (no freopen of stdout): MOD.sp
            b.append("cd /tmp;/mnt/c2x <c5 >%s.sp 2>>%s;cmp %s.sn %s.sp >>%s.cmp 2>&1&&rm %s.sp;cd /mnt" % (m, e, m, m, m, m))
            b.append("cd /tmp;/usr/lib/c2 c5 %s.sb >>%s 2>&1;cmp %s.s %s.sb >>%s.cmp 2>&1&&rm %s.sb;cd /mnt" % (m, e, m, m, m, m))
            if c2o:   # the shipped binary run from /mnt: separates "run from /mnt" from "our code"
                b.append("cd /tmp;/mnt/c2o c5 %s.so >>%s 2>&1;cmp %s.s %s.so >>%s.cmp 2>&1&&rm %s.so;cd /mnt" % (m, e, m, m, m, m))
            b.append("cd /tmp;>c5;cd /mnt")
        else:
            b.append("cd /tmp;/usr/lib/c2 c5 %s.s >>%s 2>&1;>c5;cd /mnt" % (m, e))                  # shipped c2 on it
    return b


def lauf(namen, c2x=None, c2o=None, s0=False, kurz=False):
    sys.path.insert(0, os.path.join(U.TOOLS, "kernel"))
    import gast_as
    U.pruefe()
    U.emu.build()
    # items = (program, module file); /tmp holds ca. 250 KB and s0 + s of every module stay there, so one session takes
    # modules up to LIMIT source bytes (a full disk shows as "Binary expression botch" / truncated output)
    jobs = {n: quellen(n) for n in namen}
    if s0:   # modules whose MOD.s0 an earlier run left under WORK/NAME/: those only (no sources needed in the guest)
        jobs = {n: ({f: t for f, t in jobs[n][0].items()
                     if os.path.exists(os.path.join(WORK, n, f[:-2] + ".s0"))}, jobs[n][1]) for n in namen}
    items = [(n, f, len(t)) for n in namen for f, t in jobs[n][0].items()]
    gruppen, akt, gr = [], [], 0
    for n, f, ln in items:
        if akt and gr + ln > LIMIT:
            gruppen.append(akt)
            akt, gr = [], 0
        akt.append((n, f))
        gr += ln
    if akt:
        gruppen.append(akt)
    for gi, grp in enumerate(gruppen):
        q, mods_alle = {}, []
        for n, f in grp:
            if s0:
                q[f[:-2] + ".s0"] = open(os.path.join(WORK, n, f[:-2] + ".s0"), "rb").read()
            else:
                q[f] = jobs[n][0][f]
                q.update(jobs[n][1])
            mods_alle.append((n, f[:-2]))
        bs = befehle([m for _n, m in mods_alle], c2x, bool(c2o), s0, kurz)
        ausf = ()
        if c2x:
            q["c2x"] = open(c2x, "rb").read()
            ausf = ("c2x",)
        if c2o:
            q["c2o"] = open(c2o, "rb").read()
            ausf += ("c2o",)
        extra = ((".sn",) if kurz else (".sn", ".sm", ".sb", ".sp")) + ((".so",) if c2o else ())
        rueck = []
        for n, m in mods_alle:
            rueck += ([] if s0 else [m + ".s0"]) + [m + ".s", m + ".err", m + ".cmp"] + ([m + e for e in extra] if c2x else [])
        ar = os.path.join(WORK, "sess_%d" % gi)
        print("session %d: %s" % (gi, " ".join(n + "/" + f for n, f in grp)), flush=True)
        aus = {}
        r = gast_as.gast_befehle(ar, q, bs, rueck, frist=20_000_000_000, ausgabe=aus,
                              ausfuehrbar=ausf)
        print("  %d s wall clock" % aus.get("dauer", 0), flush=True)
        for n, m in mods_alle:
            d = os.path.join(WORK, n)
            os.makedirs(d, exist_ok=True)
            for fn in ([] if s0 else [m + ".s0"]) + [m + ".s", m + ".cmp"] + ([m + e for e in extra] if c2x else []):
                if r.get(fn) is not None:
                    with open(os.path.join(d, fn), "wb") as f:
                        f.write(r[fn])
            # verdict per module: .sn against the shipped c2's .s; a repeat file that is missing was identical (deleted in the guest)
            sn, so_ = r.get(m + ".sn"), r.get(m + ".s")
            if c2x:
                print("  %-10s s %6d B  sn %6d B  %s  | %s" % (m, len(so_ or b""), len(sn or b""),
                      "IDENTICAL" if sn is not None and sn == so_ else "DIFFERS",
                      " ".join((r.get(m + ".cmp") or b"").decode("latin-1").split("\n"))[:150]), flush=True)
            e = (r.get(m + ".err") or b"").decode("latin-1").strip()
            if e:
                print("  %s messages: %s" % (m, e[:200]))


def modell(name, s, aus=None):
    """Model output for one module text: the pipeline's sequence.  aus: rules switched off (default: the program's own set)."""
    aus = P.c2_aus(name) if aus is None else aus
    t, cnt = U.c2_emu_s(s, aus, name == "mkfs", name == "ed", name == "tar", name == "cc", name == "c0")
    if name == "ld":
        t, c3 = U.c2_ld_s(t)
        cnt.update(c3)
    if name == "cpp":
        t, c3 = U.c2_cpp_s(t)
        cnt.update(c3)
    return t, {k: v for k, v in cnt.items() if v}


OP = re.compile(r"^([a-z][a-z0-9]*)(\t|$)")


def histo(s):
    h = {}
    for z in s.split("\n"):
        m = OP.match(z)
        if m:
            h[m.group(1)] = h.get(m.group(1), 0) + 1
    return h


def regeln_je_programm(name, s):
    """{rule: (state, sites)} for one module text.  state 'active': the rule is on for the program and fires `sites` times
    (the original has the rewritten form there, the shipped c2 does not make it).  state 'aus': the rule is switched off for the
    program (its original has the shipped c2's form); `sites` = how often it WOULD fire when switched on alone (the other
    switched-off rules stay off), i.e. sites where the shipped c2 does what the original does and the rule would break it."""
    erg = {}
    _y, ca = modell(name, s)
    if name in KEIN_MODELL:       # built plain (no model): every site of the model is a site where the original has the shipped form
        return {r: ("aus", v) for r, v in ca.items()}
    for r, v in ca.items():
        erg[r] = ("active", v)
    base = set(P.c2_aus(name))
    for r in sorted(base):
        _y, cb = modell(name, s, base - {r})
        if cb.get(r):
            erg[r] = ("aus", cb[r])
    return erg


def auswerten(namen):
    import difflib
    zeilen = ["program\tmodule\tlines_s0\tlines_s\tlines_model\tdiff_s_model\trule:state:sites"]
    regel = {}
    histos = {}
    for n in namen:
        d = os.path.join(WORK, n)
        if not os.path.isdir(d):
            print("no data:", n)
            continue
        for f in sorted(os.listdir(d)):
            if not f.endswith(".s"):
                continue
            s = open(os.path.join(d, f), encoding="latin-1").read()
            s0p = os.path.join(d, f + "0")
            s0 = open(s0p, encoding="latin-1").read() if os.path.isfile(s0p) else ""
            y, _ = modell(n, s)
            zs, zy = s.split("\n"), y.split("\n")
            nd = sum(1 for x in difflib.ndiff(zs, zy) if x[:1] in "+-")
            rr = regeln_je_programm(n, s)
            for r, (st, v) in rr.items():
                regel.setdefault(r, {}).setdefault(st, {})
                regel[r][st][n] = regel[r][st].get(n, 0) + v
            for k, t in (("s0", s0), ("s", s), ("model", y)):
                for op, c in histo(t).items():
                    histos.setdefault(op, {"s0": 0, "s": 0, "model": 0})[k] += c
            zeilen.append("%s\t%s\t%d\t%d\t%d\t%d\t%s" % (n, f, len(s0.split("\n")) if s0 else 0, len(zs), len(zy), nd,
                          ",".join("%s:%s:%d" % (r, st, v) for r, (st, v) in sorted(rr.items(), key=lambda kv: int(re.sub(r"\D", "", kv[0]) or 0)))))
    out = os.path.join(U.REPO, "userspace", "c2", "gegenprobe.tsv")
    open(out, "w").write("\n".join(zeilen) + "\n")
    print("\n".join(zeilen))
    print("\nrule\tactive (programs: sites)\taus (programs: sites)")
    for r in sorted(regel, key=lambda k: int(re.sub(r"\D", "", k) or 0)):
        fm = lambda dd: " ".join("%s:%d" % kv for kv in sorted(dd.items())) + " [sum %d]" % sum(dd.values()) if dd else "-"
        print("%s\t%s\t%s" % (r, fm(regel[r].get("active", {})), fm(regel[r].get("aus", {}))))
    zr = ["rule\tactive_sites\tactive_programs\taus_sites\taus_programs\tactive_list\taus_list"]
    for r in sorted(regel, key=lambda k: int(re.sub(r"\D", "", k) or 0)):
        a, b = regel[r].get("active", {}), regel[r].get("aus", {})
        zr.append("%s\t%d\t%d\t%d\t%d\t%s\t%s" % (r, sum(a.values()), len(a), sum(b.values()), len(b),
                  " ".join("%s:%d" % kv for kv in sorted(a.items())), " ".join("%s:%d" % kv for kv in sorted(b.items()))))
    open(os.path.join(U.REPO, "userspace", "c2", "gegenprobe_regeln.tsv"), "w").write("\n".join(zr) + "\n")
    print("\nopcode\ts0 (c1)\ts (shipped c2)\tmodel")
    for op in sorted(histos):
        h = histos[op]
        if len({h["s0"], h["s"], h["model"]}) > 1:
            print("%s\t%d\t%d\t%d" % (op, h["s0"], h["s"], h["model"]))


def xpush(namen):
    """W10f: acceptance of c2x -xpush.  For every module under WORK/NAME with MOD.sn (output of c2x built with -DXPUSH, from `lauf --c2x
    c2x_c2.bin --s0`) check  MOD.sn == host rule R1 applied to MOD.s (shipped c2 output); R1 = uspace.c2_emu_s with every other rule off."""
    _t, cnt = U.c2_emu_s("", (), False)
    alle = set(cnt)
    ok = bad = 0
    for n in namen:
        d = os.path.join(WORK, n)
        for f in sorted(os.listdir(d)) if os.path.isdir(d) else []:
            if not f.endswith(".sn"):
                continue
            s = open(os.path.join(d, f[:-1]), encoding="latin-1").read()
            sn = open(os.path.join(d, f), encoding="latin-1").read()
            y, c = U.c2_emu_s(s, alle - {"R1"}, False)
            if y == sn:
                ok += 1
                print("%-10s %-10s R1 sites %3d  c2x == shipped + R1" % (n, f[:-3], c["R1"]))
            else:
                bad += 1
                a, b = y.split("\n"), sn.split("\n")
                k = next((i for i in range(min(len(a), len(b))) if a[i] != b[i]), min(len(a), len(b)))
                print("%-10s %-10s R1 sites %3d  DIFFERS at line %d: model %r  c2x %r" % (n, f[:-3], c["R1"], k + 1,
                      a[k] if k < len(a) else None, b[k] if k < len(b) else None))
    print("xpush: %d equal, %d differ" % (ok, bad))
    return bad


def bauen(namen):
    """Assemble and link, per program, (x) the shipped c2's output unchanged and (y) the model output, with the program's libc_alt
    archive, and compare both bytes with the original (`cmp` of the whole file incl. the 16-byte header).  One guest session at a
    time.  Result lines: NAME: plain(real c2) = EQUAL|differs (n B vs m B) ; model = EQUAL|differs."""
    class A:
        arbeit = None
        platte = None
        pfad = None
        quelle = None
        variante = "neu"
        libc = "alt"
        kopf = None
        ohne_libc = False
    erg = []
    for n in namen:
        d = os.path.join(WORK, n)
        mods = sorted(f for f in os.listdir(d) if f.endswith(".s"))
        ar, (_k, _raw) = P.laden(n, A)
        orig = open(os.path.join(ar, n + ".orig"), "rb").read()
        A.libc = "alt" if os.path.isfile(os.path.join(U.REPO, "userspace", "libc_alt", n, "libc_alt.a")) else "disk"
        _v, koepfe = P.quellen_lesen(n, A)
        libs = sorted(k for k in koepfe if k.startswith("libc_alt"))
        txt = {f: open(os.path.join(d, f), encoding="latin-1").read() for f in mods}
        mod = {f: modell(n, t)[0] for f, t in txt.items()}
        if len(mods) == 1 and mods[0] == n + ".s":
            var = {"x_s": txt[mods[0]], "y_s": mod[mods[0]]}
        else:
            var = {"x": txt, "y": mod}
        r = U.gast_bauen(os.path.join(d, "bau"), var, koepfe, parallel=1, libs=libs)
        zeile = [n + (" (libc " + A.libc + "):")]
        for v, bez in (("x_s" if "x_s" in var else "x", "real c2"), ("y_s" if "y_s" in var else "y", "model")):
            b = r[v]["bin"]
            if b is None:
                zeile.append("%s NO binary (%s)" % (bez, r[v]["err"].strip()[:80]))
            else:
                open(os.path.join(d, "bau", bez.replace(" ", "_") + ".bin"), "wb").write(b)
                zeile.append("%s %s (%d B, original %d B)" % (bez, "EQUAL" if b == orig else "differs", len(b), len(orig)))
        print(" ".join(zeile), flush=True)
        erg.append(" ".join(zeile))
    return erg


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", choices=["lauf", "auswerten", "bauen", "xpush"])
    ap.add_argument("namen", nargs="*")
    ap.add_argument("--c2x", help="lauf: also run this c2 binary on the same input, output MOD.sn (W10b)")
    ap.add_argument("--c2o", help="lauf: also run this binary (the shipped c2, userspace/c2/work/c2.orig) from /mnt as control, MOD.so (W10c)")
    ap.add_argument("--kurz", action="store_true", help="lauf with --c2x: only the shipped c2 and c2x once each (MOD.s, MOD.sn)")
    ap.add_argument("--s0", action="store_true", help="lauf: skip cpp/c0/c1, take MOD.s0 left by an earlier run (W10c)")
    a = ap.parse_args()
    if a.cmd == "lauf":
        lauf(verfuegbar(a.namen), a.c2x, a.c2o, a.s0, a.kurz)
    elif a.cmd == "bauen":
        bauen(a.namen)
    elif a.cmd == "xpush":
        sys.exit(1 if xpush(a.namen) else 0)
    else:
        auswerten(a.namen)


if __name__ == "__main__":
    main()
