"""Tolerant parser for Lua table literals, used to read Balatro's game data.

It understands strings, numbers, booleans, nil and table constructors.
Anything else (function calls, arithmetic, references such as G.C.RED)
is returned as an Expr object holding the raw source text, so the caller
can decide what to do with it instead of the parser guessing.
"""

import re


class Expr:
    """A Lua expression the parser did not evaluate. `src` is its raw text."""

    def __init__(self, src):
        self.src = src

    def __repr__(self):
        return f"Expr({self.src!r})"

    def __eq__(self, other):
        return isinstance(other, Expr) and other.src == self.src


class Tok:
    __slots__ = ("kind", "value", "start", "end")

    def __init__(self, kind, value, start, end):
        self.kind, self.value, self.start, self.end = kind, value, start, end

    def __repr__(self):
        return f"Tok({self.kind},{self.value!r})"


_LONG_BRACKET = re.compile(r"\[(=*)\[")
_NUMBER = re.compile(r"0[xX][0-9a-fA-F]+|(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?")
_NAME = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
_PUNCT = ["...", "..", "==", "~=", "<=", ">=", "::"]
_ESCAPES = {"n": "\n", "t": "\t", "r": "\r", "\\": "\\", '"': '"', "'": "'", "\n": "\n", "a": "\a", "b": "\b", "f": "\f", "v": "\v"}


def tokenize(src, pos=0):
    """Yield tokens from `src` starting at `pos`, skipping whitespace and comments."""
    n = len(src)
    while pos < n:
        c = src[pos]
        if c in " \t\r\n":
            pos += 1
            continue
        if src.startswith("--", pos):
            m = _LONG_BRACKET.match(src, pos + 2)
            if m:
                close = "]" + m.group(1) + "]"
                end = src.find(close, m.end())
                pos = n if end < 0 else end + len(close)
            else:
                end = src.find("\n", pos)
                pos = n if end < 0 else end + 1
            continue
        start = pos
        if c in "\"'":
            pos += 1
            out = []
            while pos < n and src[pos] != c:
                ch = src[pos]
                if ch == "\\":
                    nxt = src[pos + 1]
                    if nxt.isdigit():
                        m = re.match(r"\d{1,3}", src[pos + 1:])
                        out.append(chr(int(m.group(0))))
                        pos += 1 + len(m.group(0))
                        continue
                    out.append(_ESCAPES.get(nxt, nxt))
                    pos += 2
                    continue
                out.append(ch)
                pos += 1
            pos += 1
            yield Tok("str", "".join(out), start, pos)
            continue
        m = _LONG_BRACKET.match(src, pos)
        if m:
            close = "]" + m.group(1) + "]"
            end = src.find(close, m.end())
            body = src[m.end():end]
            if body.startswith("\n"):
                body = body[1:]
            pos = end + len(close)
            yield Tok("str", body, start, pos)
            continue
        m = _NUMBER.match(src, pos)
        if m and (c.isdigit() or (c == "." and pos + 1 < n and src[pos + 1].isdigit())):
            text = m.group(0)
            value = int(text, 16) if text[:2].lower() == "0x" else (float(text) if any(ch in text for ch in ".eE") else int(text))
            pos = m.end()
            yield Tok("num", value, start, pos)
            continue
        m = _NAME.match(src, pos)
        if m:
            pos = m.end()
            yield Tok("name", m.group(0), start, pos)
            continue
        for p in _PUNCT:
            if src.startswith(p, pos):
                pos += len(p)
                yield Tok("op", p, start, pos)
                break
        else:
            pos += 1
            yield Tok("op", c, start, pos)


class Parser:
    def __init__(self, src, pos=0):
        self.src = src
        self.toks = list(tokenize(src, pos))
        self.i = 0

    def peek(self, k=0):
        j = self.i + k
        return self.toks[j] if j < len(self.toks) else Tok("eof", None, len(self.src), len(self.src))

    def take(self):
        t = self.peek()
        self.i += 1
        return t

    def expect(self, value):
        t = self.take()
        if t.value != value:
            raise SyntaxError(f"expected {value!r}, got {t!r} at offset {t.start}")
        return t

    def table(self):
        """Parse a table constructor. Returns a dict for keyed fields; positional
        fields are stored under integer keys 1..n, as in Lua."""
        self.expect("{")
        out, idx = {}, 1
        while self.peek().value != "}":
            t = self.peek()
            if t.value == "[":
                self.take()
                key = self.value()
                self.expect("]")
                self.expect("=")
                out[key] = self.value()
            elif t.kind == "name" and self.peek(1).value == "=" and self.peek(2).value != "=":
                self.take()
                self.take()
                out[t.value] = self.value()
            else:
                out[idx] = self.value()
                idx += 1
            if self.peek().value in (",", ";"):
                self.take()
            elif self.peek().value != "}":
                raise SyntaxError(f"unexpected {self.peek()!r} at offset {self.peek().start}")
        self.expect("}")
        return out

    def _simple(self):
        t = self.peek()
        if t.value == "{":
            return self.table()
        if t.kind in ("str", "num"):
            self.take()
            return t.value
        if t.kind == "name" and t.value in ("true", "false", "nil"):
            self.take()
            return {"true": True, "false": False, "nil": None}[t.value]
        if t.value == "-" and self.peek(1).kind == "num":
            self.take()
            return -self.take().value
        raise _NotSimple()

    def value(self):
        """Parse one field value. Literals are returned as Python values; any
        other expression is returned as Expr(raw_source)."""
        start_i = self.i
        try:
            v = self._simple()
            if self.peek().value in (",", ";", "}", "]"):
                return v
        except _NotSimple:
            pass
        self.i = start_i
        return self._raw_expr()

    def _raw_expr(self):
        depth = 0
        first = self.peek()
        last = first
        while True:
            t = self.peek()
            if t.kind == "eof":
                break
            if depth == 0 and t.value in (",", ";", "}", "]"):
                break
            if t.value in ("(", "{", "["):
                depth += 1
            elif t.value in (")", "}", "]"):
                depth -= 1
            last = self.take()
        return Expr(self.src[first.start:last.end].strip())


class _NotSimple(Exception):
    pass


def parse_table_at(src, pattern):
    """Find the regex `pattern` (which must end right before a '{') and parse
    the table constructor that follows it."""
    m = re.search(pattern, src)
    if not m:
        raise LookupError(f"pattern not found: {pattern}")
    brace = src.index("{", m.end() - 1)
    # Tokenize only the balanced region, so trailing code can't trip the tokenizer.
    end = find_matching_brace(src, brace)
    return Parser(src[brace:end + 1]).table()


def find_matching_brace(src, open_pos):
    depth = 0
    for t in tokenize(src, open_pos):
        if t.value == "{":
            depth += 1
        elif t.value == "}":
            depth -= 1
            if depth == 0:
                return t.start
    raise SyntaxError("unbalanced braces")
