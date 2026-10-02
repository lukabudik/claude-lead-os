#!/usr/bin/env bash
# daily.sh - weekday morning chain:
#   plaud-daily-ingest -> slack-daily-digest -> morning-brief
#
# Each step runs even if an earlier one failed (a dead Plaud token should not
# cost you the brief). Exit code is non-zero if any step failed.
#
# launchd runs a missed job when the Mac wakes. If that happens after
# CLO_MORNING_CUTOFF (hour, default 11), the ingest steps still run but the
# morning brief is skipped: a 15:00 "plan your day" is noise.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN="${SCRIPT_DIR}/run-skill.sh"
CUTOFF="${CLO_MORNING_CUTOFF:-11}"

failed=()

"$RUN" plaud-daily-ingest || failed+=("plaud-daily-ingest")
"$RUN" slack-daily-digest || failed+=("slack-daily-digest")

hour=$((10#$(date +%H)))
if ((hour < CUTOFF)); then
  "$RUN" morning-brief || failed+=("morning-brief")
else
  echo "$(date '+%F %T') morning-brief skipped: started at ${hour}:00, after cutoff ${CUTOFF}:00"
fi

if ((${#failed[@]} > 0)); then
  echo "$(date '+%F %T') daily chain finished with failures: ${failed[*]}" >&2
  exit 1
fi
echo "$(date '+%F %T') daily chain ok"
