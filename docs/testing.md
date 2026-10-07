# Testing guide

Tests run **inside the real game**. A test drives Balatro through the same functions its buttons
call, waits for animations to finish, and asserts on exact game values (chips, mult, score, money,
cards). There are no mocks; if a test passes, the game really behaves that way.

```bash
./dev.sh test                 # run everything
./dev.sh test joker           # only tests whose "file > name" contains "joker" (case-insensitive)
./dev.sh test --restart       # force a game restart first
./dev.sh test --stay          # stay on the test profile afterwards (inspect the final state)
```

`./dev.sh test` starts the game if needed and **restarts it automatically when files under `mod/`
changed since launch**. The exceptions are `mod/dev/tests/` and `mod/dev/scenario*`, which are re-read
on every run. Output streams as tests finish. Exit code: 0 = all passed, 1 = failures, 3 = the game
crashed, hung or could not start.

```
PASS  vanilla/jokers.lua > Joker: +4 Mult (2.3s)
FAIL  framework.lua > scenario can force the boss blind (0.2s)
      expected "bl_hook", got "bl_manacle"   [dev/tests/framework.lua:19]
      game: state=BLIND_SELECT ante=1 round=0 dollars=4 hands_left=4 jokers=
```

## Sharing the game

There is one game, so commands that talk to it (`test`, `eval`, `scenario`, `state`, `start`, `stop`,
`restart`) take a lock and queue: `Waiting for the game (in use by pid ...)` means another terminal or agent is
running. Each run restarts the game if any mod code changed since launch, including other people's edits. A test
run therefore loads everyone's current files; a file that fails to load is skipped and shown as
`WARN  mod file skipped at load: <file>: <error>` at the top of the output.

Batch your work: write several jokers, then run their tests together (`./dev.sh test j_ride_the_bus` or a
broader filter). Don't loop single tests.

## Isolation

- Tests run on **profile 3**, a dedicated test profile with everything unlocked. The player's profile and
  game speed are restored afterwards, so test runs never touch the player's save or stats.
- Every test should start with `T.start_run{...}`, a fresh run seeded with `BPTEST` (Red Deck,
  White Stake by default). Same seed + same actions = same result.
- Tests take over the game window while they run.

## Writing a test

Put files anywhere under `mod/dev/tests/` (subfolders are fine). Files run in alphabetical order, and so do the tests within each file.

```lua
local T = BPlus.test

T.test('Greedy Joker: +3 Mult per scored Diamond', function()
    T.start_run({ jokers = { 'greedy_joker' } })   -- scenario table, see below
    T.select_blind()                               -- BLIND_SELECT -> SELECTING_HAND
    T.set_hand({ 'AD', 'KD', '9D', '5D', '2D' })   -- make the hand exactly these cards
    local r = T.play({ 'AD', 'KD', '9D', '5D', '2D' })
    T.eq(r.hand, 'Flush')
    T.eq(r.chips, 35 + 11 + 10 + 9 + 5 + 2)        -- show the arithmetic, not just the total
    T.eq(r.mult, 4 + 3 * 5)
end)
```

Guidelines:
- Put the expected value as arithmetic that explains itself (`2 + 4 + 4`, not `10`).
- Prefer `T.set_hand` + exact `T.eq` over "score went up" checks.
- One behaviour per test; name it `'<Card>: <behaviour>'`.
- `mod/dev/tests/framework.lua` exercises every action and is the reference for usage.
- `mod/dev/tests/vanilla/` pins vanilla behaviour that our upgrades are compared against.

## Scenario fields (`T.start_run`, `dev.new_run`, `mod/dev/scenario.lua`)

| Field | Meaning |
|---|---|
| `seed`, `deck`, `stake` | Run setup. Test defaults: `'BPTEST'`, `'b_red'`, `1` |
| `ante`, `boss` | Starting ante; force the first boss (`'hook'` = `'bl_hook'`) |
| `dollars`, `infinite_money`, `free_rerolls` | Money setup (`infinite_money` = `true` for a $1000 floor, or a number) |
| `hands`, `discards`, `hand_size`, `joker_slots`, `consumable_slots` | Round and slot sizes |
| `jokers`, `consumables` | `'blueprint'` or `{ key = 'j_joker', edition = 'foil', stickers = { 'eternal' } }` |
| `vouchers` | Redeemed immediately |
| `shop_queue` | Forced into the next shop joker slots, in order |
| `shop_pool` | Every shop joker slot (including rerolls) drawn from this list |

Jokers given by a scenario never get a random edition unless you set `edition`, and `stickers` are always
applied (forced). "+" jokers are given as `'bplus_joker_plus'` or `'j_bplus_joker_plus'`.

Card keys may omit their prefix (`'blueprint'` = `'j_blueprint'`, `'pluto'` = `'c_pluto'`).
Vanilla keys are in `~/Library/Application Support/Balatro/Mods/lovely/dump/game.lua`.

## API (`local T = BPlus.test`)

Actions check preconditions like the real button would (wrong state, too many cards, not
affordable, no slot...) and call `T.fail` with a clear message instead of doing something odd.

**Run flow**

| Call | From → to | Returns |
|---|---|---|
| `T.start_run(scenario)` | anything → `BLIND_SELECT` | `dev.state()` snapshot |
| `T.select_blind()` | `BLIND_SELECT` → `SELECTING_HAND` | blind name |
| `T.skip_blind()` | `BLIND_SELECT` (not Boss) | the new tag |
| `T.play(cards)` | `SELECTING_HAND` | `{ hand, chips, mult, score, dollars, state }` (`dollars` = change during the hand) |
| `T.discard(cards)` | `SELECTING_HAND` | — (spends a discard, draws back up) |
| `T.win_blind()` | `SELECTING_HAND` → `ROUND_EVAL` | — shortcut; no hand is scored |
| `T.cash_out()` | `ROUND_EVAL` → `SHOP` | money gained |
| `T.to_shop()` | `BLIND_SELECT` → `SHOP` | select + win + cash out |
| `T.leave_shop()` | `SHOP` → `BLIND_SELECT` | — |

**Shop, cards, consumables**

| Call | Notes |
|---|---|
| `T.buy(key_or_index)` | shop jokers/consumables (Buy), vouchers (Redeem), boosters (Open); returns the card |
| `T.reroll()` | pays the reroll cost |
| `T.sell(key_or_index)` | owned joker or consumable; returns the money gained |
| `T.use(key_or_index, targets)` | consumable (owned or in an open pack); `targets` = hand cards to select first |
| `T.pick(key_or_index)` / `T.skip_pack()` | inside an opened booster pack |
| `T.set_hand(specs)` | rewrites the hand to exactly these cards; extras go back to the deck |
| `T.joker(k)`, `T.consumable(k)`, `T.find(area, k)` | look up owned cards (nil if absent) |
| `T.upgrade(k)` | permanent upgrade of an owned joker via `BPlus.upgrade_card`; fails if not eligible; returns the card |
| `T.force_behavior(k, mode)` | make an owned joker behave as `'plus'` (what Carpenter does), `'base'` (what The Rust does) or normally (`nil`) |

| `T.joker_display(k, live)` | what JokerDisplay shows for an owned joker: `{ text, reminder, extra = {rows}, values }` (strings as rendered, e.g. `text = '+20'`). Forces a rebuild first; `live = true` skips that and reads what the game's own updates produced (call `T.wait_frames(10)` before it to test automatic refresh) |

**Card specs** (hand cards in `set_hand`, `play`, `discard`, `use` targets): rank + suit, `'AS'`,
`'10H'` (or `'TH'`), `'2C'`; or a table `{ 'KH', enhancement = 'glass', edition = 'foil', seal = 'Red' }`.
`play`/`discard` also accept 1-based hand indices (left to right after sorting).

**Assertions**: `T.eq(actual, expected, what)` (deep for tables), `T.near(a, e, tol, what)`,
`T.truthy(v, what)`, `T.falsy(v, what)`, `T.contains(list, value, what)`, `T.fail(msg)`,
`T.errors(fn) -> message` (asserts that fn fails).

**State and waiting**: `T.state()` (same as `dev.state()`: dollars, hands_left, jokers, hand, shop...),
`T.state_name()`, `T.wait_idle()`, `T.wait_until(pred, what, timeout)`, `T.wait_frames(n)`.
Every action already waits for idle; you rarely need these.

Direct game access is fine for setup and assertions (`G.GAME.hands['Flush'].level`,
`G.jokers.cards[1].ability.mult`), but **change game state through actions**, not by calling
`G.FUNCS.*` yourself. The raw button functions have hidden modes that buttons never use. For
example, `discard_cards_from_highlighted(nil, true)` is The Hook's free discard: no discard spent,
no redraw.

## Testing JokerDisplay

Every "+" joker declares `joker_display_def` (see CONVENTIONS "JokerDisplay"). Assert it with
`T.joker_display(k).text` (and `.reminder` / `.extra` when the definition has them). Test the three cases:
the "+" joker normally, the vanilla joker after `T.force_behavior(k, 'plus')` (must show "+" numbers) and the
"+" joker after `T.force_behavior(k, 'base')` (vanilla numbers). Stored state (shared via `state_transfer`)
is kept across forced behaviours, so a growing joker shows its stored value through the other definition.

## How it works

- `mod/src/dev/test/runner.lua`: discovers test files, runs each test as a coroutine resumed once per
  frame from `Game:update`, and writes results to `<save dir>/bplus_dev/test_out.txt`.
  `./dev.sh test` streams that file.
- `mod/src/dev/test/actions.lua`: the actions. "Idle" means there are no blocking events in
  `G.E_MANAGER`, no controller locks, no screen wipe, and the state handler has finished (`G.STATE_COMPLETE`),
  holding for 3 consecutive frames.
- `mod/src/dev/actions.lua`: hooks `G.FUNCS.evaluate_play` to record each hand's final
  chips/mult/score (`BPlus.dev.last_hand`). That is what `T.play` returns.
- Speed: tests run at game speed ×16. Higher doesn't help, because the event queue handles about one event
  per frame. Expect about 1.5 s per test.

## Ad-hoc checks without a test file

```bash
./dev.sh eval 'dev.state()'                # snapshot of the current run
./dev.sh eval 'G.GAME.hands["Flush"]'      # any expression; statements work too
./dev.sh eval -f /path/to/script.lua
```

`eval` runs synchronously in one frame, so it cannot wait for animations. Use a test for
anything multi-step.
