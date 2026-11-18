"""Guard for mutos_io/cpa/src/mutoscpa.mac (plan 48 chain C3.1 -> C4.1).

C3.1 (fast): ASCII only; none of the internal addresses (A lines of doc/plus/cpa/c1_4_inventar.md
section 3) appears as a number outside EQU lines.
"""
import re

from conftest import PROJECT_ROOT

SRC = PROJECT_ROOT / "mutos_io" / "cpa" / "src" / "mutoscpa.mac"

# .PHASE bases, message copy, initial stack, DCB/AUF buffer pointers (as bytes of the pair)
A_NUMBERS = ["9000H", "9400H", "0A400H", "0C8B6H", "0A5A8H", "0A5A9H", "0CB68H",
             "0A8B6H", "0A7B6H", "0B8B6H", "0A5B6H", "0A636H", "0A6B6H", "0A736H"]
A_BYTE_PAIRS = re.compile(r"\bDB\b[^;\n]*\b(0B6H|36H),(0A[5-8]H|0B8H)\b", re.I)


def _code_lines():
    for n, ln in enumerate(SRC.read_text(encoding="ascii").splitlines(), 1):
        code = ln.split(";", 1)[0]
        if re.match(r"^\w+\s+EQU\b", code):
            continue
        yield n, code


def test_quelle_ascii():
    SRC.read_bytes().decode("ascii")


def test_keine_a_zahlen_ausser_equ():
    bad = [(n, c) for n, c in _code_lines()
           if any(re.search(r"\b%s\b" % z, c, re.I) for z in A_NUMBERS) or A_BYTE_PAIRS.search(c)]
    assert not bad, bad
