#!/usr/bin/env bash
# Dev helper for the Balatro Plus mod (macOS + Steam).
#   ./dev.sh link              symlink mod/ into Balatro's Mods folder
#   ./dev.sh run               launch Balatro with Lovely (log streams to this terminal)
#   ./dev.sh start | stop      launch in the background / quit the game
#   ./dev.sh log               show our lines + errors from the latest Lovely log
#   ./dev.sh check             syntax check + language-server diagnostics
#   ./dev.sh eval '<lua>'      run Lua inside the running game (dev mode); `dev` = BPlus.dev
#   ./dev.sh eval -f file.lua  same, from a file
#   ./dev.sh scenario [name]   start a new run with dev/scenario.lua or dev/scenarios/<name>.lua
#   ./dev.sh state             print a snapshot of the current run
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
MOD_NAME="BalatroPlus"
GAME_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Balatro"
SAVE_DIR="$HOME/Library/Application Support/Balatro"
MODS_DIR="$SAVE_DIR/Mods"
LOG_DIR="$MODS_DIR/lovely/log"
REMOTE_DIR="$SAVE_DIR/bplus_dev"
GAME_PROCESS="Balatro.app/Contents/MacOS/love"

launch() {
  cd "$GAME_DIR"
  DYLD_INSERT_LIBRARIES=liblovely.dylib ./Balatro.app/Contents/MacOS/love "$@"
}

# Send Lua to the game and print the result. Exit code 1 on Lua error, 2 on timeout.
remote_eval() {
  local code="$1" id="$$-$RANDOM" timeout=15
  pgrep -f "$GAME_PROCESS" >/dev/null || { echo "Game is not running (./dev.sh start)" >&2; exit 2; }
  mkdir -p "$REMOTE_DIR"
  printf -- '-- id: %s\n%s\n' "$id" "$code" > "$REMOTE_DIR/cmd.lua.tmp"
  mv "$REMOTE_DIR/cmd.lua.tmp" "$REMOTE_DIR/cmd.lua"
  local deadline=$((SECONDS + timeout))
  while [ $SECONDS -lt $deadline ]; do
    if [ -f "$REMOTE_DIR/out.txt" ] && [ "$(head -1 "$REMOTE_DIR/out.txt")" = "$id" ]; then
      local status; status="$(sed -n 2p "$REMOTE_DIR/out.txt")"
      tail -n +3 "$REMOTE_DIR/out.txt"; echo
      [ "$status" = ok ] && return 0 || return 1
    fi
    sleep 0.1
  done
  rm -f "$REMOTE_DIR/cmd.lua"
  echo "Timed out after ${timeout}s (is dev_mode on and the game past the loading screen?)" >&2
  exit 2
}

case "${1:-}" in
  link)
    target="$MODS_DIR/$MOD_NAME"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$REPO/mod" ]; then echo "Already linked: $target -> $REPO/mod"
    elif [ -e "$target" ] && [ ! -L "$target" ]; then echo "Error: $target exists and is not a symlink" >&2; exit 1
    else ln -sfn "$REPO/mod" "$target" && echo "Linked $target -> $REPO/mod"; fi
    ;;
  run)
    launch "${@:2}"
    ;;
  start)
    pgrep -f "$GAME_PROCESS" >/dev/null && { echo "Game already running"; exit 0; }
    (launch "${@:2}" >/dev/null 2>&1 &)
    echo "Launched (logs: ./dev.sh log)"
    ;;
  stop)
    pkill -f "$GAME_PROCESS" && echo "Stopped" || echo "Game was not running"
    ;;
  log)
    latest="$LOG_DIR/$(ls -t "$LOG_DIR" | head -1)"
    echo "== $latest"
    grep -nE "BalatroPlus|BPlus\.dev|ERROR|WARN|Oops|stack traceback" "$latest" || echo "(no matching lines)"
    ;;
  check)
    status=0
    while IFS= read -r f; do luajit -bl "$f" >/dev/null || status=1; done < <(find "$REPO" -name '*.lua' -not -path '*/.git/*')
    lua-language-server --check "$REPO" --checklevel=Warning --logpath "${TMPDIR:-/tmp}/bplus-luals" || status=1
    exit $status
    ;;
  eval)
    if [ "${2:-}" = "-f" ]; then remote_eval "$(cat "$3")"; else remote_eval "${2:?usage: ./dev.sh eval '<lua>'}"; fi
    ;;
  scenario)
    remote_eval "dev.new_run(${2:+\"$2\"})"
    ;;
  state)
    remote_eval "dev.state()"
    ;;
  *)
    sed -n '2,11p' "$0"; exit 1
    ;;
esac
