# Balatro+ — Agent Brief: Joker Upgrade Table

You are joining the **Balatro+** modding project. Balatro+ is a mod in which most vanilla jokers get an **upgraded version** (a "+" joker). Read this whole file before doing anything.

Your job is to build and maintain the **joker upgrade table**: a spec sheet mapping every vanilla joker to its upgraded version. Each approved row is later implemented as one self-contained feature, by you or by another agent.

The **upgrade mechanics** decide how players get upgrades during a run. They are already designed; see the "Upgrade mechanics" section. They are implemented in Phase 5, after the joker pilot.

Some questions are still open on purpose; see "Open questions" at the end. **Never resolve an open question yourself.** Work around it as described there.

> **Update, 2026-10-07: the upgrade mechanics are now designed.** If you started before this date, then before going further:
> 1. **Update `plannig/CONVENTIONS.md`.**
>    - §4 ("Shop pool") and §6 still say the mechanic is not designed. Bring them in line with the "Upgrade mechanics" section below.
>    - Add the `base_calculate` / `plus_calculate` split from the Architecture section.
> 2. **Check scaling rows.** Rows for scaling jokers now wait on Q1, including the Ride the Bus example in CONVENTIONS.md. Mark them `blocked`; don't pick an answer.
> 3. **Map the new paths** the same way as the existing ones:
>    - `src/balance.lua` → `mod/src/balance.lua`
>    - `specs/mechanics/` → `plannig/specs/mechanics/`

---

## Core principles

1. **Design happens before implementation.** An implementing agent must never have to make a design decision. If a row is ambiguous, it is not ready, so send it back to `draft`.
2. **Vanilla data comes from the game source, never from memory.** Joker effects and numbers must be extracted from the game files (see Phase 0). If you cannot access the source, stop and ask the human. Do not fill vanilla values from recall.
3. **The human approves designs.** You propose designs; the human approves them. Only rows with `status: approved` may be implemented.
4. **Work in batches grouped by archetype.** Design rows in batches of 15–20, grouped by archetype, so balance can be compared side by side.
5. **Pilot before mass production.** Implement about 5 diverse jokers first, then fix the conventions, then scale up.

---

## Architecture decision (fixed)

Each upgraded joker is a **separate joker** with its own key, art, description and collection entry. It is *not* an "upgraded" flag on the vanilla joker.

- The key format is `j_bplus_<vanilla_name>_plus` (e.g. `j_bplus_ride_the_bus_plus`).
- Upgrading a joker in a run means replacing the card with its "+" version and copying over:
  - the fields listed in `state_transfer`,
  - the edition (Foil, Holo, Polychrome, Negative),
  - the stickers (Eternal, Perishable, Rental).
- A central lookup table maps `vanilla_key → plus_key`. The upgrade mechanics read it.
- **All permanent upgrades go through one shared function**, `BPlus.upgrade_card(card)`. No mechanic swaps cards on its own. The function:
  - swaps the card to its `plus_key` **in place**, keeping its position, edition and stickers;
  - copies state according to `state_transfer`;
  - does nothing if the joker has no upgrade (`upgradable: no`) or is already upgraded.
- **Base and plus logic must each be callable on any card's data.** Two mechanics need this:
  - **Carpenter** runs the *plus* behavior of a base joker without swapping the card.
  - **The Rust** makes an upgraded joker run its *base* behavior for one blind.

  Structure every plus joker so both behaviors are exposed as functions, e.g. `base_calculate(card, context)` and `plus_calculate(card, context)`, that operate on the card's own ability table. Document the exact pattern in `CONVENTIONS.md` before the pilot.
- **Rules that apply everywhere:**
  - A joker can be upgraded **once**. There is no "++".
  - Duplicates keep the upgrade level. An upgraded joker copied by Invisible Joker or Ankh yields an upgraded copy.
  - Blueprint and Brainstorm copy the **upgraded** effect of an upgraded joker.

---

## Repository layout (create it if missing)

```
CONVENTIONS.md            # code + naming conventions (you write this in Phase 0)
design/
  jokers.csv              # master table, one row per vanilla joker (source of truth for design)
  patterns.md             # the upgrade pattern library + global balance rules
specs/
  jokers/<vanilla_key>.yaml   # one implementation ticket per approved row
src/
  jokers/<plus_key>.lua       # implementations
  upgrade_map.lua             # vanilla_key -> plus_key lookup
assets/                   # art (separate pipeline; placeholders are fine)
```

---

## Row schema (`design/jokers.csv`)

Store complex values (configs, test lists) as JSON strings inside the CSV cells.

| Field | Description | Example (Ride the Bus) |
|---|---|---|
| `vanilla_key` | Key from the game source; unique ID | `j_ride_the_bus` |
| `vanilla_name` | Display name | Ride the Bus |
| `vanilla_rarity` | Common / Uncommon / Rare / Legendary | Common |
| `archetype` | Grouping tag for batching (see below) | Scaling Mult |
| `vanilla_effect` | Exact description text **from localization source** | +1 Mult per consecutive hand played without a scoring face card |
| `vanilla_config` | Exact config table **from game source** | `{"extra": 1}` |
| `upgradable` | `yes` / `no` (no = excluded from Balatro+) | yes |
| `pattern` | Upgrade pattern from `patterns.md` | Remove downside |
| `plus_key` | New key | `j_bplus_ride_the_bus_plus` |
| `plus_name` | New display name | Express Bus |
| `plus_effect` | Final player-facing text | Same gain, but a scoring face card halves Mult instead of resetting it |
| `plus_config` | Exact numbers | `{"extra": 1}` |
| `plus_rarity` / `plus_cost` | Rarity and shop cost. Both always equal the vanilla values | Common / 6 |
| `state_transfer` | Fields copied from the vanilla card on upgrade | `["mult"]` |
| `blueprint_compat` / `eternal_compat` / `perishable_compat` | Booleans | true / true / false |
| `impl_notes` | Hooks/contexts used, gotchas, interactions | `context.before` for the face check; `context.joker_main` for scoring |
| `acceptance_tests` | Concrete scenarios that prove it works | `["3 hands without face cards -> +3 Mult", "then a scoring face card -> Mult becomes 1"]` |
| `status` | `draft` → `approved` → `implemented` → `tested`, or `blocked` (waiting on an open question) | approved |
| `art_status` | `none` / `placeholder` / `final` | placeholder |

`state_transfer` and `acceptance_tests` are mandatory for every approved row. If a joker has no persistent state, write `[]`.

**Exception: scaling jokers.** This means any joker whose value accumulates during a run. How their state behaves on upgrade is an open question (Q1).
- Design everything else in the row as usual.
- Write `TBD (Q1)` in `state_transfer`.
- Set `status: blocked`.

Do not pick an answer yourself.

### Archetype tags (starting set; refine in Phase 1)

Flat Mult · Flat Chips · xMult · Suit-conditional · Hand-type-conditional · Scaling Mult · Scaling Chips · Scaling xMult · Retrigger · Probability · Economy · Card generation (tarot/planet/spectral) · Deck manipulation · Copy (Blueprint-like) · Self-destructing / decaying · Legendary · Other

---

## Upgrade pattern library (starting set; finalize in `design/patterns.md`)

| Pattern | Idea | Example |
|---|---|---|
| Promote | +Mult → ×Mult, or +Chips → +Mult | Joker: +4 Mult → ×1.5 Mult |
| Relax condition | The trigger fires more often | Greedy Joker also counts Wild cards and one other suit |
| Remove downside | Drop the reset, decay or self-destruct | Ice Cream stops melting |
| Faster scaling | Same scaling, bigger step | Green Joker gains +2 instead of +1 |
| Better odds | Probability jokers get better chances | 1 in 2 → 1 in 1.5 |
| Extra retrigger | Retrigger one more time | Hack retriggers twice |
| Second effect | Keep the effect and add a small related one | Egg also gives +$1 at end of round |
| Fulfilment | The joker "completes" its theme | Gros Michel → Cavendish (vanilla precedent) |

### Global balance rules (proposed; confirm with the human)

These are guidelines, not hard limits. The human may knowingly break one for a specific joker (e.g. Medusa drops Marble Joker's effect; Midas Touch can overwrite enhancements Midas Mask would leave alone). When a row breaks a guideline on purpose, say so in its `impl_notes`, and don't "fix" it.

- An upgrade is **never strictly worse** than its base, in any situation.
- An upgrade is roughly **one rarity step** stronger than its base, in power only. Its rarity label does not change.
- An upgrade keeps the **identity** of the base joker: same idea, more of it, or the idea fulfilled.
- An upgrade must not break Blueprint/Brainstorm compatibility unless the base already lacks it.
- Use "flat number bump" upgrades sparingly. They are allowed, but they are the least interesting option.
- **Prices stay the same (decided).** A "+" joker costs exactly what its vanilla joker costs: `plus_cost = vanilla_cost`. Never raise the price to balance an upgrade.
- **Rarity stays the same (decided).** A "+" joker has its vanilla joker's rarity: `plus_rarity = vanilla_rarity`.

---

## Upgrade mechanics

### Design target

- A **normal run produces 1–2 upgrades**, counting Carpenter.
- Runs with a strong build and **good economy find more**. This works through the shop-based sources: money buys rerolls, and rerolls surface more upgrades.
- Every number marked *TBD* below is a balance value. Put all of them in one file, `src/balance.lua`, so tuning never requires touching logic. Use the tentative values for now.

### Eligible jokers

A joker is **eligible** for an upgrade when two things are true:
- it is `upgradable: yes`, and
- it is not already upgraded.

Every mechanic that picks a "random joker" picks among eligible jokers only. A consumable that needs an eligible joker cannot be used when there is none. Its `can_use` returns false, which is how Hex behaves.

### One version per joker (decided; implement later)

A player may never hold a base joker and its "+" version at the same time. It is either the base or the upgrade, never both.
- This is decided, but it is **not being implemented yet**. Don't build enforcement for it now, and don't design rows around it.
- When it is implemented, decide how it interacts with M5 Salesman and the other shop sources (M6–M8): they can offer the upgraded version of a joker you already hold.

### Mechanics

| # | Name | Type | Behavior | Tentative numbers |
|---|---|---|---|---|
| M1 | **Carpenter** | Joker | Blueprint-style. The joker to its **right** behaves as its upgraded version: Carpenter runs that joker's `plus_calculate` and suppresses its base effect, and the joker shows a "+" badge. This is **not permanent**: if Carpenter moves or leaves, the joker returns to its base behavior. Carpenter does nothing if the joker to its right is missing, ineligible or already upgraded. If that joker is Blueprint or Brainstorm, it behaves as Blueprint+ or Brainstorm+. | Uncommon, cost TBD. `blueprint_compat: false` (tentative) |
| M2 | **Apprentice** | Joker | Invisible Joker-style. After **3 rounds** it becomes active and shows a round counter. Selling it while active calls `BPlus.upgrade_card` on one random eligible joker. If there is no eligible joker, it shows a message and nothing happens. | 3 rounds; rarity and cost TBD |
| M3 | Tarot (name TBD) | Tarot | **1 in X** chance to upgrade one random eligible joker. On failure, show "Nope!" like Wheel of Fortune. It must use the standard probability system, so that Oops! All 6s improves the odds. | X = 8 (tune within 6–10) |
| M4 | Spectral (name TBD) | Spectral | Hex-style. Upgrades one random eligible joker and destroys all other non-Eternal jokers. | — |
| M5 | **Salesman** | Joker (the "+" row for Showman, `j_bplus_ring_master_plus`) | Same as Showman. In addition, upgraded jokers appear in the shop **more often**. This applies to every joker the shop offers, not only to jokers you already hold. Salesman works **on its own**: without Craftsmanship it lets upgraded jokers appear at a base rate, and Craftsmanship/Masterwork raise that rate further (decided 2026-10-07). A shop joker that appears upgraded is a **fresh card**: it starts from its own initial values. Designed by the human (2026-10-07, replaces the earlier Showman+ design); do not redesign it. | Base rate and stacking with M6 TBD |
| M6 | **Craftsmanship / Masterwork** | Voucher pair | Craftsmanship lets upgraded jokers appear in the shop, at the same price as their base version. Masterwork (requires Craftsmanship) makes them appear more often. This works like Hone/Glow Up for editions. | Rates TBD; price = base price (decided) |
| M7 | **Masterwork Tag** | Skip tag | Like Foil Tag: the next eligible joker in the shop appears upgraded. | Free or discounted: TBD |
| M8 | **Workshop Pack** | Booster pack | Choose 1 of 2 jokers. Each one has a chance to be upgraded. | Chance, price and sizes TBD |
| M9 | **Veteran Deck** | Deck | A joker upgrades automatically (`BPlus.upgrade_card`) after being held for **N rounds**. Each joker tracks its own count. | N TBD |
| M10 | **The Rust** | Boss blind | For this blind, upgraded jokers act as their **base** versions (they run `base_calculate`). This includes jokers currently upgraded by Carpenter. | — |

Ideas that were considered and **rejected**: Smith (merging duplicate jokers), Anvil (sacrifice one joker to upgrade another), and a standalone "Personal Shopper" joker (replaced by Salesman). Do not implement them.

---

## Phases and your tasks

### Phase 0 — Setup and vanilla extraction (start here)

1. **Locate the game source.** Ask the human for the path to their Balatro install. On Windows, `Balatro.exe` is a fused LÖVE executable and can be opened as a zip archive (e.g. with 7-Zip). Extract it to a working folder **outside the repo**. Do not commit game source.
2. **Extract the vanilla jokers:**
   - `game.lua` → the `P_CENTERS` entries whose keys start with `j_`. Capture the key, name, rarity, cost, config, and the `blueprint_compat` / `eternal_compat` / `perishable_compat` flags.
   - `localization/en-us.lua` → `descriptions.Joker`, which holds the effect text.
   - Write a small script for this (keep it in `tools/`). Do not copy values by hand.
3. **Generate `design/jokers.csv`.** It should have one row per vanilla joker (vanilla 1.0 has 150), vanilla columns filled, `status: draft`, and the design columns empty.
4. **Write `CONVENTIONS.md`.** Base it on the current Steamodded (SMODS) API, and verify the API against the current Steamodded docs/wiki rather than from memory. Cover at minimum:
   - mod folder structure and the mod header,
   - how a joker is declared (`SMODS.Joker`) and how `calculate` contexts are used,
   - key naming,
   - how `upgrade_map.lua` is structured,
   - atlas/art conventions and placeholder art,
   - how state transfer on upgrade will be done (a shared helper function, not per-joker code),
   - how acceptance tests are run (in-game debug steps or a debug mod, whichever is practical).
5. **Report to the human** with:
   - the row count,
   - any jokers whose effect text uses dynamic values you could not resolve,
   - a proposed archetype tag for every joker.
6. **Stop and wait** for the human to confirm the archetypes.

### Phase 1 — Pattern library

1. Finalize `design/patterns.md`, using the starting set above plus any new patterns that the archetypes suggest.
2. Propose the `upgradable: no` list, for example the legendaries, or jokers whose upgrade would be degenerate.
   - **Blueprint and Brainstorm must be `upgradable: yes`.** Carpenter relies on them having "+" versions.
   - **Showman's row is pre-designed** (see M5 Salesman).
3. Get the human's sign-off on both.

### Phase 2 — Design in batches

For each archetype batch (15–20 rows):

1. Fill every design column for the batch.
2. Present the batch to the human as a compact table:
   - vanilla effect vs. plus effect,
   - pattern used,
   - one line of balance reasoning per row.
3. Apply the human's edits and set the approved rows to `approved`.
4. Export each approved row to `specs/jokers/<vanilla_key>.yaml`. That file is the implementation ticket.

### Phase 3 — Pilot implementation

1. Implement exactly these kinds of jokers first, one each:
   - a flat Mult joker,
   - a scaling joker (with `state_transfer`),
   - a probability joker,
   - an economy joker,
   - a Blueprint-compatible joker with an unusual context.
2. Also build the shared `BPlus.upgrade_card(card)` function and `upgrade_map.lua`, and the `base_calculate` / `plus_calculate` structure from the Architecture section. Prove that both behaviors can be invoked from outside the card, because Carpenter and The Rust depend on this.
   - Do not pick a scaling joker whose state behavior is still `TBD (Q1)`. Pick a non-scaling joker with persistent state instead (e.g. one that counts rounds).
3. Update `CONVENTIONS.md` with anything the pilot taught you.
4. Report back before scaling up.

### Phase 4 — Mass implementation

Rules for every ticket:

- **One ticket = one joker = one commit.**
- For each ticket:
  1. Implement the joker.
  2. Run its acceptance tests.
  3. Set `status: tested`.
- If a spec turns out to be unimplementable or unclear:
  1. Set `status: draft`.
  2. Add a note in `impl_notes`.
  3. Move on. Do not redesign it yourself.

---

### Phase 5 — Upgrade mechanics

Start this once the Phase 3 pilot is done. It can run in parallel with Phase 4.

1. Turn each mechanic M1–M10 into a ticket in `specs/mechanics/<id>_<name>.yaml`. Use the same idea as the joker tickets: behavior, numbers (referencing `balance.lua`), edge cases and acceptance tests.
2. Get the tickets approved.
3. Implement in this order:
   1. M3 tarot and M4 spectral. They are the simplest, and they are useful as debug tools for testing every later ticket.
   2. M2 Apprentice.
   3. M1 Carpenter.
   4. M5 Salesman.
   5. M6 vouchers, M7 tag and M8 pack.
   6. M9 Veteran Deck.
   7. M10 The Rust.
4. **Any mechanic that interacts with a scaling joker** (Carpenter, every permanent upgrade): test it only with non-scaling jokers until Q1 is decided. Leave a note in the ticket.

---

## Open questions (do not resolve these yourself)

Every row blocked on one of these still gets a ticket, marked BLOCKED, and is listed in `plannig/specs/jokers/BLOCKED.md`. Both are generated by `tools/export_specs.py`. When a question is decided, start from that list.

**Q1 — Scaling state on upgrade.** When a scaling joker is upgraded, where does its value start? For example, Green Joker at +10 Mult gets upgraded to a version that gains +2 per hand. The candidates are:
- **Reset**: the value starts over.
- **Carry over**: it keeps +10, and the new rate applies from now on.
- **Recompute**: it becomes +20, as if it had always been upgraded.

The same question applies when Carpenter moves on or off a scaling joker. Until this is decided:
- scaling joker rows stay `blocked` with `state_transfer: TBD (Q1)`;
- the pilot avoids scaling jokers.

**Q2 — Do the mechanic jokers have "+" versions?** This applies to Carpenter and Apprentice. Until it is decided, set both to `upgradable: no`.

**Q3 — Balance numbers.** All *TBD* values in the mechanics table are open. Use the tentative values and keep every number in `balance.lua`.

---

## When to stop and ask the human

- You cannot access the game source.
- A design rule would have to be broken to make an upgrade work.
- A vanilla joker's behavior in the source differs from its description text.
- A mechanic ticket needs behavior that is not described in the mechanics table.
- Work cannot continue without resolving one of the open questions.
