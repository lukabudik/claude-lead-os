---
name: one-on-one-prep
description: Prepares a 1:1 with a direct report (or skip-level). Reads their people file, the last 1:1 notes, commitments in both directions, recent signals from Slack and meetings, and their stated growth goals, then writes an agenda block at the top of the 1:1 log in people/<slug>.md. Use when the user says "prep my 1:1 with <name>", "1:1 prep", "what should I talk about with <name>", or when morning-brief flags a 1:1 that needs prep.
---

# one-on-one-prep

The 1:1 is their meeting. The prep makes sure you show up having done what you promised, aware of
what happened in their week, and with one or two growth topics instead of a status update.

## Inputs

| Input | Source | Default |
|---|---|---|
| Person | user arg (name or slug) | the next 1:1 on today's calendar |
| Vault root | `$BRAIN_DIR` | `~/brain` |
| Person file | `people/<slug>.md` | required; if missing, offer to create from `templates/person.md` and stop |
| Calendar | Calendar MCP | to find the next 1:1 date and the slot length |
| Slack (optional) | Slack MCP search tool | their messages and threads with you, last 14 days |

## State file

`$BRAIN_DIR/.state/one-on-one-prep.json`

```json
{ "people": { "jane-doe": { "last_prepped_for": "2026-10-02", "last_signal_scan": "2026-10-02T09:10:00Z" } } }
```

`last_signal_scan` bounds the Slack and meetings scan on the next run (falls back to the date of
the previous 1:1). Re-running for the same date replaces the agenda block.

## Procedure

### 1. Read the person file first

From `people/<slug>.md` read `## Snapshot` (role, team, tenure, goals), `## Open loops`,
`## 1:1 log` (last 3 entries), `## Context log` (since the last 1:1). You may read `## Private`
to inform your own judgement, but never copy from it into the agenda block or anywhere else.

Determine the window: from the previous 1:1 date (newest heading in `## 1:1 log`) to now. No
previous 1:1 -> last 14 days.

### 2. Commitments both ways

- `@me` items in their file = what I promised them. Status of each: done (ticked elsewhere?
  check the linked note), still open, overdue. These open the agenda; being late on them costs
  trust.
- `@<slug>` items = what they committed to. Only list overdue ones, framed as "check if you need
  help", not as an audit.
- Items from the last 1:1 entry's notes that were not converted to loops.

### 3. Recent signals (window only)

Collect at most 6, each one line with a link:

- **Meetings**: `meetings/` notes where `people:` includes them. Decisions they drove, risks they
  raised, actions they took on.
- **Slack**: their threads with you; places they were @-mentioned on blockers; shipped
  announcements; questions they asked publicly that went unanswered. Use Slack MCP search with
  `from:<their user>` and `to:me` in the window.
- **Projects**: STATUS logs of projects they own (`Owner:` or `people:`) — slipped dates,
  phase changes.
- **Recognition**: things they did well that someone else mentioned. These are easy to forget
  and worth saying out loud.

Signals are observations, not interpretations. Write "raised the vendor risk in planning twice",
not "seems frustrated".

### 4. Growth topics

From `## Snapshot` goals and past 1:1 entries tagged growth/career, pick 1-2 topics. Link each to
a concrete opportunity from the signals ("you ran the planning review; want to own the next
one?"). No goals recorded -> propose asking about them as a topic.

### 5. Write the agenda block

At the top of `## 1:1 log` (newest-first), add or replace:

```markdown
### 2026-10-02
<!-- one-on-one-prep:start -->
**Their topics first.** Ask: what's on your mind?

**I owe**
- [x] @me intro to the data team — done 2026-09-30
- [ ] @me feedback on the RFC draft — due 2026-09-29 (overdue, do before or say so)

**Follow-ups from last time** ([[2026-09-25-jane-doe-1-1]])
- Hiring loop for the backend role — status?

**Signals since 09-25**
- Drove the scope cut decision in [[2026-10-01-q4-roadmap-review-platform]]
- Flagged on-call load in #team-channel twice ([link](...))
- Recognition: [[sam-lee]] credited her for the migration runbook ([link](...))

**Growth**
- Goal "lead cross-team work": offer to chair the next planning review.

**Questions**
- What's one thing slowing your team down that I could remove?
- On-call load: what would good look like by end of quarter?
<!-- one-on-one-prep:end -->
Notes:
```

Rules:

- Under 30 lines. Their topics first, always.
- Leave `Notes:` empty; the owner or `plaud-daily-ingest` fills it after the meeting.
- No ratings, no performance judgements, nothing from `## Private`, no comparisons with peers.
- Bump `updated:` in frontmatter.

### 6. Show and report

Print the block in chat so the owner can read it before the meeting, then the report.

## Never store

- Compensation, promotion, rating, health, family, or personal-life content. If a signal touches
  these (for example a Slack DM about leave), write nothing; mention in chat only "There is a
  personal/HR topic in your DMs since last 1:1" so the owner can decide.
- Other people's opinions about this person, unless it is public recognition.

## Final report (≤6 lines)

```
one-on-one-prep — jane-doe, 2026-10-02 10:30 (30 min)
I owe: 1 open (overdue) · they owe: 0 overdue · signals: 3 · growth topics: 1
Agenda written to people/jane-doe.md (1:1 log)
```
