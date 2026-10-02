#!/usr/bin/env bash
# Claude Code status line: model | directory | git branch (* if dirty)
# Claude Code pipes session JSON to stdin and shows the first line of stdout.
# Wire it up in ~/.claude/settings.json: "statusLine": {"type": "command", "command": "bash ~/.claude/statusline.sh"}

input=$(cat)

json_get() {
  # $1 = jq filter. Falls back to python3 if jq isn't installed.
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$input" | python3 -c '
import json, sys
path = sys.argv[1].lstrip(".").split(".")
try:
    d = json.load(sys.stdin)
    for p in path:
        d = d[p]
    print(d)
except Exception:
    pass' "$1"
  fi
}

model=$(json_get '.model.display_name')
cwd=$(json_get '.workspace.current_dir')
[ -z "$cwd" ] && cwd=$(json_get '.cwd')
[ -z "$cwd" ] && cwd="$PWD"

dir=$(basename "$cwd")
[ "$cwd" = "$HOME" ] && dir="~"

branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
if [ -n "$branch" ] && [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -n 1)" ]; then
  branch="${branch}*"
fi

DIM='\033[2m'; CYAN='\033[36m'; YELLOW='\033[33m'; RESET='\033[0m'

line="${DIM}${model:-claude}${RESET} ${DIM}|${RESET} ${CYAN}${dir}${RESET}"
[ -n "$branch" ] && line="${line} ${DIM}|${RESET} ${YELLOW}${branch}${RESET}"

printf '%b\n' "$line"
