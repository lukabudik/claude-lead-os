# 04 — Skills

A skill is a folder with a `SKILL.md` file that teaches Claude one repeatable job: "ingest my
recordings", "prep my 1:1". You write the playbook once; Claude follows it every time, the same
way, whether you ask in chat or a scheduled job calls it at 07:30.

## How skills load: progressive disclosure

| Level | What is in context | When |
|---|---|---|
| 1. Metadata | `name` + `description` from the frontmatter (a few dozen tokens) | every session, always |
| 2. Body | the rest of `SKILL.md` | only when the skill triggers |
| 3. References | files in `references/`, scripts, config | only when the body says to read them |

So twenty skills cost you roughly what one paragraph of CLAUDE.md costs, until one is used. Two
consequences:

- **The description is the trigger.** Claude decides to use a skill by matching your request
  against descriptions. A vague description means the skill never fires (or fires on the wrong
  thing).
- **The listing has a budget** (about 1% of the context window). When you have too many skills,
  the least-used descriptions get dropped. Eight sharp skills beat forty-five overlapping ones.

A skill is also invocable directly as a slash command: `/morning-brief`. That is how the headless
jobs call them (`claude -p "/morning-brief"`).

## Skill vs. the other extension points

| Mechanism | What it is | Loaded | Use it when | Example in this repo |
|---|---|---|---|---|
| **CLAUDE.md / rules** | Standing instructions | every request | Claude got the same thing wrong twice | `vault/CLAUDE.md`: where notes go |
| **Skill** | A playbook for one job, triggered by description or `/name` | description always, body on use | You keep pasting the same multi-step prompt | `plaud-daily-ingest` |
| **Slash command** (`.claude/commands/*.md`) | A saved prompt you invoke by name | on invocation | A short prompt shortcut, no supporting files needed. Skills now cover this too; prefer skills for anything with steps | — |
| **Subagent** (`.claude/agents/*.md`) | A separate Claude with its own context window and tool set | when delegated | A side task would flood your main context (a big search, a review) | weekly synthesis can fan out per source |
| **Hook** (`settings.json`) | A shell command the harness runs on an event (SessionStart, PreToolUse, Stop...) | zero tokens unless it prints | Something must happen every time, or must be blocked regardless of what Claude decides | SessionStart injects today's focus |
| **MCP server** | A connector that gives Claude tools (Slack, Calendar, Plaud) | tool names at start, schemas on demand | You keep copying data from a browser tab into the chat | Slack, Calendar, Plaud |

Rule of thumb: instructions are requests, hooks are enforcement. "Never send a Slack message" in a
skill is advice; denying the send tool in the allowlist (see `automation/allowed-tools/`) is a guarantee.

## The skills in this repo

| Skill | Trigger phrases | Writes | Needs |
|---|---|---|---|
| `plaud-daily-ingest` | "ingest my recordings", daily job | `meetings/`, people + project logs, daily note | Plaud MCP (Calendar optional) |
| `slack-daily-digest` | "what did I miss", daily job | daily note "Slack digest", facts into STATUS / `knowledge/` | Slack MCP |
| `morning-brief` | "plan my day", daily job | top of daily note: Top 3, day plan, prep | Calendar MCP |
| `meeting-prep` | "prep me for the 2pm" | prep block in daily note | Calendar MCP (Slack optional) |
| `one-on-one-prep` | "prep my 1:1 with Jane" | agenda in `people/<slug>.md` | Calendar (Slack optional) |
| `decision-log` | "log this decision" | `decisions/YYYY-MM-DD-slug.md` + STATUS link | Slack for thread sources |
| `weekly-second-brain` | "weekly review", Friday job | `weekly/YYYY-Www.md`, people updates, memory proposals | Slack MCP |
| `kb-gardener` | "lint my brain", Friday job | lint report, safe fixes | none |

See [`skills/README.md`](../skills/README.md) for the full catalog including the extra skills.

Every skill in this repo follows the same contract:

- **State file** at `$BRAIN_DIR/.state/<skill>.json` with a cursor and processed IDs, so a re-run
  never duplicates and a missed day catches up.
- **Machine-owned blocks** between `<!-- <skill>:start -->` and `<!-- <skill>:end -->` markers.
  Re-runs replace the block; your own text outside it is never touched.
- **Append, don't rewrite** people and project files: dated bullets under known headings.
- **Never store** compensation, health, performance, HR, credentials. The skill writes "sensitive
  topic, not stored" and flags it.
- **A short final report**, so a headless run's log tells you what happened in five lines.

## Install

Skills live in one of three places: `~/.claude/skills/` (personal, every project),
`.claude/skills/` inside a repo (project only), or inside a plugin. We use personal, via symlinks,
so `git pull` in this repo updates them:

```bash
cd ~/code/claude-lead-os   # wherever you cloned it
mkdir -p ~/.claude/skills
for d in skills/*/; do
  name=$(basename "$d")
  ln -sfn "$PWD/$d" "$HOME/.claude/skills/$name"
done
```

`install.sh` does the same. Then:

1. Start `claude` in your vault and type `/` — the skills appear in the list.
2. Copy `skills/slack-daily-digest/config.example.yaml` to `$BRAIN_DIR/.config/slack-daily-digest.yaml`
   and fill in your user ID and channel tiers.
3. Run each daily skill once by hand (`/plaud-daily-ingest`, `/slack-daily-digest`,
   `/morning-brief`) before you schedule them. The first run creates the state files and shows you
   what the output looks like on your real data.

Only install skills you have read. A skill is a prompt with access to your tools.

## Write your own

### Anatomy

```
skills/my-skill/
├── SKILL.md            # required: frontmatter + instructions
├── references/         # optional: depth Claude reads only when needed
│   └── taxonomy.md
├── scripts/            # optional: deterministic helpers Claude runs instead of reasoning
└── config.example.yaml # optional: user-specific settings, copied into the vault
```

```markdown
---
name: my-skill
description: Does X from Y and writes Z. Use when the user says "...", "...", or when the
  Friday job runs it.
---

# my-skill

## Inputs
## State file
## Procedure
1. ...
## Never store
## Final report
```

### Rules that matter

| Rule | Why |
|---|---|
| `name`: lowercase, hyphens, max 64 chars, matches the folder | It becomes `/name` |
| `description`: third person, what it does + "Use when ..." with real phrases you say, max 1,024 chars | It is the only thing Claude sees when deciding to trigger |
| Body under ~500 lines | The whole body enters context on every use |
| Push depth into `references/`, one level deep | Claude reads references on demand; nested chains get skimmed |
| Write the procedure as numbered steps with exact paths and formats | Unattended runs need no judgement calls about where output goes |
| Make it idempotent (state file, marker blocks) | Scheduled jobs re-run, overlap, and catch up after sleep |
| Say what not to store | The default is to write down everything it reads |
| End with a fixed-shape report | You read logs, not transcripts |
| Assume Claude is smart | Explain your conventions, not how to summarise |

### Getting a skill right

1. Do the job by hand in a chat three times. Note what you had to correct.
2. Write the skill from those corrections, not from imagination.
3. Run it on real data. Read the output, not just the report.
4. Fix the description if it did not trigger on the phrases you actually use.
5. Only then schedule it.

`/skill-creator` (from the official plugin marketplace) can scaffold and evaluate skills if you
want a guided loop.

## Chaining skills

Skills do not call each other directly; they communicate through files. Each one writes a known
block in a known place, and the next one reads it.

```
07:30 weekday chain (automation/daily.sh), one after another:
  1. plaud-daily-ingest  ->  meetings/*.md, daily/<today>.md [plaud-daily-ingest block]
  2. slack-daily-digest  ->  daily/<today>.md [slack-daily-digest block]
  3. morning-brief       ->  reads both blocks + calendar + open loops
                             writes daily/<today>.md [morning-brief block] at the top
                             (usually done before 08:00)
Fri    weekly-second-brain ->  reads 5 daily notes + meetings/ + Slack DMs -> weekly/YYYY-Www.md
Fri    kb-gardener         ->  lints what the week wrote
```

Why files and not one giant skill:

- Each step fails independently. A dead Plaud token does not cost you the brief; the brief says
  "plaud ingest not run today" and moves on (it checks the other skills' state files).
- Each step is testable on its own and re-runnable by hand.
- The intermediate outputs are useful to you directly, not just to the next skill.

Hand-offs between skills are explicit lines in reports: `plaud-daily-ingest` and
`slack-daily-digest` list "Suggested decision-log entries"; `morning-brief` marks meetings as
`prep` or `1:1 prep` so you know when to run `meeting-prep` or `one-on-one-prep`.

The scheduling side (launchd, cron, `claude -p`, cloud routines) is in
[05-loops-and-automation.md](05-loops-and-automation.md).
