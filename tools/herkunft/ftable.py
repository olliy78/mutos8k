#!/usr/bin/env python3
"""ftable.py -- per-function similarity table from a `herkunft.py report --json` file.

Row = MUTOS function, column = reference tree: similarity (percent) of the same-named function, or
`(nn%)` = name missing, best other function.  `-` = no function found.

Usage:
  python3 -I tools/herkunft/ftable.py REPORT.json func[,func...]
  (create REPORT.json with: herkunft.py report --mutos kernel/c/*.c --ref label=dir ... --json REPORT.json)
"""
import json
import sys


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    d = json.load(open(argv[1]))
    want = argv[2].split(",")
    refs = list(d["refs"])
    print("%-9s %-9s " % ("func", "file") + " ".join("%5s" % r[:5] for r in refs))
    for m in d["modules"]:
        for f in m["functions"]:
            if f["name"] in want:
                row = []
                for r in refs:
                    x = f["matches"].get(r)
                    if not x:
                        row.append("   - ")
                        continue
                    sn = x.get("same_name")
                    row.append(("%4d%%" % round(100 * sn["sim"])) if sn else ("(%2d%%)" % round(100 * x["sim"])))
                print("%-9s %-9s " % (f["name"], m["file"].split("/")[-1]) + " ".join(row))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
