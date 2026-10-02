#!/usr/bin/env bash
# SessionStart hook: inject today's context into every new Claude Code session.
# Claude Code adds whatever this script prints to stdout to the session context.
# Wire it up in ~/.claude/settings.json under hooks.SessionStart (see settings.example.json).
#
# Prints (each part skipped if the file is missing):
#   1. today's date and ISO week
#   2. ~/brain/me/current-focus.md
#   3. today's daily note, or yesterday's "Tomorrow" section if today's doesn't exist yet
#   4. the last entries of log.md (what skills changed recently)
#
# Item 4 is the "structured note-taking" half of Anthropic's context-engineering advice
# (anthropic.com/engineering/effective-context-engineering-for-ai-agents): state lives in files
# outside the context window and is pulled back in. The settings matcher includes "compact", so
# after a compaction Claude gets the recent log back. PreCompact cannot do this: per the hooks
# reference its output never reaches Claude, it can only block the compaction.
#
# Override the vault location with BRAIN_DIR (env var or settings.json "env").

set -u

BRAIN_DIR="${BRAIN_DIR:-$HOME/brain}"
MAX_LINES="${BRAIN_HOOK_MAX_LINES:-80}"   # per file, keeps the injected context cheap
LOG_LINES="${BRAIN_HOOK_LOG_LINES:-10}"   # log.md entries to inject, 0 = none

# Drain stdin (Claude Code sends hook JSON); we don't need it, but don't leave the pipe open.
cat >/dev/null 2>&1 || true

[ -d "$BRAIN_DIR" ] || exit 0   # no vault, nothing to inject, never fail the session

today=$(date +%Y-%m-%d)
week=$(date +%G-W%V)
# yesterday: BSD date (macOS) first, then GNU date (Linux)
yesterday=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d yesterday +%Y-%m-%d 2>/dev/null || echo "")

tildify() { printf '%s' "$1" | sed "s|^$HOME|~|"; }

print_file() {
  local label="$1" path="$2"
  [ -f "$path" ] || return 0
  local total
  total=$(wc -l < "$path" | tr -d ' ')
  echo
  echo "## $label ($(tildify "$path"))"
  # strip YAML frontmatter to save tokens
  awk 'NR==1 && /^---$/ {fm=1; next} fm && /^---$/ {fm=0; next} !fm' "$path" | head -n "$MAX_LINES"
  if [ "$total" -gt "$MAX_LINES" ]; then
    echo "... (truncated, $total lines total — read the file for the rest)"
  fi
}

echo "# Brain context (injected by SessionStart hook)"
echo "Today is $today (ISO week $week). Vault: $(tildify "$BRAIN_DIR") — rules in CLAUDE.md there."

print_file "Current focus" "$BRAIN_DIR/me/current-focus.md"

daily="$BRAIN_DIR/daily/$today.md"
if [ -f "$daily" ]; then
  print_file "Today's daily note" "$daily"
else
  echo
  echo "## Today's daily note"
  echo "Not created yet ($(tildify "$daily")). Run the morning-brief skill or create it from templates/daily.md."
  if [ -n "$yesterday" ] && [ -f "$BRAIN_DIR/daily/$yesterday.md" ]; then
    carry=$(awk '/^## Tomorrow/{f=1; next} /^## /{f=0} f' "$BRAIN_DIR/daily/$yesterday.md" | grep -v '^[[:space:]]*$' | head -n 20)
    if [ -n "$carry" ]; then
      echo
      echo "### Carried over from $yesterday"
      echo "$carry"
    fi
  fi
fi

log_file="$BRAIN_DIR/log.md"
if [ "$LOG_LINES" -gt 0 ] 2>/dev/null && [ -f "$log_file" ]; then
  recent=$(grep -E '^- [0-9]{4}-[0-9]{2}-[0-9]{2} ' "$log_file" | tail -n "$LOG_LINES")
  if [ -n "$recent" ]; then
    echo
    echo "## Recent vault activity (last $LOG_LINES lines of $(tildify "$log_file"))"
    echo "$recent"
  fi
fi

exit 0
