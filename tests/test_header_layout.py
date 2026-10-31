"""Layout guard for kernel/h (AP H4): offsets and sizes of the kernel structures must not move.

The headers follow the V7 text (unions b_un, i_un, f_un ...), but the layout is the measured one of mutos_1216
(doc/kernel/header_belegstand.md).  A tiny C struct layouter (Z8001 cc model: char 1, int/short/pointer 2, long 4,
everything but char aligned to 2) computes the offsets; the expected values below are the measured ones.
No emulator needed.
"""
import re
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
H = ROOT / "kernel" / "h"

BASE = {"char": 1, "short": 2, "int": 2, "unsigned": 2, "long": 4}


def strip_comments(t):
    return re.sub(r"/\*.*?\*/", " ", t, flags=re.S)


class Layout:
    def __init__(self):
        self.macros = {}
        self.typedefs = {}      # name -> (size, align)
        self.structs = {}       # tag -> (size, {member: offset})
        for name in ("types.h", "param.h", "dir.h"):
            self.read_macros_and_typedefs((H / name).read_text())

    def read_macros_and_typedefs(self, text):
        text = strip_comments(text)
        for m in re.finditer(r"^#define\s+(\w+)\s+(.+)$", text, re.M):
            self.macros[m.group(1)] = m.group(2).strip()
        for m in re.finditer(r"typedef\s+([\w ]+?)\s*(\*?)\s*(\w+)(\[(\w+)\])?\s*;", text):
            base, star, name, _, dim = m.groups()
            if star:
                self.typedefs[name] = (2, 2)
            else:
                size = BASE[base.strip().replace("unsigned int", "unsigned").replace("unsigned short", "short")] \
                    if base.strip() in BASE or base.strip().startswith("unsigned") else self.typedefs[base.strip()][0]
                n = self.num(dim) if dim else 1
                self.typedefs[name] = (size * n, 1 if size == 1 and not dim else 2)

    def num(self, expr):
        for _ in range(20):
            new = re.sub(r"\b[A-Za-z_]\w*\b", lambda m: self.macros.get(m.group(0), m.group(0)), expr)
            if new == expr:
                break
            expr = new
        expr = re.sub(r"sizeof\s*\(\s*daddr_t\s*\)", "4", expr)
        expr = re.sub(r"\(\s*(daddr_t|ino_t|dev_t)\s*\)", "", expr)
        return int(eval(expr, {"__builtins__": {}}, {}))

    # --- parser -------------------------------------------------------------------------------
    def parse_header(self, name):
        text = strip_comments((H / name).read_text())
        self.read_macros_and_typedefs(text)
        for m in re.finditer(r"\bstruct\s+(\w+)\s*\{", text):
            tag = m.group(1)
            body, _ = self.block(text, m.end() - 1)
            if tag not in self.structs:
                self.structs[tag] = self.layout(body, union=False)

    @staticmethod
    def block(text, i):
        depth, j = 0, i
        while True:
            if text[j] == "{":
                depth += 1
            elif text[j] == "}":
                depth -= 1
                if depth == 0:
                    return text[i + 1:j], j + 1
            j += 1

    def layout(self, body, union):
        """Return (size, {member: absolute offset within this aggregate}); nested members are hoisted (V7 cc name space)."""
        members, off, size, i = {}, 0, 0, 0
        body = body.strip()
        while i < len(body):
            m = re.match(r"\s*(struct|union)\s*(\w*)\s*\{", body[i:])
            if m:
                sub, end = self.block(body, i + m.end() - 1)
                kind = m.group(1)
                ssize, smem = self.layout(sub, union=(kind == "union"))
                rest_end = body.index(";", end)
                dname = body[end:rest_end].strip()
                al = 2
                off = (off + 1) & ~1 if not union else 0
                base = off
                for k, v in smem.items():
                    members.setdefault(k, base + v)
                if dname:
                    members[dname] = base
                off = base + ssize if not union else 0
                size = max(size, base + ssize)
                i = rest_end + 1
                continue
            j = body.index(";", i)
            decl = body[i:j].strip()
            i = j + 1
            if not decl:
                continue
            msize, malign, mname = self.decl(decl)
            if malign == 2:
                off = (off + 1) & ~1 if not union else 0
            at = 0 if union else off
            members[mname] = at
            if not union:
                off += msize
            size = max(size, at + msize)
        return (size + 1) & ~1, members

    def decl(self, d):
        fp = re.match(r"[\w\s]+\(\s*\*\s*(\w+)\s*\)\s*\(\s*\)", d)
        if fp:
            return 2, 2, fp.group(1)
        m = re.match(r"(.*?)(\*?)\s*(\w+)\s*(\[([^\]]+)\])?\s*$", d, re.S)
        typ, star, name, _, dim = m.groups()
        typ = " ".join(typ.split())
        if "*" in typ:
            star, typ = "*", typ.replace("*", "").strip()
        n = self.num(dim) if dim else 1
        if star:
            return 2 * n, 2, name
        typ = re.sub(r"^(register|extern)\s+", "", typ)
        if typ.startswith("struct "):
            size = self.structs[typ[7:]][0]
            return size * n, 2, name
        t = typ.replace("unsigned short", "short").replace("unsigned int", "int")
        if t in BASE or t == "unsigned":
            size = BASE[t]
            return size * n, 1 if size == 1 else 2, name
        size, al = self.typedefs[t]
        return size * n, al if not dim else (1 if size == 1 else 2), name


def build():
    lay = Layout()
    for h in ("buf.h", "inode.h", "file.h", "proc.h", "filsys.h", "mount.h", "text.h", "callo.h", "ino.h", "dir.h",
              "fblk.h", "map.h", "mbx.h", "conf.h", "systm.h", "tty.h", "user.h"):
        lay.parse_header(h)
    return lay


# measured values (header_belegstand.md, header comments); hex
EXPECT = {
    "buf": (0x18, dict(b_flags=0, b_forw=2, b_back=4, av_forw=6, av_back=8, b_dev=0xA, b_bcount=0xC, b_un=0xE, b_addr=0xE,
                       b_words=0xE, b_filsys=0xE, b_dino=0xE, b_daddr=0xE, b_blkno=0x10, b_xmem=0x14, b_error=0x15, b_resid=0x16)),
    "inode": (0x4A, dict(i_flag=0, i_count=1, i_dev=2, i_number=4, i_mode=6, i_nlink=8, i_uid=0xA, i_gid=0xC, i_size=0xE,
                         i_un=0x12, i_addr=0x12, i_rdev=0x12, i_lastr=0x46)),
    "file": (8, dict(f_flag=0, f_count=1, f_inode=2, f_un=4, f_offset=4, f_chan=4)),
    "proc": (0x1C, dict(p_stat=0, p_flag=1, p_pri=2, p_time=3, p_cpu=4, p_nice=5, p_sig=6, p_uid=8, p_pgrp=0xA, p_pid=0xC,
                        p_ppid=0xE, p_addr=0x10, p_size=0x12, p_wchan=0x14, p_textp=0x16, p_link=0x18, p_clktim=0x1A)),
    "xproc": (0x1A, dict(xp_xstat=0x10, xp_utime=0x12, xp_stime=0x16)),
    "filsys": (0x1B8, dict(s_isize=0, s_fsize=2, s_nfree=6, s_free=8, s_ninode=0xD0, s_inode=0xD2, s_flock=0x19A, s_ilock=0x19B,
                           s_fmod=0x19C, s_ronly=0x19D, s_time=0x19E, s_tfree=0x1A2, s_tinode=0x1A6)),
    "mount": (6, dict(m_dev=0, m_bufp=2, m_inodp=4)),
    "text": (0xC, dict(x_daddr=0, x_caddr=2, x_size=4, x_iptr=6, x_count=8, x_ccount=9, x_flag=0xA)),
    "callo": (6, dict(c_time=0, c_arg=2, c_func=4)),
    "dinode": (0x40, dict(di_mode=0, di_nlink=2, di_uid=4, di_gid=6, di_size=8, di_addr=0xC, di_atime=0x34, di_mtime=0x38, di_ctime=0x3C)),
    "direct": (16, dict(d_ino=0, d_name=2)),
    "fblk": (2 + 4 * 50, dict(df_nfree=0, df_free=2)),
    "map": (4, dict(m_size=0, m_addr=2)),
    "rkmbx": (14, dict(mb_cmd=0, mb_unit=1, mb_dir=2, mb_stat=3, mb_seg=4, mb_addr=6, mb_cnt=8, mb_blk=0xA)),
    "bdevsw": (8, dict(d_open=0, d_close=2, d_strategy=4, d_tab=6)),
    "linesw": (20, dict(l_open=0, l_input=0xA, l_output=0xC, l_x=0xE)),
    "sysent": (4, dict(sy_narg=0, sy_nrarg=1, sy_call=2)),
    "tty": (0x3C, dict(t_inq=0, t_outq=6, t_oproc=0xC, t_pgrp=0x10, t_obuf=0x12, t_dev=0x14, t_erase=0x18, t_kill=0x19,
                       t_flags=0x1A, t_state=0x28, t_lstate=0x2A, t_delct=0x2E, t_line=0x34, t_ocnt=0x36, t_hwp=0x38, t_hwf=0x3A)),
    "user": (0x3FC, dict(u_segflg=0x12, u_error=0x13, u_uid=0x16, u_gid=0x18, u_ruid=0x1A, u_rgid=0x1C, u_procp=0x1E, u_ap=0x20,
                         u_r=0x22, r_val1=0x22, r_val2=0x24, u_base=0x26, u_count=0x28, u_offset=0x2A, u_cdir=0x2E, u_rdir=0x30,
                         u_dbuf=0x32, u_dirp=0x40, u_dent=0x42, u_pdir=0x52, u_ofile=0x62, u_pofile=0x8A, u_arg=0x9E,
                         u_tsize=0xA8, u_dsize=0xAA, u_ssize=0xAC, u_qsav=0xAE, u_ssav=0xC0, u_signal=0xD2, u_utime=0xF4,
                         u_stime=0xF8, u_cutime=0xFC, u_cstime=0x100, u_ar0=0x104, u_prof=0x10A, pr_scale=0x110, u_sep=0x113,
                         u_ttyp=0x114, u_ttyd=0x116, u_ex=0x118, u_exname=0x140, u_start=0x14E, u_cmask=0x156,
                         u_fpsaved=0x15A, u_fparea=0x15C)),
}


@pytest.fixture(scope="module")
def lay():
    return build()


@pytest.mark.parametrize("tag", sorted(EXPECT))
def test_layout(lay, tag):
    size, members = EXPECT[tag]
    got_size, got = lay.structs[tag]
    assert got_size == size, "sizeof(struct %s): %#x, measured %#x" % (tag, got_size, size)
    bad = {k: (hex(got.get(k, -1)), hex(v)) for k, v in members.items() if got.get(k) != v}
    assert not bad, "struct %s offsets (got, measured): %s" % (tag, bad)


def test_cdevsw_size(lay):
    assert lay.structs["cdevsw"][0] == 14
