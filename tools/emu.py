"""Locate and drive the emulator project (k1520emu); stdlib only.

The emulator provides the machine and the tools (k1520dbg, k1520disktool, z8kdis, boot_trace, tools/cpm_bau.py).
It is a SEPARATE project and is never modified from here.

Lookup: env K1520EMU, else ../a5120emu relative to this repo; the directory must contain tools/dev.sh.
Scripts that need the emulator call fehlt() first and exit with 77 (skip) when it returns True.

  tool(name, *args)   run `dev.sh tool <name> args` (rebuilds first); NOTE: dev.sh changes into the emulator
                      directory, so every path argument must be absolute.
  tool_cmd(name)      argument list prefix for subprocess (dev.sh tool <name>)
  binary(name)        path of <emu>/build/<name> after ONE `dev.sh build` per process (for frequent calls)
  cpm_bau()           import the emulator's tools/cpm_bau.py (M80/LINKMT build, CPA_TOOLS)
  dbg(args, repo_subst=True)  run k1520dbg; in `-x` scripts @REPO@ = repo root, @DISK:name@ = emu.mutos_disk(name)
  repo()              root of the mutos8k repo
"""
import importlib
import os
import re
import subprocess
import sys
import tempfile

SKIP = 77
_HERE = os.path.dirname(os.path.abspath(__file__))
_built = False


def repo():
    return os.path.dirname(_HERE)


def emulator():
    """Emulator root or None."""
    cand = os.environ.get("K1520EMU") or os.path.join(os.path.dirname(repo()), "a5120emu")
    cand = os.path.abspath(os.path.expanduser(cand))
    if os.path.isfile(os.path.join(cand, "tools", "dev.sh")):
        return cand
    return None


def fehlt():
    """True when the emulator project is not available."""
    return emulator() is None


def _need():
    e = emulator()
    if e is None:
        raise RuntimeError("emulator project not found (set K1520EMU=<path to a5120emu>)")
    return e


def tool(name, *args, **kw):
    """Run `tools/dev.sh tool <name> args` in the emulator; returns CompletedProcess.

    keyword args are passed to subprocess.run (capture_output, text, env, check, timeout ...)."""
    e = _need()
    return subprocess.run([os.path.join(e, "tools", "dev.sh"), "tool", name] + [str(a) for a in args],
                          cwd=e, **kw)


def tool_cmd(name):
    """Argument list prefix `[dev.sh, "tool", name]` for subprocess calls."""
    return [os.path.join(_need(), "tools", "dev.sh"), "tool", name]


def build():
    """One `dev.sh build` per process."""
    global _built
    if not _built:
        e = _need()
        if not os.environ.get("K1520EMU_NOBUILD"):
            r = subprocess.run([os.path.join(e, "tools", "dev.sh"), "build"], cwd=e,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            if r.returncode != 0:
                raise RuntimeError("dev.sh build failed:\n" + r.stdout[-2000:])
        _built = True


def binary(name):
    """Path of a freshly built emulator binary (build once, then call it directly)."""
    build()
    return os.path.join(_need(), "build", name)


def cpm_bau():
    """The emulator's cpm_bau module."""
    d = os.path.join(_need(), "tools")
    if d not in sys.path:
        sys.path.insert(0, d)
    return importlib.import_module("cpm_bau")


def mutos_disk(name):
    """Finished guest disk file name `name`: disks/gebaut first, else the emulator's disks/gebaut."""
    p = os.path.join(repo(), "disks", "gebaut", name)
    if os.path.isfile(p):
        return p
    e = emulator()
    if e:
        q = os.path.join(e, "disks", "a5120_16_MUTOS", name)
        if os.path.isfile(q):
            return q
    return p


def dbg(args, **kw):
    """Run k1520dbg; `-x script` files get @REPO@ replaced by the repo root (copy in a temp dir)."""
    args = [re.sub(r"@DISK:([^@]+)@", lambda m: mutos_disk(m.group(1)), str(a)) for a in args]
    out = list(args)
    tmp = tempfile.mkdtemp(prefix="dbg_")
    for i, a in enumerate(args[:-1]):
        if a == "-x" and os.path.isfile(args[i + 1]):
            with open(args[i + 1], encoding="latin-1") as f:
                txt = f.read().replace("@REPO@", repo())
            txt = re.sub(r"@DISK:([^@]+)@", lambda m: mutos_disk(m.group(1)), txt)
            p = os.path.join(tmp, os.path.basename(args[i + 1]))
            with open(p, "w", encoding="latin-1") as f:
                f.write(txt)
            out[i + 1] = p
    return tool("k1520dbg", *out, **kw)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "dbg":     # tools/emu.py dbg <k1520dbg args>
        if fehlt():
            sys.exit(SKIP)
        sys.exit(dbg(sys.argv[2:]).returncode)
    print("repo:     ", repo())
    print("emulator: ", emulator())
