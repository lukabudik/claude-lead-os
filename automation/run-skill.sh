#!/usr/bin/env bash
# run-skill.sh - run one Claude Code skill headless, safely, on a schedule.
#
#   run-skill.sh <skill-name> [extra prompt...]
#
# What it does:
#   - cd into $BRAIN_DIR (your vault), so the vault CLAUDE.md and .memory load
#   - takes a per-skill lock (a second run of the same skill is skipped, exit 0)
#   - keeps a Mac awake while it runs (caffeinate -i)
#   - runs `claude -p "/<skill> ..."` in dontAsk mode with a scoped tool allowlist
#   - caps turns, dollars and wall-clock time
#   - logs to $BRAIN_DIR/.logs/<skill>-<YYYY-MM-DD>.log
#   - raises a desktop notification on failure
#
# Configuration: env vars, or ~/.config/claude-lead-os/env (written by install.sh).
# Write the file as `: "${VAR:=value}"` lines so an explicit env var still wins.
#   BRAIN_DIR          vault path                          (default: ~/brain)
#   CLAUDE_BIN         claude executable                   (default: first on PATH)
#   CLO_MAX_TURNS      --max-turns                         (default: 40)
#   CLO_MAX_BUDGET     --max-budget-usd per run            (default: 3.00)
#   CLO_TIMEOUT        wall-clock seconds before kill      (default: 1800)
#   CLO_MODEL          --model alias, empty = your default (default: empty)
#   CLO_TOOLS_DIR      dir with allowlist files            (default: <repo>/automation/allowed-tools)
#   CLO_NOTIFY         1 = notify on failure, 0 = silent   (default: 1)
#
# Exit codes: 0 ok or skipped (lock held), 1 usage/setup error, 124 timeout,
# otherwise the exit code of claude.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# launchd and cron start with a near-empty PATH. Add the usual install spots.
export PATH="${HOME}/.local/bin:${HOME}/.claude/local:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

CONFIG_FILE="${CLO_CONFIG:-${HOME}/.config/claude-lead-os/env}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
fi

usage() {
  echo "usage: $(basename "$0") <skill-name> [extra prompt...]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
SKILL="$1"
shift
EXTRA="$*"

# Skill names are kebab-case; refuse anything else so the name is safe in paths.
if [[ ! "$SKILL" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "invalid skill name: $SKILL" >&2
  exit 1
fi

BRAIN_DIR="${BRAIN_DIR:-${HOME}/brain}"
CLAUDE_BIN="${CLAUDE_BIN:-$(command -v claude || true)}"
MAX_TURNS="${CLO_MAX_TURNS:-40}"
MAX_BUDGET="${CLO_MAX_BUDGET:-3.00}"
TIMEOUT_SECS="${CLO_TIMEOUT:-1800}"
MODEL="${CLO_MODEL:-}"
TOOLS_DIR="${CLO_TOOLS_DIR:-${SCRIPT_DIR}/allowed-tools}"
NOTIFY="${CLO_NOTIFY:-1}"

LOG_DIR="${BRAIN_DIR}/.logs"
TODAY="$(date +%Y-%m-%d)"
LOG_FILE="${LOG_DIR}/${SKILL}-${TODAY}.log"
LOCK_DIR="${TMPDIR:-/tmp}/claude-lead-os.${SKILL}.lock"

notify() {
  # notify <title> <message>
  [[ "$NOTIFY" == "1" ]] || return 0
  local title="$1" msg="$2"
  if [[ "$(uname -s)" == "Darwin" ]] && command -v osascript >/dev/null 2>&1; then
    # Pass text as argv so quotes in the message cannot break the AppleScript.
    osascript - "$title" "$msg" >/dev/null 2>&1 <<'APPLESCRIPT' || true
on run argv
  display notification (item 2 of argv) with title (item 1 of argv)
end run
APPLESCRIPT
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$msg" || true
  fi
}

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
}

fail_setup() {
  echo "$1" >&2
  notify "claude-lead-os: ${SKILL} not started" "$1"
  exit 1
}

[[ -d "$BRAIN_DIR" ]] || fail_setup "BRAIN_DIR does not exist: $BRAIN_DIR"
[[ -n "$CLAUDE_BIN" && -x "$CLAUDE_BIN" ]] || fail_setup "claude CLI not found on PATH (set CLAUDE_BIN)"
mkdir -p "$LOG_DIR"

# --- lock: mkdir is atomic on every POSIX filesystem -------------------------
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  old_pid="$(cat "${LOCK_DIR}/pid" 2>/dev/null || true)"
  if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
    log "skip: ${SKILL} already running (pid ${old_pid})"
    exit 0
  fi
  # Stale lock from a crashed run: take it over.
  rm -rf "$LOCK_DIR"
  mkdir "$LOCK_DIR" || { log "skip: could not acquire lock"; exit 0; }
fi
echo "$$" >"${LOCK_DIR}/pid"

CLAUDE_PID=""
WATCHDOG_PID=""
CAFFEINATE_PID=""
stop_watchdog() {
  [[ -n "$WATCHDOG_PID" ]] || return 0
  pkill -P "$WATCHDOG_PID" 2>/dev/null || true # its sleep child
  kill "$WATCHDOG_PID" 2>/dev/null || true
  WATCHDOG_PID=""
}
# shellcheck disable=SC2329 # invoked by trap
cleanup() {
  stop_watchdog
  [[ -n "$CAFFEINATE_PID" ]] && kill "$CAFFEINATE_PID" 2>/dev/null || true
  [[ -n "$CLAUDE_PID" ]] && kill -TERM "$CLAUDE_PID" 2>/dev/null || true
  rm -rf "$LOCK_DIR"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# --- keep the Mac awake for the duration of this script ----------------------
if command -v caffeinate >/dev/null 2>&1; then
  caffeinate -i -w "$$" &
  CAFFEINATE_PID=$!
fi

# --- tool allowlist: _base.txt + <skill>.txt, one rule per line, # comments --
read_rules() {
  local file="$1" line
  [[ -f "$file" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -n "$line" ]] && printf '%s\n' "$line"
  done <"$file"
}

ALLOWED=()
while IFS= read -r rule; do ALLOWED+=("$rule"); done < <(read_rules "${TOOLS_DIR}/_base.txt"; read_rules "${TOOLS_DIR}/${SKILL}.txt")
DENIED=()
while IFS= read -r rule; do DENIED+=("$rule"); done < <(read_rules "${TOOLS_DIR}/_deny.txt")

# --- build the command --------------------------------------------------------
PROMPT="/${SKILL}"
[[ -n "$EXTRA" ]] && PROMPT="${PROMPT} ${EXTRA}"

UNATTENDED_NOTE="This is an unattended scheduled run started by run-skill.sh on ${TODAY}. \
Nobody is watching: do not ask questions, make the reasonable choice and note it in the output file. \
Never send messages, emails or comments on anyone's behalf; create drafts only. \
If a connector is unavailable or unauthenticated, write what you could do, list what was skipped, and finish."

CMD=("$CLAUDE_BIN" -p "$PROMPT"
  --permission-mode dontAsk
  --permission-prompts none
  --max-turns "$MAX_TURNS"
  --max-budget-usd "$MAX_BUDGET"
  --append-system-prompt "$UNATTENDED_NOTE"
  --output-format text)
[[ -n "$MODEL" ]] && CMD+=(--model "$MODEL")
[[ ${#ALLOWED[@]} -gt 0 ]] && CMD+=(--allowedTools "${ALLOWED[@]}")
[[ ${#DENIED[@]} -gt 0 ]] && CMD+=(--disallowedTools "${DENIED[@]}")

# --- run ----------------------------------------------------------------------
cd "$BRAIN_DIR"

# Fail fast (and loudly) if the CLI is logged out, instead of a silent empty run.
if ! "$CLAUDE_BIN" auth status >/dev/null 2>&1; then
  log "FAIL: claude is not logged in (run: claude auth login)"
  notify "claude-lead-os: ${SKILL} not run" "Claude Code is logged out. Run: claude auth login"
  exit 1
fi
log "start: ${SKILL} (turns<=${MAX_TURNS}, budget<=\$${MAX_BUDGET}, timeout=${TIMEOUT_SECS}s)"
log "allow: ${ALLOWED[*]:-<none>}"
start_ts=$(date +%s)

# stdin from /dev/null: -p must not wait on a terminal that is not there.
"${CMD[@]}" </dev/null >>"$LOG_FILE" 2>&1 &
CLAUDE_PID=$!

# Portable timeout (macOS ships no `timeout`): a watchdog sends SIGINT first so
# claude can end the turn cleanly, then SIGTERM.
(
  exec 2>/dev/null # no "Terminated" noise when the watchdog is cancelled
  sleep "$TIMEOUT_SECS"
  if kill -0 "$CLAUDE_PID" 2>/dev/null; then
    echo "[watchdog] timeout after ${TIMEOUT_SECS}s, interrupting" >>"$LOG_FILE"
    kill -INT "$CLAUDE_PID" 2>/dev/null || true
    sleep 20
    kill -TERM "$CLAUDE_PID" 2>/dev/null || true
    touch "${LOCK_DIR}/timed-out"
  fi
) &
WATCHDOG_PID=$!

set +e
wait "$CLAUDE_PID"
rc=$?
set -e
CLAUDE_PID=""
stop_watchdog

[[ -f "${LOCK_DIR}/timed-out" ]] && rc=124
elapsed=$(($(date +%s) - start_ts))

if [[ $rc -eq 0 ]]; then
  log "done: ${SKILL} ok in ${elapsed}s"
else
  log "FAIL: ${SKILL} exit=${rc} after ${elapsed}s"
  notify "claude-lead-os: ${SKILL} failed (exit ${rc})" "See ${LOG_FILE}"
fi
exit "$rc"
