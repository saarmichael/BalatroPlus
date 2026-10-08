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
- **BUG-ART-1** (orchestrator, not blocking, open) Art pass only checked the in-run joker area visually; the
  collection and shop views (overlay + Wee/Half/Photograph/Square sizes + legendary soul layer) are unverified.
- **BUG-ART-2** (orchestrator, not blocking, open) ART reported `./dev.sh check` warnings in
  `mod/src/behavior.lua` and `mod/src/dev/test/actions.lua` (JokerDisplay globals from JD0); recheck in the end pass.
- **BUG-JD-1** (JD1, not blocking, open) JokerDisplay tests select cards with `G.hand:add_to_highlighted` directly
  (no `T.*` action for highlighting). Breaks the "only T actions" rule. End pass: add a `T.highlight(...)` action to
  the dev toolkit and convert every JokerDisplay test that highlights directly (grep `add_to_highlighted` in
  mod/dev/tests).
- **BUG-JD-2** (JD1, not blocking, open) Existing gameplay tests sometimes ERROR at 0.0s at the start of a file
  during parallel runs (likely a game restart mid-run by another agent). The end-pass full suite must be clean;
  investigate only if it reproduces there.
- **BUG-JD-3** (orchestrator, not blocking, open) Part of BUG-JD-1: `mod/dev/tests/jokers/j_half.lua` JokerDisplay
  test sets `JokerDisplay.current_hand` directly; convert it with the new highlight action too.
- **BUG-JD-4** (orchestrator, not blocking, open) El Santo (Luchador+) JokerDisplay shows "(Inactive)" outside a
  Boss Blind, copied from vanilla. But El Santo works when sold at any time (it disables the next Boss), so it should
  read "(Active!)" whenever selling it would do something (any time a Boss is still ahead, or the current Boss
  isn't disabled). Fix the definition in mod/src/jokers/j_bplus_luchador_plus.lua and its test.
- **BUG-JD-5** (JD8, not blocking but HIGH priority: a crash) One j_vagabond run errored inside JokerDisplay's
  remove during `delete_run` at `T.start_run` while other agents were running; it didn't repeat. Possibly related
  to the JokerDisplay wrappers added to mod/src/behavior.lua (JD0) running on a card being deleted. Find the error
  in the Lovely logs (`./dev.sh log`, search "JokerDisplay" / "remove"), make the wrapper safe for removed cards, add
  a test that deletes a run with switched jokers (T.force_behavior) on the table.
- **BUG-JD-6** (JD8, not blocking, open) `./dev.sh check` reported 13 problems in 7 files outside JD8 (during the
  JokerDisplay pass). End pass: `./dev.sh check` must be clean (see also BUG-ART-2).
- **BUG-JD9-1** (JD9, not blocking, open) mod/src/behavior.lua: JokerDisplay's `calculate_card_triggers` looks up `retrigger_function` by `joker.config.center.key` outside the behaviour swap, so a vanilla retrigger joker forced to 'plus' (and a "+" one forced to 'base') still uses its own definition's retrigger count (e.g. Hanging Chad forced to plus counts vanilla's 2, not 3). Text/reminder displays are correct. Retrigger JokerDisplay tests therefore only cover the "+" joker.
- **BUG-JD-7** (JD10, not blocking, open; same root cause as BUG-JD9-1) JokerDisplay looks up per-joker functions
  by `card.config.center.key` outside the behaviour swap: `retrigger_function` (BUG-JD9-1) and `get_blueprint_joker`
  (vanilla Blueprint next to Carpenter shows one copy target instead of Architect's two). Fix both in one place in
  mod/src/behavior.lua: run JokerDisplay's trigger/blueprint lookups (src/api_helper_functions.lua:
  calculate_card_triggers and the blueprint helper) under the swap of the joker being looked up. Then add the
  forced-behaviour retrigger tests (Hanging Chad, Hack) and a vanilla-Blueprint-forced-to-plus display test.
- **BUG-JD-8** (JD10, not blocking, open) Triboulet+ JokerDisplay test only checks the idle X1 state (no card
  selection action). After BUG-JD-1 adds the highlight action, add a selected-Jack case.
- **BUG-JD-9** (JD5, not blocking, open) A wide `./dev.sh test JokerDisplay` run showed FAIL lines for
  j_baseball, j_blueprint, j_brainstorm, j_delayed_grat, j_hack, j_loyalty_card, j_matador, j_stencil while other
  batches were still being written. j_blueprint, j_brainstorm and j_hack belong to batches that reported PASS
  (JD9/JD10), so these may be order-dependent (state leaking between tests in one run) or flaky. End pass: run
  `./dev.sh test JokerDisplay` once after all batches are in and fix whatever still fails.
- **BUG-JD-5 update** (JD4) Reproduces often now: the FIRST test of a file ERRORs at 0.0s inside JokerDisplay's
  `remove` (JokerDisplay display_functions.lua) when `T.start_run` deletes the previous run (seen in even_steven,
  odd_todd, scholar, walkie_talkie, smiley, shoot_the_moon). BUG-JD-2 (0.0s errors) is very likely the same bug.
  Fix this FIRST in the end pass: it makes the full suite flaky and could crash a real game when a run ends.
- **BUG-JD-5 likely cause** (JD3) A test that highlights cards with `G.hand:add_to_highlighted` and doesn't
  unhighlight makes the NEXT test's `T.start_run` crash in JokerDisplay's remove. JD3 added `G.hand:unhighlight_all()`
  at the end of its tests; JD1/JD4 tests don't. Fix in the toolkit, not per test: `T.start_run` (or the run teardown)
  clears highlights before deleting the run, and the new `T.highlight` action (BUG-JD-1) is the only way tests select
  cards. Then confirm no 0.0s errors remain in the full suite.
- **BUG-JD-10** (JD3, cosmetic, open) Flower Garden JokerDisplay reminder "(3 Suits)" hard-codes the English word
  "Suits" (mod/src/jokers/j_bplus_flower_pot_plus.lua). Use a localization entry (mod loc or an existing key).
- **BUG-JD7-1** (JD7, not blocking, open) mod/src/jokers/j_bplus_loyalty_card_plus.lua: a "+" Membership Card forced to 'base' shows the vanilla reminder "(5 remaining)" regardless of hands played, because vanilla JokerDisplay reads `ability.loyalty_remaining`, which only vanilla code refreshes at joker_main (not in `state_transfer`). The X value is right.
- **BUG-JD-11** (JD2, cosmetic, open) Test titles in mod/dev/tests/jokers/j_trading.lua and j_matador.lua may
  say "(Active)" while asserting "(Active!)"; make names match assertions. Also part of BUG-JD-6: "Undefined global
  JokerDisplay" lint warnings in several test files (add the global to the lint config or a `---@diagnostic` line).
