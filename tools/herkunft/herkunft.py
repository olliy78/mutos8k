#!/usr/bin/env python3
"""herkunft.py -- provenance comparison of K&R C kernel sources (MUTOS 8000 vs UNIX V7 / System III).

Pure standard library; run with `python3 -I tools/herkunft/herkunft.py ...` (the script is one
self-contained module, so -I does not hurt).

Pipeline
  1. tokenize (comments removed, #include dropped, other preprocessor lines kept as pp tokens,
     strings and char constants preserved)
  2. split a file into functions (column-independent: top level statements, brace matching, K&R
     parameter declarations are recognised) and "rest" (declarations, tables, #define, struct bodies)
  3. normalise token streams on three levels
       names   verbatim tokens
       abs     locals/params -> ID, numbers -> NUM, scalar types -> T (casts, register/auto and local
               declarations dropped: the PDP-11 -> Z8001 seam), call names / members / globals / macros /
               strings / keywords kept
       strict  every non-keyword identifier -> ID (also calls, members, globals)
  4. Winnowing (MOSS): k-grams of tokens, hash, window w, keep minimum of each window
  5. similarity: containment in both directions + Jaccard over fingerprint sets, per function and per file
  6. extra evidence per function: shared string literals, call-set overlap, statement counts

Sub commands: compare, report, sysent, structs.  See `--help`.
"""
import argparse
import collections
import difflib
import json
import re
import struct
import sys
import zlib
from pathlib import Path

DEFAULT_K = 5
DEFAULT_W = 4
LEVELS = ("names", "abs", "strict")

KEYWORDS = frozenset("""auto break case char continue default do double else enum extern float for goto if int
long register return short sizeof static struct switch typedef union unsigned void while""".split())
# type words that are collapsed to T on the abs/strict levels (scalar types and the V7 typedefs)
SCALARS = frozenset("""int char long short unsigned float double void daddr_t caddr_t ino_t time_t dev_t off_t
paddr_t physadr label_t ushort uint ulong u_char u_short u_int u_long size_t""".split())
CONTROL = frozenset("if for while switch case default else do".split())
DECL_START = frozenset("""int char long short unsigned float double void struct union register static extern auto
typedef""".split()) | SCALARS
NOT_DECL_ID = KEYWORDS  # an identifier at statement start that is a keyword never starts a "ID ID" declaration

# --------------------------------------------------------------------------------------------------
# tokenizer
# --------------------------------------------------------------------------------------------------
Tok = collections.namedtuple("Tok", "kind text line pp")  # kind: ID NUM STR CHR OP

_MASTER = re.compile(r"""
    (?P<ws>[ \t\r\f\v]+)
  | (?P<nl>\n)
  | (?P<cmt>/\*.*?\*/ | //[^\n]*)
  | (?P<str>"(?:\\.|[^"\\\n])*")
  | (?P<chr>'(?:\\.|[^'\\\n])+')
  | (?P<num>0[xX][0-9a-fA-F]+[lLuU]*|\d+\.\d*(?:[eE][+-]?\d+)?[fFlL]*|\.\d+(?:[eE][+-]?\d+)?|\d+(?:[eE][+-]?\d+)?[lLuU]*)
  | (?P<id>[A-Za-z_]\w*)
  | (?P<op>->|\+\+|--|<<=|>>=|<<|>>|<=|>=|==|!=|&&|\|\||\+=|-=|\*=|/=|%=|&=|\|=|\^=|\.\.\.|\S)
""", re.X | re.S)

_PP_TOK = re.compile(r"""(?P<str>"(?:\\.|[^"\\\n])*")|(?P<chr>'(?:\\.|[^'\\\n])+')
  |(?P<num>0[xX][0-9a-fA-F]+[lLuU]*|\d+(?:\.\d*)?(?:[eE][+-]?\d+)?[lLuU]*)|(?P<id>[A-Za-z_]\w*)
  |(?P<op>->|\+\+|--|<<|>>|<=|>=|==|!=|&&|\|\||\S)""", re.X)
_CMT = re.compile(r"/\*.*?\*/|//[^\n]*", re.S)
_MARKER = re.compile(r"KERNEL\s+([0-9A-Fa-f]{3,6})")


def tokenize(text):
    """Return (tokens, markers).  markers = [(line, 'xxxx')] from /* KERNEL xxxx */ comments."""
    toks, markers = [], []
    pos, line, n = 0, 1, len(text)
    line_start = 0
    while pos < n:
        m = _MASTER.match(text, pos)
        if not m:  # cannot happen (op matches any non-space), but be safe
            pos += 1
            continue
        kind = m.lastgroup
        s = m.group()
        if kind == "nl":
            line += 1
            line_start = m.end()
        elif kind == "ws":
            pass
        elif kind == "cmt":
            mk = _MARKER.search(s)
            if mk:
                markers.append((line, mk.group(1).upper()))
            line += s.count("\n")
            if "\n" in s:
                line_start = pos + s.rindex("\n") + 1
        elif kind == "op" and s == "#" and not text[line_start:pos].strip():
            # preprocessor line (with backslash continuation); comments inside are dropped
            end = pos
            while True:
                e = text.find("\n", end)
                if e < 0:
                    end = n
                    break
                if text[e - 1:e] == "\\":
                    end = e + 1
                    continue
                end = e
                break
            raw = text[pos + 1:end]
            body = _CMT.sub(" ", raw.replace("\\\n", " "))
            words = _PP_TOK.findall(body) and [(mm.lastgroup, mm.group()) for mm in _PP_TOK.finditer(body)]
            if words and words[0][1] == "include":
                pass
            elif words:
                toks.append(Tok("OP", "#", line, True))
                for k2, w2 in words:
                    toks.append(Tok({"str": "STR", "chr": "CHR", "num": "NUM", "id": "ID", "op": "OP"}[k2], w2, line, True))
            line += text.count("\n", pos, end)
            pos = end
            continue
        else:
            toks.append(Tok({"str": "STR", "chr": "CHR", "num": "NUM", "id": "ID", "op": "OP"}[kind], s, line, False))
        pos = m.end()
    return toks, markers


# --------------------------------------------------------------------------------------------------
# function extraction
# --------------------------------------------------------------------------------------------------
class Func:
    __slots__ = ("name", "file", "line", "end_line", "header", "body", "marker", "params", "_cache")

    def __init__(self, name, file, header, body, marker):
        self.name, self.file = name, file
        self.header, self.body, self.marker = header, body, marker
        self.line = header[0].line
        self.end_line = body[-1].line
        self.params = []
        self._cache = {}


def _match_table(T):
    """index of the matching closer for every '(' '[' '{' (unbalanced -> len-1)."""
    mt = {}
    stack = []
    pairs = {")": "(", "]": "[", "}": "{"}
    for i, t in enumerate(T):
        if t.kind != "OP":
            continue
        if t.text in "([{" and len(t.text) == 1:
            stack.append(i)
        elif t.text in pairs:
            # pop until the matching opener type (tolerate stray closers)
            for j in range(len(stack) - 1, -1, -1):
                if T[stack[j]].text == pairs[t.text]:
                    op = stack[j]
                    del stack[j:]
                    mt[op] = i
                    break
    n = len(T)
    for i in stack:
        mt[i] = n - 1
    return mt


def _func_header(hdr, mt_local):
    """hdr = tokens of a top level statement up to (excluding) '{'.  Return (name, p, q) or None."""
    p = None
    for i, t in enumerate(hdr):
        if t.text == "=" and t.kind == "OP":
            return None
        if t.text == "(" and t.kind == "OP":
            p = i
            break
    if p is None or p == 0 or hdr[p - 1].kind != "ID" or hdr[p - 1].text in KEYWORDS:
        return None
    # matching ')'
    depth, q = 0, None
    for i in range(p, len(hdr)):
        if hdr[i].kind == "OP" and hdr[i].text == "(":
            depth += 1
        elif hdr[i].kind == "OP" and hdr[i].text == ")":
            depth -= 1
            if depth == 0:
                q = i
                break
    if q is None:
        return None
    rest = hdr[q + 1:]
    if rest and rest[-1].text != ";":
        return None
    return hdr[p - 1].text, p, q


def _kr_params_so_far(hdr):
    """At a ';' inside a top level statement: is this a K&R parameter declaration list of a function?"""
    p = None
    for i, t in enumerate(hdr):
        if t.kind == "OP" and t.text in ("=", "{"):
            return False
        if t.kind == "OP" and t.text == "(":
            p = i
            break
    if p is None or p == 0 or hdr[p - 1].kind != "ID" or hdr[p - 1].text in KEYWORDS:
        return False
    depth = 0
    for i in range(p, len(hdr)):
        if hdr[i].kind == "OP" and hdr[i].text == "(":
            depth += 1
        elif hdr[i].kind == "OP" and hdr[i].text == ")":
            depth -= 1
            if depth == 0:
                rest = hdr[i + 1:]
                return bool(rest) and rest[0].kind == "ID"
    return False


def split_file(toks, markers, fname=""):
    """-> (funcs, rest_tokens).  rest includes preprocessor tokens."""
    T = [t for t in toks if not t.pp]
    rest = [t for t in toks if t.pp]
    mt = _match_table(T)
    funcs = []
    n = len(T)
    mk = sorted(markers)
    used_line = 0
    i = 0
    while i < n:
        j = start = i
        done = False
        while j < n and not done:
            t = T[j]
            if t.kind == "OP" and t.text == "{":
                hdr = T[start:j]
                fh = _func_header(hdr, mt)
                if fh:
                    k = mt.get(j, n - 1)
                    body = T[j:k + 1]
                    marker = None
                    for ml, mv in mk:
                        if used_line < ml <= hdr[0].line:
                            marker = mv
                    f = Func(fh[0], fname, hdr, body, marker)
                    used_line = f.end_line
                    pname = [x.text for x in hdr[fh[1] + 1:fh[2]] if x.kind == "ID"]
                    f.params = pname
                    funcs.append(f)
                    i = k + 1
                    done = True
                    continue
                j = mt.get(j, n - 1) + 1  # initializer / struct body: part of this statement
                continue
            if t.kind == "OP" and t.text == ";":
                if _kr_params_so_far(T[start:j]):
                    j += 1
                    continue
                rest.extend(T[start:j + 1])
                i = j + 1
                done = True
                continue
            if t.kind == "OP" and t.text in "([":
                j = mt.get(j, n - 1) + 1
                continue
            j += 1
        if not done:
            rest.extend(T[start:])
            i = n
    return funcs, rest


# --------------------------------------------------------------------------------------------------
# declarations, locals, normalisation
# --------------------------------------------------------------------------------------------------
def _is_decl_start(T, i):
    t = T[i]
    if t.kind != "ID":
        return False
    if t.text in DECL_START:
        return True
    if t.text in NOT_DECL_ID:
        return False
    nxt = T[i + 1] if i + 1 < len(T) else None
    if nxt is None:
        return False
    if nxt.kind == "ID" and nxt.text not in KEYWORDS - DECL_START:
        # "ID ID ..." -- typedef-name declaration; but not "ID else" etc.
        return nxt.text not in ("else",)
    if nxt.text == "*" and i + 2 < len(T) and T[i + 2].kind == "ID":
        # "ID * ID ;" or "ID * ID ,"  (declaration of a pointer to a typedef)
        a = T[i + 3] if i + 3 < len(T) else None
        return a is not None and a.text in (";", ",", "[")
    return False


def _decl_names(stmt):
    names = []
    for i, t in enumerate(stmt):
        if t.kind != "ID" or t.text in KEYWORDS or t.text in SCALARS:
            continue
        prev = stmt[i - 1].text if i else ""
        nxt = stmt[i + 1].text if i + 1 < len(stmt) else ";"
        if prev in ("struct", "union", ".", "->"):
            continue
        if nxt in (",", ";", "[", "=", ")"):
            names.append(t.text)
    return names


def strip_decls(body):
    """Drop declaration statements at the start of every block.  -> (tokens, local names)."""
    out, locs = [], set()
    n = len(body)
    i = 0
    block_start = False
    while i < n:
        t = body[i]
        if block_start:
            while i < n and _is_decl_start(body, i):
                depth = 0
                j = i
                while j < n:
                    x = body[j]
                    if x.kind == "OP":
                        if x.text in "([{":
                            depth += 1
                        elif x.text in ")]}":
                            depth -= 1
                        elif x.text == ";" and depth <= 0:
                            break
                    j += 1
                locs.update(_decl_names(body[i:j]))
                i = j + 1
            block_start = False
            if i >= n:
                break
            t = body[i]
        out.append(t)
        if t.kind == "OP" and t.text == "{":
            block_start = True
        i += 1
    return out, locs


def _func_prepare(f):
    c = f._cache
    if "prep" in c:
        return c["prep"]
    kr = f.header
    # parameter names + K&R parameter declarations
    p = next(i for i, t in enumerate(kr) if t.text == "(")
    depth, q = 0, len(kr) - 1
    for i in range(p, len(kr)):
        if kr[i].text == "(":
            depth += 1
        elif kr[i].text == ")":
            depth -= 1
            if depth == 0:
                q = i
                break
    locs = set(x.text for x in kr[p + 1:q] if x.kind == "ID")
    body2, bl = strip_decls(f.body)
    locs |= bl
    c["prep"] = (body2, locs)
    return c["prep"]


def _normalise(toks, level, locs):
    out = []
    prev_kind = ""
    for i, t in enumerate(toks):
        txt = t.text
        if t.kind == "ID":
            if txt in ("register", "auto"):
                continue
            if txt in SCALARS:
                if out and out[-1] == "T":
                    continue
                out.append("T")
                continue
            prev = toks[i - 1].text if i and toks[i - 1].kind == "OP" else ""
            member = prev in (".", "->")
            if txt in KEYWORDS:
                out.append(txt)
            elif member:
                out.append("ID" if level == "strict" else txt)
            elif txt in locs or level == "strict":
                out.append("ID")
            else:
                out.append(txt)
        elif t.kind in ("NUM", "CHR"):
            out.append("NUM")
        else:
            out.append(txt)
    # remove casts "( T * * )" / "( struct x * )" except after sizeof
    res = []
    i, n = 0, len(out)
    while i < n:
        if out[i] == "(":
            j = i + 1
            if j < n and out[j] == "T":
                j += 1
            elif j + 1 < n and out[j] in ("struct", "union"):
                j += 2
            else:
                j = -1
            if j > 0:
                while j < n and out[j] == "*":
                    j += 1
                if j < n and out[j] == ")" and not (res and res[-1] in ("sizeof",)):
                    i = j + 1
                    continue
        res.append(out[i])
        i += 1
    return res


def norm_function(f, level):
    key = ("n", level)
    if key in f._cache:
        return f._cache[key]
    if level == "names":
        r = [t.text for t in f.header] + [t.text for t in f.body]
    else:
        body2, locs = _func_prepare(f)
        r = _normalise([t for t in body2], level, locs)
    f._cache[key] = r
    return r


def norm_rest(toks, level):
    if level == "names":
        return [t.text for t in toks]
    return _normalise(toks, level, frozenset())


def func_extras(f):
    """strings, calls, statement count of a function (raw tokens)."""
    if "extras" in f._cache:
        return f._cache["extras"]
    strings, calls = set(), set()
    stmts = 0
    depth = 0
    body = f.body
    for i, t in enumerate(body):
        if t.kind == "STR" and len(t.text) > 2:
            strings.add(t.text)
        elif t.kind == "ID":
            if t.text in CONTROL:
                stmts += 1
            nx = body[i + 1].text if i + 1 < len(body) else ""
            pv = body[i - 1].text if i else ""
            if nx == "(" and t.text not in KEYWORDS and pv not in (".", "->"):
                calls.add(t.text)
        elif t.kind == "OP":
            if t.text == "(":
                depth += 1
            elif t.text == ")":
                depth -= 1
            elif t.text == ";" and depth <= 0:
                stmts += 1
    r = (strings, calls, stmts)
    f._cache["extras"] = r
    return r


# --------------------------------------------------------------------------------------------------
# winnowing and similarity
# --------------------------------------------------------------------------------------------------
def _tokhash(s):
    return zlib.crc32(s.encode("latin-1", "replace"))


def kgram_hashes(tokens, k):
    th = [_tokhash(t) for t in tokens]
    n = len(th)
    if n == 0:
        return []
    if n < k:
        return [zlib.crc32(struct.pack("<%dI" % n, *th))]
    return [zlib.crc32(struct.pack("<%dI" % k, *th[i:i + k])) for i in range(n - k + 1)]


def winnow(hashes, w):
    """MOSS winnowing.  -> sorted list of (hash, position) fingerprints (rightmost minimum per window)."""
    n = len(hashes)
    if n == 0:
        return []
    if n < w:
        m = min(hashes)
        return [(m, max(i for i, h in enumerate(hashes) if h == m))]
    sel = {}
    last = -1
    for s in range(n - w + 1):
        win = hashes[s:s + w]
        m = min(win)
        pos = s + max(i for i, h in enumerate(win) if h == m)
        if pos != last:
            sel[pos] = m
            last = pos
    return sorted((h, p) for p, h in sel.items())


def fingerprint(tokens, k=DEFAULT_K, w=DEFAULT_W):
    """set of winnowing fingerprint hashes of a normalised token list."""
    return frozenset(h for h, _ in winnow(kgram_hashes(tokens, k), w))


def similarity(a, b):
    """-> dict(c_ab, c_ba, jac, sim).  c_ab = share of a's fingerprints found in b."""
    if not a or not b:
        return {"c_ab": 0.0, "c_ba": 0.0, "jac": 0.0, "sim": 0.0}
    inter = len(a & b)
    c_ab, c_ba = inter / len(a), inter / len(b)
    return {"c_ab": c_ab, "c_ba": c_ba, "jac": inter / len(a | b), "sim": (c_ab + c_ba) / 2}


def jaccard(a, b):
    if not a and not b:
        return 0.0
    return len(a & b) / len(a | b)


# --------------------------------------------------------------------------------------------------
# source files and trees
# --------------------------------------------------------------------------------------------------
class Source:
    """One parsed source file with lazily computed fingerprints."""

    def __init__(self, path, k=DEFAULT_K, w=DEFAULT_W, text=None):
        self.path = Path(path)
        self.k, self.w = k, w
        if text is None:
            text = self.path.read_bytes().decode("latin-1")
        toks, markers = tokenize(text)
        self.toks = toks
        self.funcs, self.rest = split_file(toks, markers, str(path))
        self._fp = {}

    @property
    def name(self):
        return self.path.name

    def stream(self, level):
        s = []
        for f in self.funcs:
            s.extend(norm_function(f, level))
        s.extend(norm_rest(self.rest, level))
        return s

    def fp(self, level):
        if ("file", level) not in self._fp:
            self._fp[("file", level)] = fingerprint(self.stream(level), self.k, self.w)
        return self._fp[("file", level)]

    def ntok(self):
        return len(self.toks)

    def func_fp(self, f, level):
        key = ("fn", id(f), level)
        if key not in self._fp:
            self._fp[key] = fingerprint(norm_function(f, level), self.k, self.w)
        return self._fp[key]


def list_sources(paths, exts=(".c", ".h")):
    """expand files / directories (non-recursive) into a sorted file list."""
    out = []
    for p in paths:
        p = Path(p)
        if p.is_dir():
            out.extend(sorted(x for x in p.iterdir() if x.is_file() and x.suffix in exts))
        elif p.is_file():
            out.append(p)
    return out


class RefTree:
    """A reference "source" (one label, several directories) with inverted index for functions."""

    def __init__(self, label, paths, k=DEFAULT_K, w=DEFAULT_W):
        self.label = label
        self.k, self.w = k, w
        self.sources = [Source(p, k, w) for p in list_sources(paths)]
        self.funcs = [(s, f) for s in self.sources for f in s.funcs]
        self.by_name = collections.defaultdict(list)
        for idx, (s, f) in enumerate(self.funcs):
            self.by_name[f.name].append(idx)
        self._idx = {}
        self._fidx = {}

    def func_index(self, level):
        if level not in self._idx:
            ix = collections.defaultdict(list)
            for n, (s, f) in enumerate(self.funcs):
                for h in s.func_fp(f, level):
                    ix[h].append(n)
            self._idx[level] = ix
        return self._idx[level]

    def file_index(self, level):
        if level not in self._fidx:
            ix = collections.defaultdict(list)
            for n, s in enumerate(self.sources):
                for h in s.fp(level):
                    ix[h].append(n)
            self._fidx[level] = ix
        return self._fidx[level]

    def file_matches(self, src, level="abs", top=5):
        fp = src.fp(level)
        cnt = collections.Counter()
        ix = self.file_index(level)
        for h in fp:
            for n in ix.get(h, ()):
                cnt[n] += 1
        res = []
        for n, inter in cnt.items():
            o = self.sources[n]
            sm = similarity(fp, o.fp(level))
            res.append((sm["sim"], n, sm))
        res.sort(key=lambda x: (-x[0], x[1]))
        out = []
        for _, n, sm in res[:top]:
            d = dict(sm)
            d["ref_file"] = str(self.sources[n].path)
            out.append(d)
        return out

    def best_function(self, src, f, level="abs", cands=3):
        """best matching reference function of f.  -> dict with scores, or None"""
        fp = src.func_fp(f, level)
        cnt = collections.Counter()
        ix = self.func_index(level)
        for h in fp:
            for n in ix.get(h, ()):
                cnt[n] += 1
        best = None
        for n, inter in cnt.items():
            s2, f2 = self.funcs[n]
            sm = similarity(fp, s2.func_fp(f2, level))
            key = (round(sm["sim"], 6), f2.name == f.name, inter, -n)
            if best is None or key > best[0]:
                best = (key, n, sm)
        res = {"ref_file": None, "ref_name": None, "ref_line": None, "sim": 0.0, "c_ab": 0.0, "c_ba": 0.0,
               "jac": 0.0}
        if best is not None:
            s2, f2 = self.funcs[best[1]]
            res.update(best[2])
            res.update(ref_file=str(s2.path), ref_name=f2.name, ref_line=f2.line)
            res["name_equal"] = f2.name == f.name
            res["ref_ntok"] = len(norm_function(f2, level))
            st1, ca1, n1 = func_extras(f)
            st2, ca2, n2 = func_extras(f2)
            res["strings_common"] = sorted(st1 & st2)
            res["strings"] = [len(st1), len(st2)]
            res["calls_jac"] = round(jaccard(ca1, ca2), 3)
            res["stmts"] = [n1, n2]
            for lv in LEVELS:
                if lv != level:
                    res["sim_" + lv] = round(similarity(src.func_fp(f, lv), s2.func_fp(f2, lv))["sim"], 4)
            res["partial"] = max(res["c_ab"], res["c_ba"]) >= 0.7 and min(res["c_ab"], res["c_ba"]) < 0.5
        # same-name function (if any): sim at the chosen level
        same = None
        for n in self.by_name.get(f.name, ()):
            s2, f2 = self.funcs[n]
            sm = similarity(fp, s2.func_fp(f2, level))
            if same is None or sm["sim"] > same["sim"]:
                same = {"ref_file": str(s2.path), "sim": round(sm["sim"], 4)}
        res["same_name"] = same
        for kk in ("sim", "c_ab", "c_ba", "jac"):
            res[kk] = round(res[kk], 4)
        return res


def parse_ref(spec, k, w):
    """'LABEL=path[:path...]' or 'path' -> RefTree"""
    if "=" in spec:
        label, paths = spec.split("=", 1)
    else:
        label, paths = Path(spec).name, spec
    return RefTree(label, [p for p in paths.split(":") if p], k, w)


# --------------------------------------------------------------------------------------------------
# compare / report
# --------------------------------------------------------------------------------------------------
def compare_file(path, refs, level="abs", k=DEFAULT_K, w=DEFAULT_W, top=3):
    src = Source(path, k, w)
    res = {"file": str(path), "ntok": src.ntok(), "nfuncs": len(src.funcs), "level": level, "k": k, "w": w,
           "files": {}, "functions": []}
    for r in refs:
        res["files"][r.label] = r.file_matches(src, level, top)
    for f in src.funcs:
        ent = {"name": f.name, "line": f.line, "marker": f.marker, "ntok": len(norm_function(f, level)),
               "matches": {}}
        for r in refs:
            ent["matches"][r.label] = r.best_function(src, f, level)
        res["functions"].append(ent)
    return res


def summarize_source(res, label, threshold):
    """aggregate per-function matches of one MUTOS file against one reference tree"""
    n = len(res["functions"])
    tot = sum(f["ntok"] for f in res["functions"]) or 1
    wsum = hit = hi = nm = 0
    files = collections.Counter()
    for f in res["functions"]:
        m = f["matches"][label]
        wsum += m["sim"] * f["ntok"]
        if m["sim"] >= threshold:
            hit += 1
            files[Path(m["ref_file"]).name] += 1
        if m["sim"] >= 0.8:
            hi += 1
        if m.get("same_name") and m["same_name"]["sim"] >= threshold:
            nm += 1
    return {"n_funcs": n, "n_ge_thr": hit, "n_ge_80": hi, "same_name_ge_thr": nm,
            "wmean": round(wsum / tot, 4) if n else 0.0, "top_files": files.most_common(3)}


def fmt_pct(x):
    return "%3d%%" % round(100 * x)


def cmd_compare(a):
    refs = [parse_ref(s, a.k, a.w) for s in a.ref]
    res = compare_file(a.file, refs, a.level, a.k, a.w, a.top)
    if a.json:
        print(json.dumps(res, indent=1))
        return 0
    print("%s  tokens=%d functions=%d level=%s k=%d w=%d" % (res["file"], res["ntok"], res["nfuncs"], a.level,
                                                              a.k, a.w))
    for lab, ms in res["files"].items():
        print("\nfile similarity vs %s" % lab)
        for m in ms:
            print("  %s sim  jac=%s  mut-in-ref=%s  ref-in-mut=%s  %s" % (
                fmt_pct(m["sim"]), fmt_pct(m["jac"]), fmt_pct(m["c_ab"]), fmt_pct(m["c_ba"]), m["ref_file"]))
    for r in refs:
        print("\nfunctions vs %s" % r.label)
        for f in res["functions"]:
            m = f["matches"][r.label]
            if m["sim"] < a.min:
                continue
            print("  %-12s %4s ntok=%-4d %s (c=%s/%s j=%s) -> %s:%s%s" % (
                f["name"], f["marker"] or "", f["ntok"], fmt_pct(m["sim"]), fmt_pct(m["c_ab"]), fmt_pct(m["c_ba"]),
                fmt_pct(m["jac"]), Path(m["ref_file"] or "-").name, m["ref_name"],
                "  [same name]" if m.get("name_equal") else ""))
    return 0


def cmd_report(a):
    refs = [parse_ref(s, a.k, a.w) for s in a.ref]
    mfiles = list_sources(a.mutos)
    data = {"params": {"k": a.k, "w": a.w, "level": a.level, "threshold": a.threshold},
            "refs": {r.label: {"files": len(r.sources), "funcs": len(r.funcs)} for r in refs}, "modules": []}
    for p in mfiles:
        res = compare_file(p, refs, a.level, a.k, a.w, a.top)
        res["summary"] = {r.label: summarize_source(res, r.label, a.threshold) for r in refs}
        data["modules"].append(res)
    if a.json:
        Path(a.json).parent.mkdir(parents=True, exist_ok=True)
        Path(a.json).write_text(json.dumps(data, indent=1) + "\n")
    md = render_md(data, refs)
    if a.md:
        Path(a.md).parent.mkdir(parents=True, exist_ok=True)
        Path(a.md).write_text(md)
    if not a.json and not a.md:
        print(md)
    return 0


def render_md(data, refs):
    P = data["params"]
    labels = [r.label for r in refs]
    L = ["# Herkunftsvergleich (maschinell erzeugt)", "",
         "Parameter: k=%d, w=%d, Stufe `%s`, Schwelle %d%%.  Werte: token-gewichtetes Mittel der besten "
         "Funktionstreffer (`wmean`), in Klammern Funktionen mit sim >= Schwelle / alle Funktionen, "
         "`gl.Name` = davon Funktionen mit namensgleichem Treffer >= Schwelle; "
         "`sim` = (Containment MUTOS-in-Ref + Ref-in-MUTOS) / 2." % (P["k"], P["w"], P["level"],
                                                                      round(100 * P["threshold"])), ""]
    L.append("## Referenzen")
    L.append("")
    for lab, d in data["refs"].items():
        L.append("* `%s`: %d Dateien, %d Funktionen" % (lab, d["files"], d["funcs"]))
    L += ["", "## Matrix Modul x Quelle (Funktionsebene)", ""]
    L.append("| Modul | Fkt | Token | " + " | ".join(labels) + " |")
    L.append("|---|---|---|" + "---|" * len(labels))
    for m in data["modules"]:
        cells = []
        for lab in labels:
            s = m["summary"][lab]
            if m["nfuncs"]:
                tf = s["top_files"][0][0] if s["top_files"] else "-"
                cells.append("%s (%d/%d, gl.Name %d) %s" % (fmt_pct(s["wmean"]).strip(), s["n_ge_thr"], s["n_funcs"],
                                                            s["same_name_ge_thr"], tf))
            else:
                cells.append("-")
        L.append("| %s | %d | %d | %s |" % (Path(m["file"]).name, m["nfuncs"], m["ntok"], " | ".join(cells)))
    L += ["", "## Matrix Modul x Quelle (Dateiebene, beste Referenzdatei)", ""]
    L.append("| Modul | " + " | ".join(labels) + " |")
    L.append("|---|" + "---|" * len(labels))
    for m in data["modules"]:
        cells = []
        for lab in labels:
            fm = m["files"][lab]
            cells.append("%s %s" % (fmt_pct(fm[0]["sim"]).strip(), Path(fm[0]["ref_file"]).name) if fm else "-")
        L.append("| %s | %s |" % (Path(m["file"]).name, " | ".join(cells)))
    L += ["", "## Funktionen je Modul", ""]
    for m in data["modules"]:
        if not m["functions"]:
            continue
        L += ["### %s" % Path(m["file"]).name, "",
              "| Funktion | Marke | Token | " + " | ".join(labels) + " |", "|---|---|---|" + "---|" * len(labels)]
        for f in m["functions"]:
            cells = []
            for lab in labels:
                x = f["matches"][lab]
                cells.append("%s %s:%s%s" % (fmt_pct(x["sim"]).strip(), Path(x["ref_file"] or "-").name,
                                             x["ref_name"], "" if x.get("name_equal") else "~"))
            L.append("| %s | %s | %d | %s |" % (f["name"], f["marker"] or "", f["ntok"], " | ".join(cells)))
        L.append("")
    return "\n".join(L) + "\n"


# --------------------------------------------------------------------------------------------------
# sysent table and struct layouts (separating evidence V7 / System III)
# --------------------------------------------------------------------------------------------------
def parse_sysent(path):
    """-> list of (argc, funcname) per slot, from a sysent initializer in any of the three layouts."""
    toks, _ = tokenize(Path(path).read_bytes().decode("latin-1"))
    T = [t for t in toks if not t.pp]
    for i in range(len(T) - 3):
        if T[i].text == "sysent" and T[i + 1].text == "[":
            j = i
            while j < len(T) and T[j].text != "=":
                j += 1
            j += 1
            if j >= len(T) or T[j].text != "{":
                continue
            mt = _match_table(T)
            end = mt[j]
            body = T[j + 1:end]
            ent = []
            if any(t.text == "{" for t in body):  # { argc, func }
                k = 0
                while k < len(body):
                    if body[k].text == "{":
                        e = mt.get(j + 1 + k) - (j + 1)
                        grp = [t for t in body[k + 1:e] if t.text != ","]
                        ent.append((int(grp[0].text, 0), grp[-1].text))
                        k = e
                    k += 1
            else:  # argc, flag, func
                vals = [t for t in body if t.text != ","]
                for k in range(0, len(vals) - 2, 3):
                    ent.append((int(vals[k].text, 0), vals[k + 2].text))
            return ent
    return []


def parse_structs(path):
    """-> {struct name: [member names]} for `struct NAME { ... }` definitions."""
    toks, _ = tokenize(Path(path).read_bytes().decode("latin-1"))
    T = [t for t in toks if not t.pp]
    mt = _match_table(T)
    res = {}
    for i in range(len(T) - 2):
        if T[i].text == "struct" and T[i + 1].kind == "ID" and T[i + 2].text == "{":
            end = mt.get(i + 2, len(T) - 1)
            members, stmt, depth = [], [], 0
            for t in T[i + 3:end]:
                if t.text == "{":
                    depth += 1
                elif t.text == "}":
                    depth -= 1
                elif t.text == ";" and depth == 0:
                    members.extend(_decl_names(stmt))
                    stmt = []
                    continue
                if depth == 0 or t.text == "}":
                    stmt.append(t)
            if T[i + 1].text not in res or len(members) > len(res[T[i + 1].text]):
                res[T[i + 1].text] = members
    return res


def cmd_sysent(a):
    m = parse_sysent(a.mutos)
    out = {"mutos": {"slots": len(m)}, "refs": {}}
    for spec in a.ref:
        lab, path = spec.split("=", 1) if "=" in spec else (spec, spec)
        r = parse_sysent(path)
        same = [i for i in range(min(len(m), len(r))) if m[i][1] == r[i][1]]
        sameargc = [i for i in range(min(len(m), len(r))) if m[i] == r[i]]
        diff = [(i, m[i][1], r[i][1]) for i in range(min(len(m), len(r))) if m[i][1] != r[i][1]]
        out["refs"][lab] = {"slots": len(r), "same_func": len(same), "same_func_and_argc": len(sameargc),
                            "differ": diff}
    print(json.dumps(out, indent=1))
    return 0


def cmd_structs(a):
    mine = {}
    for p in list_sources(a.mutos, (".h",)):
        for k, v in parse_structs(p).items():
            mine.setdefault(k, (p.name, v))
    refs = [parse_ref(s, a.k, a.w) for s in a.ref]
    out = {}
    for name, (fn, mem) in sorted(mine.items()):
        ent = {"file": fn, "members": mem, "refs": {}}
        for r in refs:
            best = None
            for s in r.sources:
                if s.path.suffix != ".h":
                    continue
                st = parse_structs(s.path).get(name)
                if st is not None:
                    ratio = difflib.SequenceMatcher(None, mem, st).ratio()
                    if best is None or ratio > best["ratio"]:
                        best = {"file": s.path.name, "ratio": round(ratio, 3), "only_mutos": sorted(set(mem) - set(st)),
                                "only_ref": sorted(set(st) - set(mem)), "n": len(st)}
            ent["refs"][r.label] = best
        out[name] = ent
    print(json.dumps(out, indent=1))
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(prog="herkunft", description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)

    def common(p):
        p.add_argument("-k", type=int, default=DEFAULT_K)
        p.add_argument("-w", type=int, default=DEFAULT_W)
        p.add_argument("--level", choices=LEVELS, default="abs")

    c = sub.add_parser("compare", help="one MUTOS file against reference trees")
    c.add_argument("file")
    c.add_argument("--ref", nargs="+", required=True, help="LABEL=dir[:dir...] or dir")
    c.add_argument("--top", type=int, default=3)
    c.add_argument("--min", type=float, default=0.0, help="hide functions below this sim")
    c.add_argument("--json", action="store_true")
    common(c)
    c.set_defaults(fn=cmd_compare)

    r = sub.add_parser("report", help="all MUTOS files against all reference trees")
    r.add_argument("--mutos", nargs="+", default=["kernel/c", "kernel/h", "kernel/conf"])
    r.add_argument("--ref", nargs="+", required=True)
    r.add_argument("--json", help="write JSON here")
    r.add_argument("--md", help="write Markdown here")
    r.add_argument("--threshold", type=float, default=0.5)
    r.add_argument("--top", type=int, default=3)
    common(r)
    r.set_defaults(fn=cmd_report)

    s = sub.add_parser("sysent", help="compare sysent tables slot by slot")
    s.add_argument("mutos")
    s.add_argument("--ref", nargs="+", required=True, help="LABEL=file")
    s.set_defaults(fn=cmd_sysent)

    t = sub.add_parser("structs", help="compare struct member lists of headers")
    t.add_argument("--mutos", nargs="+", default=["kernel/h"])
    t.add_argument("--ref", nargs="+", required=True)
    t.add_argument("-k", type=int, default=DEFAULT_K)
    t.add_argument("-w", type=int, default=DEFAULT_W)
    t.set_defaults(fn=cmd_structs)

    a = ap.parse_args(argv)
    return a.fn(a)


if __name__ == "__main__":
    sys.exit(main())
