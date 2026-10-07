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
