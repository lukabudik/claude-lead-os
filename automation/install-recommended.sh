#!/usr/bin/env bash
# install-recommended.sh - install the "Install first" tier of third-party plugins
# from docs/11-skill-library.md. Opt-in, idempotent, dry run by default.
#
#   ./automation/install-recommended.sh             show the plan, change nothing
#   ./automation/install-recommended.sh --apply     add marketplaces + install plugins
#   ./automation/install-recommended.sh --apply --scope project
#                                                   install into ./.claude/settings.json
#                                                   of the current directory (run it
#                                                   from your vault) instead of ~/.claude
#
# What it installs (Anthropic-maintained, no hooks, no MCP servers):
#   document-skills@anthropic-agent-skills       docx / pptx / xlsx / pdf
#   skill-creator@claude-plugins-official        write, test and benchmark skills
#   claude-md-management@claude-plugins-official audit CLAUDE.md, capture learnings
#
# It only calls the `claude plugin` CLI. It never copies third-party skill files into
# this repo or your vault. Already-added marketplaces and already-installed plugins
# are skipped, so re-running is safe. Read docs/11 (and each SKILL.md) first.

set -euo pipefail

CLAUDE_BIN="${CLAUDE_BIN:-claude}"
APPLY=0
SCOPE="user"

usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1 ;;
    --dry-run) APPLY=0 ;;
    --scope)
      [[ $# -ge 2 ]] || { echo "--scope needs user|project|local" >&2; exit 1; }
      SCOPE="$2"
      shift
      ;;
    --scope=*) SCOPE="${1#*=}" ;;
    -h | --help) usage; exit 0 ;;
    *) echo "unknown option: $1 (try --help)" >&2; exit 1 ;;
  esac
  shift
done

case "$SCOPE" in
  user | project | local) ;;
  *) echo "invalid --scope: $SCOPE (user|project|local)" >&2; exit 1 ;;
esac

# marketplace name | GitHub owner/repo
MARKETPLACES=(
  "claude-plugins-official|anthropics/claude-plugins-official"
  "anthropic-agent-skills|anthropics/skills"
)

# plugin@marketplace
PLUGINS=(
  "document-skills@anthropic-agent-skills"
  "skill-creator@claude-plugins-official"
  "claude-md-management@claude-plugins-official"
)

# --- output helpers -----------------------------------------------------------
if [[ -t 1 ]]; then
  B=$'\033[1m' G=$'\033[32m' Y=$'\033[33m' D=$'\033[2m' R=$'\033[0m'
else
  B="" G="" Y="" D="" R=""
fi
ok() { printf '  %sok%s       %s\n' "$G" "$R" "$*"; }
skip() { printf '  %sskip%s     %s\n' "$D" "$R" "$*"; }
plan() { printf '  %swould run%s %s\n' "$Y" "$R" "$*"; }
warn() { printf '  %swarn%s     %s\n' "$Y" "$R" "$*" >&2; }
section() { printf '\n%s%s%s\n' "$B" "$*" "$R"; }

# --- preflight ----------------------------------------------------------------
HAVE_CLAUDE=1
if ! command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
  HAVE_CLAUDE=0
  if [[ $APPLY -eq 1 ]]; then
    echo "claude CLI not found (set CLAUDE_BIN or install Claude Code first)" >&2
    exit 1
  fi
  warn "claude CLI not found; showing the plan without checking what is installed"
fi

MARKETS_JSON=""
PLUGINS_JSON=""
if [[ $HAVE_CLAUDE -eq 1 ]]; then
  MARKETS_JSON="$("$CLAUDE_BIN" plugin marketplace list --json 2>/dev/null || true)"
  PLUGINS_JSON="$("$CLAUDE_BIN" plugin list --json 2>/dev/null || true)"
fi

has_marketplace() { grep -Eq "\"name\": *\"$1\"" <<<"$MARKETS_JSON"; }
has_plugin() { grep -Eq "\"id\": *\"$1\"" <<<"$PLUGINS_JSON"; }

if [[ $APPLY -eq 1 ]]; then
  printf '%sInstalling the "Install first" tier (scope: %s)%s\n' "$B" "$SCOPE" "$R"
else
  printf '%sDry run: nothing will change. Re-run with --apply to install (scope: %s).%s\n' "$B" "$SCOPE" "$R"
fi

# --- marketplaces -------------------------------------------------------------
section "Marketplaces"
for entry in "${MARKETPLACES[@]}"; do
  name="${entry%%|*}"
  repo="${entry#*|}"
  if has_marketplace "$name"; then
    skip "$name (already added)"
    continue
  fi
  if [[ $APPLY -eq 0 ]]; then
    plan "$CLAUDE_BIN plugin marketplace add $repo --scope $SCOPE"
    continue
  fi
  # owner/repo clones over SSH when git is set up for it; fall back to HTTPS.
  if "$CLAUDE_BIN" plugin marketplace add "$repo" --scope "$SCOPE"; then
    ok "$name"
  elif "$CLAUDE_BIN" plugin marketplace add "https://github.com/${repo}.git" --scope "$SCOPE"; then
    ok "$name (via HTTPS)"
  else
    echo "failed to add marketplace $name ($repo)" >&2
    exit 1
  fi
done

# --- plugins ------------------------------------------------------------------
section "Plugins"
for id in "${PLUGINS[@]}"; do
  if has_plugin "$id"; then
    skip "$id (already installed)"
    continue
  fi
  if [[ $APPLY -eq 0 ]]; then
    plan "$CLAUDE_BIN plugin install $id --scope $SCOPE"
    continue
  fi
  if "$CLAUDE_BIN" plugin install "$id" --scope "$SCOPE"; then
    ok "$id"
  else
    echo "failed to install $id" >&2
    exit 1
  fi
done

# --- next steps ---------------------------------------------------------------
section "Next"
if [[ $APPLY -eq 1 ]]; then
  echo "  Restart Claude Code, or run /reload-plugins in an open session."
  echo "  Check token cost: $CLAUDE_BIN plugin details <plugin@marketplace>"
else
  echo "  Inside a Claude Code session the same steps are:"
  for entry in "${MARKETPLACES[@]}"; do
    echo "    /plugin marketplace add ${entry#*|}"
  done
  for id in "${PLUGINS[@]}"; do
    echo "    /plugin install $id"
  done
fi
echo "  Other tiers are opt-in, one at a time: see docs/11-skill-library.md"
