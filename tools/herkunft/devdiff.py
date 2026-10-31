#!/usr/bin/env python3
"""devdiff.py -- statement level deviation analysis: MUTOS function vs a subject tree, classified against other trees.

For every MUTOS function that has a same-named function in the SUBJECT tree (e.g. Torsten Hippe's
kernel with its #ifdef switches resolved), both bodies are reduced to statement lists (comments, casts,
register/auto, local declarations, braces removed; locals renamed to ID; numbers canonicalised to
decimal; types collapsed -- the PDP-11 -> Z8001 seam is thereby normalised away).  The two lists are
aligned (difflib); every differing block ("hunk") is then looked up in the same-named function of
each other tree ("does every statement of this side occur there?").

Verdict per hunk (M = MUTOS side, H = subject side, O = other trees that have the function):
  M_OTHER   M occurs in some tree of O, H in none      -> subject differs from the others (subject changed/added)
  H_OTHER   H occurs in some tree of O, M in none      -> MUTOS differs from the others
  MIXED     both occur, in different trees
  SHARED    both occur in the same tree (pure form difference)
  M_ONLY    M non-empty, H empty, M in no tree        -> statement only MUTOS has
  H_ONLY    H non-empty, M empty, H in no tree        -> statement only the subject has
  REWRITE   both non-empty, neither occurs anywhere   -> different text on both sides (compiler form, own code)
For M empty / H empty hunks that occur in O the verdict is H_OTHER / M_OTHER respectively
(the missing side is "the others agree with the side that has it").

Usage (all paths are arguments; trees are `label=dir[:dir...]`, first non-recursive .c files per dir):
  python3 -I tools/herkunft/devdiff.py --mutos kernel/c/alloc.c kernel/c/iget.c \\
      --subject hippe=SCR/h6_hippe_eff/sys \\
      --tree v7=original/unix-v7/usr/sys/sys --tree nij=SCR/h6_nijmegen_eff/kernel \\
      --aux hraw=SCR/h6_hippe/usr/sys/sys --json out.json --md out.md
  --alias MUTOSNAME=TREENAME   pair differently named functions (e.g. ttyspec=ttyspcl); repeatable
  --min-ratio R                functions with statement ratio < R are flagged `form` (compiler form), default 0.6
The --aux trees are only reported (field `aux`), they do not take part in the verdict.
"""
import argparse
import collections
import difflib
import json
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import herkunft as H  # noqa: E402  (tokenizer / function splitter of the provenance tool)

CTRL = ("if", "while", "for", "switch")


def _canon_num(t):
    s = t.text
    if t.kind == "CHR":
        return H.Tok("STR", s, t.line, t.pp)
    m = re.fullmatch(r"(0[xX][0-9a-fA-F]+|\d+)[lLuU]*", s)
    if not m:
        return H.Tok("STR", s, t.line, t.pp)
    d = m.group(1)
    try:
        v = int(d, 16) if d[:2] in ("0x", "0X") else (int(d, 8) if len(d) > 1 and d[0] == "0" else int(d))
    except ValueError:
        return H.Tok("STR", s, t.line, t.pp)
    return H.Tok("STR", "#%d" % v, t.line, t.pp)


def statements(func):
    """Return [(text, line)] for the function body (see module doc)."""
    body, locs = H._func_prepare(func)
    toks = [_canon_num(t) if t.kind in ("NUM", "CHR") else t for t in body]
    # normalise per token but keep a map back to lines: run the normaliser on the whole stream and align
    norm = H._normalise(toks, "abs", locs)
    # the normaliser drops tokens (casts, register); lines are therefore taken proportionally from the
    # first surviving occurrence -- good enough for navigation, not exact
    lines = [t.line for t in toks]
    n_n, n_t = len(norm), max(len(toks), 1)
    stm, cur, depth, start = [], [], 0, None
    expect_hdr = False

    def flush(i):
        nonlocal cur, start
        if cur:
            stm.append((" ".join(cur), lines[min(int(start * n_t / max(n_n, 1)), len(lines) - 1)] if lines else 0))
        cur, start = [], None

    i = 0
    while i < n_n:
        w = norm[i]
        if w in ("{", "}"):
            flush(i)
            i += 1
            continue
        if start is None:
            start = i
        cur.append(w)
        if w == "(":
            depth += 1
        elif w == ")":
            depth -= 1
            if depth == 0 and expect_hdr:
                expect_hdr = False
                flush(i)
        elif depth == 0:
            if w == ";":
                flush(i)
            elif w in CTRL:
                expect_hdr = True
            elif w in ("else", "do"):
                flush(i)
            elif w == ":" and (cur[0] in ("case", "default") or (len(cur) == 2 and re.fullmatch(r"\w+", cur[0]))):
                flush(i)
        i += 1
    flush(n_n)
    return stm


def load_tree(spec):
    label, dirs = spec.split("=", 1)
    funcs = collections.defaultdict(list)
    for d in dirs.split(":"):
        for p in sorted(Path(d).glob("*.c")):
            try:
                text = p.read_bytes().decode("latin-1")
                toks, markers = H.tokenize(text)
                fs, _ = H.split_file(toks, markers, str(p))
            except Exception:  # noqa: BLE001  (broken historic source: skip the file)
                continue
            for f in fs:
                funcs[f.name].append((str(p), f))
    return label, funcs


def hunks(a, b):
    sm = difflib.SequenceMatcher(None, [x[0] for x in a], [x[0] for x in b], autojunk=False)
    out = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag != "equal":
            out.append((a[i1:i2], b[j1:j2]))
    return sm.ratio(), out


def occurs(side, sets):
    """trees (labels) in which every statement of `side` occurs."""
    if not side:
        return set()
    txt = [s[0] for s in side]
    return {lab for lab, ss in sets.items() if all(t in ss for t in txt)}


def verdict(m, h, mo, ho):
    if m and h:
        if mo and ho:
            return "SHARED" if mo & ho else "MIXED"
        if mo:
            return "M_OTHER"
        if ho:
            return "H_OTHER"
        return "REWRITE"
    if m:
        return "M_OTHER" if mo else "M_ONLY"
    return "H_OTHER" if ho else "H_ONLY"


def load_soll(path):
    """round-trip table 'module function GLEICH|NAHE' (doc/herkunft/daten/rundlauf_soll.txt) -> {(module, func): flag}"""
    out = {}
    if path:
        for ln in Path(path).read_text().splitlines():
            w = ln.split()
            if len(w) == 3 and not ln.startswith("#"):
                out[(w[0], w[1])] = w[2]
    return out


def analyse(mutos_files, subject, trees, aux, alias, min_ratio, soll=None, base=None):
    soll = soll or {}
    slabel, sfuncs = subject
    res = []
    for mf in mutos_files:
        text = Path(mf).read_bytes().decode("latin-1")
        toks, markers = H.tokenize(text)
        fs, _ = H.split_file(toks, markers, mf)
        for f in fs:
            tname = alias.get(f.name, f.name)
            if tname not in sfuncs:
                res.append({"file": mf, "func": f.name, "status": "no_counterpart"})
                continue
            sp, sf = sfuncs[tname][0]
            ma, sa = statements(f), statements(sf)
            ratio, hk = hunks(ma, sa)
            sets, present = {}, []
            for lab, fn in trees:
                if tname in fn:
                    present.append(lab)
                    sets[lab] = set(s[0] for _, ff in fn[tname] for s in statements(ff))
            auxsets = {}
            sets_all = dict(sets)
            sets_all[slabel] = set(x[0] for x in sa)
            for lab, fn in aux:
                if tname in fn:
                    auxsets[lab] = set(s[0] for _, ff in fn[tname] for s in statements(ff))
            rec = {"file": mf, "func": f.name, "status": "ok", "ratio": round(ratio, 3), "nM": len(ma), "nH": len(sa),
                   "ref_file": sp, "form": ratio < min_ratio,
                   "bytes": soll.get((Path(mf).stem, f.name), "-"), "trees": present, "hunks": []}
            if base in sets:
                # statements of MUTOS that the base tree (plain V7) does not have, and who else has them
                rec["novel"] = [{"s": t, "line": ln, "in": sorted(l for l, ss in sets_all.items() if l != base and t in ss),
                                 "aux": sorted(l for l, ss in auxsets.items() if t in ss)}
                                for t, ln in ma if t not in sets[base]]
                # statements of the subject that the base does not have, and whether MUTOS has them
                mset = set(x[0] for x in ma)
                rec["subj_novel"] = [{"s": t, "line": ln, "in_mutos": t in mset,
                                      "others": sorted(l for l, ss in sets.items() if l != base and t in ss)}
                                     for t, ln in sa if t not in sets[base]]
            for m, h in hk:
                mo, ho = occurs(m, sets), occurs(h, sets)
                rec["hunks"].append({
                    "verdict": verdict(m, h, mo, ho),
                    "M": [s[0] for s in m], "H": [s[0] for s in h],
                    "M_line": m[0][1] if m else None, "H_line": h[0][1] if h else None,
                    "M_in": sorted(mo), "H_in": sorted(ho),
                    "M_in_aux": sorted(occurs(m, auxsets)), "H_in_aux": sorted(occurs(h, auxsets))})
            res.append(rec)
    return res


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--mutos", nargs="+", required=True)
    ap.add_argument("--subject", required=True)
    ap.add_argument("--tree", action="append", default=[])
    ap.add_argument("--aux", action="append", default=[])
    ap.add_argument("--alias", action="append", default=[])
    ap.add_argument("--soll", help="rundlauf_soll.txt: marks functions whose source is proven byte-identical (GLEICH)")
    ap.add_argument("--min-ratio", type=float, default=0.6)
    ap.add_argument("--base", help="label of the plain-V7 tree: adds `novel` / `subj_novel` statement lists")
    ap.add_argument("--json")
    ap.add_argument("--md")
    a = ap.parse_args(argv)
    alias = dict(x.split("=", 1) for x in a.alias)
    res = analyse(a.mutos, load_tree(a.subject), [load_tree(t) for t in a.tree], [load_tree(t) for t in a.aux],
                  alias, a.min_ratio, load_soll(a.soll), a.base)
    if a.json:
        Path(a.json).write_text(json.dumps(res, indent=1))
    cnt = collections.Counter()
    for r in res:
        if r["status"] == "ok":
            for h in r["hunks"]:
                cnt[("form" if r["form"] else "text", r["bytes"], h["verdict"])] += 1
    lines = []
    for r in res:
        if r["status"] != "ok":
            lines.append("%s %s: no counterpart" % (r["file"], r["func"]))
            continue
        lines.append("== %s %s ratio=%.2f%s bytes=%s hunks=%d trees=%s" % (os.path.basename(r["file"]), r["func"], r["ratio"],
                     " FORM" if r["form"] else "", r["bytes"], len(r["hunks"]), ",".join(r["trees"])))
        for h in r["hunks"]:
            lines.append("  [%s] M@%s in=%s | H@%s in=%s aux=%s/%s" % (h["verdict"], h["M_line"], h["M_in"], h["H_line"],
                         h["H_in"], h["M_in_aux"], h["H_in_aux"]))
            for s in h["M"]:
                lines.append("      M> " + s)
            for s in h["H"]:
                lines.append("      H> " + s)
    lines.append("")
    lines.append("counts (kind, bytes, verdict): " + json.dumps({"%s/%s/%s" % k: v for k, v in sorted(cnt.items())}))
    out = "\n".join(lines)
    if a.md:
        Path(a.md).write_text(out + "\n")
    else:
        print(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
