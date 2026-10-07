# Bug list (build of the "+" jokers and mechanics)

Triage rule (from the human, 2026-10-08): a bug that **blocks** other tests or agents (crashes shared runs, breaks
a shared file, stops a batch) is fixed immediately. Everything else is written here and fixed + tested together in
one pass after the batches finish.

Columns: id, found by, blocking?, status, description.

## Open (fix in the end pass)

- **BUG-2** (orchestrator, cosmetic, open) The last 7 B3 commits (ancient, rough_gem, bloodstone, arrowhead,
  onyx_agate, flower_pot, seeing_double) say "ASS" instead of "PASS" in their messages. Code is fine. Fixing means
  rewording history on the shared branch; only do it once no agent is committing (or leave it).
- **BUG-3** (orchestrator, cosmetic, open) B2 and B4 commit messages carry test names / counts instead of the PASS
  lines (B4's j_fibonacci has none). The end-pass full suite is the evidence; no history rewrite planned.
- **BUG-4** (orchestrator, cosmetic, open) Test name "Hive Mind: real Carpenter right of a vanilla Brainstorm" in
  `mod/dev/tests/jokers/j_brainstorm.lua`: the setup has Carpenter *left* of Brainstorm (correct); only the name is
  wrong.
- **BUG-5** (B4, unverified) B4 saw a `./dev.sh check` warning in `mod/src/jokers/j_bplus_swashbuckler_plus.lua`;
  the orchestrator's later check run was clean. Recheck in the end pass.

## Fixed

- **BUG-1 / Q-B9-1** (B9, not blocking: the affected test was dropped; fix was already written when the triage rule
  arrived, so it was finished) `BPlus.with_center` restored the card's own `ability` before deferred events ran, so
  vanilla code that reads `self.ability` inside `G.E_MANAGER:add_event` saw the wrong shape. Cat Burglar under The
  Rust crashed the game (`ease_hands_played({hands=5})`). Any vanilla joker with a deferred `self.ability` read was
  exposed. Fix: `mod/src/behavior.lua` wraps events queued during a swap so they run under the same swap. Test
  restored: "Cat Burglar: forced to base (The Rust case)".
- **BUG-MC-1** (MC, not blocking, open) mod/dev/tests/framework.lua "skip blind grants a tag": fails since the Masterwork Tag joined the tag pool (seeded BPTEST pick shifts to an immediate-type tag that is consumed at once, so T.skip_blind returns nil). Fix: force a non-immediate tag in that test (any tag added to the pool can shift the seed again).
- **BUG-MC-2** (MC, not blocking, open) mod/dev/tests/jokers/j_throwback.lua "Nostalgic Joker: forced to base scores the vanilla X1.5": expected 1.5, got 1 in the full-suite run (j_throwback owner to check).
