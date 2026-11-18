"""Guard for tools/userspace/wk_w8.py (rebuild of the shipped libc.a, crt0.o, mcrt0.o; doc/userspace/wk_w8.md).

* host parts: every member of the shipped libc.a has a source in userspace/libc (NAME.c or NAME.s), the sources are 7-bit ASCII,
  the archive writer reproduces the shipped libc.a from its own members (order, headers, padding) -- needs the shipped disk (skips without);
* `gast` + USERSPACE_GAST=1: the guest rebuild of a few members (`cc -O -c`, `as -u`) is byte-identical to the shipped members.
"""
import os
import sys

import pytest

from conftest import PROJECT_ROOT

TOOLS = PROJECT_ROOT / "tools" / "userspace"
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "kernel"))
sys.path.insert(0, str(TOOLS))
import wk_w8 as W   # noqa: E402
import objformat as O  # noqa: E402
import uspace as U  # noqa: E402

LIBC = PROJECT_ROOT / "userspace" / "libc"


def test_sources_are_ascii():
    for p in list(LIBC.glob("*.c")) + list(LIBC.glob("*.s")):
        p.read_bytes().decode("ascii")


@pytest.fixture(scope="module")
def shipped(tmp_path_factory):
    try:
        U.pruefe()
        return U.libc_archiv(str(tmp_path_factory.mktemp("w8")))
    except U.Fehlt:
        pytest.skip("emulator or disk missing")


def test_every_member_has_a_source(shipped):
    names = [m.name.decode()[:-2] for m in O.Archiv.lesen(shipped).mitglieder]
    assert len(names) == 140
    missing = [n for n in names if not ((LIBC / (n + ".c")).exists() or (LIBC / (n + ".s")).exists())]
    assert missing == []
    assert (LIBC / "crt0.s").exists() and (LIBC / "mcrt0.s").exists()


def test_archive_writer_reproduces_libc_a(shipped):
    ar = O.Archiv.lesen(shipped)
    again = O.Archiv([O.Mitglied(m.name, m.datum, m.uid, m.gid, m.mode, m.daten, m.pad) for m in ar.mitglieder]).schreiben()
    assert again == shipped


@pytest.mark.gast
@pytest.mark.skipif(not os.environ.get("USERSPACE_GAST"), reason="guest run (minutes); set USERSPACE_GAST=1")
def test_guest_members_identical(shipped, tmp_path):
    W.WORK = str(tmp_path)
    W.SHIP = str(tmp_path / "ship")
    os.makedirs(W.SHIP, exist_ok=True)
    for m in O.Archiv.lesen(shipped).mitglieder:
        (tmp_path / "ship" / m.name.decode()).write_bytes(m.daten)
    erg = W.gast(["strlen", "atoi"], "c")
    for n, (err, ob) in erg.items():
        assert ob == W.schiff(n), n
