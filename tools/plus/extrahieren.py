"""Plan 47 P1.3: provenance record -- extract the non-C kernel sources of the natural build into kernel/plus/.

The files low.s, bss.s, dn0.s..dn3.s, shim.s, abs.o, mk1 and Makefile were generated ONCE from the original disk image
(gesamtbau.nat_quellen + basis.anpassen, objects of P1.1) and are maintained by hand from now on.  This script only documents
where they came from and proves it: a second run with --force into a scratch directory must give the same bytes.

  python3 -I tools/plus/extrahieren.py [--ziel DIR] [--force] [--arbeit DIR] [--objekte DIR]   (exit 77 without the emulator)
"""
import argparse
import os
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
sys.path.insert(0, os.path.join(os.path.dirname(HIER), "kernel"))
import basis  # noqa: E402  (imports gesamtbau, gast_as, rundlauf_gast)

G = basis.G
STANDARD_ZIEL = os.path.join(G.WURZEL, "kernel", "plus")


def erzeugen(arbeit, objekte):
    """-> {file name: bytes} of the files that belong to kernel/plus."""
    welt = G.Welt(basis.rundlauf_gast.kernel_holen(), objekte)
    q, _ = G.nat_quellen(welt, arbeit)
    basis.anpassen(q)
    d1, d2, _, _ = basis.aufteilen(q)
    aus = {"mk1": d1["mk1"], "Makefile": d2["Makefile"]}
    for n in basis.ASM:
        aus[n] = d2[n]
    return {n: (v if isinstance(v, bytes) else v.encode("ascii")) for n, v in aus.items()}


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--ziel", default=STANDARD_ZIEL)
    ap.add_argument("--force", action="store_true", help="overwrite existing files")
    ap.add_argument("--arbeit", default="/tmp/mplus/p1_3/extrahieren")
    ap.add_argument("--objekte", default="/tmp/mplus/p1_1/obj")
    a = ap.parse_args(argv)
    try:
        basis.gast_as.pruefe_hilfsmittel()
    except basis.gast_as.Fehlt as e:
        print("skip: missing", e)
        return 77
    os.makedirs(a.arbeit, exist_ok=True)
    dateien = erzeugen(a.arbeit, a.objekte)
    os.makedirs(a.ziel, exist_ok=True)
    for n, b in sorted(dateien.items()):
        p = os.path.join(a.ziel, n)
        if os.path.exists(p) and not a.force:
            print("exists, not overwritten:", p)
            continue
        open(p, "wb").write(b)
        print("written: %s (%d bytes)" % (p, len(b)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
