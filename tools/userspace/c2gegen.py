"""Plan 52 W5e: Gegenprobe of the c2 rule model against the ORIGINAL /usr/lib/c2 (doc/userspace/wk_w5e.md).

The rule model (uspace.c2_emu_s and the program-bound sets) rewrites the text that `cc -O -S` delivers.  That text is
ALREADY the output of the shipped /usr/lib/c2.  So the model is a map "shipped c2 output -> output of the c2 that built
the original program".  This tool measures what the shipped c2 does:

  lauf  NAME...   guest: cpp, c0, c1 by hand, then the shipped c2 on c1's output.  Per module NAME/MOD.s0 = c1 output
                  (unoptimized) and NAME/MOD.s = shipped c2 output, under userspace/c2/work/gegen/ (not committed).
                  Several small single-file programs share one session; multi-file programs get their own.
  auswerten NAME... host: model on MOD.s (rule counts, with the program's real C2_AUS and with every rule on), line
                  differences, opcode histograms s0 / s / model.  Writes userspace/c2/gegenprobe.tsv.

  var NAME DEF...  host (W10l): write the variant directory userspace/c2/work/var/NAME/ (c20.c, c21.c, c2.h) with `#define DEF 1`
                  lines in front of both c20.c and c21.c (e.g. `var cm9 XCMPMEM`, `var all9 XPUSH XCMPMEM XHZERO`); the build uses
                  `pipeline.py bau c2 --c2emu --libc alt --quelle NAME=userspace/c2/work/var/NAME`.
  lauf --c2x BIN --auto --regeln R.. --extra R3 [--null]  (W10o) each module runs c2x with `-x<letters>` derived from its program's rule set
                  (c2x_flags; letters in userspace/c2/c2.h); --null adds a flag-less run MOD.sz that must equal MOD.s.
  tokcheck [--update] host (W10l): the default c2 (no defines) must be token-identical to the sources before the first c2x switch
                  (git rev C2_BASE_REV): `cpp -P -I. FILE | tr -s ' \\t\\n' '\\n' | md5sum`, stored in userspace/c2/tokens.md5.
                  Exit 1 on a difference.  --update re-derives the stored md5 from C2_BASE_REV.

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
        # W10w: `noopt` modules (link.txt marker) are compiled without -O and never reach c2 -- skip them (as_y.c hangs the shipped c2)
        ohne = getattr(t, "noopt", ())
        return {f: x for f, x in t.items() if f not in ohne}, koepfe
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


# W10o: c2x run-time flag letters (userspace/c2/c2.h) per rule of the older c2
FLAGBUCHSTABE = {"R1": "p", "R4": "c", "R38": "m", "R2": "z", "R30": "k", "R63": "wW", "R43": "s", "R7": "7", "R3": "3", "R10": "t", "R32": "r", "R5": "5", "R42": "4", "R64": "6", "R45": "e", "R71": "a", "R34": "n", "R6": "d", "R65": "g", "R60": "o", "R70": "q", "R77": "u", "R92": "v", "R97": "f", "R98": "h", "R99": "i", "R100": "j"}


def c2x_flags(name, regeln, extra=()):
    """W10o: the `-x...` argument for program NAME: letters of the rules in regelsatz(name, ...) that c2x implements ('' = no flag)."""
    r = regelsatz(name, regeln, extra)
    # W10t: pseudo rule R5T (only the `ld DST` form of R5, pr) is a letter of its own
    return "".join(FLAGBUCHSTABE[x] for x in FLAGBUCHSTABE if x in r) + ("T" if "R5" in r and "R5T" in P.c2_aus(name) else "")


# W10z: modules that get c2x's flag S (shared strings in copy() above a heap use of XTHR): the one function that does not fit with c2x otherwise
SHARE_MODS = () if os.environ.get("C2GEGEN_NOS") else ("as_code",)   # W10aa: C2GEGEN_NOS=1 measures without flag S


def befehle(mods, c2x=None, c2o=False, s0=False, kurz=False, flags=None, null=False):
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
            fl = ("-x" + flags[m] + " ") if flags and flags.get(m) else ""   # W10o: flags of the module's program
            nf = "- " if os.environ.get("C2GEGEN_N") else ""   # W10z: option `-` prints "<n>K core" (heap peak) to the .err file
            b.append("cd /tmp;/usr/lib/c2 %sc5 %s.s >>%s 2>&1;/mnt/c2x %s%sc5 %s.sn >>%s 2>&1;>c5;cd /mnt" % (nf, m, e, fl, nf, m, e))
            if null:   # c2x without any flag must equal the shipped c2: MOD.sz
                b.append("cd /tmp;cat /mnt/%s.s0 >c5;/mnt/c2x c5 %s.sz >>%s 2>&1;>c5;cd /mnt" % (m, m, e))
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


def lauf(namen, c2x=None, c2o=None, s0=False, kurz=False, regeln=None, extra=(), null=False):
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
        fls = {m: c2x_flags(n, regeln, extra) + ("S" if m in SHARE_MODS else "") for n, m in mods_alle} if regeln else None   # W10o: per-program flags
        bs = befehle([m for _n, m in mods_alle], c2x, bool(c2o), s0, kurz, fls, null)
        ausf = ()
        if c2x:
            q["c2x"] = open(c2x, "rb").read()
            ausf = ("c2x",)
        if c2o:
            q["c2o"] = open(c2o, "rb").read()
            ausf += ("c2o",)
        extra_ = ((".sn",) if kurz else (".sn", ".sm", ".sb", ".sp")) + ((".so",) if c2o else ()) + ((".sz",) if null else ())
        rueck = []
        for n, m in mods_alle:
            rueck += ([] if s0 else [m + ".s0"]) + [m + ".s", m + ".err", m + ".cmp"] + ([m + e for e in extra_] if c2x else [])
        ar = os.path.join(WORK, "sess_%d" % gi)
        print("session %d: %s" % (gi, " ".join(n + "/" + f for n, f in grp)), flush=True)
        aus = {}
        r = gast_as.gast_befehle(ar, q, bs, rueck, frist=20_000_000_000, ausgabe=aus,
                              ausfuehrbar=ausf)
        print("  %d s wall clock" % aus.get("dauer", 0), flush=True)
        for n, m in mods_alle:
            d = os.path.join(WORK, n)
            os.makedirs(d, exist_ok=True)
            for fn in ([] if s0 else [m + ".s0"]) + [m + ".s", m + ".cmp"] + ([m + e for e in extra_] if c2x else []):
                if r.get(fn) is not None:
                    with open(os.path.join(d, fn), "wb") as f:
                        f.write(r[fn])
            # verdict per module: .sn against the shipped c2's .s; a repeat file that is missing was identical (deleted in the guest)
            sn, so_ = r.get(m + ".sn"), r.get(m + ".s")
            if null:
                print("  %-10s flags %-12r no-flag run %s" % (m, fls.get(m) if fls else "", "SAME as shipped c2" if r.get(m + ".sz") == so_ and so_ else "DIFFERS"), flush=True)
            if c2x:
                print("  %-10s s %6d B  sn %6d B  %s  | %s" % (m, len(so_ or b""), len(sn or b""),
                      "IDENTICAL" if sn is not None and sn == so_ else "DIFFERS",
                      " ".join((r.get(m + ".cmp") or b"").decode("latin-1").split("\n"))[:150]), flush=True)
            e = (r.get(m + ".err") or b"").decode("latin-1").strip()
            if e:
                print("  %s messages: %s" % (m, e[:200]))
                print("  %s core: %s" % (m, " ".join(x for x in e.split("\n") if x.endswith("K core"))))


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


def regelsatz(name, regeln, extra=()):
    """W10n: host rule set the real build of program NAME uses for the switch groups under test: (regeln + program-bound extra)
    minus the program's own C2_AUS (pipeline.c2_aus).  Programs built plain (KEIN_MODELL) get no rule."""
    if name in KEIN_MODELL:
        return set()
    return (set(regeln) | set(extra)) - set(P.c2_aus(name))


def xpush(namen, regeln=("R1",), extra=(), global_=False):
    """W10f: acceptance of c2x -xpush.  For every module under WORK/NAME with MOD.sn (output of c2x built with -DXPUSH, from `lauf --c2x
    c2x_c2.bin --s0`) check  MOD.sn == host rules applied to MOD.s (shipped c2 output); the rules are uspace.c2_emu_s with all others off.
    W10g: `regeln` names the active rules (--regeln R4 for -DXCMPMEM, R1,R4 for both switches).
    W10n: the set is per program (regelsatz: regeln + extra - C2_AUS of the program, the same code as the build); global_=True gives the old
    single list.  A difference is classified: (b) when the program has rules of the group OFF (c2x applies them unconditionally, needs a
    finer switch), else (a/c) to be judged by hand."""
    _t, cnt = U.c2_emu_s("", (), False)
    alle = set(cnt)
    ok = bad = 0
    for n in namen:
        d = os.path.join(WORK, n)
        akt = set(regeln) | set(extra) if global_ else regelsatz(n, regeln, extra)
        aus_gr = sorted((set(regeln) | set(extra)) - akt, key=lambda r: int(r[1:]))
        for f in sorted(os.listdir(d)) if os.path.isdir(d) else []:
            if not f.endswith(".sn"):
                continue
            s = open(os.path.join(d, f[:-1]), encoding="latin-1").read()
            sn = open(os.path.join(d, f), encoding="latin-1").read()
            y, c = U.c2_emu_s(s, (alle - akt) | (set(P.c2_aus(n)) & {"R5T"}), False)   # W10t: the pseudo rule R5T (pr) is not a counter key
            if n == "ld":   # W10af: R97-R100 are model rules of ld only (c2_ld_s), applied after c2_emu_s
                y, _c3 = U.c2_ld_s(y)
            tag = "off:" + ",".join(aus_gr) if aus_gr else "off:-"
            if y == sn:
                ok += 1
                print("%-10s %-10s EQUAL    %s" % (n, f[:-3], tag))
            else:
                bad += 1
                a, b = y.split("\n"), sn.split("\n")
                k = next((i for i in range(min(len(a), len(b))) if a[i] != b[i]), min(len(a), len(b)))
                print("%-10s %-10s DIFFERS  %s line %d: model %r  c2x %r" % (n, f[:-3], tag, k + 1,
                      a[k] if k < len(a) else None, b[k] if k < len(b) else None))
    print("xpush %s%s: %d equal, %d differ" % ("+".join(regeln), "" if global_ else " per program" + (" +" + "+".join(extra) if extra else ""), ok, bad))
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


C2DIR = os.path.join(U.REPO, "userspace", "c2")
C2_BASE_REV = "705e611^"     # last commit before the first c2x define (W10f -xpush): the original reconstruction
C2_FILES = ("c20.c", "c21.c")


def var(name, defs):
    """Write userspace/c2/work/var/NAME/{c20.c,c21.c,c2.h}; both modules get the #define lines (hzpass lives in c21.c, its call in c20.c)."""
    d = os.path.join(C2DIR, "work", "var", name)
    os.makedirs(d, exist_ok=True)
    kopf = "".join("#define %s 1\n" % x for x in defs)
    for f in C2_FILES:
        open(os.path.join(d, f), "w", encoding="latin-1").write(kopf + open(os.path.join(C2DIR, f), encoding="latin-1").read())
    open(os.path.join(d, "c2.h"), "wb").write(open(os.path.join(C2DIR, "c2.h"), "rb").read())
    print(d, "defines:", " ".join(defs) or "(none)")


def tokmd5(text):
    """md5 of the cpp -P token stream (white space folded to newlines) of a c2 source text, headers from userspace/c2."""
    import hashlib
    import subprocess
    import tempfile
    with tempfile.TemporaryDirectory() as t:
        f = os.path.join(t, "x.c")
        open(f, "w", encoding="latin-1").write(text)
        o = subprocess.run(["cpp", "-P", "-I" + C2DIR, f], capture_output=True, check=True).stdout.decode("latin-1")
    return hashlib.md5(re.sub(r"[ \t\n]+", "\n", o).encode("latin-1")).hexdigest()


def tokcheck(update):
    import subprocess
    mdf = os.path.join(C2DIR, "tokens.md5")
    if update:
        zeilen = []
        for f in C2_FILES:
            txt = subprocess.run(["git", "-C", U.REPO, "show", C2_BASE_REV + ":userspace/c2/" + f], capture_output=True, check=True).stdout.decode("latin-1")
            zeilen.append("%s  %s" % (tokmd5(txt), f))
        open(mdf, "w").write("\n".join(zeilen) + "\n")
    soll = dict(l.split()[::-1] for l in open(mdf).read().splitlines())
    bad = 0
    for f in C2_FILES:
        ist = tokmd5(open(os.path.join(C2DIR, f), encoding="latin-1").read())
        ok = ist == soll.get(f)
        bad += not ok
        print("%s %s %s" % (f, ist, "OK" if ok else "DIFFERS (expected %s)" % soll.get(f)))
    return bad


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", choices=["lauf", "auswerten", "bauen", "xpush", "var", "tokcheck"])
    ap.add_argument("namen", nargs="*")
    ap.add_argument("--c2x", help="lauf: also run this c2 binary on the same input, output MOD.sn (W10b)")
    ap.add_argument("--c2o", help="lauf: also run this binary (the shipped c2, userspace/c2/work/c2.orig) from /mnt as control, MOD.so (W10c)")
    ap.add_argument("--extra", default="", help="xpush: program-bound rules added to every program's set (W10n, e.g. R3), minus its C2_AUS")
    ap.add_argument("--global", dest="glob", action="store_true", help="xpush: old behaviour, one list for all programs")
    ap.add_argument("--regeln", default="R1", help="xpush: host rules the c2x output must equal (comma list, W10g)")
    ap.add_argument("--auto", action="store_true", help="lauf with --c2x: pass each module the -x flags of its program (c2x_flags from --regeln/--extra, W10o)")
    ap.add_argument("--null", action="store_true", help="lauf with --c2x --kurz: also run c2x WITHOUT flags on the same input (MOD.sz, must equal MOD.s)")
    ap.add_argument("--kurz", action="store_true", help="lauf with --c2x: only the shipped c2 and c2x once each (MOD.s, MOD.sn)")
    ap.add_argument("--s0", action="store_true", help="lauf: skip cpp/c0/c1, take MOD.s0 left by an earlier run (W10c)")
    ap.add_argument("--update", action="store_true", help="tokcheck: re-derive userspace/c2/tokens.md5 from C2_BASE_REV")
    a = ap.parse_args()
    if a.cmd == "var":
        var(a.namen[0], a.namen[1:])
        return
    if a.cmd == "tokcheck":
        sys.exit(1 if tokcheck(a.update) else 0)
    if a.cmd == "lauf":
        lauf(verfuegbar(a.namen), a.c2x, a.c2o, a.s0, a.kurz, tuple(a.regeln.split(",")) if a.auto else None,
             tuple(x for x in a.extra.split(",") if x), a.null)
    elif a.cmd == "bauen":
        bauen(a.namen)
    elif a.cmd == "xpush":
        sys.exit(1 if xpush(a.namen, tuple(a.regeln.split(",")), tuple(x for x in a.extra.split(",") if x), a.glob) else 0)
    else:
        auswerten(a.namen)


if __name__ == "__main__":
    main()
