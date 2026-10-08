# Bug list (build of the "+" jokers and mechanics)

Triage rule (from the human, 2026-10-08): a bug that **blocks** other tests or agents (crashes shared runs, breaks
a shared file, stops a batch) is fixed immediately. Everything else is written here and fixed + tested together in
one pass after the batches finish.

Columns: id, found by, blocking?, status, description.

## Open (fix in the end pass)

(none)

## Won't fix

- **BUG-2** (orchestrator, cosmetic) The last 7 B3 commits (ancient, rough_gem, bloodstone, arrowhead,
  onyx_agate, flower_pot, seeing_double) say "ASS" instead of "PASS". Won't fix (orchestrator): no history rewrite.
- **BUG-3** (orchestrator, cosmetic) B2 and B4 commit messages carry test names / counts instead of the PASS
  lines. Won't fix (orchestrator): no history rewrite; the end-pass full suite is the evidence.

## Fixed

- **BUG-EP2-2** (end pass) Hive Mind Galaxy/Constellation test failed with "cannot use c_venus right now". Obsolete: the Architect / Hive Mind rebuild (D23) replaced the test; `jokers/j_brainstorm` now passes (39 passed).
- **BUG-1 / Q-B9-1** (B9) `BPlus.with_center` restored the card's own `ability` before deferred events ran, so
  vanilla code reading `self.ability` inside `G.E_MANAGER:add_event` saw the wrong shape (Cat Burglar under The
  Rust crashed). Fixed in 599356c: events queued during a swap run under the same swap.
- **BUG-4** Hive Mind test name said Carpenter was right of Brainstorm; renamed to "left". Fixed in cc3b2e7.
- **BUG-5** (B4, unverified) `./dev.sh check` warning in `j_bplus_swashbuckler_plus.lua`: not reproducible, check
  is clean (end pass).
- **BUG-6 / BUG-B5-1 / BUG-MC-2** Vanilla values computed in `Card:update` by joker name (Throwback x_mult, Stencil,
  Swashbuckler mult, ...) were not computed for a "+" card forced to 'base'. Fixed in f1866f1: `update` added to the
  `wrap(...)` list in `mod/src/behavior.lua`; Buccaneer's own Card.update hook removed (redundant). Throwback
  "forced to base" test restored, Joker Mold forced-to-base test added.
- **BUG-7** M9 Ice Cream test name now says 100 -> 95 Chips. Fixed in eb5c8e5.
- **BUG-MC-1** framework "skip blind grants a tag" now forces a non-immediate tag (tag_d_six). Fixed in 3579c0f.
- **BUG-JD-5 / BUG-JD-2** (HIGH, crash) Starting a new run while cards were highlighted in hand crashed in `delete_run`
  (removing a highlighted card runs `parse_highlighted` -> `update_hand_text`, whose event touches the already torn-down
  hand-text UI; Handy runs such events immediately). Also reachable in a real game (back to menu with cards selected).
  Fixed in 60ad02a: `Game:delete_run` hook in mod/src/behavior.lua clears the selection first; regression test
  `core/run_teardown.lua` (fails without the fix). No 0.0s errors in the JokerDisplay run afterwards.
- **BUG-JD-1 / JD-3 / JD-8 / JD-11** `T.highlight` action added (60ad02a, documented in docs/testing.md); every test
  converted (b089895); Triboulet+ selected-Jack case added; Chase Card / Toreador test names now say "(Active!)".
- **BUG-JD-7 (retrigger part) / BUG-JD9-1** Fixed in 717a26c: JokerDisplay's `calculate_card_triggers`,
  `calculate_joker_modifiers` and `calculate_joker_triggers` run under each joker's behaviour swap; tests for Hanging
  Chad and Hack. The get_blueprint_joker part is dropped (Architect/Carpenter are being redesigned by the human).
- **BUG-JD7-1** Membership Card forced to base: `with_center` derives vanilla `loyalty_remaining`. Fixed in ddd3b72;
  the "(3 remaining)" reminder check is restored.
- **BUG-JD-4** El Santo JokerDisplay "(Active!)" whenever selling disables a Boss (current, or next if the flag isn't
  set). Fixed in e31f2c9.
- **BUG-ART-1** Shop and collection views checked in the real game (screenshots in docs/screenshots/: plus_art_shop.png,
  plus_art_collection.png): overlay, Wee/Half sizes and the legendary soul layer look right, nothing to fix.
  The overlay was also made much more visible on request (fb5fe7c, docs/screenshots/plus_art_v2.png).
- **BUG-ART-2 / BUG-JD-6** `./dev.sh check` is clean (1d2eaf9).
- **BUG-JD-10** Flower Garden "Suits" via `BPlus.dict` (8ec3f33).
- **BUG-JD-9** `./dev.sh test JokerDisplay`: 145 passed after the fixes above (the earlier FAILs were from batches still
  being written; the highlight leak caused the rest).
- **BUG-EP2-1** (end pass, found by the first full-suite run) `T.cash_out` right after a win could remove the round-eval UI
  while the earnings rows were still being added by non-blocking events: the game crashed (`round_eval` nil at
  common_events.lua:1197) and the suite hung. Fixed: `T.cash_out` waits for the real Cash Out button first
  (framework tests: 11 passed).
- **BUG-RA-1** (RA batch) `T.cash_out()` timed out at ROUND_EVAL. Fixed by the toolkit change in c5bb01c; `copy/plus_copy_sweep.lua` now cashes out and leaves the shop again (282 passed).
- **BUG-EP2-3** (end pass, full suite) Veteran Deck Ride the Bus / Ice Cream tests assumed a 1-card hand scores in the
  third blind, but the seeded boss of that run is now The Psychic (score 0). Fixed by forcing `boss = 'club'` in both tests.
