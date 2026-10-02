#!/usr/bin/env bash
# weekly.sh - Friday afternoon chain:
#   weekly-second-brain -> team-health-radar -> kb-gardener
#
# The gardener runs last so it lints the week's fresh writes. Every step always
# runs; exit code is non-zero if any failed. Drop a step by setting
# CLO_WEEKLY_SKIP="team-health-radar" (space-separated skill names).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN="${SCRIPT_DIR}/run-skill.sh"

failed=()
SKIP=" ${CLO_WEEKLY_SKIP:-} "
want() { [[ "$SKIP" != *" $1 "* ]]; }

# The weekly synthesis reads a whole week of signals: give it more room.
if want weekly-second-brain; then
  CLO_MAX_TURNS="${CLO_WEEKLY_MAX_TURNS:-80}" CLO_MAX_BUDGET="${CLO_WEEKLY_MAX_BUDGET:-6.00}" \
    "$RUN" weekly-second-brain || failed+=("weekly-second-brain")
fi
if want team-health-radar; then
  "$RUN" team-health-radar || failed+=("team-health-radar")
fi
if want kb-gardener; then
  "$RUN" kb-gardener || failed+=("kb-gardener")
fi

if ((${#failed[@]} > 0)); then
  echo "$(date '+%F %T') weekly chain finished with failures: ${failed[*]}" >&2
  exit 1
fi
echo "$(date '+%F %T') weekly chain ok"
