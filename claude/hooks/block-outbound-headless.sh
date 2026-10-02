#!/usr/bin/env bash
# PreToolUse hook: in unattended runs, deny every tool that can send data out.
#
# Why: Simon Willison's "lethal trifecta" (simonwillison.net/2025/Jun/16/the-lethal-trifecta/).
# An agent with (1) private data, (2) untrusted input and (3) a way to communicate externally
# can be prompt-injected into leaking (1) through (3). A scheduled run reads your vault (1) and
# Slack/email/transcripts (2), and nobody is watching. This hook removes leg (3) for those runs.
# Interactive sessions are untouched: there, send-actions stay on "ask" in permissions.
#
# Active only when CLO_HEADLESS=1 (automation/run-skill.sh sets it). Otherwise it exits 0
# silently and the normal permission flow applies.
#
# Contract (code.claude.com/docs/en/hooks, PreToolUse): JSON on stdin with tool_name and
# tool_input; to block, exit 0 and print
#   {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny",
#    "permissionDecisionReason":"..."}}
# The reason is shown to Claude, so it can finish the run with a draft instead.
#
# Configure with env vars (extended regex, matched case-insensitively):
#   CLO_OUTBOUND_TOOL_REGEX   tool names to deny
#   CLO_OUTBOUND_ALLOW_REGEX  tool names exempt from the deny list (default: drafts)
#   CLO_OUTBOUND_BASH_REGEX   Bash commands to deny (network clients, gh writes)
#   CLO_OUTBOUND_LOG          where blocked calls are logged (default $BRAIN_DIR/.logs/outbound-blocked.log)
#
# Test:
#   echo '{"tool_name":"mcp__claude_ai_Slack__slack_send_message","tool_input":{}}' \
#     | CLO_HEADLESS=1 bash block-outbound-headless.sh

set -u

[ "${CLO_HEADLESS:-0}" = "1" ] || exit 0

# Tool-name tokens are separated by "_" in MCP names (mcp__<server>__<tool>), so "send" matches
# slack_send_message and gmail send_message but not "sender_lookup" or "list_comments".
DEFAULT_TOOL_REGEX='^(WebFetch|WebSearch)$|(^|_)(send|post|reply|forward|schedule|share|unshare|publish|invite|upload|respond|comment)(_|$)|(create|update)_event|(save|create|add)_comment|save_issue|create_issue'
DEFAULT_ALLOW_REGEX='(^|_)draft(s)?(_|$)'
DEFAULT_BASH_REGEX='(^|[;&|(`[:space:]])(curl|wget|nc|ncat|netcat|ssh|scp|sftp|rsync|ftp|telnet|socat)([[:space:]]|$)|gh[[:space:]]+(pr|issue|release|gist)[[:space:]]+(create|comment|edit|close|merge|review)|gh[[:space:]]+api|git[[:space:]]+push|osascript'

TOOL_REGEX="${CLO_OUTBOUND_TOOL_REGEX:-$DEFAULT_TOOL_REGEX}"
ALLOW_REGEX="${CLO_OUTBOUND_ALLOW_REGEX:-$DEFAULT_ALLOW_REGEX}"
BASH_REGEX="${CLO_OUTBOUND_BASH_REGEX:-$DEFAULT_BASH_REGEX}"
LOG_FILE="${CLO_OUTBOUND_LOG:-${BRAIN_DIR:-$HOME/brain}/.logs/outbound-blocked.log}"

payload="$(cat)"

# Extract tool_name and, for Bash, tool_input.command. jq if present, else python3, else a
# sed fallback for the name and the raw payload for the command (errs on the side of denying).
tool_name=""
command=""
if command -v jq >/dev/null 2>&1; then
  tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null)"
  command="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1; then
  tool_name="$(printf '%s' "$payload" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("tool_name",""))
except Exception: pass' 2>/dev/null)"
  command="$(printf '%s' "$payload" | python3 -c 'import json,sys
try: print((json.load(sys.stdin).get("tool_input") or {}).get("command",""))
except Exception: pass' 2>/dev/null)"
else
  tool_name="$(printf '%s' "$payload" | tr -d '\n' | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  # Greedy: everything from the command value to the last quote. May include later fields,
  # which can only cause an extra deny, never a missed one.
  command="$(printf '%s' "$payload" | tr -d '\n' | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')"
  [ -n "$command" ] || command="$payload"
fi

deny() {
  local reason="$1"
  if mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null; then
    printf '%s denied %s: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${tool_name:-?}" "$reason" >>"$LOG_FILE" 2>/dev/null || true
  fi
  # Reasons are fixed strings plus a tool name; strip quotes/backslashes so the JSON stays valid.
  reason="$(printf '%s' "$reason" | tr -d "\"\\\\")"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
}

[ -n "$tool_name" ] || exit 0

if [ "$tool_name" = "Bash" ]; then
  if printf '%s' "$command" | grep -Eiq -- "$BASH_REGEX"; then
    deny "Unattended run (CLO_HEADLESS=1): outbound shell command blocked by block-outbound-headless.sh. Write what you would have sent into the vault as a draft instead."
  fi
  exit 0
fi

if printf '%s' "$tool_name" | grep -Eiq -- "$TOOL_REGEX"; then
  if [ -n "$ALLOW_REGEX" ] && printf '%s' "$tool_name" | grep -Eiq -- "$ALLOW_REGEX"; then
    exit 0
  fi
  deny "Unattended run (CLO_HEADLESS=1): ${tool_name} can send data outside the vault and is blocked by block-outbound-headless.sh. Write a draft into the vault instead and list it in the report."
fi

exit 0
