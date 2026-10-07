#!/usr/bin/env python3
"""Extract every vanilla joker from the Balatro source into plannig/design/jokers.csv.

Usage:
    python3 tools/extract_vanilla_jokers.py [--src PATH] [--out CSV] [--report MD]

--src is the unpacked game folder (containing game.lua) or the Balatro.love zip.
Default: ~/Documents/Code/Personal/balatro-vanilla-src/Balatro.love

Everything comes from the source, nothing is typed in by hand:
  * game.lua       P_CENTERS entries whose key starts with j_ (key, name, rarity,
                   cost, config, compat flags, order); base probabilities
  * card.lua       Card:set_ability (how config becomes card.ability) and
                   Card:generate_UIBox_ability_table (loc_vars that fill #n#)
  * localization/en-us.lua   descriptions.Joker text, misc tables used by localize()
  * functions/UI_definitions.lua  rarity number -> label mapping

Vanilla columns are machine-owned and rewritten on every run. Design columns are
kept from the existing CSV (matched by vanilla_key), so re-running is always safe.
"""

import argparse
import csv
import io
import json
import math
import os
import re
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lua_literal import Expr, Parser, find_matching_brace, parse_table_at  # noqa: E402
from lua_eval import EvalError, LuaFunc, evaluate, num, tostr  # noqa: E402

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_SRC = os.path.expanduser("~/Documents/Code/Personal/balatro-vanilla-src/Balatro.love")
DEFAULT_OUT = os.path.join(REPO, "plannig", "design", "jokers.csv")
DEFAULT_REPORT = os.path.join(REPO, "plannig", "design", "vanilla_extract_report.md")

MACHINE_COLUMNS = [
    "vanilla_order", "vanilla_key", "vanilla_name", "vanilla_rarity", "vanilla_cost",
    "vanilla_effect", "vanilla_config",
    "vanilla_blueprint_compat", "vanilla_eternal_compat", "vanilla_perishable_compat",
    "vanilla_effect_raw", "vanilla_loc_vars",
]
COLUMNS = [
    "vanilla_order", "vanilla_key", "vanilla_name", "vanilla_rarity", "vanilla_cost",
    "archetype", "vanilla_effect", "vanilla_config",
    "vanilla_blueprint_compat", "vanilla_eternal_compat", "vanilla_perishable_compat",
    "upgradable", "pattern", "plus_key", "plus_name", "plus_effect", "plus_config",
    "plus_rarity", "plus_cost", "state_transfer",
    "blueprint_compat", "eternal_compat", "perishable_compat",
    "impl_notes", "acceptance_tests", "status", "art_status",
    "vanilla_effect_raw", "vanilla_loc_vars",
]
DESIGN_DEFAULTS = {"status": "draft", "art_status": "none"}
UNRESOLVED = "<?>"


# --- source access ----------------------------------------------------------

class Source:
    def __init__(self, path):
        self.path = path
        self.zip = zipfile.ZipFile(path) if os.path.isfile(path) else None

    def read(self, rel):
        if self.zip:
            return self.zip.read(rel).decode("utf-8")
        with open(os.path.join(self.path, rel), encoding="utf-8") as f:
            return f.read()


def function_body(src, header):
    """Return the source text of a top-level Lua function, from its header to
    the next top-level `function` (good enough for card.lua's layout)."""
    start = src.index(header)
    nxt = re.compile(r"^function ", re.M).search(src, start + len(header))
    return src[start: nxt.start() if nxt else len(src)]


def jsonable(v):
    if isinstance(v, Expr):
        return {"__lua": v.src}
    if isinstance(v, dict):
        return {str(k): jsonable(x) for k, x in v.items()}
    if isinstance(v, float) and v.is_integer():
        return v  # keep 1.0 as written in source
    return v


def lua_bool(v):
    return "true" if v is True else "false" if v is False else ("" if v is None else str(v))


# --- localize() and the runtime environment ---------------------------------

def make_localize(loc):
    misc, desc = loc["misc"], loc["descriptions"]

    def localize(args, misc_cat=None):
        # Mirrors functions/misc_functions.lua localize() for the cases jokers use.
        if not isinstance(args, dict):
            if misc_cat is not None and misc_cat in misc:
                return misc[misc_cat].get(args, "ERROR")
            return misc["dictionary"].get(args, "ERROR")
        if args.get("type") == "variable":
            text = misc["v_dictionary"].get(args.get("key"))
            if text is None:
                return "ERROR"
            vars_ = args.get("vars") or {}
            return re.sub(r"#(\d+)#", lambda m: tostr(vars_.get(int(m.group(1)), "ERROR")), text)
        if args.get("type") == "name_text":
            return desc[args["set"]][args["key"]]["name"]
        raise EvalError(f"localize type {args.get('type')!r} not supported")

    return LuaFunc(localize, "localize")


def lua_math():
    return {"max": LuaFunc(lambda *a: max(num(x) for x in a), "math.max"),
            "min": LuaFunc(lambda *a: min(num(x) for x in a), "math.min"),
            "floor": LuaFunc(lambda x: math.floor(num(x)), "math.floor")}


# --- card.ability simulation (Card:set_ability) -------------------------------

def build_ability_model(card_src):
    body = function_body(card_src, "function Card:set_ability(")
    m = re.search(r"self\.ability\s*=\s*\{", body)
    end = find_matching_brace(body, m.end() - 1)
    base_fields = Parser(body[m.end() - 1: end + 1]).table()
    # Per-name initialisation blocks:  if self.ability.name == 'X' then ... end
    inits = []
    for bm in re.finditer(r"if self\.ability\.name == (['\"])([^'\"\n]+)\1 then\s*\n(.*?)\n    end", body, re.S):
        stmts = re.findall(r"self\.ability\.(\w+)\s*=(?!=)\s*([^\n]+)", bm.group(3))
        inits.append((bm.group(2), stmts))
    return base_fields, inits


def make_ability(center, model, env_base):
    base_fields, inits = model
    ability, notes = {}, []
    env = dict(env_base, center=center, self={"ability": None}, copy_table=LuaFunc(lambda t: t, "copy_table"))
    for k, v in base_fields.items():
        if isinstance(v, Expr):
            try:
                ability[k], _ = evaluate(v.src, env)
            except EvalError as e:
                notes.append(f"set_ability field {k}: {e}")
        else:
            ability[k] = v
    env = dict(env_base, self={"ability": ability})
    for name, stmts in inits:
        if name != center["name"]:
            continue
        for field, expr in stmts:
            expr = re.sub(r"\s+end$", "", expr.strip())  # one-line `if ... then x = y end`
            try:
                ability[field], _ = evaluate(expr, env)
            except EvalError:
                note = f"`ability.{field}` is set at runtime ({expr})"
                if not any(n.startswith(f"`ability.{field}`") for n in notes):
                    notes.append(note)
    return ability, notes


# --- loc_vars branches (Card:generate_UIBox_ability_table) ---------------------

def build_loc_var_branches(card_src):
    body = function_body(card_src, "function Card:generate_UIBox_ability_table(")
    start = body.index("elseif self.ability.set == 'Joker' then")
    end = body.index("local badges = {}", start)
    region = body[start:end]
    heads = list(re.finditer(r"(?:if|elseif)\s+((?:\(?\s*self\.ability\.name\s*==\s*(['\"]).+?\2\s*\)?\s*(?:or\s+)?)+)\s*then", region, re.S))
    branches = {}
    for i, h in enumerate(heads):
        names = [n for _, n in re.findall(r"self\.ability\.name\s*==\s*(['\"])(.+?)\1", h.group(1))]
        seg = region[h.end(): heads[i + 1].start() if i + 1 < len(heads) else len(region)]
        lm = re.search(r"\bloc_vars\s*=\s*\{", seg)
        exprs = None
        if lm:
            close = find_matching_brace(seg, lm.end() - 1)
            exprs = Parser(seg[lm.end() - 1: close + 1]).table()
        info = {
            "exprs": exprs,
            "main_start": bool(re.search(r"\bmain_start\s*=", seg)),
            "main_end": bool(re.search(r"\bmain_end\s*=", seg)),
            "locals": bool(re.search(r"\blocal\s+\w+", seg)),
        }
        for n in names:
            branches[n] = info
    return branches


def resolve_loc_vars(exprs, env):
    """Return a list of dicts {n, expr, value, kind}; kind is static, runtime or unresolved."""
    out = []
    if not exprs:
        return out
    n = 1
    while n in exprs:
        e = exprs[n]
        src = e.src if isinstance(e, Expr) else json.dumps(e)
        item = {"n": n, "expr": src}
        try:
            value, used = evaluate(src, env) if isinstance(e, Expr) else (e, set())
            if value is None or isinstance(value, dict):
                raise EvalError("no value")
            if value == "ERROR":
                raise EvalError("localize() returned ERROR (key only exists during a run)")
            item["value"] = tostr(value)
            dynamic = [u for u in used if u.startswith("G.") and u not in ("G.GAME", "G.GAME.probabilities.normal")]
            dynamic += [u for u in used if u.startswith("self.ability.") and u.split(".")[2] not in env["_base_fields"]]
            item["kind"] = "runtime" if dynamic else "static"
            if dynamic:
                item["note"] = "value shown is the default outside a run"
        except EvalError as err:
            item["value"] = UNRESOLVED
            item["kind"] = "unresolved"
            item["note"] = str(err)
        out.append(item)
        n += 1
    return out


def render_text(lines, vars_by_n):
    text = " ".join(lines)
    text = re.sub(r"#(\d+)#", lambda m: vars_by_n.get(int(m.group(1)), UNRESOLVED), text)
    text = re.sub(r"\{[^{}]*\}", "", text)
    return re.sub(r"\s+", " ", text).strip()


# --- main ------------------------------------------------------------------------

def extract(src_path):
    src = Source(src_path)
    game = src.read("game.lua")
    card = src.read("card.lua")
    loc_src = src.read("localization/en-us.lua")
    ui = src.read("functions/UI_definitions.lua")
    try:
        version = src.read("version.jkr").split()[0]
    except (OSError, KeyError):
        version = "unknown"

    centers = parse_table_at(game, r"self\.P_CENTERS\s*=\s*\{")
    probabilities = parse_table_at(game, r"probabilities\s*=\s*\{")
    loc = parse_table_at(loc_src, r"return\s*\{")
    rm = re.search(r"\(\{(localize\('k_\w+'\)(?:,\s*localize\('k_\w+'\))*)\}\)\[card\.config\.center\.rarity\]", ui)
    rarity_keys = re.findall(r"localize\('(k_\w+)'\)", rm.group(1))
    rarity_names = {i + 1: loc["misc"]["dictionary"][k] for i, k in enumerate(rarity_keys)}

    model = build_ability_model(card)
    branches = build_loc_var_branches(card)
    env_base = {
        "G": {"GAME": {"probabilities": probabilities}},
        "localize": make_localize(loc),
        "math": lua_math(),
        "tostring": LuaFunc(tostr, "tostring"),
    }

    jokers = sorted(((k, v) for k, v in centers.items() if isinstance(k, str) and k.startswith("j_")),
                    key=lambda kv: kv[1]["order"])
    rows, findings = [], []
    for key, c in jokers:
        ability, notes = make_ability(c, model, env_base)
        # Fields in Card:set_ability's base table are known at creation; anything
        # else (tallies, per-name fields) only exists or changes during a run.
        base_keys = set(model[0].keys())
        loc_entry = loc["descriptions"]["Joker"].get(key)
        raw_lines = [loc_entry["text"][i] for i in sorted(k for k in loc_entry["text"] if isinstance(k, int))] if loc_entry else []
        branch = branches.get(c["name"])
        env = dict(env_base, self={"ability": ability}, _base_fields=base_keys)
        resolved = resolve_loc_vars(branch["exprs"] if branch else None, env)
        vars_by_n = {r["n"]: r["value"] for r in resolved}
        placeholders = sorted({int(n) for n in re.findall(r"#(\d+)#", " ".join(raw_lines))})
        problems = []
        if not loc_entry:
            problems.append("no localization entry")
        if branch is None:
            problems.append("no loc_vars branch in card.lua")
        missing = [n for n in placeholders if n not in vars_by_n]
        if missing:
            problems.append(f"text uses #{', #'.join(map(str, missing))}# but loc_vars has no value")
        if branch and branch["main_start"]:
            problems.append("description is built as custom UI in card.lua (main_start); localization text is empty or partial")
        if branch and branch["main_end"]:
            problems.append("info only: card shows a status badge (main_end), not part of the effect text")
        for r in resolved:
            if r["kind"] != "static" and r["n"] in placeholders:
                problems.append(f"#{r['n']}# {r['kind']}: {r['expr']}" + (f" ({r['note']})" if r.get("note") else ""))
        problems += notes
        if problems:
            findings.append((key, c["name"], problems))

        rows.append({
            "vanilla_order": c["order"],
            "vanilla_key": key,
            "vanilla_name": loc_entry["name"] if loc_entry else c["name"],
            "vanilla_rarity": rarity_names.get(c["rarity"], c["rarity"]),
            "vanilla_cost": c["cost"],
            "vanilla_effect": render_text(raw_lines, vars_by_n) or "<custom UI: built in card.lua, see report>",
            "vanilla_config": json.dumps(jsonable(c.get("config", {})), ensure_ascii=False),
            "vanilla_blueprint_compat": lua_bool(c.get("blueprint_compat")),
            "vanilla_eternal_compat": lua_bool(c.get("eternal_compat")),
            "vanilla_perishable_compat": lua_bool(c.get("perishable_compat")),
            "vanilla_effect_raw": json.dumps(raw_lines, ensure_ascii=False),
            "vanilla_loc_vars": json.dumps([{k: r[k] for k in ("n", "expr", "value", "kind")} for r in resolved], ensure_ascii=False),
        })
    return version, rows, findings


def merge(rows, out_path):
    old = {}
    if os.path.exists(out_path):
        with open(out_path, newline="", encoding="utf-8") as f:
            for r in csv.DictReader(f):
                old[r["vanilla_key"]] = r
    merged = []
    for r in rows:
        prev = old.pop(r["vanilla_key"], {})
        row = {}
        for col in COLUMNS:
            if col in MACHINE_COLUMNS:
                row[col] = r[col]
            else:
                row[col] = prev.get(col) or DESIGN_DEFAULTS.get(col, "")
        merged.append(row)
    return merged, sorted(old)


def write_report(path, version, src_path, rows, findings, dropped):
    rel = os.path.relpath
    lines = [
        "# Vanilla extraction report",
        "",
        "Generated by `tools/extract_vanilla_jokers.py`. Do not edit by hand; re-run the script.",
        "",
        f"- Game version: `{version}`",
        f"- Jokers extracted: **{len(rows)}**",
        "- Rarity counts: " + ", ".join(f"{k} {sum(1 for r in rows if r['vanilla_rarity'] == k)}" for k in ("Common", "Uncommon", "Rare", "Legendary")),
        "",
        "## Placeholders",
        "",
        "`vanilla_effect` replaces `#n#` with the value at card creation.",
        "- **runtime**: the value depends on run state. The text shows what the game shows outside a run, e.g. `Currently +0`.",
        f"- **unresolved**: no value could be computed from the source. The text shows `{UNRESOLVED}`.",
        "",
        "## Jokers that need attention",
        "",
    ]
    if not findings:
        lines.append("None.")
    for key, name, problems in findings:
        lines.append(f"- **{name}** (`{key}`)")
        lines += [f"  - {p}" for p in problems]
    if dropped:
        lines += ["", "## Rows in the old CSV that no longer exist in the source", ""]
        lines += [f"- `{k}`" for k in dropped]
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[1])
    ap.add_argument("--src", default=DEFAULT_SRC)
    ap.add_argument("--out", default=DEFAULT_OUT)
    ap.add_argument("--report", default=DEFAULT_REPORT)
    a = ap.parse_args()

    version, rows, findings = extract(a.src)
    merged, dropped = merge(rows, a.out)
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    buf = io.StringIO()
    w = csv.DictWriter(buf, fieldnames=COLUMNS, lineterminator="\n")
    w.writeheader()
    w.writerows(merged)
    with open(a.out, "w", newline="", encoding="utf-8") as f:
        f.write(buf.getvalue())
    write_report(a.report, version, a.src, rows, findings, dropped)
    print(f"Balatro {version}: {len(rows)} jokers -> {a.out}")
    print(f"{len(findings)} jokers flagged -> {a.report}")
    if dropped:
        print(f"WARNING: {len(dropped)} old rows not in source: {', '.join(dropped)}")


if __name__ == "__main__":
    main()
