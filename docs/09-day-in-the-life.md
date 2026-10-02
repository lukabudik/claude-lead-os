# 09 — A day in the life

What this setup looks like for a tribe lead: four squads, about 35 people, a manager who wants a
weekly update, and somewhere between six and nine meetings a day. Times are examples. Nothing
here is magic; it is the same eight skills running on a schedule and on demand.

## The weekday

### 07:30 — the machine does the reading (you are not at your desk)

launchd fires `automation/daily.sh`. It runs three skills headless, one after another, each with
a read-only tool allowlist (sending messages is denied):

| Step | What happens | Typical runtime |
|---|---|---|
| `plaud-daily-ingest` | Yesterday's 4-6 recordings become `meetings/` notes. Action items land in people files under Open loops; project logs get a dated line. | 3-6 min |
| `slack-daily-digest` | Reads tier-1 channels fully, DMs and group DMs, mentions everywhere, skims tier 2. Writes the digest block into today's note; two or three durable facts go into project STATUS files with permalinks. | 4-8 min |
| `morning-brief` | Reads the two blocks above, today's calendar, overdue open loops, `me/current-focus.md`. Writes the brief at the top of `daily/<today>.md`. | 1-2 min |

If the Mac was asleep at 07:30, launchd runs the job on wake. After 11:00 the brief is skipped
(a "plan your day" at 15:00 is noise); the ingest steps still run.

### 08:15 — read one page

Open `daily/<today>.md` in Obsidian or your editor. It looks like this:

```markdown
## Brief — Thu 2026-10-01
_Inputs: calendar 8 events · Slack digest 07:41 · 5 meetings ingested_

### Top 3
1. [ ] Reply to the headcount split question before the 14:00 planning review
2. [ ] Draft the API deprecation decision (focus: platform migration)
3. [ ] Unblock the vendor contract with procurement (4 days overdue)

### Day plan
| Time | Meeting | Prep |
| 09:00 | Squad leads standup | none |
| 10:30 | 1:1 with a squad lead | 1:1 prep |
| 14:00 | Q4 planning review | prep |
...
```

Below it: the Slack digest (must act / decisions / FYI) and the list of meetings ingested. Ten
minutes, coffee, done. You check the must-act boxes as you clear them; the weekly synthesis
reads those checkboxes later.

What you do not do anymore: scroll 30 channels, or reconstruct what was agreed yesterday from
memory.

### 08:30 — clear the must-acts

Most are two-line Slack replies. You write them yourself. When you want a draft, ask in the
session and edit it; nothing is sent without you pressing enter in Slack.

### 10:15 — before the 1:1

```
/one-on-one-prep jane-doe
```

Two minutes later the agenda sits at the top of the 1:1 log in her person file: what you owe her
(one item, overdue, so you do it now or say so), follow-ups from last time, three signals from
the past two weeks with links, one growth topic. Her topics still come first; the prep just stops
you from walking in empty-handed.

### 13:45 — before the planning review

```
/meeting-prep 14:00
```

Attendees mapped to people files, last two notes from the same series, what each side owes, the
project's current phase, a suggested agenda with outcomes and three questions. You change the
agenda, paste it into the invite or just keep it open.

### During meetings

The recorder runs. You take no notes beyond the occasional line in the meeting's `## My notes`
section. Tomorrow morning the ingest turns the recording into a note.

When a real decision happens in a meeting or a thread:

```
/decision-log https://<workspace>.slack.com/archives/C0.../p1759...
```

An ADR lands in `decisions/` with context, options, the decision, owner, and a revisit date, and
the project STATUS links to it. Takes a minute while it is fresh; saves an hour of archaeology in
six weeks.

### Ad hoc, all day

The vault is the context. You ask the session questions and it answers from files, not from
guesses:

- "What did we decide about the release train, and who pushed back?"
- "Draft my weekly update to my manager from this week's STATUS files."
- "Which of my open loops with the platform squad are older than a week?"

### 17:30 — close the day (optional, 5 minutes)

Tick done items in the brief, write two lines under it if anything matters for tomorrow. If you
worked on a project, update its STATUS (Claude does it if you ask; the rule in `vault/CLAUDE.md`
is "read STATUS first, update it last").

## Friday

### 16:00 — the weekly chain

launchd fires `automation/weekly.sh`:

| Step | Output |
|---|---|
| `weekly-second-brain` | `weekly/YYYY-Www.md`: wins, decisions (marked if no ADR), risks, open loops by person, themes, what changed per project, focus check. People files get last-interaction dates and reconciled open loops. Memory changes are **proposed**, not applied. Stale projects flagged. |
| `kb-gardener` | Lint report in the daily note: stale STATUS files, broken links, untriaged inbox, duplicate people, MEMORY.md over budget. Safe fixes (frontmatter, slug normalisation, missing index lines) are applied; everything else is a checklist. |

### 16:45 — your 30-minute review

1. Read the weekly note. Write three lines under `## My reflection`. This is the part no skill does.
2. Tick the memory proposals you agree with; the next session applies them.
3. Work the gardener's high-severity items: update the stale STATUS, merge the duplicate person.
4. Update `me/current-focus.md` if priorities moved. Everything else filters through it next week.
5. Use the weekly note as the source for your update to your manager.

## Monthly

- Prune `.memory/`: the gardener tells you when MEMORY.md nears its budget. Merge, shorten, delete.
- Archive finished projects (`Phase: done`, move to `projects/_archive/`).
- Re-read the Slack tier config. Channels drift; your tier 1 should be the 5-10 you would read
  first anyway.
- Skim the headless logs in `$BRAIN_DIR/.logs/` for repeated failures (expired tokens are the
  usual cause).

## What it costs

| Item | Rough figure |
|---|---|
| Daily chain | 10-15 minutes of machine time, unattended; capped per run by `--max-turns` and `--max-budget-usd` |
| Weekly chain | 15-25 minutes, higher caps |
| Your time | ~15 min/day reading and clearing, ~30 min Friday review |
| Setup | 30 minutes to install, about two weeks before people files and STATUS logs are dense enough to be useful |

## What it does not do

- It does not make decisions, send messages, or talk to people for you. Every scheduled run is
  read-only outside the vault.
- It does not replace being in the room. Prep makes 1:1s better; it does not make them optional.
- It does not know what it was not given. Unrecorded hallway conversations and calls you did not
  record are invisible; write one line in the daily note when they matter.
- It gets worse if you stop gardening. A vault nobody reviews fills with stale STATUS files and
  duplicate people within a month. The Friday review is the price of the rest.

## When things break

| Symptom | Usual cause | Fix |
|---|---|---|
| Brief says "Slack digest not run today" | Slack connector token expired | Reconnect in an interactive session, re-run `/slack-daily-digest` |
| No meetings ingested | Plaud still transcribing, or auth expired | Pending recordings are retried next run; for auth, run the Plaud login once interactively |
| Same item in the digest twice | State file deleted or edited | Leave `.state/` alone; the skills dedupe by permalink and recording ID |
| People linked to the wrong person | Two people with the same first name | Add `aliases:` to their person files; the skills check them |
| Brief at 14:00 | Mac asleep all morning | Expected: the brief is skipped after the cutoff, ingest still runs |
