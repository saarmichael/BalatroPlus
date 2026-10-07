#!/usr/bin/env bash
# Commit only the given paths, serialised between parallel agents (one shared working tree).
#   tools/commit.sh "joker: j_x -> j_bplus_x_plus" mod/src/jokers/j_bplus_x_plus.lua mod/dev/tests/jokers/j_x.lua
set -euo pipefail
cd "$(dirname "$0")/.."
msg="$1"; shift
[ $# -gt 0 ] || { echo "usage: tools/commit.sh <message> <paths...>" >&2; exit 1; }
LOCK=".git/bplus-commit.lock"
until mkdir "$LOCK" 2>/dev/null; do sleep 0.5; done
trap 'rmdir "$LOCK"' EXIT
git add -- "$@"
git commit -q -m "$msg" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -- "$@"
git log -1 --oneline
