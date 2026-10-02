---
name: morning-brief
description: Writes today's morning brief at the top of daily/YYYY-MM-DD.md. Combines today's calendar, yesterday's Slack digest and ingested meetings, open loops from people files and project STATUS next actions, and me/current-focus.md into a plan, prep needed per meeting, and 3 priorities. Use when the user says "morning brief", "plan my day", "what's on today", "brief me", or when run headless by the daily 08:00 job (after plaud-daily-ingest and slack-daily-digest).
---

# morning-brief

One screen that tells you what today is for. It reads what the 07:30 jobs produced, it does not
redo their work: no Slack crawling, no transcript reading.

## Inputs

| Input | Source | Required |
|---|---|---|
| Vault root | `$BRAIN_DIR` (default `~/brain`) | yes |
| Today's events | Calendar MCP: list events for today (all calendars you own) | yes; degrade gracefully if missing |
| Current focus | `me/current-focus.md` | yes |
| Goals | `me/goals.md` (quarterly goals `G1`...) | optional; skip goal tags if missing |
| Slack digest | `daily/<today>.md` block `slack-daily-digest`, else yesterday's note | optional |
| Meetings ingested | `daily/<today>.md` block `plaud-daily-ingest` + `meetings/` from the last 2 days | optional |
| Yesterday | `daily/<yesterday>.md` (last working day on Mondays) | optional |
| Open loops | `- [ ]` lines in `people/*.md` `## Open loops` and `projects/*/STATUS.md` `## Next actions` | yes |

Tools: Calendar MCP (e.g. Google Calendar `list_events`, `get_event`), file reads. Read-only
outside the vault.

## State file

`$BRAIN_DIR/.state/morning-brief.json`

```json
{ "last_brief": "2026-10-02", "generated_at": "2026-10-02T08:00:40Z", "event_ids": ["abc123", "def456"] }
```

Used to detect a re-run on the same day: regenerate the block in place, and report which events
were added or cancelled since the earlier brief (compare `event_ids`).

## Procedure

### 1. Freshness check

- If the `slack-daily-digest` or `plaud-daily-ingest` block is missing from today's note, check
  their state files (`.state/<skill>.json`). Last run older than 18h -> say so in the brief's
  header line ("Slack digest not run today"). Do not run them from here.

### 2. Calendar

1. List today's events. Drop declined events, all-day "OOO"/"focus" placeholders (but note OOO of
   others if they are attendees in your meetings), and events with only you (keep them as focus
   blocks).
2. For each meeting: time, title, attendees (map to `[[person-slug]]` where a people file exists),
   whether it is recurring, linked doc in the description.
3. Classify: `1:1`, `team ritual`, `decision/review`, `external`, `interview`, `large/broadcast`.

### 3. Prep needed per meeting

For each meeting, decide in one line what prep it needs. Look at:

- Open loops with any attendee (`@me` items you owe them are the important ones).
- The last meeting note with the same title or attendees (grep `meetings/` for the series slug or
  attendee slugs, newest first). Unfinished action items from it.
- A linked project STATUS if the title or description maps to a project.

Prep levels: `none` · `skim` (read last notes, 5 min) · `prep` (run `meeting-prep`) ·
`1:1 prep` (run `one-on-one-prep`). Large broadcasts and recurring rituals with no open loops are
`none`.

### 4. Pick 3 priorities

Candidates, in rough order of weight:

1. Must-act items from today's Slack digest still unchecked.
2. `@me` open loops due today or overdue.
3. Next actions on projects listed in `me/current-focus.md`.
4. Prep for decision/review meetings today.

Rules: exactly 3, each a concrete outcome finishable today ("Send Q4 headcount split to Jane"),
not an area ("Hiring"). At least one must advance a current-focus item; if none can, say so. If a
priority conflicts with a packed calendar (less than 90 min free), make it smaller rather than
pretending.

**Score against goals** (if `me/goals.md` exists): end each priority with the goal id it moves,
`(G2)`, or `(no goal)`. In the day plan, add the goal id to the Why column where a meeting
clearly serves one. If two of three priorities are `(no goal)`, or under a third of today's
meeting time maps to any goal, add one line under Top 3: `Drift: today is mostly off-goal (G1,
G3 untouched)`. State it, do not lecture. The idea is from mimurchison/claude-chief-of-staff,
whose goals file lets Claude push back when time drifts from stated priorities.

### 5. Write the brief

File: `daily/<today>.md`. Create from `templates/daily.md` if missing (or minimal frontmatter
`type: daily`, `date`, `tags: [daily]`). Insert the block **directly after the frontmatter and H1**,
replacing an existing `morning-brief` block:

```markdown
<!-- morning-brief:start -->
## Brief — Fri 2026-10-02
_Inputs: calendar 7 events · Slack digest 07:32 · 3 meetings ingested · focus updated 2026-09-28_

### Top 3
1. [ ] Approve Q4 headcount split and reply to [[jane-doe]] (Slack must-act, due today) (G2)
2. [ ] Draft the API deprecation decision for [[q4-roadmap]] (focus: platform migration) (G1)
3. [ ] Unblock [[sam-lee]] on vendor contract (open loop, 4 days overdue) (no goal)

### Day plan
| Time | Meeting | Prep | Why |
|---|---|---|---|
| 09:00 | Platform standup | none | ritual, no open loops |
| 10:30 | 1:1 [[jane-doe]] | 1:1 prep | 2 open loops, last 1:1 had a follow-up |
| 13:00 | Q4 planning review | prep | decision expected on scope; read [[q4-roadmap]] |
| 15:00-17:00 | free | — | use for priority 2 |

### Open loops due
- [ ] @me send capacity model to [[sam-lee]] — due 2026-10-01 (overdue)
- [ ] @jane-doe share hiring plan — due 2026-10-02

### Yesterday, in one line
Release train moved to Wed; checkout incident resolved; 2 decisions logged.
<!-- morning-brief:end -->
```

Rules:

- Under 40 lines. Link, don't copy: the digest and meeting notes are one click away.
- Open loops: due today or overdue, max 8, `@me` first. Note "+N more" if truncated.
- Free blocks of 60+ minutes appear in the day plan; suggest which priority goes there.
- Re-run on the same day: replace the block, keep human edits outside it, and add a line
  `Changed since 08:00: +1:1 with ..., cancelled ...` if events changed.

### 6. Save state and report

Write `.state/morning-brief.json`. Then append one line to `log.md` (format in `skills/README.md`): `- 2026-10-02 08:00 morning-brief brief written, 3 priorities (2 on goals) [[2026-10-02]]`. In interactive mode, print the Top 3 and the day-plan table.
Headless, print the report below.

## Never store

- Event descriptions with dial-in codes, passwords, or private notes; keep title and attendees only.
- Private calendar entries (doctor, family): show them as `busy (private)` and nothing else.
- Content from a person's `## Private` section, even if it is relevant to a 1:1 today.

## Final report (≤8 lines)

```
morning-brief — 2026-10-02 08:00
7 events (2 need prep: 1:1 jane-doe, Q4 planning review) · 2h free
Top 3 written (2 on goals) · 5 open loops due (2 overdue)
Inputs: slack digest ok · plaud ingest ok · focus last updated 4 days ago
```
