# CLAUDE.md -- mutos8k

Guidance for Claude Code (and humans) working in this repository.

## What this project is

Research, documentation and reconstruction of **MUTOS 8000**, the UNIX V7 derivative for the robotron
A5120.16 (A5120 with the EM064/EM256 extension board carrying a U8001 = Z8001).  Goals:

1. **Understand and document** the system: kernel, the U880-side driver `mutos_io`, the toolchain, the disks,
   and (step by step) the user space.
2. **Reconstruct sources** that the original MUTOS toolchain (`cc -O`, `as -u`, `ld -s`, our `make`) turns back
   into working binaries -- **self-hosting**: MUTOS builds its own kernel.  Byte-identity with the originals is the
   standard of proof wherever it is reachable.
3. **Adapt** where useful (e.g. more buffers, the EM1024 1-MB board), always as a documented, tested variant.
4. **Compare with UNIX V7** (`original/unix-v7/`, to be loaded later) and, where possible, move the decompiled code
   back towards the original V7 source text.

**The emulator is a separate project.**  `~/projects/a5120emu` (k1520emu) provides the machine (A5120.16 with
EM256/EM1024), the debugger `k1520dbg`, `boot_trace`, the DiskTool (`k1520disktool`, MUTOS file system) and the
Z8000/Z80 disassemblers (`z8kdis`, `z80_disasm2.py`).  **Never copy those tools here** -- call them through
`tools/emu.py`, which locates the emulator (env `K1520EMU`, default `../a5120emu`) and always goes through its
`k1520emu: tools/dev.sh tool <name>` (rebuilds stale binaries first).  Hardware changes (e.g. EM1024) belong to the emulator.

## Language rules (binding)

* **Source code: English.**  Comments, symbol names (functions, variables, macros, files of new code), log and
  error texts in code are English.  Existing German comments and identifiers are migrated **step by step** --
  when you touch a file, translate what you touch; do not mass-rename in one go without a byte-identity check
  (renaming a C symbol changes nothing in the binary only if the 8-character limit and the link order stay intact).
* **No non-ASCII characters in code** (no umlauts, no typographic quotes) -- the guest tools are 7-bit, and the
  guest `cpp`/`as`/`ld` see only the first **8 characters** of a name.
* **Documentation (`doc/`, README files): German** for now (the existing material is German); new technical
  documents may be English.  Keep facts marked as *measured* vs. *assumed*.
* Kernel C code is **K&R C as the MUTOS `cc` understands it**: no prototypes, no `void` where V7 has none,
  struct members share the name space with variables (prefix members: `p_stat`, `i_mode`, ...), macro names
  significant to 8 characters.

## Layout

```
doc/            documentation (system, kernel, mutos_io, toolchain, disks, user space, plans, references)
kernel/c        reconstructed kernel C sources (one file per original module, functions in kernel order,
                marker /* KERNEL xxxx */ = address in the original mutos_1216)
kernel/h        kernel headers with measured struct layouts (doc/kernel/header_belegstand.md)
kernel/conf     conf.c, sysent.c (configuration tables)
kernel/asm/ref  reference disassembly of the original kernel, one .s per module (assembles byte-identical)
kernel/karte    disassembler maps (karte.txt, linkkarte.txt, adressen.txt)
kernel/abdeckung  execution coverage of the original kernel (U8001 cover runs)
mutos_io/       U880 side: reconstructed source (src/mutosio.mac), map, build, loader-disk pipeline
userspace/      user-space programs (our make, toolchain probes; later the MUTOS commands)
original/       ORIGINAL third-party sources for comparison (unix-v7/, sys3/, hippe-v7/, wega/) -- read-only references
disks/original  images of the original MUTOS disks and the source archives the disk builds start from
disks/gebaut    built disks (NOT committed, see .gitignore)
tools/          Python helpers (tools/emu.py, tools/kernel/*, tools/disks/*)
versuche/       experiments and debugger scripts (k1520dbg -x)
tests/          pytest; guest tests are marked `gast` and skip (exit 77 / pytest skip) without the emulator
```

## Working in the guest (MUTOS inside the emulator)

* Guest runs take minutes to hours of wall clock: **run them in the background**, never poll with `sleep`, and
  leave no waiting loops behind.
* `k1520dbg` mounts copy-on-write by default; with `--rw` **only ever on copies**, never on files in `disks/`.
* The root disk is too small for `cc`'s temporary files: mount an empty disk as `/tmp` (drive A, `rk0`).
* Host files carry 2026 time stamps; set sources to 1987 (`k1520disktool attr --mtime`) and the guest date to 1987,
  otherwise `make` always rebuilds.  End every guest session with `sync`.
* Keystrokes: wait for the prompt after every `keys` (use unique markers + `gscreen`), otherwise characters get lost.
* Fixed addresses the U880 side knows: mailbox at D532 (segment 0), `u` at FC00.  Free in segment 0: D586..EC00.

## Proof standards

* Every reconstruction has a **round-trip guard** (`--check`, exit 77 when the toolchain/emulator is missing):
  source -> original tools -> bytes == original.  Commit only states that pass.
* Every claim in the documentation is either measured (with the command/run that shows it) or marked as assumption.
* Byte-identical where possible; where the old kernel `c2` cannot be reproduced, "functionally equal" plus a boot +
  work test (`tools/kernel/gesamtbau.py`) is the fallback, and the deviation is listed in `doc/kernel/c_rueckbau.md`.

## Licence

BSD 3-Clause (see LICENSE).  MUTOS 8000 is a UNIX V7 derivative; the V7 sources are under the Caldera licence
(BSD-style), to be added to LICENSE.  Original disk images and reconstructed sources are kept here for research.
