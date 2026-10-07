# Balatro Plus

A Steamodded (SMODS) + Lovely mod for Balatro (macOS, Steam). Goal: (almost) every vanilla joker
gets a basic and an upgraded version. Upgrade triggers (tarot, voucher, shop, joker effects...) are
still being designed by the user, so keep upgrade logic behind one entry point that any trigger can call.
The user wants to stay involved in system design: explain trade-offs and ask before big structural decisions.

## Layout

- `mod/`: the mod itself, symlinked to `~/Library/Application Support/Balatro/Mods/BalatroPlus`.
  Manifest `mod/BalatroPlus.json` (id `BalatroPlus`, prefix `bplus`, so keys look like `j_bplus_...`). Lua global `BPlus`.
- `mod/src/`: features. `mod/src/dev/`: dev toolkit + test framework, loaded only when `dev_mode = true` in `mod/config.lua`.
- `mod/dev/tests/`: in-game tests. `mod/dev/scenario.lua` and `mod/dev/scenarios/`: manual test setups.
- `dev.sh`: every dev command. `docs/testing.md`: testing guide + API.
- `plannig/`: the user's design brief, conventions and joker design table (`BALATRO_PLUS_AGENT_BRIEF.md`,
  `CONVENTIONS.md`, `design/jokers.csv`). Read them before implementing jokers. For how to *run* tests,
  `docs/testing.md` is current.

## Commands

```bash
./dev.sh check            # syntax + lua-language-server; must be clean
./dev.sh test [filter]    # in-game tests; auto-restarts the game if mod code changed. Exit 0 = pass
./dev.sh eval '<lua>'     # run Lua in the live game, e.g. ./dev.sh eval 'dev.state()'
./dev.sh log              # mod lines + errors from the latest Lovely log
./dev.sh start|stop|restart
```

## Working rules

- **Verify every gameplay change in the real game.** Write or extend a test in `mod/dev/tests/`
  (read `docs/testing.md` first), run `./dev.sh check` and `./dev.sh test`, and report the
  results. A change isn't done until its test passes.
- New behaviour gets a test with exact expected numbers written as arithmetic (`2 + 4 + 4`).
- Change game state in tests only through `BPlus.test` actions, never raw `G.FUNCS.*` calls.
  They are safe wrappers around the real buttons.
- Tests run on profile 3 and restore the player's profile and speed. Never point tests or
  `dev.new_run` at the player's profile; that overwrites their run save.
- If tests crash the game, `./dev.sh test` exits 3 and prints errors from the Lovely log.
  `./dev.sh log` shows more.

## Reference

- Vanilla source (read-only): `~/Library/Application Support/Steam/steamapps/common/Balatro/Balatro.app/Contents/Resources/Balatro.love/`
- Source after Lovely/SMODS patches, regenerated each launch: `~/Library/Application Support/Balatro/Mods/lovely/dump/`.
  This is what actually runs; SMODS replaces many vanilla functions.
- Steamodded source + API definitions: `~/Library/Application Support/Balatro/Mods/smods/` (`lsp_def/`, `src/`), docs at https://docs.smods.dev
- Installed alongside: DebugPlus (console `/`, Ctrl+key tools), JokerDisplay (we should support it), Handy, Nopeus.
