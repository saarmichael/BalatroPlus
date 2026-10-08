# Decisions log (build of the "+" jokers and mechanics, started 2026-10-07)

## Update (orchestrator, 2026-10-08, second pass) — read this first

- **JokerDisplay support** for all 141 "+" jokers + Carpenter + Apprentice (D18, D20, D21), tested.
- **"+" art**: vanilla sprite + a visible "+" shader overlay with a corner emblem (D19); screenshots in
  docs/screenshots/ (plus_art_v2.png, shop, collection).
- **Redesigns by the human**: Carpenter is a sell effect on the last sold joker (D22); Architect / Hive Mind copy the
  upgraded ability of their target, falling back to the regular ability (D23 + amendment). D24 lists the knock-on
  effects (The Rust no longer interacts with Carpenter).
- **Copy-joker coverage**: vanilla Blueprint/Brainstorm over every "+" joker (copy/blueprint_sweep, combos), and the
  new Architect/Hive Mind rule over every joker plus lineups/cycles/chains (copy/plus_copy_*).
- **Fixed**: a crash when a run is deleted with cards selected (real games too), JokerDisplay under The Rust, and
  the rest of plannig/BUGS.md (Open: none).
- **Final full suite: 1472 passed, 0 failed, 0 errors.** `./dev.sh check` clean.
- **Try it**: switch to an empty profile slot, close the game, `./dev.sh scenario showcase`.
- **Watch out**: Architect's JokerDisplay overrides `JokerDisplay.calculate_blueprint_copy` from its joker file; a
  JokerDisplay update could break that display. Still not done: real art, "one version per joker", balance playtest.

## Summary (orchestrator, 2026-10-08) — read this first

**Built** on `build/plus-jokers` (not merged; not pushed):
- All **141 "+" jokers** (every `upgradable = yes` row), one commit per joker, each with in-game tests.
  CSV status `tested` for all 141; specs regenerated. The 9 `upgradable = no` jokers have no "+" version.
- All **10 mechanics** M1-M10 with tickets in `plannig/specs/mechanics/`, code in `mod/src/mechanics/`, tests in
  `mod/dev/tests/mechanics/`: Carpenter, Apprentice, Wheel of Fortune change, Apotheosis, Salesman (= Showman+),
  Craftsmanship/Masterwork, Masterwork Tag, Workshop Pack, Veteran Deck, The Rust. Numbers in `balance.lua`.
- **Final full suite: 705 passed, 0 failed, 0 errors.** `./dev.sh check` clean.

**Shared-code changes during the build:** `BPlus.upgrade_card(card, { fresh = true })` for shop/pack upgrades (MC);
`behavior.lua` now runs deferred events and `Card:update` under a behaviour swap (BUG-1, BUG-6) — vanilla code that
reads `self.ability` later or per frame works when Carpenter/The Rust switch a joker.

**For your review:** decisions D8-D17 below (mechanics details, accepted deviations from tickets), questions
Q-B9-1 and Q-B5-1 (both answered), and `plannig/BUGS.md` (all fixed except two cosmetic commit-message issues,
won't fix).

**Left / set aside:** JokerDisplay support (separate pass); "one version per joker" enforcement (brief: later);
placeholder art everywhere; no real playthrough / balance testing yet (tests are scripted scenarios). Commit
messages of 7 B3 jokers say "ASS" for "PASS" and B2/B4 commits lack PASS lines (BUG-2/3, no history rewrite).

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

**D16. Accepted deviations from tickets (B6, reviewed by orchestrator).**
- Buccaneer (Swashbuckler+): computes the sell-value sum live in `calculate`/`loc_vars` instead of storing
  `extra.mult` every frame; `mult = 0` dropped from config. Same behaviour, no stored state.
- Never Misprint: seed `bplus_misprint` instead of the ticket's `bplus_never_misprint` (orchestrator's batch
  hint said `bplus_<name>`). Harmless; plain text "+10 to +50 Mult".
- El Santo (Luchador+): `selling_self` not guarded by `not context.blueprint` (vanilla isn't either; setting the
  flag is idempotent). Selling while the current Boss is already disabled arms the flag for the next Boss.
- Lich (Mr. Bones+): the "saved" test loses at 40% of required chips instead of 30% (exact 30% isn't reachable
  with a natural hand); the 20% test still checks the game-over side of the 25% line.
- Tonkotsu (Ramen+): destroy check uses a 1e-9 float tolerance.

**D17. B10 judgment calls (accepted by orchestrator).**
- Architect / Hive Mind show one compat badge: "compatible" if at least one of the two targets can be copied.
- Chicot+: its 25% chip cut applies at `setting_blind`; a Chicot+ bought mid-blind disables an active Boss (as
  vanilla) but doesn't cut that blind's chips.
- Phantom (Invisible+): with no room or no other joker it shows the vanilla message and does nothing.
- Yorick+ normalises its counter on the first discard after an upgrade/switch, as the ticket specifies.
- Follow-up requested: Architect/Hive Mind copying retrigger jokers (repetitions through SMODS.merge_effects), and a
  real Carpenter + Blueprint test.

## Orchestrator decisions (JokerDisplay + art pass, 2026-10-08)

**D18. JokerDisplay definitions live in each joker's `BPlus.Joker{}` call** as `joker_display_def = function(JokerDisplay)
return {...} end` (JokerDisplay's own API for mod objects). No separate definitions file, so batch agents only touch
their own joker files. Shared helpers (if any) go in `core.lua`. Mechanic jokers (Carpenter, Apprentice) get
definitions too.

**D19. (FLAGGED for review) "+" art = the vanilla joker's own sprite + a "+" overlay.** `BPlus.Joker` defaults the
atlas/pos (and soul_pos for legendaries) to the vanilla joker's, replacing the placeholder. The overlay is a custom
shader drawn like an edition but visibly different from Foil/Holo/Polychrome/Negative; if a shader proves
impractical, a half-transparent "+" graphic drawn on top instead. It must stack with real editions. The overlay
follows **behaviour**, like the "+" tooltip badge: a vanilla joker next to Carpenter shows it; a "+" joker under The
Rust doesn't. Carpenter/Apprentice keep placeholder art and no overlay.

**D20. (FLAGGED for review) JokerDisplay shows what the joker currently behaves as**: next to Carpenter a vanilla
joker displays its "+" numbers; under The Rust a "+" joker displays vanilla numbers. Implemented once in the shared
code (JokerDisplay's per-card update runs under the behaviour swap), not per joker.

**D21. JokerDisplay for Architect / Hive Mind shows one copy target** (the first compatible of the two),
"(incompatible)" if neither. JokerDisplay's blueprint API returns a single card; showing both would need a custom
display. Accepted (JD10).

## Redesign by the human (2026-10-08): Carpenter, Architect, Hive Mind

**D22. Carpenter (M1) is now a sell effect, decided by the human.** Supersedes D12 and the brief's M1 row.
New game state: the **last sold joker** (per run, saved in `G.GAME`), excluding Carpenter itself. Selling Carpenter
adds the "+" version of the last sold joker to the jokers area. Details (human, 2026-10-08):
- If the last sold joker is already a "+" joker, Carpenter gives it back as a fresh "+" joker.
- Using Carpenter **consumes** the record: a second Carpenter does nothing until another joker is sold.
- The created joker is **fresh**: starting "+" values, no edition, no stickers (like an upgraded shop joker).
- Orchestrator calls: no last sold joker, or one without a "+" version -> message, nothing happens, record kept.
  No room (e.g. Negative Carpenter, slots still full) -> message, nothing happens, record kept. Carpenter's
  tooltip and JokerDisplay show what it would create. Carpenter is no longer a behaviour provider: no "+" badge,
  no neighbour switching. Its price/rarity are unchanged (Uncommon, $8); blueprint_compat false (nothing to copy).

**D23. Architect (Blueprint+) and Hive Mind (Brainstorm+) copy the UPGRADED ability of their target, decided by
the human.** Supersedes the "copy two jokers" design (D17/D21 parts about two targets). Architect's target is the
joker to its right, Hive Mind's the leftmost joker, as in vanilla. They copy that joker's "+" ability:
- target is a "+" joker -> copy it as it is;
- target is a vanilla joker whose "+" version can be run on it (`carpenter_compat = true`, now meaning "its '+'
  ability can be run on the vanilla card") and is blueprint-compatible -> copy the "+" ability, using the target's
  stored values (e.g. vanilla Ride the Bus at +5 copied as Express Bus shows +5);
- otherwise incompatible: shrinking jokers like Popcorn (`carpenter_compat = false`), jokers whose "+" version is
  not blueprint-compatible, and jokers with no "+" version (orchestrator: including Gros Michel / Cavendish, which
  vanilla Blueprint can copy; rule = "they only ever copy '+' abilities").
Under The Rust they act as vanilla Blueprint/Brainstorm (unchanged D13 behaviour).
- **Amended by the human (2026-10-08): fall back to the base ability.** If the "+" ability can't be copied but the
  target's regular ability can (vanilla Blueprint rule), they copy the regular ability. Order: "+" target ->
  copy it; vanilla target with a copyable "+" (carpenter_compat + blueprint_compat) -> copy the "+" ability;
  else target blueprint-compatible -> copy its regular ability (Popcorn, Gros Michel, Cavendish...); else
  incompatible (only what vanilla Blueprint can't copy either). This replaces the "incompatible" bullet above.

**D24. Consequences.** The Rust no longer interacts with Carpenter (D13's Carpenter clause is void). The behaviour
"plus" view built for Carpenter is now used by Architect/Hive Mind to run a vanilla joker's "+" ability; the
per-joker "vanilla forced to '+'" tests stay valid (they test exactly that view), only their "Carpenter" wording is
outdated. D19/D20 (overlay / JokerDisplay follow behaviour) now only matter for The Rust.

## Questions from agents

(none yet)

**Q-B9-1 (ANSWERED)** j_burglar / behaviour switching (shared `mod/src/behavior.lua`): vanilla Burglar's `setting_blind` code reads `self.ability.extra` and `self.ability.name` lazily INSIDE a `G.E_MANAGER:add_event` closure (`ease_hands_played(self.ability.extra)`). `BPlus.with_center` restores the card's real `ability` as soon as `calculate_joker` returns, so when the event runs later, a Cat Burglar forced to 'base' (what The Rust does) passes its own table `{hands=5}` to `ease_hands_played` and the game crashes (`common_events.lua:161: attempt to compare table with number`, found with `T.force_behavior(1, 'base')` on `bplus_burglar_plus`). Any vanilla joker that defers reads of `self.ability` into events is affected (Burglar for sure; probably Certificate/Marble-style ones too). Cat Burglar's own code is fine (reads values into locals before the event) and the vanilla-forced-to-'plus' direction works. Options: (a) keep the view alive until the event queue drains (hard), (b) in `with_center`, wrap events added during the call so they run inside the same swap, (c) accept and have The Rust skip these. I removed the "forced to base" test for Cat Burglar so the suite doesn't crash; needs a decision for The Rust (M10) on Cat Burglar.

Answer (orchestrator): fixed generically in behavior.lua (BUG-1), commit 599356c; Cat Burglar forced-to-base test restored.

**Q-B5-1 (ANSWERED)** j_glass (Plexiglass Joker): when the "+" Glass Joker is forced to `'base'` (The Rust), the game crashes at `SMODS.scale_card` (`src/utils.lua:3375: attempt to perform arithmetic on field 'scalar' (a table value)`). Cause: vanilla Glass Joker's `remove_playing_cards` branch (card.lua ~3099) wraps `SMODS.scale_card(self, {ref_table = self.ability, ref_value='x_mult', scalar_value='extra', ...})` in `G.E_MANAGER:add_event(...)`. The event runs after `BPlus.with_center` has already swapped the card's real `ability` back, so `self.ability.extra` is the "+" joker's table `{Xmult, Xmult_mod}` instead of the vanilla number 0.75. Any vanilla joker code that touches `self.ability` inside a deferred event has the same problem under The Rust. This is in the shared `mod/src/behavior.lua` (view swap only lasts for the call), so I did not touch it. Options: (a) behavior.lua keeps the swapped view alive until the card's queued events have run (hard), (b) behavior.lua special-cases: while a view is active, also wrap `G.E_MANAGER:add_event` so events created during the call re-enter the view when they run (generic fix), (c) accept: drop the "+ forced to base" test for Glass and treat it as a known limitation. Everything else for Glass is done and passes (shatter, Hanged Man, upgrade, vanilla forced to plus). Waiting on a decision.

  Answer (orchestrator): option (b). Same root cause as Q-B9-1 / BUG-1; the generic fix (events queued during a swap re-enter it) is in mod/src/behavior.lua, being verified and committed by the SF agent. Restore the Glass "forced to base" test and commit Glass once it passes.
