#!/usr/bin/env bash
# install.sh - set up claude-lead-os on this machine. Safe to re-run.
#
#   ./install.sh                     interactive install, vault at ~/brain
#   ./install.sh --brain-dir ~/notes use another vault location (or BRAIN_DIR=...)
#   ./install.sh --with-launchd      also schedule the daily/weekly runs (macOS)
#   ./install.sh --dry-run           print what would happen, change nothing
#   ./install.sh --yes               no questions, accept defaults
#
# It never overwrites a file you already have:
#   vault files      copied only if missing
#   skills           symlinked into ~/.claude/skills (existing names left alone)
#   rules, agents,   copied if missing, otherwise written next to yours as
#   commands, hooks  *.example (CLAUDE.md: CLAUDE.lead-os.md); a custom vault
#                    path replaces ~/brain in the copies
#   settings.json    never touched; merge instructions are printed instead

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
CONFIG_DIR="${HOME}/.config/claude-lead-os"

DRY_RUN=0
WITH_LAUNCHD=0
ASSUME_YES=0
BRAIN_ARG=""

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --with-launchd) WITH_LAUNCHD=1 ;;
    --yes | -y) ASSUME_YES=1 ;;
    --brain-dir)
      [[ $# -ge 2 ]] || { echo "--brain-dir needs a path" >&2; exit 1; }
      BRAIN_ARG="$2"
      shift
      ;;
    --brain-dir=*) BRAIN_ARG="${1#*=}" ;;
    -h | --help) usage; exit 0 ;;
    *) echo "unknown option: $1 (try --help)" >&2; exit 1 ;;
  esac
  shift
done

# --- output helpers -----------------------------------------------------------
if [[ -t 1 ]]; then
  B=$'\033[1m' G=$'\033[32m' Y=$'\033[33m' D=$'\033[2m' R=$'\033[0m'
else
  B="" G="" Y="" D="" R=""
fi
say() { printf '%s\n' "$*"; }
ok() { printf '  %sok%s    %s\n' "$G" "$R" "$*"; }
skip() { printf '  %sskip%s  %s\n' "$D" "$R" "$*"; }
warn() { printf '  %swarn%s  %s\n' "$Y" "$R" "$*"; }
section() { printf '\n%s%s%s\n' "$B" "$*" "$R"; }

# run <cmd...>: execute, or just print it in dry-run mode.
run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '  %sdry-run%s %s\n' "$Y" "$R" "$*"
  else
    "$@"
  fi
}

tildify() {
  # print a path with $HOME shown as ~
  # shellcheck disable=SC2088 # a literal ~ is the point here
  case "$1" in
    "$HOME"/*) printf '~/%s' "${1#"$HOME"/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

expand_path() {
  # expand a leading ~ without eval
  local p="$1"
  # shellcheck disable=SC2088 # matching a literal ~ typed by the user
  case "$p" in
    "~") p="$HOME" ;;
    "~/"*) p="${HOME}/${p#"~/"}" ;;
  esac
  printf '%s' "$p"
}

# --- 1. prerequisites ---------------------------------------------------------
section "1. Prerequisites"
if command -v claude >/dev/null 2>&1; then
  ok "claude CLI: $(claude --version 2>/dev/null | head -n1)"
else
  warn "claude CLI not found. Install it first: https://code.claude.com/docs/en/setup"
  [[ $DRY_RUN -eq 1 ]] || exit 1
fi
[[ $DRY_RUN -eq 1 ]] && say "  ${Y}Dry run: nothing will be changed.${R}"

# --- 2. vault location --------------------------------------------------------
section "2. Vault"
DEFAULT_BRAIN="${BRAIN_ARG:-${BRAIN_DIR:-${HOME}/brain}}"
BRAIN="$DEFAULT_BRAIN"
if [[ -z "$BRAIN_ARG" && $ASSUME_YES -eq 0 && -t 0 ]]; then
  read -r -p "  Where should your knowledge base live? [${DEFAULT_BRAIN}] " answer || true
  BRAIN="${answer:-$DEFAULT_BRAIN}"
fi
BRAIN="$(expand_path "$BRAIN")"
case "$BRAIN" in
  /*) ;;
  *) BRAIN="$(pwd)/${BRAIN}" ;;
esac
say "  vault: ${BRAIN}"

run mkdir -p "$BRAIN" "${BRAIN}/.logs"

# The repo's config files assume the vault is at ~/brain. If you chose another
# path, installed copies get that path substituted.
BRAIN_TILDE="$(tildify "$BRAIN")"
CUSTOM_BRAIN=0
[[ "$BRAIN" == "${HOME}/brain" ]] || CUSTOM_BRAIN=1
TMP_RENDER="$(mktemp -d)"
trap 'rm -rf "$TMP_RENDER"' EXIT

# render <src>: print the path of a copy with ~/brain replaced (or src itself)
render() {
  local src="$1" out
  if [[ $CUSTOM_BRAIN -eq 0 ]]; then
    printf '%s' "$src"
    return
  fi
  out="${TMP_RENDER}/$(basename "$src")"
  sed -E "s#~/brain([^A-Za-z0-9_-]|\$)#${BRAIN_TILDE}\1#g" "$src" >"$out"
  printf '%s' "$out"
}


copied=0
kept=0
while IFS= read -r -d '' src; do
  rel="${src#"${REPO_DIR}/vault/"}"
  dest="${BRAIN}/${rel}"
  if [[ -e "$dest" ]]; then
    kept=$((kept + 1))
    continue
  fi
  run mkdir -p "$(dirname "$dest")"
  case "$src" in
    *.md | *.json) run cp "$(render "$src")" "$dest" ;;
    *) run cp -p "$src" "$dest" ;;
  esac
  copied=$((copied + 1))
done < <(find "${REPO_DIR}/vault" -type f ! -name '.DS_Store' -print0)
ok "vault template: ${copied} file(s) added, ${kept} existing file(s) kept"

# --- 3. skills ----------------------------------------------------------------
section "3. Skills -> ${CLAUDE_HOME}/skills"
run mkdir -p "${CLAUDE_HOME}/skills"
for dir in "${REPO_DIR}"/skills/*/; do
  [[ -f "${dir}SKILL.md" ]] || continue
  name="$(basename "$dir")"
  target="${CLAUDE_HOME}/skills/${name}"
  src="${dir%/}"
  if [[ -L "$target" ]]; then
    if [[ "$(readlink "$target")" == "$src" ]]; then
      skip "${name} (already linked)"
    else
      warn "${name}: ${target} links elsewhere ($(readlink "$target")), left alone"
    fi
  elif [[ -e "$target" ]]; then
    warn "${name}: ${target} exists and is not ours, left alone"
  else
    run ln -s "$src" "$target"
    ok "${name}"
  fi
done

# --- 4. user-level config -----------------------------------------------------
section "4. User config -> ${CLAUDE_HOME}"

# install_file <src> <dest> [conflict-dest]
#   copy if dest is missing; skip if identical; otherwise write conflict-dest
#   (default <dest>.example) and ask the user to merge. Never overwrites dest.
install_file() {
  local src dest="$2" alt="${3:-$2.example}"
  src="$(render "$1")"
  if [[ ! -e "$dest" ]]; then
    run mkdir -p "$(dirname "$dest")"
    run cp "$src" "$dest"
    ok "$(tildify "$dest")"
  elif cmp -s "$src" "$dest"; then
    skip "$(tildify "$dest") (identical)"
  else
    run cp "$src" "$alt"
    warn "$(tildify "$dest") exists; ours saved as $(basename "$alt") - merge by hand"
  fi
}

# install_dir <subdir>: claude/<subdir>/* -> ~/.claude/<subdir>/ (agents, commands, rules)
install_dir() {
  local sub="$1" f
  [[ -d "${REPO_DIR}/claude/${sub}" ]] || return 0
  for f in "${REPO_DIR}/claude/${sub}"/*.md; do
    [[ -e "$f" ]] || continue
    install_file "$f" "${CLAUDE_HOME}/${sub}/$(basename "$f")"
  done
}

install_dir rules
install_dir agents
install_dir commands

if [[ -f "${REPO_DIR}/claude/CLAUDE.md" ]]; then
  install_file "${REPO_DIR}/claude/CLAUDE.md" "${CLAUDE_HOME}/CLAUDE.md" "${CLAUDE_HOME}/CLAUDE.lead-os.md"
fi

if [[ -d "${REPO_DIR}/claude/hooks" ]]; then
  for f in "${REPO_DIR}"/claude/hooks/*; do
    [[ -f "$f" ]] || continue
    install_file "$f" "${CLAUDE_HOME}/hooks/$(basename "$f")"
    [[ $DRY_RUN -eq 1 ]] || chmod +x "${CLAUDE_HOME}/hooks/$(basename "$f")" 2>/dev/null || true
  done
fi

if [[ -f "${REPO_DIR}/claude/statusline.sh" ]]; then
  install_file "${REPO_DIR}/claude/statusline.sh" "${CLAUDE_HOME}/statusline.sh"
  [[ $DRY_RUN -eq 1 ]] || chmod +x "${CLAUDE_HOME}/statusline.sh" 2>/dev/null || true
fi

# A settings example with your vault path filled in, for the manual merge below.
# This file is ours (~/.config/claude-lead-os), so it is refreshed on every run.
SETTINGS_EXAMPLE="${REPO_DIR}/claude/settings.example.json"
if [[ -f "$SETTINGS_EXAMPLE" ]]; then
  run mkdir -p "$CONFIG_DIR"
  run cp "$(render "$SETTINGS_EXAMPLE")" "${CONFIG_DIR}/settings.example.json"
  SETTINGS_EXAMPLE="${CONFIG_DIR}/settings.example.json"
  ok "$(tildify "$SETTINGS_EXAMPLE") (vault path: ${BRAIN_TILDE})"
  if [[ "$BRAIN_TILDE" == /* ]]; then
    warn "vault is outside \$HOME: permission rules need the //absolute form, e.g. Edit(/${BRAIN}/**). Fix those lines when merging."
  fi
fi

# Remember BRAIN_DIR for run-skill.sh, hooks and statusline. `:=` keeps an
# explicitly exported BRAIN_DIR in charge.
ENV_FILE="${CONFIG_DIR}/env"
if [[ -f "$ENV_FILE" ]]; then
  skip "$(tildify "$ENV_FILE") (exists)"
else
  run mkdir -p "$CONFIG_DIR"
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '  %sdry-run%s write %s with BRAIN_DIR=%s\n' "$Y" "$R" "$ENV_FILE" "$BRAIN"
  else
    # shellcheck disable=SC2016 # the file must contain literal ${VAR:=...}
    {
      echo "# claude-lead-os settings, sourced by automation/run-skill.sh"
      echo "# Use the := form so an explicitly exported variable still wins."
      printf ': "${BRAIN_DIR:=%s}"\n' "$BRAIN"
      echo '# : "${CLO_MAX_TURNS:=40}"'
      echo '# : "${CLO_MAX_BUDGET:=3.00}"'
      echo '# : "${CLO_MODEL:=sonnet}"'
    } >"$ENV_FILE"
    ok "$(tildify "$ENV_FILE")"
  fi
fi

# --- 5. scheduling (optional) -------------------------------------------------
section "5. Scheduling"
if [[ $WITH_LAUNCHD -eq 1 ]]; then
  if [[ "$(uname -s)" != "Darwin" ]]; then
    warn "--with-launchd is macOS only. On Linux use automation/cron/crontab.example"
  else
    AGENTS_DIR="${HOME}/Library/LaunchAgents"
    DOMAIN="gui/$(id -u)"
    run mkdir -p "$AGENTS_DIR"
    for tpl in "${REPO_DIR}"/automation/launchd/*.plist; do
      label="$(basename "$tpl" .plist)"
      dest="${AGENTS_DIR}/${label}.plist"
      if [[ $DRY_RUN -eq 1 ]]; then
        printf '  %sdry-run%s render %s -> %s, then launchctl bootstrap %s\n' "$Y" "$R" "$(basename "$tpl")" "$dest" "$DOMAIN"
        continue
      fi
      tmp="$(mktemp)"
      sed -e "s|__HOME__|${HOME}|g" -e "s|__REPO__|${REPO_DIR}|g" -e "s|__BRAIN_DIR__|${BRAIN}|g" "$tpl" >"$tmp"
      plutil -lint -s "$tmp" >/dev/null || { warn "${label}: rendered plist invalid, skipped"; rm -f "$tmp"; continue; }
      # Re-running replaces the job: unload the old definition first.
      launchctl bootout "${DOMAIN}/${label}" 2>/dev/null || true
      mv "$tmp" "$dest"
      chmod 644 "$dest"
      if launchctl bootstrap "$DOMAIN" "$dest"; then
        ok "${label} scheduled"
      else
        warn "${label}: launchctl bootstrap failed; try: launchctl bootstrap ${DOMAIN} ${dest}"
      fi
    done
    say "  Test now:  launchctl kickstart ${DOMAIN}/com.claude-lead-os.morning"
    say "  Logs:      ${BRAIN}/.logs/"
  fi
else
  skip "no scheduler installed (re-run with --with-launchd, or see automation/routines.md)"
fi

# --- 6. what is left for you --------------------------------------------------
section "6. Finish by hand"
cat <<EOF
  a) Merge settings. Your $(tildify "$CLAUDE_HOME")/settings.json was not touched.
     Open both files and copy over the keys you want:
       ${SETTINGS_EXAMPLE}
     The important ones: "permissions" (allow read tools, deny secrets and send
     tools), "hooks" (SessionStart context), "statusLine", "autoMemoryDirectory".
     Also add  "env": { "BRAIN_DIR": "${BRAIN}" }  so hooks and the statusline
     find your vault.
     Check the result with:  claude doctor

  b) Connect integrations (Slack, Calendar, Gmail, tracker, recorder):
       docs/06-mcp-and-integrations.md
     Then make the tool names in automation/allowed-tools/*.txt match yours.

  c) Fill in the vault: ${BRAIN}/CLAUDE.md and the me/ folder, then try:
       cd ${BRAIN} && claude
       > /morning-brief

  d) Test a scheduled skill by hand before trusting the schedule:
       ${REPO_DIR}/automation/run-skill.sh morning-brief
       tail -n 50 ${BRAIN}/.logs/morning-brief-\$(date +%F).log
EOF
[[ $DRY_RUN -eq 1 ]] && say "
  ${Y}Dry run complete. Nothing was changed.${R}"
exit 0
