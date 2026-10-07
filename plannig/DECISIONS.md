# Decisions log (build of the "+" jokers and mechanics, started 2026-10-07)

Questions that came up during implementation and the answer used. The orchestrator (Claude) answered them while
the human was away; **review these**. Format: question, answer, who asked, files affected.

## Orchestrator decisions (foundation)

**D1. No `upgrade_map.lua` file.** The map is built at load time from `BPlus.Joker{...}` calls.
Why: ~14 agents adding lines to one file in parallel would race. Behaviour is the same: `BPlus.upgrade_map`
(vanilla -> plus) and `BPlus.base_map` (plus -> vanilla). CONVENTIONS.md section 6 updated.

**D2. "+" jokers never spawn on their own** (`in_pool` returns false, set by `BPlus.Joker`). They only reach a run
through the upgrade mechanics. Why: the brief's mechanics (M5-M8) all upgrade a vanilla joker the shop/pack already
rolled; a "+" joker rolled directly would bypass every upgrade rate.

**D3. `base_calculate` / `plus_calculate` are generic, not per-joker.** `mod/src/behavior.lua` swaps the card's
`ability`/`center` for the other version's shape for the duration of a call, so vanilla code (for The Rust) and
"+" code (for Carpenter) run unchanged on the real card. `state_transfer` paths are synced both ways, so growing
jokers keep their value and only the rate changes. Joker files contain no Carpenter/Rust code; their obligation is
a complete `state_transfer`. Tests use `T.force_behavior` to exercise both directions without Carpenter/Rust.

**D4. Behaviour switching re-applies deck effects.** When a joker starts/stops behaving as its other version, its
`remove_from_deck` runs under the old behaviour and `add_to_deck` under the new (as on a debuff: no "card added"
events). Example: Juggler next to Carpenter gives +2 hand size, back to +1 when Carpenter leaves.

**D5. Test determinism fixes in the dev toolkit.** Scenario jokers get no random edition unless one is given, and
scenario `stickers` are forced (vanilla stickers were silently not applied before).

**D6. `dev.new_run` refuses to run on a player profile** unless called with `{ allow_player_profile = true }`
(`./dev.sh scenario`, the DebugPlus console and the `n` keybind pass it). See incident below.

**D7. Git.** Work is on branch `build/plus-jokers`, one commit per joker via `tools/commit.sh` (commits only the
given paths). CSV `status` columns are updated by the orchestrator in batches, not by each agent.

## Incident

- 2026-10-07 23:13: while debugging, the orchestrator ran `dev.new_run` on **profile 2** (the profile active after
  a test run restored it), which overwrote `profile 2/save.jkr`. If a run was in progress there, it is lost
  (no Time Machine backup was reachable). D6 makes this impossible now.

## Questions from agents

(none yet)
