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


def karte_bauen(rawpfad, laenge, vorab=(), max_runden=10):
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
        neu = [a for a in neu if a not in codes]
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
            ist_s = name.endswith("_s")          # assembler variant: cc assembles and links it
            q = {name + (".s" if ist_s else ".c"): text}
            q.update(kopfdateien)
            # the guest runner appends `cat fertigN` (a file on /mnt): every command must end in /mnt
            fl = "-s" if ist_s else flags
            lib = "".join(" /mnt/" + l for l in libs)
            befehle = [("cd /tmp;cc %s -I/mnt -o %s /mnt/%s%s%s >%s.err 2>&1;cd /mnt" % (fl, name, name, ".s" if ist_s else ".c", lib, name))]
            rueck = [name, name + ".err"]
            if asm and not ist_s:
                befehle.append("cd /tmp;cc %s -I/mnt -S /mnt/%s.c >%s.err2 2>&1;cd /mnt" % (flags.replace("-s", "").strip(), name, name))
                rueck += [name + ".s", name + ".err2"]
            aus = {}
            r = gast_as.gast_befehle(os.path.join(arbeit, name), q, befehle, rueck, frist=frist, ausgabe=aus)
            erg[name] = {"bin": r.get(name), "err": (r.get(name + ".err") or b"").decode("latin-1"),
                         "s": (r.get(name + ".s") or b"").decode("latin-1") if asm else None,
                         "dauer": aus.get("dauer", 0.0)}
            log("%s: %s, %d s wall clock" % (name, "binary %d B" % len(r[name]) if r.get(name) else "NO binary",
                                             aus.get("dauer", 0)))
    ts = [threading.Thread(target=lauf, args=(n, t)) for n, t in varianten.items()]
    for t in ts:
        t.start()
    for t in ts:
        t.join()
    return erg


def c2_emu_s(s):
    """Rewrite a `cc -O -S` assembler source so that it reads as the ORIGINAL (older) c2 would have emitted it -- inverse
    of c2_kanon on the .s text (as dialect, hex numbers with %):
      R1  `inc SP,#%k ; ld @SP,x`  ->  `inc SP,#%k+2 ; push @SP,x`
      R2  `xorb rhN,rhN ; ldb mem,rlN` (mem not a register)  ->  XORB dropped
      R3  `xorb rhN,rhN ; cp .. ; jr cc L ; jr M`  ->  `xorb rhN,rhN` inserted before the final `jr M`
    Returns (new text, {rule: count}).  Assembling the result with the guest `as` shows whether the rules explain ALL
    differences of the own code (doc/userspace/init.md)."""
    z = s.split("\n")
    out, n = [], {"R1": 0, "R2": 0, "R3": 0}
    i = 0
    while i < len(z):
        a = z[i]
        b = z[i + 1] if i + 1 < len(z) else ""
        m1 = re.match(r"inc\tSP,#%([0-9A-F]+)$", a)
        m2 = re.match(r"ld\t@SP,(.*)$", b)
        if m1 and m2:
            out.append("inc\tSP,#%%%X" % (int(m1.group(1), 16) + 2))
            out.append("push\t@SP," + m2.group(1))
            n["R1"] += 1
            i += 2
            continue
        x = re.match(r"xorb\t(rh\d),(rh\d)$", a)
        if x and x.group(1) == x.group(2):
            y = re.match(r"ldb\t([^,]+),r([hl]\d)$", b)
            if y and not re.match(r"r[hl]\d$", y.group(1)) and y.group(2) == "l" + x.group(1)[2:]:
                n["R2"] += 1
                i += 1
                continue
            c = z[i + 1] if i + 1 < len(z) else ""
            j = z[i + 2] if i + 2 < len(z) else ""
            k = z[i + 3] if i + 3 < len(z) else ""
            if (re.match(r"cp\t", c) and re.match(r"jr\t\w+\tL\d+$", j) and re.match(r"jr\tL\d+$", k)
                    and (i + 4 >= len(z) or not z[i + 4].startswith("xorb"))):
                out += [a, c, j, a, k]
                n["R3"] += 1
                i += 4
                continue
        out.append(a)
        i += 1
    return "\n".join(out), n


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
    vorab += list(extra)        # verbatim map lines (db/dw/dwc/txt for jump tables and strings, kom ...)
    karte, runden, zeiger = karte_bauen(rp, len(raw), vorab=vorab)
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
