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

## Orchestrator decisions (mechanics, settled before the batch launch)

**D8. M3 Wheel of Fortune.** `SMODS.take_ownership('c_wheel_of_fortune', ...)`. Vanilla odds and "Nope!" unchanged
(Oops! All 6s still applies). On a success, pick among the outcomes that have a valid joker (upgrade: an eligible
joker; editions: an edition-less joker), renormalising the shares from `balance.wheel_of_fortune`, then a random
joker valid for that outcome. `can_use` is true if either kind of joker exists. The card text is updated.

**D9. M4 Apotheosis.** New Spectral, cost like Hex. `can_use` needs an eligible joker. Upgrades one random eligible
joker (`BPlus.upgrade_card`) and destroys every other non-Eternal joker.

**D10. M2 Apprentice.** Uncommon, $6, `blueprint_compat = false`, `eternal_compat = false` (like Invisible Joker).
Counts rounds at `end_of_round` (not on blueprint/repetition contexts), active at `balance.apprentice.rounds`, shows
the counter. Selling it while active upgrades a random eligible joker, never itself. With none eligible it shows a
message and does nothing. No "+" version, never eligible (Q2).

**D11. M9 Veteran Deck.** A `SMODS.Back`. Each joker counts rounds held in its own ability field
(`ability.bplus_veteran_rounds`), incremented at end of round. At `balance.veteran_deck.rounds` it gets
`BPlus.upgrade_card` if eligible (the counter is irrelevant afterwards).

**D12. M1 Carpenter.** Uncommon, $8, `blueprint_compat = false`. Behaviour provider at priority 100: the joker to
Carpenter's right behaves as 'plus' unless Carpenter is debuffed. The affected joker shows a "+" badge; Carpenter
shows Blueprint-style compatible/incompatible text. No "+" version, never eligible.

**D13. M10 The Rust.** A `SMODS.Blind` with normal boss stats, `boss.min = 2`. Behaviour provider at priority 200
(above Carpenter): every joker behaves as 'base' while The Rust is the active, non-disabled blind (Chicot/Luchador
disable it). Covers Carpenter-upgraded jokers too; `carpenter_compat = false` jokers are untouched (already enforced
by `behavior_target`). Tested with Ride the Bus (growing) and Ice Cream (shrinking; rerun once B6 lands).

**D14. M5-M8 shop/pack upgrades.** One shared helper, "maybe upgrade a freshly created shop/pack joker", living in
the MC mechanics files. Shop rate = Salesman `salesman.upgrade_rate` + Craftsmanship `craftsmanship.upgrade_rate`
(Masterwork replaces it with `masterwork.upgrade_rate`); 0 without any of them. Workshop Pack rolls 1 in
`workshop_pack.odds` per joker via the smods probability helpers. An upgraded shop/pack joker is a FRESH "+" card
with its starting values (no state transfer); MC may add an `opts.fresh` option to `BPlus.upgrade_card` (allowed
shared-file edit). Price stays the base price. M7 Masterwork Tag works like Foil Tag (next eligible shop joker
appears upgraded). M8 has Buffoon-pack sizes, prices and weights. Placeholder art (PIL-generated if needed).
M5 Salesman is the `j_ring_master` "+" row (`j_bplus_ring_master_plus`).

**D15. Not built now:** "one version per joker" enforcement (brief: later) and JokerDisplay support (separate pass).

## Questions from agents

(none yet)
