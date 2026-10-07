# Balatro+ — Agent Brief: Joker Upgrade Table

You are joining the **Balatro+** modding project. Balatro+ is a mod in which most vanilla jokers get an **upgraded version** (a "+" joker). Read this whole file before doing anything.

Your job is to build and maintain the **joker upgrade table**: a spec sheet mapping every vanilla joker to its upgraded version. Each approved row is later implemented as one self-contained feature, by you or by another agent.

**Out of scope for now:** the mechanic that performs upgrades (spectral card, tarot, etc.). It will be designed separately. Do not implement or design it. The table only has to *support* it, through the `upgradable` and `state_transfer` fields.

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
- A central lookup table maps `vanilla_key → plus_key`. The future upgrade mechanic will read it.

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
| `plus_rarity` / `plus_cost` | Rarity and shop cost | Uncommon / 7 |
| `state_transfer` | Fields copied from the vanilla card on upgrade | `["mult"]` |
| `blueprint_compat` / `eternal_compat` / `perishable_compat` | Booleans | true / true / false |
| `impl_notes` | Hooks/contexts used, gotchas, interactions | `context.before` for the face check; `context.joker_main` for scoring |
| `acceptance_tests` | Concrete scenarios that prove it works | `["3 hands without face cards -> +3 Mult", "then a scoring face card -> Mult becomes 1"]` |
| `status` | `draft` → `approved` → `implemented` → `tested` | approved |
| `art_status` | `none` / `placeholder` / `final` | placeholder |

`state_transfer` and `acceptance_tests` are mandatory for every approved row. If a joker has no persistent state, write `[]`.

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

- An upgrade is **never strictly worse** than its base, in any situation.
- An upgrade is roughly **one rarity step** stronger than its base.
- An upgrade keeps the **identity** of the base joker: same idea, more of it, or the idea fulfilled.
- An upgrade must not break Blueprint/Brainstorm compatibility unless the base already lacks it.
- Use "flat number bump" upgrades sparingly. They are allowed, but they are the least interesting option.

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
2. Also build the shared state-transfer helper and `upgrade_map.lua`.
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

## When to stop and ask the human

- You cannot access the game source.
- A design rule would have to be broken to make an upgrade work.
- A vanilla joker's behavior in the source differs from its description text.
- Anything touches the upgrade *mechanic* itself. That is not designed yet.
