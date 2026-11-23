"""wk_w8_tabelle: per-member result table of W8 (host only; needs `wk_w8.py holen` and the objects of the last builds in work/bau).

  python3 -I tools/userspace/wk_w8_tabelle.py          # markdown table + counts

Class (Plan 44, section 4): G = object file byte-identical to the shipped member, E = text, data, bss and relocations equal, only
debug/section symbol values differ, A = same text/data/bss/relocation words, symbol table order differs (source = data words),
F = not reproduced.
"""
import os
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import wk_w8 as W   # noqa: E402

MODEL = {"popen": "R130", "system": "R130"}    # built via cc -S -> model -> as (wk_w8.py mbau)
WORDS = {"fltpr", "ecvt", "atof", "frexp", "ldexp"}


def klasse(n):
    p = os.path.join(W.WORK, "bau", n + ".o")
    if not os.path.isfile(p):
        return "F", "no object"
    r = W.vergleich(open(p, "rb").read(), W.schiff(n))
    return {"G": "G", "E1": "E", "A1": "A"}.get(r, "F"), r


def quelle(n):
    c, s = os.path.join(W.LIBC, n + ".c"), os.path.join(W.LIBC, n + ".s")
    if os.path.isfile(c):
        t = open(c, "rb").read()
        for d in ("gen", "stdio"):
            v = os.path.join(W.V7, d, n + ".c")
            if os.path.isfile(v):
                return "C", n + ".c", "V7 unchanged" if open(v, "rb").read() == t else "V7 + changes"
        return "C", n + ".c", "reconstructed"
    t = open(s, "rb").read().decode("latin-1")
    return "asm", n + ".s", "data words" if n in WORDS else "reconstructed"


def main():
    rows, cnt = [], {}
    for n in W.mitglieder() + ["crt0", "mcrt0"]:
        k, r = klasse(n)
        art, src, herk = quelle(n)
        cnt[(art, k)] = cnt.get((art, k), 0) + 1
        rows.append((n, art, src, herk, k, MODEL.get(n, "")))
    print("| Glied | Art | Quelle | Herkunft | Klasse | c2-Modell |")
    print("|-------|-----|--------|----------|--------|-----------|")
    for r in rows:
        print("| %s | %s | `%s` | %s | **%s** | %s |" % r)
    print()
    for art in ("C", "asm"):
        print(art, {k: v for (a, k), v in sorted(cnt.items()) if a == art})
    return 0


if __name__ == "__main__":
    sys.exit(main())
