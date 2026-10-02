---
name: meeting-prep
description: Prepares for a specific meeting, or the next one on the calendar. Pulls the attendees' people files, prior meetings in the same series or with the same people, open loops in both directions, and the linked project STATUS, then proposes an agenda, questions to ask, and what to bring. Writes a prep block into today's daily note. Use when the user says "prep me for my next meeting", "prep for the 2pm", "what do I need to know before meeting X", or "brief me on <meeting>". For a 1:1 with a direct report use one-on-one-prep instead.
---

# meeting-prep

Five minutes before a meeting, answer: who is in the room, what happened last time, what is open
between us, what I want out of this one.

## Inputs

| Input | Source | Default |
|---|---|---|
| Target meeting | user arg (title fragment, time, or event link) | next event on the calendar starting within 12h that has at least one other attendee |
| Vault root | `$BRAIN_DIR` | `~/brain` |
| Event details | Calendar MCP: list events / get event | required |
| Slack (optional) | Slack MCP search tool | recent threads with attendees on the meeting topic |

If the target is a recurring 1:1 with a direct report (person file says so, or `team:` matches a
team you lead), hand off: "This is a 1:1 with a report; running one-on-one-prep" and follow that
skill instead.

## State file

`$BRAIN_DIR/.state/meeting-prep.json`

```json
{ "prepped": { "<event_id>:2026-10-02": { "at": "2026-10-02T12:40:00Z", "block": "daily/2026-10-02.md" } } }
```

Re-running for the same event instance replaces its block instead of adding a second one. Prune
entries older than 30 days.

## Procedure

### 1. Resolve the meeting

1. Find the event. Ambiguous match (two events fit) -> list them and ask, unless headless; then
   take the soonest.
2. Collect: title, start/end, organizer, attendees (with response status), description, attached
   doc links, recurrence.
3. Map attendees to `people/<slug>.md` (name or email; check `aliases:`). Unmapped attendees are
   listed by display name. Group invites: list the group, don't expand it.

### 2. Gather history

- **Same series**: `grep -l` in `meetings/` for the series slug (title kebab-case) -> last 3 notes.
- **Same people**: meetings whose `people:` contains 2+ of today's attendees, last 60 days, last 3.
- From those notes take: TL;DR, decisions, action items still `- [ ]`.
- **Project**: from the event description/title or the prior notes' `project:` key ->
  `projects/<slug>/STATUS.md`: Phase, Next actions, open questions.
- **Decisions**: `decisions/` files linked from that project in the last 90 days.
- **Slack (optional)**: search the meeting topic and attendees over the last 7 days; keep at most
  3 threads that change what you'd say (a new blocker, a decision, a disagreement).

### 3. Open loops both ways

From each attendee's `## Open loops`:

- `@me` items = what I owe them. These go first; walking in with them undone is the main risk.
- `@<their-slug>` items = what they owe me. Candidates for the agenda.

Also scan the prior meeting notes' unchecked action items for the same.

### 4. Draft the agenda

- Goal of the meeting in one sentence. If the invite has no stated goal, infer one and mark it
  `(inferred)`.
- 3-5 agenda items, each with a desired outcome (`decide`, `align`, `inform`, `unblock`) and a
  rough time box that fits the slot.
- 3 questions worth asking: things the notes leave unresolved, risks nobody owns, a check on an
  assumption in STATUS.
- "Bring": numbers, docs, or decisions you need to have ready.

### 5. Write the prep block

In `daily/<today>.md` (create with minimal frontmatter if missing), under a `## Meeting prep`
heading (create once, after the morning brief block), replace or insert:

```markdown
<!-- meeting-prep:<event_id>:start -->
### 13:00 Q4 planning review
**Who:** [[jane-doe]] (organizer), [[sam-lee]], Pat Kim (no file) · **Project:** [[q4-roadmap]] (Phase: scoping)
**Goal:** decide which two Q4 bets get staffed (inferred)

**Last time** ([[2026-09-25-q4-planning-review]]): agreed to cut feature X; Sam to bring capacity numbers.

**I owe:** - [ ] @me send capacity model to [[sam-lee]] — due 2026-10-01 (overdue)
**They owe:** - [ ] @sam-lee capacity numbers per squad — due 2026-10-01

**Agenda**
1. Capacity numbers (align, 10 min)
2. Bet A vs bet B (decide, 25 min)
3. Owners and next checkpoint (decide, 10 min)

**Ask**
- What did we assume about the migration date, and is it still true?
- Who owns the vendor dependency if bet B wins?
- What would make us revisit this in November?

**Bring:** capacity model, last quarter's delivery numbers.
<!-- meeting-prep:<event_id>:end -->
```

Keep it under 30 lines. Link notes; don't paste them.

If the meeting has no prior notes and no people files, say so plainly and keep the prep to goal +
agenda + "Things to learn about these people".

### 6. Optional: pre-create the meeting note

If the user asks, create `meetings/YYYY-MM-DD-<slug>.md` from `templates/meeting.md` with
frontmatter (`type: meeting`, `date`, `people`, `project`, `source: manual`) and the agenda under
`## Notes`. `plaud-daily-ingest` will later fill its machine block in the same file if the
recording's calendar match produces the same slug.

### 7. Save state and report

Save the state file. Then append one line to `log.md` (format in `skills/README.md`): `- 2026-10-02 12:40 meeting-prep prep for <meeting> [[<daily-note>]]`.

## Never store

- Dial-in codes and passcodes from the invite.
- Anything from a person's `## Private` section. If it is relevant (for example, someone is on
  reduced hours), the owner already knows; do not surface it in a block others might see on screen.
- External attendees' personal details beyond name, company, and role.

## Final report (≤6 lines)

```
meeting-prep — Q4 planning review 13:00
3 attendees (1 without a people file) · 2 prior notes · 1 overdue @me item
Prep block written to daily/2026-10-02.md
```
