#!/usr/bin/env bash
# Dev helper for the Balatro Plus mod (macOS + Steam).
#   ./dev.sh link              symlink mod/ into Balatro's Mods folder
#   ./dev.sh run               launch Balatro with Lovely (log streams to this terminal)
#   ./dev.sh start | stop      launch in the background (waits until ready) / quit the game
#   ./dev.sh restart           stop + start
#   ./dev.sh log               show our lines + errors from the latest Lovely log
#   ./dev.sh check             syntax check + language-server diagnostics
#   ./dev.sh test [filter]     run in-game tests (mod/dev/tests); restarts the game if mod code changed
#        options: --restart (always restart first), --speed N, --stay (stay on the test profile after)
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
LAUNCH_STAMP="$REMOTE_DIR/launched_at"
GAME_PROCESS="Balatro.app/Contents/MacOS/love"

# One game, many callers: commands that talk to the game take a lock so parallel agents/terminals
# queue instead of clobbering each other's runs. Stale locks (dead holder) are taken over.
LOCK_DIR="$SAVE_DIR/bplus_dev/game.lock"
acquire_game_lock() {
  [ -n "${BPLUS_LOCK_HELD:-}" ] && return 0
  mkdir -p "$SAVE_DIR/bplus_dev"
  local waited=0
  until mkdir "$LOCK_DIR" 2>/dev/null; do
    local holder; holder="$(cat "$LOCK_DIR/pid" 2>/dev/null || true)"
    if [ -n "$holder" ] && ! kill -0 "$holder" 2>/dev/null; then
      rm -rf "$LOCK_DIR"; continue
    fi
    if [ $waited -eq 0 ]; then echo "Waiting for the game (in use by pid ${holder:-?}: $(cat "$LOCK_DIR/what" 2>/dev/null || echo '?'))..." >&2; fi
    sleep 1; waited=$((waited + 1))
    if [ $waited -gt 3600 ]; then echo "Gave up waiting for the game lock after 1h" >&2; exit 3; fi
  done
  echo $$ > "$LOCK_DIR/pid"
  echo "$*" > "$LOCK_DIR/what"
  export BPLUS_LOCK_HELD=1
  trap 'rm -rf "$LOCK_DIR"' EXIT
  trap 'rm -rf "$LOCK_DIR"; exit 130' INT TERM
}

game_running() { pgrep -f "$GAME_PROCESS" >/dev/null; }

launch() {
  cd "$GAME_DIR"
  DYLD_INSERT_LIBRARIES=liblovely.dylib ./Balatro.app/Contents/MacOS/love "$@"
}

latest_log() { echo "$LOG_DIR/$(ls -t "$LOG_DIR" | head -1)"; }

# Send Lua to the game and print the result.
# Returns 0 ok, 1 Lua error, 2 game not running / no answer within the timeout.
remote_eval() {
  local code="$1" timeout="${2:-15}" id="$$-$RANDOM"
  game_running || { echo "Game is not running (./dev.sh start)" >&2; return 2; }
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
  echo "No answer after ${timeout}s (is dev_mode on and the game past the loading screen?)" >&2
  return 2
}

# Wait until the mod's dev toolkit answers (game finished booting).
wait_ready() {
  local deadline=$((SECONDS + 120))
  while [ $SECONDS -lt $deadline ]; do
    if ! game_running; then
      echo "Game exited during startup. Errors from $(latest_log):" >&2
      grep -nE "ERROR|Oops|traceback" "$(latest_log)" | tail -20 >&2
      return 1
    fi
    [ "$(remote_eval 'BPlus.test ~= nil' 2 2>/dev/null)" = "true" ] && return 0
    sleep 1
  done
  echo "Game did not become ready within 120s" >&2
  return 1
}

start_game() {
  if game_running; then echo "Game already running"; return 0; fi
  mkdir -p "$REMOTE_DIR"
  touch "$LAUNCH_STAMP"
  (launch "$@" >/dev/null 2>&1 &)
  echo "Launching..."
  wait_ready && echo "Game ready"
}

stop_game() {
  if game_running; then
    pkill -f "$GAME_PROCESS"
    while game_running; do sleep 0.2; done
    echo "Stopped"
  else
    echo "Game was not running"
  fi
}

# Mod code changed since the game was launched? (Tests and scenarios are re-read live, so they don't count.)
code_changed_since_launch() {
  [ -f "$LAUNCH_STAMP" ] || return 1
  [ -n "$(find "$REPO/mod" -type f -newer "$LAUNCH_STAMP" \
      -not -path "$REPO/mod/dev/tests/*" -not -path "$REPO/mod/dev/scenario*" | head -1)" ]
}

run_tests() {
  local filter="" speed="" stay="false" restart="false"
  while [ $# -gt 0 ]; do
    case "$1" in
      --restart) restart="true" ;;
      --speed) speed="$2"; shift ;;
      --stay) stay="true" ;;
      *) filter="$1" ;;
    esac
    shift
  done

  if game_running && { [ "$restart" = true ] || code_changed_since_launch; }; then
    echo "Restarting the game to load current mod code..."
    stop_game >/dev/null
  fi
  if ! game_running; then
    start_game || exit 3
  elif [ ! -f "$LAUNCH_STAMP" ]; then
    echo "Note: game wasn't launched by dev.sh; can't tell if mod code is current (use --restart)."
  fi

  local id="t$$-$RANDOM" out="$REMOTE_DIR/test_out.txt"
  local lua_filter="nil"
  if [ -n "$filter" ]; then lua_filter="[[$filter]]"; fi
  if ! remote_eval "BPlus.test.run({ id = '$id', filter = $lua_filter, speed = ${speed:-nil}, stay = $stay })" 10 >/dev/null; then
    echo "Could not start the test run" >&2
    exit 3
  fi

  local printed=1 last_progress=$SECONDS total
  while true; do
    if [ -f "$out" ] && [ "$(head -1 "$out")" = "id $id" ]; then
      total=$(wc -l < "$out" | tr -d ' ')
      if [ "$total" -gt "$printed" ]; then
        sed -n "$((printed + 1)),${total}p" "$out"
        printed=$total
        last_progress=$SECONDS
      fi
      if grep -q "^== done $id PASS ==" "$out"; then exit 0; fi
      if grep -q "^== done $id FAIL ==" "$out"; then exit 1; fi
    fi
    if ! game_running; then
      echo "Game exited during the test run (crash?). Errors from $(latest_log):" >&2
      grep -nE "ERROR|Oops|traceback" "$(latest_log)" | tail -20 >&2
      exit 3
    fi
    if [ $((SECONDS - last_progress)) -gt 180 ]; then
      echo "No test progress for 180s; the game may be on a crash screen or hung. Errors from $(latest_log):" >&2
      grep -nE "ERROR|Oops|traceback" "$(latest_log)" | tail -20 >&2
      exit 3
    fi
    sleep 0.2
  done
}

case "${1:-}" in
  run|start|stop|restart|test|eval|scenario|state) acquire_game_lock "$@" ;;
esac

case "${1:-}" in
  link)
    target="$MODS_DIR/$MOD_NAME"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$REPO/mod" ]; then echo "Already linked: $target -> $REPO/mod"
    elif [ -e "$target" ] && [ ! -L "$target" ]; then echo "Error: $target exists and is not a symlink" >&2; exit 1
    else ln -sfn "$REPO/mod" "$target" && echo "Linked $target -> $REPO/mod"; fi
    ;;
  run)
    mkdir -p "$REMOTE_DIR"; touch "$LAUNCH_STAMP"
    launch "${@:2}"
    ;;
  start) start_game "${@:2}" ;;
  stop) stop_game ;;
  restart) stop_game; start_game "${@:2}" ;;
  log)
    echo "== $(latest_log)"
    grep -nE "BalatroPlus|BPlus\.dev|ERROR|WARN|Oops|stack traceback" "$(latest_log)" || echo "(no matching lines)"
    ;;
  check)
    status=0
    while IFS= read -r f; do luajit -bl "$f" >/dev/null || status=1; done < <(find "$REPO" -name '*.lua' -not -path '*/.git/*')
    lua-language-server --check "$REPO" --checklevel=Warning --logpath "${TMPDIR:-/tmp}/bplus-luals" || status=1
    exit $status
    ;;
  test) run_tests "${@:2}" ;;
  eval)
    if [ "${2:-}" = "-f" ]; then remote_eval "$(cat "$3")"; else remote_eval "${2:?usage: ./dev.sh eval '<lua>'}"; fi
    ;;
  scenario)
    name_arg="nil"; [ -n "${2:-}" ] && name_arg="\"$2\""
    remote_eval "dev.new_run($name_arg, { allow_player_profile = true })" ;;
  state) remote_eval "dev.state()" ;;
  *)
    sed -n '2,15p' "$0"; exit 1
    ;;
esac
