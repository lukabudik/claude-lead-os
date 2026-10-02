# 10 — Extras: more skills, subagents, commands, and how to build your own

The eight core skills run your day. These extras cover the rest of a lead's job: managing up,
watching team health, quarterly reviews, hiring, email, and getting answers out of the vault.
Plus four subagents and four slash commands.

All of it follows the same rules as the core: the vault is the source of truth, every fact is
cited, numbers are never invented, and nothing is sent on your behalf.

## Catalog

### Skills (`skills/<name>/SKILL.md`)

| Skill | Use when | Reads | Writes | MCP |
|---|---|---|---|---|
| `stakeholder-update` | You owe your manager a daily/weekly update | daily notes, meetings, STATUS, decisions, recipient's person file | draft block in today's daily note; log line in recipient's file after you send | none (Slack optional, read-only) |
| `team-health-radar` | Friday, or "which team needs me?" | team files, tracker, team channels, retros | `## Radar` block in `teams/<team>.md`, `## Team flags` in the weekly note | Slack, Linear or Jira |
| `qbr-prep` | A quarterly review is 1-2 weeks out | focus, STATUS logs, weekly notes, decisions, team metrics | `projects/qbr-YYYY-Qn/` outline + "numbers needed" list | none |
| `interview-debrief` | Right after an interview | your notes or transcript, role scorecard | `people/candidates/YYYY-MM-DD-<role>-<id>.md` with `retain_until` | Plaud/Granola/Fireflies (optional) |
| `inbox-triage` | Morning email pass | Gmail, last 24h | `## Inbox` block in today's note, commitments into person files | Gmail (read; drafts optional) |
| `ask-my-brain` | "What do we know about...", "when did we decide..." | the whole vault | nothing (chat answer with file citations) | none |

### Slash commands (implemented as user-invocable skills)

| Command | What it does |
|---|---|
| `/today` | Opens (or creates) today's note, runs `morning-brief` if empty, gives a 10-line brief |
| `/capture <text>` | Appends a timestamped line to `inbox/YYYY-MM-DD-capture.md`; tasks become `- [ ] @me` |
| `/remember <fact>` | Writes one memory file to `.memory/` and an index line to `.memory/MEMORY.md` |
| `/prep <meeting or person>` | Routes to `one-on-one-prep` for a person, `meeting-prep` for anything else, scorecard gaps for interviews |

These are skills with `disable-model-invocation: true`, so they run only when you type them.
Claude Code merged custom commands into skills: a file at `.claude/commands/today.md` and a skill
at `.claude/skills/today/SKILL.md` both create `/today`. The old `commands/` folder still works,
but skills support supporting files, `$ARGUMENTS`/`$0` substitution, and `` !`cmd` `` context
injection, so this kit uses skills. Each command injects the current date with `` !`date` ``
so the model never guesses "today".

### Subagents (`claude/agents/*.md` → `~/.claude/agents/`)

| Agent | Tools | Model | Use when |
|---|---|---|---|
| `kb-researcher` | Read, Grep, Glob | haiku | A question needs more than 2-3 vault files; keeps the main context clean |
| `slack-scout` | Read, Grep, Slack MCP (send tools denied) | sonnet | You need a sweep of channels/DMs/topic, returned as asks / decisions / risks / FYI |
| `writer` | Read, Grep, Glob | sonnet | The content is known and the draft must sound like you (`me/` + `rules/writing-voice.md`) |
| `reviewer` | Read, Grep, Glob | opus | Before anything goes to an exec, a big channel, or outside: claim check, asks, tone, leaks, length |

Subagents run in their own context window and return only their final answer. That is the
point: a Slack sweep that reads 200 messages costs the main conversation 15 lines. Claude
delegates automatically based on each agent's `description`, or you ask: "use slack-scout to
check #checkout-squad since Monday".

Install: copy or symlink `claude/agents/*.md` into `~/.claude/agents/` (user level) or
`.claude/agents/` inside your vault (project level). Edit `slack-scout.md` and replace
`mcp__slack` with your Slack server name as shown by `/mcp`.

## When to use what

| Situation | Reach for |
|---|---|
| 08:00, coffee | `/today` (or let the scheduled `morning-brief` run) |
| Idea mid-meeting | `/capture ask Sam about lending 2 engineers` |
| Claude got something wrong about how you work | `/remember updates to my manager stay under 120 words` |
| Five minutes before a meeting | `/prep 13:00` or `/prep priya` |
| End of day, manager expects an update | `stakeholder-update daily`, then `reviewer` on the draft |
| Friday afternoon | `weekly-second-brain` + `team-health-radar` |
| "Did we ever decide on X?" | `ask-my-brain did we decide who owns the token client?` |
| Two weeks before QBR | `qbr-prep 2026-Q3`, then go collect the numbers it lists |
| Just finished an interview | `interview-debrief inbox/2026-10-02-plaud-interview.md senior-em` |
| Inbox at 40+ unread | `inbox-triage` |
| Big announcement to the whole org | `writer` for the draft, `reviewer` before you post |

Worked outputs for the daily, weekly, meeting, and 1:1 flows are in [`examples/`](../examples/).

## Build your own skill in 10 minutes

The best skills come from a task you already do every week and have explained to Claude more
than twice. Example: every Monday you write a short "dependencies across teams" note for the
leads sync.

### 1. Write down the recipe (2 min)

Answer five questions in plain words:

| Question | Example answer |
|---|---|
| When do I do it? | Monday before the 10:00 leads sync, or when someone asks "what's blocking whom" |
| What do I read? | team files, tracker issues labelled `blocked`, last week's weekly note |
| What do I produce? | a table: blocked team, blocked by, item, days waiting, owner of the unblock |
| Where does it go? | `daily/YYYY-MM-DD.md`, section `## Cross-team dependencies` |
| What must never happen? | posting it anywhere; naming a person as the cause |

### 2. Create the file (1 min)

```bash
mkdir -p ~/.claude/skills/dependency-map
$EDITOR ~/.claude/skills/dependency-map/SKILL.md
```

Use `~/.claude/skills/` for skills you want everywhere, or `<vault>/.claude/skills/` to keep it
with the vault. To share it through this kit, put it in `skills/` and re-run `install.sh`.

### 3. Write the frontmatter (2 min)

The `description` decides when Claude loads the skill. Say what it does, then "Use when..."
with the phrases you actually type.

```yaml
---
name: dependency-map
description: Build a cross-team dependency table (who is blocked by whom, for how long, who owns the unblock) from team files, blocked tracker issues, and last week's review. Use when the user asks "what's blocking whom", "dependency map", "cross-team blockers", or before the Monday leads sync.
argument-hint: "[days, default 14]"
---
```

Optional fields worth knowing: `disable-model-invocation: true` (only runs when you type
`/dependency-map`), `allowed-tools` (pre-approve tools so it runs without prompts),
`context: fork` with `agent: <name>` (run it inside a subagent).

### 4. Write the body (4 min)

Copy this skeleton. Keep it under ~150 lines; move long reference material into a
`references/` file next to `SKILL.md` and link it.

```markdown
# dependency-map

One line on why this exists.

## Inputs
| Input | Source | Default |
|---|---|---|
| Window | `$ARGUMENTS` days | 14 |
| Vault root | `$BRAIN_DIR` | `~/brain` |

## Procedure
1. Read `teams/*.md`; collect each team's tracker key from frontmatter.
2. Query the tracker for issues with label `blocked` updated in the window.
3. For each, find the blocking team (issue links, comments). Unknown? Write `unknown`, don't guess.
4. Sort by days waiting, longest first.
5. Write the table into today's daily note between `<!-- dependency-map:start -->` and
   `<!-- dependency-map:end -->` (replace on re-run).

## Output
(paste one example table, so the model copies the shape)

## Guardrails
- Read-only on the tracker. Never comment or change status.
- Teams, not people, are "blocked by".
- Cite the issue key for every row.
```

Four things make a skill reliable: **a fixed output path**, **marked blocks** so re-runs
replace instead of duplicate, **an example of the output**, and **explicit guardrails**
(read-only, no invented numbers, draft-never-send).

### 5. Test it (1 min, then iterate)

```bash
claude "/dependency-map 7"
```

Check the output against what you would have written. Fix the skill, not the output: every
correction you make by hand once should become a line in the procedure or guardrails. When
it works three weeks in a row, schedule it (see [05-loops-and-automation.md](05-loops-and-automation.md)).

For a guided version with test prompts and evals, install Anthropic's `skill-creator` plugin
and ask Claude to "turn my dependency-map routine into a skill".

## Safety notes specific to the extras

- `interview-debrief` files hold personal data about candidates. Keep `people/candidates/` out
  of any shared remote (add it to `.gitignore`), set `candidates_retention_months` to your
  company's policy, and let `kb-gardener` list expired files for deletion.
- `inbox-triage` treats email as untrusted input. Deny Gmail send/forward/trash tools in
  `settings.json` permissions so a malicious email cannot make Claude act. See
  [07-security-and-privacy.md](07-security-and-privacy.md).
- `team-health-radar` never produces per-person metrics. Keep it that way if you fork it.
- `stakeholder-update` and `writer` mark missing numbers as `[NUMBER: ...]`. Fill them yourself;
  do not ask the model to "estimate".
</content>
</invoke>
