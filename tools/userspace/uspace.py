"""Pipeline library for MUTOS user-space programs (plan 42 H7 / plan 43): original binary -> map -> listing ->
libc names -> guest build -> byte comparison.  Python stdlib only; run with `python3 -I`.

Steps (CLI: tools/userspace/pipeline.py, doc: doc/userspace/pipeline.md):
  holen     fetch the program from a finished guest disk, split the 16-byte a.out header, write NAME.raw
  karte     z8kdis map built iteratively (entries from --vorschlaege), listing NAME.lst, strings NAME.strings
  benennen  name libc functions by signature (masked text of lib/libc.a, finde_signaturen.py), write NAME.namen
  bau       compile with the MUTOS cc inside the emulator guest (copies of the disks only), fetch the binary
  vergleich byte comparison and instruction-level diff of a built binary against the original

All guest runs take minutes of wall clock; the caller runs them in the background.  Everything that needs the
emulator raises Fehlt (CLI: exit 77) when it is not there.
"""
import difflib
import os
import re
import struct
import subprocess
import sys
import tempfile
import threading

HIER = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.dirname(HIER)
sys.path.insert(0, TOOLS)
sys.path.insert(0, os.path.join(TOOLS, "kernel"))
import emu            # noqa: E402
import objformat      # noqa: E402
import finde_signaturen as sig   # noqa: E402

REPO = emu.repo()
# short disk names -> finished disk files (disks/gebaut, else the emulator's reference set)
PLATTEN = {n: "a5120_mutos8000_%s_mfm.hfe" % n for n in ("root", "usr", "cmd", "bin", "cc1", "cc2", "nroff")}
SKIP = emu.SKIP


class Fehlt(Exception):
    """A tool or disk is missing (CLI exit 77)."""


def pruefe():
    if emu.fehlt():
        raise Fehlt("emulator project (set K1520EMU)")
    for n in ("root", "usr"):
        if not os.path.isfile(emu.mutos_disk(PLATTEN[n])):
            raise Fehlt(PLATTEN[n])


def _run(args, **kw):
    r = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kw)
    return r.returncode, r.stdout.decode("latin-1"), r.stderr.decode("latin-1")


# ---------------------------------------------------------------- step (a): fetch
KOPF = struct.Struct(">8H")


def kopf_lesen(b):
    """a.out header: (magic, text, data, bss, syms, entry, unused, flag)."""
    if len(b) < 16:
        raise ValueError("file shorter than a header")
    k = KOPF.unpack(b[:16])
    if k[0] not in objformat.A_MAGICS:
        raise ValueError("no a.out magic: %04x" % k[0])
    return k


def platte_holen(platte, pfad, ziel):
    """File `pfad` (e.g. etc/init) from the finished disk `platte` (root|usr|cmd|bin..) -> bytes.  `ziel` = scratch dir."""
    pruefe()
    os.makedirs(ziel, exist_ok=True)
    img = emu.mutos_disk(PLATTEN.get(platte, platte))
    try:                    # `get` refuses to overwrite
        os.remove(os.path.join(ziel, pfad))
    except OSError:
        pass
    rc, o, e = _run([emu.binary("k1520disktool"), "get", img, pfad, "--to", ziel])
    p = os.path.join(ziel, pfad)
    if rc or not os.path.isfile(p):
        raise Fehlt("%s not on %s (%s)" % (pfad, img, (o + e).strip()))
    with open(p, "rb") as f:
        return f.read()


def roh_von(b):
    """(kopf, raw): raw = text+data image without the 16-byte header (text base 0, data directly behind the text)."""
    k = kopf_lesen(b)
    n = k[1] + k[2]
    return k, b[16:16 + n]


def holen(arbeit, name, platte, pfad):
    b = platte_holen(platte, pfad, os.path.join(arbeit, "_hol"))
    k, raw = roh_von(b)
    with open(os.path.join(arbeit, name + ".orig"), "wb") as f:
        f.write(b)
    with open(os.path.join(arbeit, name + ".raw"), "wb") as f:
        f.write(raw)
    return k, raw


# ---------------------------------------------------------------- step (b): map and listing
def z8kdis(args):
    rc, o, e = _run([emu.binary("z8kdis")] + args)
    if rc:
        raise RuntimeError("z8kdis: " + e)
    return o, e


def karte_bauen(rawpfad, laenge, vorab=(), max_runden=10, ohne=()):
    """Iterative map: `seg` + `code 0` + entries from --vorschlaege until nothing new comes.  Returns (kartentext, runden).
    `vorab` = extra map lines (name/kom/db ...) that are kept verbatim."""
    zeilen = ["seg 0 0 %X" % laenge, "code 0"]
    codes = {0}
    tmp = tempfile.mkdtemp(prefix="karte_")
    kp = os.path.join(tmp, "k.txt")
    runden = 0
    for runden in range(1, max_runden + 1):
        with open(kp, "w") as f:
            f.write("\n".join(zeilen + list(vorab)) + "\n")
        o, _ = z8kdis(["--karte", kp, "--vorschlaege", rawpfad])
        neu = [int(m.group(1), 16) for m in re.finditer(r"^code ([0-9A-Fa-f]+)", o, re.M)]
        neu = [a for a in neu if a not in codes and a not in ohne]     # `ohne`: suggestions known to be wrong (data / mid-instruction)
        if not neu:
            break
        for a in neu:
            codes.add(a)
            zeilen.append("code %04X" % a)
    return "\n".join(zeilen + list(vorab)) + "\n", runden, codes


def listing(rawpfad, kartenpfad):
    o, e = z8kdis(["--karte", kartenpfad, "--statistik", rawpfad])
    return o, e


def texte_finden(raw, ab, minlen=3):
    """NUL-terminated printable strings in raw[ab:] -> [(addr, text)]."""
    erg, i = [], ab
    while i < len(raw):
        j = i
        while j < len(raw) and 32 <= raw[j] < 127:
            j += 1
        if j - i >= minlen and j < len(raw) and raw[j] == 0:
            erg.append((i, raw[i:j].decode("ascii")))
            i = j + 1
        else:
            i = max(j, i + 1)
    return erg


FKT = re.compile(r"^(?P<a>[0-9A-F]{4})\s+(?P<b>(?:[0-9A-F]{4}\s?)+?)\s{2,}(?P<m>\S.*)$")


def befehle_lesen(lst):
    """Listing text -> [(addr, bytes_hex, mnemonic text)] (labels and data lines are kept as Befehl lines too; DW lines
    carry the mnemonic 'DW ...')."""
    erg = []
    for z in lst.split("\n"):
        m = FKT.match(z)
        if m:
            erg.append((int(m.group("a"), 16), m.group("b").replace(" ", ""), m.group("m").strip()))
    return erg


def marken_lesen(lst):
    """{label name: address} from the listing (a `name:` line gives the address of the next instruction line)."""
    erg, offen = {}, []
    for z in lst.split("\n"):
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*):$", z)
        if m:
            offen.append(m.group(1))
            continue
        m = FKT.match(z)
        if m:
            for n in offen:
                erg[n] = int(m.group("a"), 16)
        offen = []
    return erg


def aufrufziele(befehle, marken=None):
    """Function start candidates: targets of CALL/CALR (`Lxxxx`, or a label name when `marken` is given)."""
    s = set()
    for a, _b, m in befehle:
        x = re.match(r"(CALL|CALR) (\S+)$", m)
        if not x:
            continue
        t = x.group(2)
        if re.match(r"L[0-9A-F]{4}$", t):
            s.add(int(t[1:], 16))
        elif marken and t in marken:
            s.add(marken[t])
    return s


def funktionen(befehle, starts, textende):
    """[(start, ende)] over the code part: starts sorted, each ends at the next start."""
    st = sorted(x for x in starts if x < textende)
    return [(a, (st[i + 1] if i + 1 < len(st) else textende)) for i, a in enumerate(st)]


# ---------------------------------------------------------------- step (c): libc names
def libc_archiv(arbeit):
    b = platte_holen("usr", "lib/libc.a", os.path.join(arbeit, "_hol"))
    return b


def crt0_objekt(arbeit):
    return platte_holen("usr", "lib/crt0.o", os.path.join(arbeit, "_hol"))


def libc_namen(libc, raw, textende, minlen=14):
    """Signature search: libc members whose masked text occurs word-aligned in raw[:textende].
    Returns [(addr, laenge, name, schwach)] sorted by address (ambiguous matches share the address).
    Weak hits (shorter than minlen or only wildcards) are listed but flagged."""
    erg = []
    for n, ln, treffer, schwach in sig.suche(libc, raw[:textende], minlen):
        for t in treffer:
            erg.append((t, ln, n[:-2] if n.endswith(".o") else n, schwach))
    return sorted(erg)


def eindeutig(treffer):
    """Reduce the matches: keep per address the longest match; drop weak hits that lie inside a longer match."""
    nach_adr = {}
    for a, ln, n, s in treffer:
        nach_adr.setdefault(a, []).append((ln, n, s))
    gut = []
    for a in sorted(nach_adr):
        c = sorted(nach_adr[a], key=lambda e: (e[2], -e[0]))
        ln = max(e[0] for e in c)
        namen = [e[1] for e in c if e[0] == ln]
        gut.append((a, ln, "|".join(sorted(set(namen))), all(e[2] for e in c)))
    erg = []
    letzte = -1
    for a, ln, n, s in gut:
        if a < letzte and s:      # weak hit inside a stronger one
            continue
        erg.append((a, ln, n, s))
        letzte = max(letzte, a + ln)
    return erg


def eigen_ende(namen):
    """End of the program's own code = lowest address of a strong libc match (crt0 sits at 0 and counts as own code)."""
    a = [x[0] for x in namen if not x[3] and x[0] >= 0x30]
    return min(a) if a else None


def namen_schreiben(pfad, namen):
    with open(pfad, "w") as f:
        f.write("# addr length name [weak]  (libc signature matches, tools/userspace/uspace.py)\n")
        for a, ln, n, s in namen:
            f.write("%04X %4d %s%s\n" % (a, ln, n, "  weak" if s else ""))


def namen_lesen(pfad):
    erg = []
    if os.path.isfile(pfad):
        for z in open(pfad):
            if z.strip() and not z.startswith("#"):
                t = z.split()
                erg.append((int(t[0], 16), int(t[1]), t[2], len(t) > 3))
    return erg


def mitglied_symbole(libc):
    """{member name without .o: [(symbol, offset in the member text)]} for the exported text symbols (C name = symbol)."""
    erg = {}
    for m in objformat.Archiv.lesen(libc).mitglieder:
        o = m.objekt()
        erg[m.name.decode("latin-1")[:-2]] = [(x.name.decode("latin-1"), x.wert) for x in o.syms
                                              if x.ext and x.basistyp == objformat.N_TEXT]
    return erg


def kartenzeilen_namen(namen, libc=None):
    """`name` lines for the map.  The label is the exported libc symbol (so `_dup` and `_dup2` in dup.o get their own
    addresses); without symbols or archive the member name with a leading underscore."""
    sym = mitglied_symbole(libc) if libc else {}
    z = []
    for a, _ln, n, s in namen:
        if "|" in n or s:
            continue
        ss = sym.get(n) or [("_" + n, 0)]
        for sn, off in ss:
            z.append("name %04X %s" % (a + off, re.sub(r"[^A-Za-z0-9_]", "_", sn)))
    return z


# ---------------------------------------------------------------- step (d): guest build
STUFEN_AB = 20000     # source size (bytes) from which gast_bauen runs the cc passes one by one


def stufen_befehl(name, lib, nur_s):
    """cc -O [-S] by hand: cpp, c0, c1, c2 (V7 cc.c order, MUTOS paths /usr/lib/.., /usr/bin/as from the strings of `cc`).  Every pass
    truncates the files it consumed (`>file`; there is no `rm` on the guest PATH, the commands disk is not mounted), which frees the blocks.
    Errors go to NAME.err (NAME.err2 for the -S run).  Result: /tmp/NAME (linked by `cc -s -o` like the one-step cc) or /tmp/NAME.s."""
    e = name + (".err2" if nur_s else ".err")
    r = ["cd /tmp", "/usr/lib/cpp -I/mnt /mnt/%s.c ci >%s 2>&1" % (name, e), "/usr/lib/c0 ci c1 c2 >>%s 2>&1" % e, ">ci",
         "/usr/lib/c1 c1 c2 c5 >>%s 2>&1" % e, ">c1", ">c2", "/usr/lib/c2 c5 %s >>%s 2>&1" % (name + ".s" if nur_s else "c3", e), ">c5"]
    if not nur_s:
        r += ["/usr/bin/as -u -o %s.o c3 >>%s 2>&1" % (name, e), ">c3",
              "cc -s -o %s %s.o%s >>%s 2>&1" % (name, name, lib, e), ">%s.o" % name]
    r.append("cd /mnt")
    return ";".join(r)


def gast_bauen(arbeit, varianten, kopfdateien=(), flags="-O -s", asm=False, parallel=4, frist=20_000_000_000,
               log=print, libs=()):
    """varianten: {name: source text (str/bytes)}.  Each variant = its own emulator session (copies of the disks,
    drive A empty /tmp, D = source disk = /mnt) -- sessions run in parallel threads.  Headers in kopfdateien
    ({name: bytes}) are put next to the sources and found with -I/mnt.  `libs` = names of kopfdateien that are archives:
    they are named on the cc command line behind the source, i.e. searched BEFORE -lc (libc_alt, doc/userspace/libc_alt.md).
    Result {name: {"bin": bytes|None, "err": str, "s": str|None, "dauer": sec}}."""
    pruefe()
    sys.path.insert(0, os.path.join(TOOLS, "kernel"))
    import gast_as            # noqa: E402
    emu.build()
    erg = {}
    sperre = threading.Semaphore(parallel)

    def lauf(name, text):
        with sperre:
            if isinstance(text, dict):           # multi-file program: {file.c: text}, link order = list order
                return lauf_viele(name, text)
            ist_s = name.endswith("_s")          # assembler variant: cc assembles and links it
            q = {name + (".s" if ist_s else ".c"): text}
            q.update(kopfdateien)
            # the guest runner appends `cat fertigN` (a file on /mnt): every command must end in /mnt
            fl = "-s" if ist_s else flags
            lib = "".join(" /mnt/" + l for l in libs)
            # Large sources overflow the ~250 KB /tmp disk (all cc temporaries coexist: "no space on dev 4/0"): then the
            # passes are run by hand and each pass deletes its inputs (same commands as cc.c, cc -O only; USERSPACE_STUFEN=1 forces it).
            stufen = (not ist_s) and "-O" in flags.split() and (len(text) > STUFEN_AB or os.environ.get("USERSPACE_STUFEN") == "1")
            if stufen:
                befehle = [stufen_befehl(name, lib, False)]
            else:
                befehle = [("cd /tmp;cc %s -I/mnt -o %s /mnt/%s%s%s >%s.err 2>&1;cd /mnt" % (fl, name, name, ".s" if ist_s else ".c", lib, name))]
            rueck = [name, name + ".err"]
            if asm and not ist_s:
                if stufen:
                    befehle.append(stufen_befehl(name, lib, True))
                else:
                    befehle.append("cd /tmp;cc %s -I/mnt -S /mnt/%s.c >%s.err2 2>&1;cd /mnt" % (flags.replace("-s", "").strip(), name, name))
                rueck += [name + ".s", name + ".err2"]
            aus = {}
            r = gast_as.gast_befehle(os.path.join(arbeit, name), q, befehle, rueck, frist=frist, ausgabe=aus)
            erg[name] = {"bin": r.get(name), "err": (r.get(name + ".err") or b"").decode("latin-1"),
                         "s": (r.get(name + ".s") or b"").decode("latin-1") if asm else None,
                         "dauer": aus.get("dauer", 0.0)}
            log("%s: %s, %d s wall clock" % (name, "binary %d B" % len(r[name]) if r.get(name) else "NO binary",
                                             aus.get("dauer", 0)))
    def lauf_viele(name, dateien):
        """Several .c files (V7 style: each `cc -O -c`, then `cc -s -o NAME *.o` in the given order -- the V7 makefile links
        `*.o`, i.e. alphabetical; the caller passes the files in link order).  Each .c also goes through `cc -S`
        (only with asm) so that per-module .s files come back.  One command per step; every one ends in /mnt."""
        if len(name) + 5 > 14:      # guest file names are cut at 14 characters: NAME.err2 would collide / get lost
            raise ValueError("variant name %r too long: at most 9 characters (NAME.err2 must fit 14)" % name)
        q = dict(dateien)
        q.update(kopfdateien)
        cs = [f for f in dateien if f.endswith((".c", ".s"))]     # .s = rewritten assembler (c2 model): cc assembles it
        cfl = flags.replace("-s", "").strip()
        befehle = []
        rueck = [name, name + ".err"]
        for f in cs:
            befehle.append("cd /tmp;cc %s -c -I/mnt /mnt/%s >>%s.err 2>&1;cd /mnt" % (cfl if f.endswith(".c") else "", f, name))
        lib = "".join(" /mnt/" + l for l in libs)       # libc_alt archives: behind the objects, i.e. before -lc
        # rm *.o afterwards: the /tmp disk (ca. 250 KB) is too small for objects + all .s files + cc's temporaries (xec.s was lost)
        befehle.append("cd /tmp;cc -s -o %s %s%s >>%s.err 2>&1;rm -f *.o;cd /mnt" % (name, " ".join(f[:-2] + ".o" for f in cs), lib, name))
        aus = {}
        r = gast_as.gast_befehle(os.path.join(arbeit, name), q, befehle, rueck, frist=frist, ausgabe=aus)
        sdict = None
        if asm:
            # `cc -S` of all modules does not fit on the /tmp disk next to cc's temporaries: separate short sessions,
            # each with sources of at most 40 KB (the .s is ca. 1.3x the source)
            sdict, gruppen, akt, gr = {}, [], [], 0
            for f in sorted((x for x in cs if x.endswith(".c")), key=lambda x: -len(dateien[x])):
                if akt and gr + len(dateien[f]) > 40_000:
                    gruppen.append(akt)
                    akt, gr = [], 0
                akt.append(f)
                gr += len(dateien[f])
            if akt:
                gruppen.append(akt)
            for gi, grp in enumerate(gruppen):
                qs = {f: dateien[f] for f in dateien}
                qs.update(kopfdateien)
                bs = ["cd /tmp;cc %s -S -I/mnt /mnt/%s >>%s.err2 2>&1;cd /mnt" % (cfl, f, name) for f in grp]
                rs = [f[:-2] + ".s" for f in grp] + [name + ".err2"]
                rr = gast_as.gast_befehle(os.path.join(arbeit, "%s_s%d" % (name, gi)), qs, bs, rs, frist=frist, ausgabe={})
                for f in grp:
                    sdict[f[:-2] + ".s"] = (rr.get(f[:-2] + ".s") or b"").decode("latin-1")
        erg[name] = {"bin": r.get(name), "err": (r.get(name + ".err") or b"").decode("latin-1"),
                     "s": sdict, "dauer": aus.get("dauer", 0.0)}
        log("%s: %s, %d s wall clock" % (name, "binary %d B" % len(r[name]) if r.get(name) else "NO binary", aus.get("dauer", 0)))

    ts = [threading.Thread(target=lauf, args=(n, t)) for n, t in varianten.items()]
    for t in ts:
        t.start()
    for t in ts:
        t.join()
    return erg


def c2_emu_s(s, aus=(), mkfs=False):
    """Rewrite a `cc -O -S` assembler source so that it reads as the ORIGINAL (older) c2 would have emitted it -- inverse
    of c2_kanon on the .s text (as dialect, hex numbers with %):
      R1  `inc SP,#%k ; ld @SP,x`  ->  `inc SP,#%k+2 ; push @SP,x`
      R2  `xorb rhN,rhN ; ldb mem,rlN` (mem not a register)  ->  XORB dropped
      R3  `xorb rhN,rhN ; cp .. ; jr cc L ; jr M`  ->  `xorb rhN,rhN` inserted before the final `jr M`
      R4  `cp MEM,#k` (MEM not a register, not @reg) -> `ld r0,MEM ; cp r0,#k`; a following `cp MEM,#k2` directly
          behind a `jr cc` of the same chain reuses R0 (`cp r0,#k2`)   (cat/date/ls, login/getty/mount/umount)
      R5  `ld rA,rB ; test rB` -> `test rA`;  `ld rA,rB ; ld DST,rB` -> `ld DST,rA` (no copy propagation)
      R6  `ld rA,M ; testb @rA ; jr cc ; ld rB,rA` -> `ld rB,M`
      R7  `ldb rlN,mem ; cp rN,..` -> `xorb rhN,rhN` inserted between
      R8  `ldb rlA,MEM ; xorb rhA,rhA ; ldb rlB,rlA`  ->  `... ; ldb rlB,MEM`  (no register copy for a reloaded byte)
      R9  `and rX,#k ; or rA,rX` (X=A+2)  ->  `and ; ld rA+1,rX ; or rA,rA+1`
      R10 `xorb rhN,rhN ; cp rN,.. ; jr cc L ; add rN,..`  ->  `xorb rhN,rhN` inserted behind the `jr cc` (stty prmodes, 2x;
          generalises R3: the original re-zeroes RHn before the first full-register use behind a conditional jump)
      R30 exception to R2: `xorb rhN,rhN ; ldb mem,rlN ; testb rlN` (value of an assignment tested) keeps the XORB
          (mount, 2x; MODEL of the old c2, not a run of it)
    (R4..R9 were found independently on two branches and merged; numbering of doc/userspace/system_befehle.md
    R5/R6 = R8 / R5+R9 here.)
    Returns (new text, {rule: count}).  Assembling the result with the guest `as` shows whether the rules explain ALL
    differences of the own code (doc/userspace/init.md)."""
    z = s.split("\n")
    out, n = [], {"R1": 0, "R2": 0, "R3": 0, "R4": 0, "R5": 0, "R6": 0, "R7": 0, "R8": 0, "R9": 0, "R10": 0, "R30": 0, "R11": 0, "R12": 0, "R13": 0, "R14": 0, "R16": 0,
         "R32": 0, "R33": 0, "R34": 0, "R35": 0, "R36": 0, "R37": 0, "R38": 0, "R39": 0, "R42": 0, "R43": 0, "R45": 0, "R46": 0, "R47": 0, "R48": 0, "R60": 0, "R61": 0, "R62": 0, "R63": 0, "R64": 0, "R65": 0, "R66": 0, "R67": 0, "R68": 0, "R69": 0, "R70": 0, "R71": 0, "R77": 0}
    i = 0
    stored = {}         # R48: rN -> memory operand it was last stored to (word)
    bytemem = {}        # R12: rlN -> memory operand it was last stored to
    r0mem = None        # R4: memory operand currently mirrored in R0 by an emitted `ld r0,mem ; cp r0,#k`
    while i < len(z):
        a = z[i]
        b = z[i + 1] if i + 1 < len(z) else ""
        m1 = re.match(r"inc\tSP,#%([0-9A-F]+)$", a)
        m2 = re.match(r"ld\t@SP,(.*)$", b)
        if m1 and m2 and "R1" not in aus:
            out.append("inc\tSP,#%%%X" % (int(m1.group(1), 16) + 2))
            out.append("push\t@SP," + m2.group(1))
            n["R1"] += 1
            i += 2
            continue
        # R71  `ld rA,%k(FP) ; ld rB,rA ; jr L` (`p2 = s; for (p1 = s; ...)`, two register variables from the same argument): the original loads
        #      both from the argument, `... ; ld rB,%k(FP) ; jr L` (ar trim(), 1x; MODEL of the old c2, not a run of it)
        m71 = re.match(r"ld\t(r\d+),(%[0-9A-F]+\(FP\))$", a)
        if m71 and "R71" not in aus and re.match(r"ld\t(r\d+),%s$" % m71.group(1), b) and re.match(r"jr\tL\d+$", z[i + 2] if i + 2 < len(z) else ""):
            out += [a, "ld\t%s,%s" % (re.match(r"ld\t(r\d+),", b).group(1), m71.group(2))]
            n["R71"] += 1
        # R77  `ldb rl2,@r13 ; xorb rh2,rh2 ; cp r2,#%1 ; jp ne,L` -> `jr ne,L` (ps pstatus: `if (pp->p_stat == SSLEEP)` with the long switch behind it; the original c2/as
        #      chose the short jump for a span of 0xA8 bytes where the shipped c2 keeps `jp`; 1 site, MODEL of the old c2, not a run of it)
        m77 = re.match(r"jp\tne\t(L\d+)$", b)
        if ("R77" not in aus and a == "cp\tr2,#%1" and m77 and len(out) > 1 and out[-1] == "xorb\trh2,rh2" and out[-2] == "ldb\trl2,@r13"):
            out += [a, "jr\tne\t" + m77.group(1)]
            n["R77"] += 1
            i += 2
            continue
        # R63  `xorb rhN,rhN ; ldb @rM,rlN ; ld rK,rN ; ld rX,rN ; test rN` (`while ((c = *s++ = *t++))` with register c): exception to R2 (the XORB stays) and
        #      the original works on the copy: `... ; ld rK,rN ; ld rX,rK ; test rK` (mv 1x; MODEL of the old c2, not a run of it)
        x63 = re.match(r"xorb\trh(\d),rh\1$", a)
        if x63 and "R63" not in aus and i + 4 < len(z):
            r = x63.group(1)
            c63 = re.match(r"ld\t(r\d+),r%s$" % r, z[i + 2])
            d63 = re.match(r"ld\t(r\d+),r%s$" % r, z[i + 3])
            if re.match(r"ldb\t@r\d+,rl%s$" % r, b) and c63 and d63 and z[i + 4] == "test\tr" + r:
                out += [a, b, z[i + 2], "ld\t%s,%s" % (d63.group(1), c63.group(1)), "test\t" + c63.group(1)]
                n["R63"] += 1
                i += 5
                continue
        x = re.match(r"xorb\t(rh\d),(rh\d)$", a)
        if x and x.group(1) == x.group(2):
            y = re.match(r"ldb\t([^,]+),r([hl]\d)$", b)
            if y and not re.match(r"r[hl]\d$", y.group(1)) and y.group(2) == "l" + x.group(1)[2:] and "R2" not in aus:
                # R30  exception to R2: the stored byte is tested right away (value of `(*p++ = *q++) == 0`) -> XORB stays
                if re.match(r"testb\trl%s$" % x.group(1)[2:], z[i + 2] if i + 2 < len(z) else ""):
                    n["R30"] += 1
                    out.append(a)
                    i += 1
                    continue
                # R43  exception to R2: `inc rK,#%n(n>1) ; ldb rlN,@rK ; xorb rhN ; ldb @rM,rlN` (copy of a struct member array element,
                #      ncheck `hp->h_name[k] = dp->d_name[k]`, 1x; post-increment copies `inc rK,#1` still drop the XORB) keeps the XORB
                src36 = re.match(r"ldb\trl%s,@(r\d+)$" % x.group(1)[2:], z[i - 1]) if i >= 2 else None
                if (src36 and "R43" not in aus and b.startswith("ldb	@r") and re.match(r"inc\t%s,#%%([2-9A-F]|[0-9A-F]{2,})$" % src36.group(1), z[i - 2])):
                    n["R43"] += 1
                    out.append(a)
                    i += 1
                    continue
                n["R2"] += 1
                i += 1
                continue
            c = z[i + 1] if i + 1 < len(z) else ""
            j = z[i + 2] if i + 2 < len(z) else ""
            k = z[i + 3] if i + 3 < len(z) else ""
            if ("R3" not in aus and re.match(r"cp\t", c) and re.match(r"jr\t\w+\tL\d+$", j) and re.match(r"jr\tL\d+$", k)
                    and (i + 4 >= len(z) or not z[i + 4].startswith("xorb"))):
                out += [a, c, j, a, k]
                n["R3"] += 1
                i += 4
                continue
            # R10  `xorb rhN ; cp rN,.. ; jr cc L ; add rN,..` -> the original zeroes rhN again before the add
            if ("R10" not in aus and re.match(r"cp\tr%s," % x.group(1)[2:], c) and re.match(r"jr\t\w+\tL\d+$", j)
                    and re.match(r"add\tr%s," % x.group(1)[2:], k)):
                out += [a, c, j, a]
                n["R10"] += 1
                i += 3
                continue
            # R32  `xorb rhN ; cp rN,.. ; jr cc L ; cp rN,..` (chained char range test) -> rhN zeroed again before the 2nd cp (kill 1x)
            if ("R32" not in aus and re.match(r"cp\tr%s," % x.group(1)[2:], c) and re.match(r"jr\t\w+\tL\d+$", j)
                    and re.match(r"cp\tr%s," % x.group(1)[2:], k)):
                out += [a, c, j, a]
                n["R32"] += 1
                i += 3
                continue
        # R7  `ldb rlN,mem ; cp rN,..` (new c2 knows rhN is still zero) -> the original zeroes it again: `xorb rhN,rhN` inserted
        l7 = re.match(r"ldb\trl(\d),[^r]", a)
        if l7 and "R7" not in aus and re.match(r"cp\tr%s," % l7.group(1), b):
            out += [a, "xorb\trh%s,rh%s" % (l7.group(1), l7.group(1))]
            n["R7"] += 1
            i += 1
            continue
        # R6  `ld rA,M ; testb @rA ; jr cc L ; ld rB,rA` -> `ld rB,M` (the original does not forward the loaded value)
        l6 = re.match(r"ld\t(r\d+),([^r@][^,]*)$", a)
        if l6 and "R6" not in aus and i + 3 < len(z) and z[i + 1] == "testb\t@" + l6.group(1) and z[i + 2].startswith("jr\t") \
                and re.match(r"ld\t(r\d+),%s$" % l6.group(1), z[i + 3]):
            out += z[i:i + 3]
            out.append("ld\t%s,%s" % (re.match(r"ld\t(r\d+),", z[i + 3]).group(1), l6.group(2)))
            n["R6"] += 1
            i += 4
            continue
        # R37  `ld M,rN ; test rN ; jr cc L ; ld r0,rN ; cp rN,X` (M = frame/direct operand) -> the original works on the memory
        #      copy: `test M ; jr cc L ; ld r0,M ; cp r0,X`, and R4's R0 reuse then covers a following `cp M,#k` (dcheck 1x; MODEL)
        if (a.startswith("test\t") and "R37" not in aus and out and i + 3 < len(z)):
            t37 = re.match(r"test\t(r\d+)$", a)
            l37 = re.match(r"ld\t([^,]+),(r\d+)$", out[-1])
            c37 = re.match(r"cp\t(r\d+),([^,]+)$", z[i + 3])
            if (t37 and l37 and l37.group(2) == t37.group(1) and not re.match(r"(r[hlqr]?\d+|sp|fp)$|@", l37.group(1), re.I)
                    and re.match(r"jr\t", b) and z[i + 2] == "ld\tr0," + t37.group(1) and c37 and c37.group(1) == t37.group(1)):
                out += ["test\t" + l37.group(1), b, "ld\tr0," + l37.group(1), "cp\tr0," + c37.group(2)]
                r0mem = l37.group(1)
                n["R37"] += 1
                i += 4
                continue
        # R35  `ldb @r2,#%FF` (byte store of 255 through r2) -> the original loads the constant first: `ld r3,#%FF ; ldb @r2,rl3` (dcheck 1x; MODEL)
        if a == "ldb\t@r2,#%FF" and "R35" not in aus:
            out += ["ld\tr3,#%FF", "ldb\t@r2,rl3"]
            n["R35"] += 1
            i += 1
            continue
        # R36  `and rB,#%FF ; ld rA,rB ; cp rB,M` -> `cp rA,M` (the original compares the copy; dcheck 1x; MODEL)
        c36 = re.match(r"cp\t(r\d+),([^,r][^,]*|r\d+\([^,]*)$", b)
        l36 = re.match(r"ld\t(r\d+),(r\d+)$", a)
        if (l36 and c36 and c36.group(1) == l36.group(2) and "R36" not in aus and out and out[-1] == "and\t%s,#%%FF" % l36.group(2)
                and not c36.group(2).startswith("r0")):
            out += [a, "cp\t%s,%s" % (l36.group(1), c36.group(2))]
            n["R36"] += 1
            i += 2
            continue
        # R45  `xor r2,r2 ; div rr2,#k` (unsigned remainder/quotient by a constant) -> `exts rr2 ; div rr2,#k` (the original divides as signed; ncheck lookup `i%HSIZE`, 1x)
        if a == "xor\tr2,r2" and b.startswith("div\trr2,#") and "R45" not in aus:
            out.append("exts\trr2")
            n["R45"] += 1
            i += 1
            continue
        # R48  `ld MEM,rN ; ... ; ld r0,rN ; cp rN,X` -> `ld r0,MEM ; cp r0,X` (the original reloads the stored variable, icheck 1x)
        c41 = re.match(r"cp\t(r\d+),", b)
        if re.match(r"ld\tr0,r\d+$", a) and c41 and "R48" not in aus and stored.get(c41.group(1)) and a == "ld\tr0," + c41.group(1):
            out += ["ld\tr0," + stored[c41.group(1)], b.replace("cp\t" + c41.group(1) + ",", "cp\tr0,", 1)]
            n["R48"] += 1
            i += 2
            continue
        # R42  `ld rN,SRC ; ld MEM,rN ; test rN` (SRC, MEM memory operands) -> `test MEM` (the original tests the stored variable; a call result
        #      `call ; ld MEM,r2 ; test r2` keeps `test r2`, R33; ncheck `kno = dp->d_ino` 2x, icheck `n = sblock.s_..` 3x)
        m35 = re.match(r"ld\t([^,@#]+),(r\d+)$", a)
        #      (not when R37 applies to the same place: `test rN ; jr cc ; ld r0,rN ; cp rN,X` -- R37 (dcheck) covers it, measured)
        if (m35 and "R42" not in aus and b == "test\t" + m35.group(2) and not re.match(r"(r[hlqr]?\d+|sp|fp)$", m35.group(1), re.I)
                and not (i + 3 < len(z) and z[i + 2].startswith("jr\t") and z[i + 3] == "ld\tr0," + m35.group(2))
                and out and re.match(r"ld\t%s,[^r#][^,]*$|ld\t%s,@r\d+$" % (m35.group(2), m35.group(2)), out[-1])):
            out += [a, "test\t" + m35.group(1)]
            stored[m35.group(2)] = m35.group(1)
            n["R42"] += 1
            i += 2
            continue
        # R46  `ldl rr0,rr2 ; cpl rr2,M ; jr cc L` -> `cpl rr0,M` (the original compares the copy); when the code behind the jump goes on with
        #      `ld r5,.. ; xor r4,r4 ; cpl rr2,rr4 ; jr .. ; pushl @SP,rr2` it reloads rr2 first and pushes rr0 (icheck 3x; the long part 1x)
        if a == "ldl\trr0,rr2" and re.match(r"cpl\trr2,", b) and "R46" not in aus and re.match(r"jr\t", z[i + 2] if i + 2 < len(z) else ""):
            out += [a, b.replace("cpl\trr2,", "cpl\trr0,", 1), z[i + 2]]
            n["R46"] += 1
            if (i + 7 < len(z) and z[i + 3].startswith("ld\tr5,") and z[i + 4] == "xor\tr4,r4" and z[i + 5] == "cpl\trr2,rr4"
                    and z[i + 6].startswith("jr\t") and z[i + 7] == "pushl\t@SP,rr2"):
                out += ["ldl\trr2,rr0"] + z[i + 3:i + 7] + ["pushl\t@SP,rr0"]
                i += 8
            else:
                i += 3
            continue
        # R47  `divl rq0,rr4 ; ld rN,r3` -> `ld r2,r3 ; ld rN,r2` (the quotient/remainder moves over r2, as R26; icheck 1x)
        d40 = re.match(r"ld\t(r\d+),r3$", b)
        if a.startswith("divl\trq0,") and d40 and "R47" not in aus and d40.group(1) != "r2":
            out += [a, "ld\tr2,r3", "ld\t%s,r2" % d40.group(1)]
            n["R47"] += 1
            i += 2
            continue
        # R65  `ld rN,#k ; ldl rr2,X ; xor r0,r0 ; ld r1,rN ; cpl rr2,rr0` (`s = 512; if (size < 512)`, long size): the shipped c2 reuses the register that holds k,
        #      the original loads the constant again: `... ; ld r1,#k ; cpl rr2,rr0` (strip 1x; MODEL of the old c2, not a run of it)
        m65 = re.match(r"ld\t(r\d+),#([^,]+)$", a)
        if (m65 and "R65" not in aus and i + 4 < len(z) and z[i + 1].startswith("ldl\trr2,") and z[i + 2] == "xor\tr0,r0"
                and z[i + 3] == "ld\tr1," + m65.group(1) and z[i + 4] == "cpl\trr2,rr0"):
            out += [a, z[i + 1], z[i + 2], "ld\tr1,#" + m65.group(2), z[i + 4]]
            n["R65"] += 1
            i += 5
            continue
        # R64  `ldl MEM,rr4 ; testl rr4 ; jr eq L ; ldl rr2,rr4 ; ld r5,X ; xor r4,r4 ; cpl rr2,rr4 ; jr lt L2 ; ldl rr0,MEM ; cpl rr0,M` (`b = a[i]; if (b == 0) ..;
        #      if (b < x || b >= y)`, b a long local): the original works on the memory copy first and then on the loaded pair: `testl MEM ; jr eq L ; ldl rr2,MEM ;
        #      ld r5,X ; xor r4,r4 ; cpl rr2,rr4 ; jr lt L2 ; ldl rr0,rr2 ; cpl rr2,M` (df 1x; MODEL of the old c2, not a run of it)
        m64 = re.match(r"ldl\t([^,r][^,]*),rr4$", a)
        if (m64 and "R64" not in aus and i + 9 < len(z) and b == "testl\trr4" and re.match(r"jr\teq\tL\d+$", z[i + 2])
                and z[i + 3] == "ldl\trr2,rr4" and z[i + 5] == "xor\tr4,r4" and z[i + 6] == "cpl\trr2,rr4"
                and re.match(r"jr\tlt\tL\d+$", z[i + 7]) and z[i + 8] == "ldl\trr0," + m64.group(1)
                and re.match(r"cpl\trr0,", z[i + 9])):
            out += [a, "testl\t" + m64.group(1), z[i + 2], "ldl\trr2," + m64.group(1), z[i + 4], z[i + 5], z[i + 6], z[i + 7],
                    "ldl\trr0,rr2", "cpl\trr2," + z[i + 9][len("cpl\trr0,"):]]
            n["R64"] += 1
            i += 10
            continue
        # R66  `ldb @r2,rl3 ; djnz rN,L` (tail of `do { a = *ip++; ip[-1] = *ip; *ip++ = a; } while(--c)`, register c): the original has no DJNZ but
        #      `dec rN,#1 ; jr ne L` (dd 1x; MODEL of the old c2; gated on the preceding `ldb @r2,rl3`, other programs keep their DJNZ)
        m66 = re.match(r"djnz\t(r\d+),(L\d+)$", a)
        if m66 and "R66" not in aus and len(out) > 0 and out[-1] == "ldb\t@r2,rl3":
            out += ["dec\t%s,#%%1" % m66.group(1), "jr\tne\t" + m66.group(2)]
            n["R66"] += 1
            i += 1
            continue
        # R67  `ld r3,MEM ; ldb rl0,@r2 ; cpb rl0,@r3 ; jr eq L ; ld r2,r3 ; testb @r2` (`while(*cs++ == *s) ..; if(*s != 0)`-style compare of two walkers, MEM a
        #      frame parameter): the original reloads `ld r2,MEM` instead of copying r3 (dd match() 1x; MODEL of the old c2)
        m67 = re.match(r"ld\tr3,(%[0-9A-F]+\(FP\))$", a)
        if (m67 and "R67" not in aus and i + 5 < len(z) and b == "ldb\trl0,@r2" and z[i + 2] == "cpb\trl0,@r3"
                and re.match(r"jr\teq\tL\d+$", z[i + 3]) and z[i + 4] == "ld\tr2,r3" and z[i + 5] == "testb\t@r2"):
            out += [a, b, z[i + 2], z[i + 3], "ld\tr2," + m67.group(1)]
            n["R67"] += 1
            i += 5
            continue
        # R69  `call _strcmp ; inc SP,#4 ; test r2 ; jr eq L ; push @SP,#Lk` (`if (strcmp(..) != 0)` jumping over the whole password-change body): the original has a
        #      long `jp eq L` (target 0x10C bytes away); with the other rules applied the short `jr eq` is out of range for the guest `as` (ILLEGAL VALUE)
        #      (passwd 1x -- the second strcmp of passwd keeps its short `jr eq`; MODEL of the old c2, gated on this context incl. the label L21)
        m69 = re.match(r"jr\teq\t(L\d+)$", a)
        if (m69 and "R69" not in aus and len(out) >= 3 and out[-1] == "test\tr2" and out[-2] == "inc\tSP,#%4" and out[-3] == "call\t_strcmp"
                and re.match(r"push\t@SP,#L\d+$", b) and z[i + 2] == "jr\tL9015" and m69.group(1) == "L21"):
            out.append("jp\teq\t" + m69.group(1))
            n["R69"] += 1
            i += 1
            continue
        # R70  `div rr2,X ; ld MEM,r3` (quotient stored to a variable; `colw = width / ncol`): the original keeps the copy: `ld r2,r3 ; ld MEM,r2`
        #      (pr 1x; MODEL of the old c2)
        m70 = re.match(r"ld\t([^r@][^,]*),r3$", a)
        if m70 and "R70" not in aus and out and re.match(r"div\trr2,[^#]", out[-1]) and not re.match(r"jr\t", b):
            out += ["ld\tr2,r3", "ld\t%s,r2" % m70.group(1)]
            n["R70"] += 1
            i += 1
            continue
        # R61  `ld MEM,r3 ; ld r2,r3 ; ldb rl3,@r2 ; xorb rh3,rh3 ; cp r3,#k ; jr ne L ; ld r2,MEM` (MEM = frame local; `arg = argv[1]; if (arg[0] == 'c' && ...`)
        #      -> the original reloads r2 from the variable and keeps it: `ld MEM,r3 ; ld r2,MEM ; ldb .. ; xorb ; cp ; jr ne L` (the reload behind the jump
        #      is dropped; cmp 3x; MODEL of the old c2, not a run of it)
        m61 = re.match(r"ld\t(-%[0-9A-F]+\(FP\)),r3$", a)
        if (m61 and "R61" not in aus and b == "ld\tr2,r3" and i + 6 < len(z) and z[i + 2] == "ldb\trl3,@r2"
                and z[i + 3] == "xorb\trh3,rh3" and re.match(r"cp\tr3,#", z[i + 4]) and re.match(r"jr\tne\tL\d+$", z[i + 5])
                and z[i + 6] == "ld\tr2," + m61.group(1)):
            out += [a, "ld\tr2," + m61.group(1), z[i + 2], z[i + 3], z[i + 4], z[i + 5]]
            n["R61"] += 1
            i += 7
            continue
        # R62  `L: ld rN,r3 ; ld r2,X` right behind `pop r2,@SP` (join of the getc() macro, r2 dead afterwards): the shipped c2 drops the dead `ld r2,r3`,
        #      the original keeps it: `ld r2,r3 ; ld rN,r2` (cmp 1x; the three other getc joins get the same form from R5; MODEL of the old c2)
        m62 = re.match(r"ld\t(r\d+),r3$", a)
        if (m62 and "R62" not in aus and len(out) > 1 and re.match(r"L\d+:$", out[-1]) and out[-2] == "pop\tr2,@SP"
                and m62.group(1) != "r2" and re.match(r"ld\tr2,", b)):
            out += ["ld\tr2,r3", "ld\t%s,r2" % m62.group(1)]
            n["R62"] += 1
            i += 1
            continue
        # R4  `cp mem,#k` (mem = frame/direct operand) -> `ld r0,mem ; cp r0,#k`; a following `cp mem,#k2` directly
        #     behind a `jr cc` of the same chain reuses R0 (`cp r0,#k2`)
        c4 = re.match(r"cp\t([^,]+),(#[^,]+)$", a)
        if c4 and "R4" not in aus and not re.match(r"(r[hlqr]?\d+|sp|fp)$", c4.group(1), re.I) and not c4.group(1).startswith("@"):
            # R60  `ld MEM,rN ; cp MEM,#k` -> the original loads R0 from the register just stored: `ld r0,rN ; cp r0,#k` (od `c &= 0377; if (c > 037 ...`, 1x; MODEL)
            m60 = re.match(r"ld\t(.+),(r\d+)$", out[-1]) if out else None
            #      only behind `and rN,#%FF` (the same shape behind another mask or a byte load keeps R4's `ld r0,MEM`: cat 1x, mkfs 5x measured)
            if (m60 and "R60" not in aus and m60.group(1) == c4.group(1) and len(out) > 1
                    and out[-2] == "and\t%s,#%%FF" % m60.group(2)):
                out += ["ld\tr0," + m60.group(2), "cp\tr0," + c4.group(2)]
                r0mem = c4.group(1)
                n["R60"] += 1
                i += 1
                continue
            if r0mem == c4.group(1):
                out.append("cp\tr0," + c4.group(2))
            else:
                out += ["ld\tr0," + c4.group(1), "cp\tr0," + c4.group(2)]
                r0mem = c4.group(1)
            n["R4"] += 1
            # R38  `cp M,#k ; jr cc L ; ld rN,M` -> the original reuses R0: `ld rN,r0` (dcheck bmap 1x; MODEL)
            l38 = re.match(r"ld\t(r\d+),(.*)$", z[i + 2]) if i + 2 < len(z) else None
            if (l38 and "R38" not in aus and l38.group(2) == c4.group(1) and re.match(r"jr\t", b)):
                # `ld r0,M` right behind a `cp r0,#k ; jr cc` chain is dropped altogether by the original (pr `ncol > 72 || ncol > width`, 1x)
                out += [b] if l38.group(1) == "r0" else [b, "ld\t%s,r0" % l38.group(1)]
                n["R38"] += 1
                i += 3
                continue
            i += 1
            continue
        if not re.match(r"jr\t", a):
            r0mem = None
        # label / call / jump target = new basic block for R12's byte memory
        if re.match(r"L\d+:$", a) or a.startswith("call"):
            bytemem = {}
            stored = {}
        sw = re.match(r"ld\t(-?%[0-9A-F]+\(FP\)),(r\d+)$", a)
        if sw:
            stored[sw.group(2)] = sw.group(1)
        l12 = re.match(r"ldb\t([^r@][^,]*|-?%[0-9A-F]+\(FP\)),(rl\d)$", a)
        if l12 and i > 0 and z[i - 1] == "xorb\trh%s,rh%s" % (l12.group(2)[2:], l12.group(2)[2:]):
            # only a byte that was LOADED from memory (xorb right before the store), not a call result (macro skipto: no reload)
            bytemem[l12.group(2)] = l12.group(1)
        # R12  `ldb rl0,rlN ; cpb rlN,X` where rlN was stored to MEM earlier (`ldb MEM,rlN`) -> the original reloads: `ldb rl0,MEM ; cpb rl0,X`
        c12 = re.match(r"ldb\trl0,(rl\d)$", a)
        if c12 and "R12" not in aus and c12.group(1) in bytemem and re.match(r"cpb\t%s," % c12.group(1), b):
            out.append("ldb\trl0," + bytemem[c12.group(1)])
            out.append(b.replace("cpb\t" + c12.group(1) + ",", "cpb\trl0,", 1))
            n["R12"] += 1
            i += 2
            continue
        # R14  `ldb rlN,@rM ; xorb rhN,rhN ; ldb MEM,rlN ; and rN,#k` -> the original reloads the stored byte right behind the store:
        #      `... ldb MEM,rlN ; ldb rlN,MEM ; and rN,#k` (sh stoi `WHILE (c = *cp, digit(c))`; 1 site -- the same shape with an
        #      offset operand `ldb rlN,off(rM)` in word.c is NOT reloaded)
        m14 = re.match(r"ldb\t(-?%[0-9A-F]+\(FP\)),rl(\d)$", a)
        if (m14 and "R14" not in aus and re.match(r"and\tr%s,#" % m14.group(2), b) and out and out[-1] == "xorb\trh%s,rh%s" % (m14.group(2), m14.group(2))
                and len(out) > 1 and out[-2] == "ldb\trl%s,@%s" % (m14.group(2), out[-2].split("@")[-1]) and "@" in out[-2]):
            out += [a, "ldb\trl%s,%s" % (m14.group(2), m14.group(1))]
            n["R14"] += 1
            i += 1
            continue
        # R16  `jp ne,L ; ldb ; xorb ; add ; bitb ; jp eq,L` (same target L, backward distance exactly 256 B): the original c2/as range
        #      check lets the first jump be a short `jr` (disp -128 words; the guest `as` rejects exactly that, hence `wval`), the usr c2 keeps `jp` (sh word(), 1 site)
        m16 = re.match(r"jp\tne\t(L\d+)$", a)
        if ("R16" not in aus and m16 and i + 5 < len(z) and z[i + 5] == "jp\teq\t" + m16.group(1) and z[i + 4].startswith("bitb\t")
                and i > 0 and z[i - 1].startswith("and\tr2,#%80")):
            out.append("wval\t-%1180")        # `jr ne,L` (disp -128): the guest `as` rejects it (ILLEGAL VALUE), so the word is emitted as data
            n["R16"] += 1
            i += 1
            continue
        # R13  `ld MEM,rN ; cp MEM,#k` -> `ld MEM,rN ; cp rN,#k` (the original compares the register just stored)
        m13 = re.match(r"ld\t([^,]+),(r\d+)$", a)
        c13 = re.match(r"cp\t([^,]+),(#.*)$", b)
        if m13 and c13 and "R13" not in aus and c13.group(1) == m13.group(1) and not re.match(r"(r\d+|@.*)$", m13.group(1)):
            out += [a, "cp\t%s,%s" % (m13.group(2), c13.group(2))]
            n["R13"] += 1
            i += 2
            continue
        # R11 compare against the copy: `ld rA,rB ; ...(test rB | ld MEM,rB | jr cc L)... ; cp rA,#k` -> `cp rB,#k` (every cp rA,#k of
        #     the chain; the original c2 does not forward the copy into the compare, the usr c2 does) -- sh gmatch, getch, ...
        t11 = re.match(r"ld\t(r\d+),(r\d+)$", a)
        if t11 and t11.group(1) != t11.group(2) and int(t11.group(1)[1:]) < 6 and "R11" not in aus:   # scratch copy, not a register variable
            ra, rb = t11.groups()
            j = i + 1
            chain = []
            while j < len(z):
                zz = z[j]
                if re.match(r"cp\t%s,#" % ra, zz):
                    chain.append(j)
                elif not (zz == "test\t" + rb or zz.startswith("jr\t") or re.match(r"ld\t[^,]+,%s$" % rb, zz)):
                    break
                j += 1
            if chain:
                for k in range(i, j):
                    out.append(z[k].replace("cp\t" + ra + ",", "cp\t" + rb + ",", 1) if k in chain else z[k])
                n["R11"] += 1
                i = j
                continue
        # R5  `ld rA,rB ; test rB` -> `test rA` is what the usr c2 emits; the original keeps `test rA`
        t5 = re.match(r"ld\t(r\d+),(r\d+)$", a)
        t6 = re.match(r"test\t(r\d+)$", b)
        # R33  exception to R5: `call f ; ld rA,r2 ; test r2` (value of a call assigned and tested, `while (o = what())`) keeps
        #      `test r2` (chmod 1x; MODEL of the old c2, not a run of it)
        if (t5 and t6 and t5.group(2) == "r2" and t6.group(1) == "r2" and out and out[-1].startswith("call\t")
                and "R5" not in aus and "R33" not in aus):
            out += [a, b]
            n["R33"] += 1
            i += 2
            continue
        # R39  exception to R5: `xorb rhN,rhN ; ld rA,rN ; test rN` (char value `c = *s++` assigned to a register variable and tested) keeps
        #      `test rN` (clri 1x; only for a register variable r8..r13 as target: cat's `ld r2,r3 ; test r3` -> `test r2` still follows R5; MODEL of the old c2)
        if (t5 and t6 and t6.group(1) == t5.group(2) and "R5" not in aus and "R39" not in aus and out
                and int(t5.group(1)[1:]) >= 8 and out[-1] == "xorb\trh%s,rh%s" % (t5.group(2)[1:], t5.group(2)[1:])):
            out += [a, b]
            n["R39"] += 1
            i += 2
            continue
        # (pseudo rule "R5T" in `aus` switches off this `test` form only, leaving the `ld DST` form below: pr, 4 sites keep `ld r11,r2 ; test r2`)
        if t5 and t6 and t6.group(1) == t5.group(2) and "R5" not in aus and "R5T" not in aus:
            out += [a, "test\t" + t5.group(1)]
            n["R5"] += 1
            i += 2
            continue
        t7 = re.match(r"ld\t([^,]+),(r\d+)$", b)      # `ld rA,rB ; ld DST,rB` -> `ld DST,rA`
        if t5 and t7 and t7.group(2) == t5.group(2) and t7.group(1) != t5.group(1) and "R5" not in aus:
            out += [a, "ld\t%s,%s" % (t7.group(1), t5.group(1))]
            n["R5"] += 1
            i += 2
            continue
        m5 = re.match(r"ldb\t(rl\d),([^,]+)$", a)
        if m5 and "R8" not in aus and not re.match(r"r[hl]\d+$", m5.group(2)):
            c = z[i + 1] if i + 1 < len(z) else ""
            d = re.match(r"ldb\t(rl\d),(rl\d)$", z[i + 2]) if i + 2 < len(z) else None
            if c == "xorb\trh%s,rh%s" % (m5.group(1)[2:], m5.group(1)[2:]) and d and d.group(2) == m5.group(1):
                out += [a, c, "ldb\t%s,%s" % (d.group(1), m5.group(2))]
                n["R8"] += 1
                i += 3
                continue
        m7 = re.match(r"and\t(r\d+),#", a)
        m7b = re.match(r"or\t(r\d+),(r\d+)$", b)
        if m7 and m7b and "R9" not in aus and m7b.group(2) == m7.group(1) and int(m7b.group(2)[1:]) == int(m7b.group(1)[1:]) + 2:
            t = "r%d" % (int(m7b.group(1)[1:]) + 1)
            out += [a, "ld\t%s,%s" % (t, m7b.group(2)), "or\t%s,%s" % (m7b.group(1), t)]
            n["R9"] += 1
            i += 2
            continue
        # R34  `test rN ; jr eq|ne L ; jr mi|pl|lt|ge|gt|le L2` -> the original repeats `test rN` (flags not remembered) -- only right after `ld MEM,rN` (value of `n = read()` tested twice); getty's `read(); test r2; jr eq; jr pl` keeps one (cp 1x)
        t34 = re.match(r"test\t(r\d+)$", a)
        if (t34 and "R34" not in aus and out and re.match(r"ld\t[^r][^,]*,%s$" % t34.group(1), out[-1])
                and re.match(r"jr\t(eq|ne)\tL\d+$", b)
                and re.match(r"jr\t(mi|pl|lt|ge|gt|le)\tL\d+$", z[i + 2] if i + 2 < len(z) else "")):
            out += [a, b, a]
            n["R34"] += 1
            i += 2
            continue
        out.append(a)
        i += 1
    # R68  range test closing an else-if chain (`else if(c>='0' && c<='9') f |= 1; else f |= 8;` with register-less c, after R4):
    #      shipped c2 `ld r0,M ; cp r0,#lo ; jr ge LB ; LX: set..` with the then-block `LB: ld r0,M ; cp r0,#hi ; jr gt LX ; <body> ; jr LEND` placed earlier;
    #      the original has the block inline: `ld r0,M ; cp r0,#lo ; jr lt LX ; cp r0,#hi ; jr gt LX ; <body> ; jr LEND ; LX: set..`
    #      (passwd 1x; the two earlier ranges of the same chain keep the jump to the block, since LX is followed by a test there; MODEL of the old c2)
    for j in range(len(out) - 3):
        m68 = re.match(r"jr\tge\t(L\d+)$", out[j])
        if not (m68 and "R68" not in aus and re.match(r"cp\tr0,#", out[j - 1]) and re.match(r"L\d+:$", out[j + 1])
                and out[j + 2].startswith("set\t") and out.count(m68.group(1) + ":") == 1 and out.count(out[j]) == 1):
            continue
        lb, lx = m68.group(1), out[j + 1][:-1]
        try:
            b = out.index(lb + ":")
        except ValueError:
            continue
        if b >= j or not (re.match(r"ld\tr0,", out[b + 1]) and re.match(r"cp\tr0,#", out[b + 2]) and out[b + 3] == "jr\tgt\t" + lx):
            continue
        e = b + 4
        while e < len(out) and not re.match(r"jr\tL\d+$", out[e]):
            e += 1
        if e >= j or out[e + 1][-1:] != ":" and not out[e + 1].startswith(("ld", "cp")):
            continue
        blk = out[b + 2:e + 1]               # cp r0,#hi ; jr gt LX ; body ; jr LEND
        out[j:j + 1] = ["jr\tlt\t" + lx] + blk
        del out[b:e + 1]
        n["R68"] += 1
        break
    if mkfs:
        t, n2 = c2_mkfs_s("\n".join(out))
        n.update(n2)
        return t, n
    if any(l == "end _convdir" for l in out):
        t, n2 = c2_convert_s("\n".join(out))
        n.update(n2)
        return t, n
    return "\n".join(out), n


def c2_convert_s(s):
    """Rules R72-R76: measured on `bin/convert` ONLY (doc/userspace/cmd_s3b5.md); the caller applies them only to a text that contains the
    function `_convdir` (no other program has one).  Model of the old c2, not a run of it.
      R72  `call _lseek ; inc SP,#%8 ; test r2 ; jr pl|mi L`  ->  `testl rr2` (the original does not shorten the sign test of a long)   (2 sites)
      R73  `sra rN,#%1`  ->  `ld r2,#-%1 ; sda rN,r2`  (the original does not turn the shift by a constant into SRA)   (1 site)
      R74  loop inversion of the shipped c2 undone for the free-list loop of main (head `... call _blk ; inc SP,#%4 ; testl _curr ; jr ne L9nnn ; jr Lx`):
           `jr Lh ; L9nnn: BODY Lh: HEAD jr ne L9nnn ; jr Lx`  ->  `Lh: HEAD jr eq Lx ; BODY jr Lh`   (1 site)
      R75  `inc rK,#%1 ; ld r2,rK ; inc rK,#%1 ; ld r3,rM ; ldb @r2,rl3`  ->  `inc rK,#%1 ; ld r2,rK ; ld r3,rM ; ldb @r2,rl3 ; inc rK,#%1`
           (`*p++ = t` with register t: the original increments behind the store)   (1 site)
      R76  `ldb rl2,%1(r13) ; ldb @r13,rl2`  ->  `xorb rh2,rh2` inserted between (`*p = p[1]`: the shipped c2 drops the zero-extension, the original keeps it)   (1 site)
    Returns (text, counts)."""
    z = s.split("\n")
    n = {"R72": 0, "R73": 0, "R74": 0, "R75": 0, "R76": 0}
    out = []
    i = 0
    while i < len(z):
        a = z[i]
        w = lambda k: z[i + k] if i + k < len(z) else ""
        # R72
        if (a == "test\tr2" and re.match(r"jr\t(pl|mi)\tL\d+$", w(1)) and len(out) > 1 and out[-1] == "inc\tSP,#%8"
                and out[-2] == "call\t_lseek"):
            out.append("testl\trr2")
            n["R72"] += 1
            i += 1
            continue
        # R73
        m = re.match(r"sra\t(r\d+),#%1$", a)
        if m:
            out += ["ld\tr2,#-%1", "sda\t%s,r2" % m.group(1)]
            n["R73"] += 1
            i += 1
            continue
        # R76
        if a == "ldb\trl2,%1(r13)" and w(1) == "ldb\t@r13,rl2":
            out += [a, "xorb\trh2,rh2"]
            n["R76"] += 1
            i += 1
            continue
        # R75
        m = re.match(r"inc\t(r\d+),#%1$", a)
        if (m and w(1) == "ld\tr2," + m.group(1) and w(2) == a and re.match(r"ld\tr3,r\d+$", w(3)) and w(4) == "ldb\t@r2,rl3"):
            out += [a, w(1), w(3), w(4), a]
            n["R75"] += 1
            i += 5
            continue
        # R74
        m = re.match(r"jr\t(L\d+)$", a)
        if m and re.match(r"L9\d+:$", w(1)):
            lh, lb = m.group(1), w(1)[:-1]
            j = i + 2
            while j < len(z) and z[j] != lh + ":":
                j += 1
            k = j + 1
            while k < len(z) and z[k] != "jr\tne\t" + lb:
                k += 1
            if (j < len(z) and k < len(z) and "testl\t_curr" in z[j:k] and "call\t_blk" in z[j:k]
                    and re.match(r"jr\tL\d+$", z[k + 1] if k + 1 < len(z) else "")):
                out += [lh + ":"] + z[j + 1:k] + ["jr\teq\t" + z[k + 1][3:]] + z[i + 2:j] + ["jr\t" + lh]
                n["R74"] += 1
                i = k + 2
                continue
        out.append(a)
        i += 1
    return "\n".join(out), {k: v for k, v in n.items() if v}


def c2_mkfs_s(s):
    """Rules R49-R59: measured on `etc/mkfs` ONLY (doc/userspace/cmd_b3.md), applied behind c2_emu_s and only when it is called with
    mkfs=True (pipeline.py passes it for mkfs alone).  Each describes where the (older) original c2 differs from the shipped one in
    that program, with the number of sites; none of them is a run of the old c2.
      R49  `ld MEM,rN [; test rN ; jr ..] ; ld r0,MEM ; cp r0,#k` -> `ld r0,rN ; cp r0,#k`; the first following `push @SP,rN`/`test rN`
           (behind the jr chain) uses r0
      R50  `cp @rN,#k` -> `ld r0,@rN ; cp r0,#k`   (R4 for a register-indirect operand)
      R51  after `ld r0,MEM ; cp r0,#k` a later `ld rN,MEM` (same basic block, r0/MEM untouched) -> `ld rN,r0`
      R52  `mult rr4,#k ; ld r4,r5 ; sub rX,r5` -> `sub rX,r4`
      R53  `call _getnum ; ld -N(FP),r3` -> `ld r2,r3 ; ld -N(FP),r2`
      R54  `ldl MEM,rr4 ; testl rr4` -> `testl MEM`
      R55  `ld rN,X ; ld MEM(FP),rN ; ld r3,Y .. add rN,.. ; ld MEM(FP),rN` -> reload `ld rN,MEM` behind the first store (`dp = x; dp += y`)
      R56  `ld r4,@r3 ; sla r4,#%4 ; add r2,r4` -> `.. ; ld r3,r4 ; add r2,r3`
      R57  `ld r3,MEM ; .. ; ld r2,r3 ; inc @r2,#%1` -> `ld r2,MEM`
      R58  `ldl rr2,MEM ; ldl DST,rr2 ; ldk r5,#%19 ; exts rr4 ; extsl rq0 ; divl rq0,rr4` -> `ldl rr2,MEM ; nop*3 ; ldl DST,rr2 ; ldl rr2,MEM ; ..`
      R59  `ldl rr0,rr2 ; cpl rr2,M ; jr cc L ; ld r5,X ; xor r4,r4 ; cpl rr2,rr4 ; jr cc L2 ; pushl @SP,rr2` -> cpl on rr0, `ldl rr2,rr0` behind the
           first jr, `pushl @SP,rr0`"""
    z = s.split("\n")
    names = ("R49", "R50", "R51", "R52", "R53", "R54", "R55", "R56", "R57", "R58", "R59")
    n = {k: 0 for k in names}
    reg = r"(r[hl]?\d+|rr\d+|rq\d+|sp|fp|@.*)$"
    out = []
    fwd = None            # R51: MEM mirrored in r0
    alias = None          # R49: register whose next use becomes r0
    i = 0
    while i < len(z):
        a = z[i]
        b = z[i + 1] if i + 1 < len(z) else ""
        # --- bookkeeping: end of basic block
        if re.match(r"L\d+:$", a) or re.match(r"(call|jp|ret)\b", a):
            fwd = None
            alias = None
        if alias and not a.startswith(("jr\t", "cp\tr0,#")):
            if a == "push\t@SP," + alias or a == "test\t" + alias:
                a = a.replace(alias, "r0")
            alias = None
        # R51 behind the others' bookkeeping
        f37 = re.match(r"ld\t(r[1-9]\d*),(.+)$", a)
        if fwd and f37 and f37.group(2) == fwd:
            out.append("ld\t%s,r0" % f37.group(1))
            n["R51"] += 1
            i += 1
            continue
        # R49
        m35 = re.match(r"ld\t([^,]+),(r\d+)$", a)
        if m35 and not re.match(reg, m35.group(1)) and not (i and z[i - 1].startswith("xorb\t")):   # byte loads (`c = string[i]`) keep the reload
            j = i + 1
            while j < len(z) and (z[j] == "test\t" + m35.group(2) or z[j].startswith("jr\t")):
                j += 1
            if j + 1 < len(z) and z[j] == "ld\tr0," + m35.group(1) and z[j + 1].startswith("cp\tr0,#"):
                out += z[i:j]
                out += ["ld\tr0," + m35.group(2), z[j + 1]]
                alias = m35.group(2)
                fwd = m35.group(1)
                n["R49"] += 1
                i = j + 2
                continue
        # R50
        m36 = re.match(r"cp\t(@r\d+),(#[^,]+)$", a)
        if m36:
            out += ["ld\tr0," + m36.group(1), "cp\tr0," + m36.group(2)]
            n["R50"] += 1
            i += 1
            continue
        # R51 start: R4 form
        m4 = re.match(r"ld\tr0,([^@,][^,]*)$", a)
        if m4 and b.startswith("cp\tr0,#") and not re.match(reg, m4.group(1)):
            fwd = m4.group(1)
        elif fwd and not re.match(r"(cp|cpl|cpb|test|testl|testb|jr|push|pushl)\t", a) and (
                re.match(r"\w+\t(r0|rr0|rl0|rh0|rq0)\b", a) or re.match(r"\w+\t%s(,|$)" % re.escape(fwd), a)):
            fwd = None
        # R52
        if out and out[-1].startswith("mult\trr4,#") and a == "ld\tr4,r5" and re.match(r"sub\t(r\d+),r5$", b):
            out += [a, "sub\t%s,r4" % re.match(r"sub\t(r\d+),r5$", b).group(1)]
            n["R52"] += 1
            i += 2
            continue
        # R53
        if out and out[-1] == "call\t_getnum" and re.match(r"ld\t-%[0-9A-F]+\(FP\),r3$", a):
            out += ["ld\tr2,r3", a.replace(",r3", ",r2")]
            n["R53"] += 1
            i += 1
            continue
        # R54
        if re.match(r"ldl\t[^r][^,]*,rr4$", a) and b == "testl\trr4":
            out += [a, "testl\t" + a.split("\t")[1].split(",")[0]]
            n["R54"] += 1
            i += 2
            continue
        # R55
        m41 = re.match(r"ld\t(-%[0-9A-F]+\(FP\)),(r\d+)$", a)
        if m41 and out and re.match(r"ld\t%s," % m41.group(2), out[-1]) and b.startswith("ld\tr3,"):
            k = i + 1
            seen_add = False
            hit = False
            while k < len(z) and k < i + 10 and not re.match(r"(L\d+:|call|jp|jr)", z[k]):
                if z[k].startswith("add\t%s," % m41.group(2)):
                    seen_add = True
                if z[k] == a and seen_add:
                    hit = True
                    break
                k += 1
            if hit:
                out += [a, "ld\t%s,%s" % (m41.group(2), m41.group(1))]
                n["R55"] += 1
                i += 1
                continue
        # R56
        if out and out[-1] == "ld\tr4,@r3" and a == "sla\tr4,#%4" and b == "add\tr2,r4":
            out += [a, "ld\tr3,r4", "add\tr2,r3"]
            n["R56"] += 1
            i += 2
            continue
        # R57
        if a == "ld\tr2,r3" and b == "inc\t@r2,#%1":
            for q in range(len(out) - 1, max(len(out) - 8, -1), -1):
                mq = re.match(r"ld\tr3,(%[0-9A-F]+\(FP\))$", out[q])
                if mq:
                    out += ["ld\tr2," + mq.group(1), b]
                    n["R57"] += 1
                    i += 2
                    break
            else:
                mq = None
            if mq:
                continue
        # R58
        if (re.match(r"ldl\trr2,[^r]", a) and re.match(r"ldl\t[^r][^,]*,rr2$", b) and z[i + 2:i + 5] == ["ld\tr5,#%19", "exts\trr4", "extsl\trq0"]
                and z[i + 5:i + 6] == ["divl\trq0,rr4"]):
            out += [a, "nop", "nop", "nop", b, a]
            n["R58"] += 1
            i += 2
            continue
        # R59
        if (a == "ldl\trr0,rr2" and re.match(r"cpl\trr2,[^r]", b) and re.match(r"jr\t\w+\tL\d+$", z[i + 2:i + 3] and z[i + 2] or "")
                and z[i + 3].startswith("ld\tr5,") and z[i + 4] == "xor\tr4,r4" and z[i + 5] == "cpl\trr2,rr4"
                and z[i + 6].startswith("jr\t") and z[i + 7] == "pushl\t@SP,rr2"):
            out += [a, b.replace("rr2", "rr0", 1), z[i + 2], "ldl\trr2,rr0", z[i + 3], z[i + 4], z[i + 5], z[i + 6], "pushl\t@SP,rr0"]
            n["R59"] += 1
            i += 8
            continue
        out.append(a)
        i += 1
    return "\n".join(out), {k: v for k, v in n.items()}


# ---------------------------------------------------------------- comparison
def normalisieren(befehle, starts, textende, datenende, bssende=None):
    """Instruction list -> comparable lines: call/jump targets become `L`, immediates/direct operands that fall into the
    data part become `D+off`, those into bss `B+off`, text addresses that are known function starts become `F`."""
    def ersetze(m):
        v = int(m.group(1), 16)
        if textende <= v < datenende:
            return "D+%X" % (v - textende)
        if bssende and datenende <= v < bssende:
            return "B+%X" % (v - datenende)
        if v in starts and v >= 0x30:
            return "F"
        return m.group(0)
    erg = []
    for a, _b, m in befehle:
        m = re.sub(r"\bL[0-9A-F]{4}\b", "L", m)
        m = re.sub(r"%([0-9A-F]{4})\b", ersetze, m)
        erg.append(m)
    return erg


def c2_kanon(zeilen):
    """Canonical form for the two measured c2 differences between the original build and the `usr` c2 (doc/userspace/init.md):
    R1  `INC R15,#k ; LD @R15,x`  <->  `INC R15,#k+2 ; PUSH @R15,x`  (the usr c2 merges the argument slot after calls with
        more than one argument word, the original c2 only after a one-word call)
    R2  `XORB RHn,RHn ; LDB mem,RLn` (mem not a register): the original c2 drops the XORB, the usr c2 keeps it.
    R3  `XORB RHn,RHn ; CP .. ; JR cc,.. ; XORB RHn,RHn`: the original c2 keeps the repeated XORB, the usr c2 drops it.
    R4  `LD R0,mem ; CP R0,#k` (original) <-> `CP mem,#k` (usr c2); brought into the second form.
    Both sides are brought into the same form (R1 towards the original, R2: XORB dropped)."""
    erg, i = [], 0
    while i < len(zeilen):
        z = zeilen[i]
        n = zeilen[i + 1] if i + 1 < len(zeilen) else ""
        m1 = re.match(r"INC R15,#(\d+)$", z)
        m2 = re.match(r"LD @R15,(.*)$", n)
        if m1 and m2:
            erg.append("INC R15,#%d" % (int(m1.group(1)) + 2))
            erg.append("PUSH @R15," + m2.group(1))
            i += 2
            continue
        # R3: a second XORB RHn,RHn after `XORB ; CP ; JR cc` (nothing writes RHn in between) is dropped
        if (erg and i >= 3 and re.match(r"XORB (RH\d),\1$", z) and re.match(r"CP ", zeilen[i - 2]) and
                re.match(r"JR ", zeilen[i - 1]) and zeilen[i - 3] == z):
            i += 1
            continue
        x = re.match(r"XORB (RH\d),RH\d$", z)
        if x and re.match(r"LDB (?!R[HL]\d,)\S+,R[HL]\d$", n) and not n.startswith("LDB R"):
            i += 1
            continue
        # R4: the original c2 never emits `CP mem,#k`: it loads R0 first
        m4 = re.match(r"LD R0,(?!R\d+$|#)(\S+)$", z)
        if m4 and re.match(r"CP R0,#", n):
            erg.append("CP %s,%s" % (m4.group(1), n[len("CP R0,"):]))
            i += 2
            continue
        erg.append(z)
        i += 1
    return erg


def _teil(befehle, ende):
    return [b for b in befehle if b[0] < ende and not b[2].startswith("DW")]


def vergleichen(soll_roh, soll_kopf, ist_roh, ist_kopf, soll_lst, ist_lst, funktionsgrenzen=None, namen=None,
                eigen_soll=None, eigen_ist=None, c2=True, zeiger_soll=(), zeiger_ist=()):
    """Report (list of text lines, dict of key figures).  Both listings come from the same map procedure.
    eigen_soll/eigen_ist: end of the program's own code (start of the first libc function) in the two images; the
    own code is diffed in detail, the libc part only counted.  c2=True applies c2_kanon to both sides."""
    r, z = [], {}
    ts, ti = soll_kopf[1], ist_kopf[1]
    r.append("header   original: text %d data %d bss %d syms %d   built: text %d data %d bss %d syms %d" %
             (soll_kopf[1], soll_kopf[2], soll_kopf[3], soll_kopf[4], ist_kopf[1], ist_kopf[2], ist_kopf[3], ist_kopf[4]))
    z["gleich"] = soll_roh == ist_roh and soll_kopf == ist_kopf
    n = min(len(soll_roh), len(ist_roh))
    ng = sum(1 for i in range(n) if soll_roh[i] == ist_roh[i])
    z["bytes_gleich"], z["bytes_soll"] = ng, len(soll_roh)
    r.append("bytes    %d of %d equal at the same offset (built image %d B)%s" %
             (ng, len(soll_roh), len(ist_roh), "  => BYTE-IDENTICAL" if z["gleich"] else ""))
    if z["gleich"]:
        return r, z
    erst = next((i for i in range(n) if soll_roh[i] != ist_roh[i]), n)
    r.append("first difference at offset %04X" % erst)
    bs, bi = befehle_lesen(soll_lst), befehle_lesen(ist_lst)
    ss, si = aufrufziele(bs) | set(zeiger_soll), aufrufziele(bi) | set(zeiger_ist)
    es = eigen_soll if eigen_soll else ts
    ei = eigen_ist if eigen_ist else ti
    fk = funktionsgrenzen or []

    def fkt(a):
        for s0, e0 in fk:
            if s0 <= a < e0:
                return "%04X" % s0 + ("(%s)" % namen[s0] if namen and s0 in namen else "")
        return "?"

    for titel, (bs2, bi2) in (("own code (0000-%04X orig, 0000-%04X built)" % (es, ei), (_teil(bs, es), _teil(bi, ei))),
                              ("libc part", ([b for b in bs if b[0] >= es and b[0] < ts and not b[2].startswith("DW")],
                                             [b for b in bi if b[0] >= ei and b[0] < ti and not b[2].startswith("DW")]))):
        own = titel.startswith("own")
        ns = normalisieren(bs2, ss, ts, len(soll_roh), len(soll_roh) + soll_kopf[3])
        ni = normalisieren(bi2, si, ti, len(ist_roh), len(ist_roh) + ist_kopf[3])
        roh = difflib.SequenceMatcher(None, ns, ni, autojunk=False)
        g_roh = sum(b.size for b in roh.get_matching_blocks())
        if c2:
            ns, ni = c2_kanon(ns), c2_kanon(ni)
            # c2_kanon changes the lengths: the instruction lists for the position report are rebuilt below
        sm = difflib.SequenceMatcher(None, ns, ni, autojunk=False)
        g = sum(b.size for b in sm.get_matching_blocks())
        k = "own" if own else "libc"
        z[k + "_soll"], z[k + "_ist"], z[k + "_gleich_roh"], z[k + "_gleich"] = len(ns), len(ni), g_roh, g
        z[k + "_diffs"] = sum(1 for t in sm.get_opcodes() if t[0] != "equal")
        if own and es == ei and z[k + "_diffs"] == 0:
            # the instruction streams are equal after address abstraction: count the words that still differ in the image
            # (they can only be call targets, data and bss addresses, which move with the libc part)
            w = [i for i in range(0, es, 2) if soll_roh[i:i + 2] != ist_roh[i:i + 2]]
            z["own_adresswoerter"] = len(w)
            z["own_woerter"] = es // 2
            r.append("own code: instruction streams identical; %d of %d words differ in the image (address operands only)" %
                     (len(w), es // 2))
        r.append("%s: instructions original %d, built %d; matching %d (without c2 model %d); difference blocks %d" %
                 (titel, len(ns), len(ni), g, g_roh, z[k + "_diffs"]))
        if not own:
            continue
        # position of a canonical line: positions are only approximate after the c2 canonicalisation; use the
        # nearest original instruction address by counting
        adr = [b[0] for b in bs2]
        adr_i = [b[0] for b in bi2]
        last, zeilen = None, 0
        for tag, i1, i2, j1, j2 in sm.get_opcodes():
            if tag == "equal":
                continue
            a = adr[min(i1, len(adr) - 1)] if adr else 0
            f = fkt(a)
            if f != last:
                r.append("-- function %s" % f)
                last = f
            zeilen += 1
            if zeilen > 400:
                r.append("... (diff truncated)")
                break
            r.append("  ~%04X %s: orig  %s" % (a, tag, "; ".join(ns[i1:i2][:6]) + (" ..." if i2 - i1 > 6 else "")))
            r.append("                   built %s" % ("; ".join(ni[j1:j2][:6]) + (" ..." if j2 - j1 > 6 else "")))
    return r, z


# ---------------------------------------------------------------- one-shot analysis of a raw image
class Analyse:
    """Result of holen+karte+benennen for one program."""

    def __init__(self, name, arbeit, kopf, raw, karte, lst, stat, namen, texte, funk, zeiger):
        self.name, self.arbeit, self.kopf, self.raw = name, arbeit, kopf, raw
        self.karte, self.lst, self.stat, self.namen, self.texte, self.funk = karte, lst, stat, namen, texte, funk
        self.zeiger = zeiger        # entries found through code pointers (function pointers such as reset)


def analysieren(arbeit, name, raw, kopf, libc=None, handnamen=None, log=print, extra=()):
    """Map, listing, libc names for an image (also used for the built result).  Files in `arbeit`: NAME.k NAME.lst
    NAME.strings NAME.namen."""
    os.makedirs(arbeit, exist_ok=True)
    rp = os.path.join(arbeit, name + ".raw")
    with open(rp, "wb") as f:
        f.write(raw)
    text = kopf[1]
    namen = []
    if libc is not None:
        namen = eindeutig(libc_namen(libc, raw, text))
        namen_schreiben(os.path.join(arbeit, name + ".namen"), namen)
    vorab = kartenzeilen_namen(namen, libc)
    if handnamen:
        vorab += ["name %04X %s" % (a, n) for a, n in sorted(handnamen.items())]
    # extra map lines: verbatim (db/dw/dwc/txt for jump tables and strings, kom ...); `ohne ADDR` = drop that --vorschlaege entry
    ohne = {int(z.split()[1], 16) for z in extra if z.startswith("ohne ")}
    vorab += [z for z in extra if not z.startswith("ohne ")]
    karte, runden, zeiger = karte_bauen(rp, len(raw), vorab=vorab, ohne=ohne)
    texte = texte_finden(raw, text)
    kp = os.path.join(arbeit, name + ".k")
    with open(kp, "w") as f:
        f.write("# map generated by tools/userspace/uspace.py (%d rounds of --vorschlaege)\n" % runden + karte)
    lst, stat = listing(rp, kp)
    with open(os.path.join(arbeit, name + ".lst"), "w") as f:
        f.write(lst)
    with open(os.path.join(arbeit, name + ".strings"), "w") as f:
        for a, t in texte:
            f.write("%04X %s\n" % (a, t))
    befehle = befehle_lesen(lst)
    starts = aufrufziele(befehle, marken_lesen(lst)) | {0}
    funk = funktionen(befehle, starts, text)
    log("%s: %d rounds, %s" % (name, runden, stat.split("\n")[1].strip() if "\n" in stat else stat.strip()))
    return Analyse(name, arbeit, kopf, raw, karte, lst, stat, namen, texte, funk, zeiger)
