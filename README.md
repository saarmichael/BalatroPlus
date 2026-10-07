# Balatro Plus

A Steamodded mod that gives (almost) every Joker a basic and an upgraded version.

## Layout

```
mod/                    <- the actual mod; symlinked into Balatro's Mods folder
  BalatroPlus.json  Steamodded manifest (id, prefix "bplus", deps)
  config.lua            default mod config (dev_mode)
  main.lua              thin loader
  src/                  features, one file per concern
  src/dev/              dev toolkit, loaded only when dev_mode = true
  dev/scenario.lua      default test scenario (applied to new runs when enabled)
  dev/scenarios/        named test scenarios
  dev/tests/            automated in-game tests
docs/testing.md         testing guide + API
CLAUDE.md               instructions for AI agents working in this repo
dev.sh                  dev helper (run the game, logs, checks, send commands to the game)
.luarc.json             Lua language server config (Steamodded + vanilla source as libraries)
```

Dev tooling lives outside `mod/` because Steamodded treats every `.json` inside a mod folder as a potential manifest.

## Setup (macOS, done once)

Requires Lovely + Steamodded in `~/Library/Application Support/Balatro/Mods`.
[DebugPlus](https://github.com/WilsontheWolf/DebugPlus) is recommended (installed in `Mods/DebugPlus`). Plus:

```bash
brew install luajit lua-language-server
code --install-extension sumneko.lua
./dev.sh link
```

## Workflow

```bash
./dev.sh run       # launch Balatro with Lovely; log streams to the terminal
./dev.sh start     # launch in the background and wait until ready (stop / restart too)
./dev.sh log       # our lines + errors from the latest Lovely log
./dev.sh check     # syntax check + language-server diagnostics
./dev.sh test      # automated in-game tests (see docs/testing.md)
```

Edit files in `mod/`, then restart the game to pick up code changes (in game: hold **M**, or Alt+F5).
Scenario files are re-read on every new run, so they don't need a restart.

## Automated tests

`./dev.sh test [filter]` runs the tests in `mod/dev/tests/` inside the real game, on a separate test profile (profile 3).
It restarts the game when mod code changed and exits non-zero on failure.
See [docs/testing.md](docs/testing.md) for how to write tests and the full API.

## Manual testing toolkit (dev mode)

Enabled by `dev_mode = true` in `mod/config.lua`. Turn it off for releases.

**Scenarios** describe a test setup: seed, deck, stake, ante, money, hands and discards, slots, starting jokers, consumables and vouchers, and shop control.
See `mod/dev/scenario.lua` for every field.

- `mod/dev/scenario.lua` is applied to every new run while `enabled = true`.
- `mod/dev/scenarios/<name>.lua` files are applied on demand.

**Shop control:** `shop_queue` forces cards into the next shop joker slots, in order. `shop_pool` restricts every shop joker slot to a list. Rerolls use both too.

**Money:** `infinite_money` tops money back up to a floor ($1000 by default) whenever it drops below. `free_rerolls` makes rerolls cost $0.

**Ways to drive it**

| Where | How |
|---|---|
| Terminal | `./dev.sh scenario example`, `./dev.sh state`, `./dev.sh eval 'dev.give("blueprint")'`, `./dev.sh eval -f test.lua` |
| DebugPlus console (press `/`) | `bp give blueprint foil`, `bp shop hologram brainstorm`, `bp pool joker off`, `bp money inf`, `bp rerolls on`, `bp win`, `bp run example`, `bp state` |
| Keybinds | Option+N new run with `dev/scenario.lua`, Option+W win blind, Option+M toggle infinite money |
| DebugPlus built-ins | Ctrl+3 over a collection card spawns it, Ctrl+Q cycles edition, hold Z/X + 1–3 save/load state, Tab debug menu |

`./dev.sh eval` runs Lua inside the running game and prints the result. `dev` is `BPlus.dev` (see `mod/src/dev/actions.lua`), and bare expressions are returned automatically.
It works through files in `<save dir>/bplus_dev/`.

Card keys may omit the prefix: `blueprint` is the same as `j_blueprint`. Vanilla keys are listed in `Mods/lovely/dump/game.lua`.

## References

- Vanilla source (unpacked, read-only): `~/Library/Application Support/Steam/steamapps/common/Balatro/Balatro.app/Contents/Resources/Balatro.love`
- Source as patched by Lovely/Steamodded, regenerated each launch: `~/Library/Application Support/Balatro/Mods/lovely/dump`
- Steamodded API definitions: `~/Library/Application Support/Balatro/Mods/smods/lsp_def`
- Steamodded wiki: https://github.com/Steamodded/smods/wiki
