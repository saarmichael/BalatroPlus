"""Tiny evaluator for the simple Lua expressions found in Balatro's card UI code.

Used to resolve the loc_vars that fill #n# placeholders in joker descriptions.
Supports: literals, names, field/index access, calls to whitelisted functions,
table constructors, and/or/not, comparison, .., arithmetic, unary minus and #.
Anything else raises EvalError, and the caller marks the value as unresolved.
"""

import math

from lua_literal import tokenize


class EvalError(Exception):
    pass


class LuaFunc:
    def __init__(self, fn, name):
        self.fn, self.name = fn, name

    def __call__(self, *args):
        try:
            return self.fn(*args)
        except EvalError:
            raise
        except (TypeError, KeyError, ValueError) as e:
            raise EvalError(f"{self.name}: {e}") from e


def truthy(v):
    return v is not None and v is not False


def tostr(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        if isinstance(v, float) and v.is_integer() and abs(v) < 1e15:
            return str(int(v))
        return format(v, ".14g")
    if isinstance(v, str):
        return v
    raise EvalError(f"cannot convert {v!r} to string")


def num(v):
    if isinstance(v, bool) or not isinstance(v, (int, float)):
        if isinstance(v, str):
            try:
                return float(v) if "." in v else int(v)
            except ValueError:
                pass
        raise EvalError(f"arithmetic on {v!r}")
    return v


def index(obj, key):
    if obj is None:
        raise EvalError(f"attempt to index nil with {key!r}")
    if isinstance(obj, dict):
        return obj.get(key)
    raise EvalError(f"attempt to index {type(obj).__name__}")


class Evaluator:
    def __init__(self, src, env):
        self.toks = list(tokenize(src))
        self.i = 0
        self.env = env
        self.names_used = set()

    def peek(self, k=0):
        j = self.i + k
        return self.toks[j] if j < len(self.toks) else None

    def pv(self, k=0):
        t = self.peek(k)
        return t.value if t else None

    def take(self):
        t = self.peek()
        if t is None:
            raise EvalError("unexpected end of expression")
        self.i += 1
        return t

    def expect(self, v):
        t = self.take()
        if t.value != v:
            raise EvalError(f"expected {v!r}, got {t.value!r}")

    def run(self):
        v = self.expr()
        if self.peek() is not None:
            raise EvalError(f"trailing tokens at {self.pv()!r}")
        return v

    # Precedence climbing, following the Lua 5.1 manual.
    def expr(self):
        return self.or_()

    def or_(self):
        v = self.and_()
        while self.pv() == "or":
            self.take()
            rhs_start = self.i
            if truthy(v):
                self.skip(self.and_)
            else:
                self.i = rhs_start
                v = self.and_()
        return v

    def and_(self):
        v = self.cmp()
        while self.pv() == "and":
            self.take()
            if truthy(v):
                v = self.cmp()
            else:
                self.skip(self.cmp)
        return v

    def skip(self, rule):
        """Parse a sub-expression without evaluating it (short-circuit)."""
        saved = self.env
        self.env = _Skipping()
        try:
            rule()
        finally:
            self.env = saved

    def cmp(self):
        v = self.concat()
        while self.pv() in ("==", "~=", "<", ">", "<=", ">="):
            op = self.take().value
            r = self.concat()
            if isinstance(self.env, _Skipping):
                continue
            if op == "==":
                v = v == r
            elif op == "~=":
                v = v != r
            else:
                a, b = num(v), num(r)
                v = {"<": a < b, ">": a > b, "<=": a <= b, ">=": a >= b}[op]
        return v

    def concat(self):
        v = self.add()
        if self.pv() == "..":
            self.take()
            r = self.concat()  # right associative
            if isinstance(self.env, _Skipping):
                return None
            return tostr(v) + tostr(r)
        return v

    def add(self):
        v = self.mul()
        while self.pv() in ("+", "-"):
            op = self.take().value
            r = self.mul()
            if isinstance(self.env, _Skipping):
                continue
            v = num(v) + num(r) if op == "+" else num(v) - num(r)
        return v

    def mul(self):
        v = self.unary()
        while self.pv() in ("*", "/", "%"):
            op = self.take().value
            r = self.unary()
            if isinstance(self.env, _Skipping):
                continue
            a, b = num(v), num(r)
            if op == "*":
                v = a * b
            elif op == "/":
                v = a / b
            else:
                v = a - math.floor(a / b) * b
        return v

    def unary(self):
        t = self.pv()
        if t == "-":
            self.take()
            v = self.unary()
            return None if isinstance(self.env, _Skipping) else -num(v)
        if t == "not":
            self.take()
            v = self.unary()
            return not truthy(v)
        if t == "#":
            self.take()
            v = self.unary()
            if isinstance(self.env, _Skipping):
                return None
            if isinstance(v, str):
                return len(v)
            if isinstance(v, dict):
                n = 0
                while (n + 1) in v:
                    n += 1
                return n
            raise EvalError("length of non-table")
        return self.pow()

    def pow(self):
        v = self.postfix()
        if self.pv() == "^":
            self.take()
            r = self.unary()
            return None if isinstance(self.env, _Skipping) else num(v) ** num(r)
        return v

    def postfix(self):
        skipping = isinstance(self.env, _Skipping)
        t = self.take()
        path = None
        if t.kind in ("num", "str"):
            v = t.value
        elif t.value in ("true", "false", "nil"):
            v = {"true": True, "false": False, "nil": None}[t.value]
        elif t.value == "(":
            v = self.expr()
            self.expect(")")
        elif t.value == "{":
            self.i -= 1
            v = self.table()
        elif t.kind == "name":
            path = t.value
            v = None if skipping else self.env.get(t.value, _MISSING)
            if v is _MISSING:
                raise EvalError(f"unknown name {t.value!r}")
        else:
            raise EvalError(f"unexpected token {t.value!r}")
        while True:
            p = self.pv()
            if p == "." and self.peek(1) and self.peek(1).kind == "name":
                self.take()
                key = self.take().value
                if path is not None:
                    path += "." + key
                v = None if skipping else index(v, key)
            elif p == "[":
                self.take()
                key = self.expr()
                self.expect("]")
                v = None if skipping else index(v, key)
            elif p == "(" or p == "{" or (self.peek() and self.peek().kind == "str"):
                path = None  # a call result is not a plain field path
                args = self.call_args()
                if skipping:
                    v = None
                elif isinstance(v, LuaFunc):
                    v = v(*args)
                else:
                    raise EvalError("call of a non-whitelisted function")
            else:
                break
        if path is not None and not skipping:
            self.names_used.add(path)
        return v

    def call_args(self):
        if self.pv() == "{":
            return [self.table()]
        if self.peek().kind == "str":
            return [self.take().value]
        self.expect("(")
        args = []
        while self.pv() != ")":
            args.append(self.expr())
            if self.pv() == ",":
                self.take()
        self.expect(")")
        return args

    def table(self):
        self.expect("{")
        out, idx = {}, 1
        while self.pv() != "}":
            if self.peek().kind == "name" and self.pv(1) == "=":
                key = self.take().value
                self.take()
                out[key] = self.expr()
            elif self.pv() == "[":
                self.take()
                key = self.expr()
                self.expect("]")
                self.expect("=")
                out[key] = self.expr()
            else:
                out[idx] = self.expr()
                idx += 1
            if self.pv() in (",", ";"):
                self.take()
        self.expect("}")
        return out


class _Skipping(dict):
    """Environment used while skipping a short-circuited operand."""


_MISSING = object()


def evaluate(src, env):
    """Evaluate `src` in `env`. Returns (value, set of dotted names read)."""
    ev = Evaluator(src, env)
    value = ev.run()
    return value, ev.names_used
