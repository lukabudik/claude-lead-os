# claude-lead-os

**Claude Code as a second brain and chief of staff for people who run teams.**

A starter kit for tribe leads, engineering managers and product leads. It is built from plain markdown files, a set of skills and a schedule. Clone it, run one script, and within 30 minutes Claude can do the following:

- turn yesterday's meeting recordings into tagged notes, action items and updated people/project files
- tell you what you missed in Slack, and save the decisions that matter into your knowledge base
- prepare today's plan, every meeting and every 1:1 from your own history
- write your weekly review and keep the vault tidy

It is company-agnostic, local-first and MIT licensed.

---

## The idea in one picture

```
  KNOWLEDGE               SKILLS                  LOOPS
  what Claude knows       what Claude does        when Claude does it
  ─────────────────       ─────────────────       ─────────────────
  ~/brain/  (markdown)    plaud-daily-ingest      launchd / cron  →  claude -p
  CLAUDE.md maps          slack-daily-digest      /loop  (in-session)
  people/ teams/          morning-brief           /schedule  (cloud routines)
  projects/*/STATUS.md    weekly-second-brain     hooks (context + guardrails)
  .memory/ (facts)        meeting-prep, ...       permissions (allow / deny)
```

Skills never call each other. They hand work along through files: the Slack digest writes `daily/`, and the morning brief reads it. Any step can fail, be re-run or be swapped out without breaking the rest.

## Quickstart (30 minutes)

```bash
git clone https://github.com/lukabudik/claude-lead-os.git
cd claude-lead-os
./install.sh --dry-run      # see what it would do
./install.sh                # vault → ~/brain, skills → ~/.claude/skills, rules → ~/.claude/rules
```

1. **Tell it who you are (10 min, the highest-leverage step).** Fill in `~/brain/me/about-me.md`, `current-focus.md`, `key-people.md` and `preferences.md`. Everything the agent writes is shaped by these files.
2. **Connect your tools.** In Claude Code, run `/mcp`. Connect Slack, Google Calendar, Gmail and Plaud (or Granola/Fireflies). Start with read access only. See [docs/06](docs/06-mcp-and-integrations.md).
3. **Merge settings.** Merge `claude/settings.example.json` into `~/.claude/settings.json`. It adds the permissions, the SessionStart hook and the statusline.
4. **First run.** `cd ~/brain && claude`, then: *"run the morning-brief skill"*.
5. **Week two: schedule it.** Once you trust the output, run `./install.sh --with-launchd`. The daily pipeline then runs at 07:30 on weekdays and the weekly review on Fridays.

## What's inside

| Path | What |
|---|---|
| [`vault/`](vault/) | Knowledge-base template. Root `CLAUDE.md` map, folder conventions, templates, one worked example per folder |
| [`claude/`](claude/) | User-level config: `CLAUDE.md`, `rules/`, `settings.example.json`, hooks, statusline, subagents, commands |
| [`skills/`](skills/) | Claude Code skills, each a `SKILL.md` |
| [`automation/`](automation/) | `run-skill.sh` wrapper, daily/weekly pipelines, launchd plists, cron, cloud routines guide |
| [`examples/`](examples/) | What good output looks like: daily note, weekly review, meeting note, 1:1 prep (fictional company) |
| [`docs/`](docs/) | The thinking behind it (below) |

### Skills

| Skill | Cadence | What it does |
|---|---|---|
| `plaud-daily-ingest` | daily | New recordings → `meetings/` with summary, decisions, action items, tags; updates people + project files |
| `slack-daily-digest` | daily | Channels with activity since the last run → must-act / decisions / FYI in today's note; durable facts into the vault |
| `morning-brief` | daily | Calendar + open loops + digest → today's plan, prep per meeting, three priorities |
| `weekly-second-brain` | weekly | DMs, threads, meetings and daily notes → `weekly/` review; updates people files; proposes memories |
| `kb-gardener` | weekly | Stale STATUS files, orphan notes, broken links, untriaged inbox, memory index over budget |
| `meeting-prep` | on demand | Attendees, prior meetings, open loops → agenda and questions |
| `one-on-one-prep` | on demand | Commitments both ways, recent signals, growth topics → 1:1 agenda |
| `decision-log` | on demand | Decision from a thread or meeting → ADR in `decisions/`, linked from the project |

**Leader extras:** `stakeholder-update`, `team-health-radar` (weekly), `qbr-prep`, `interview-debrief`, `inbox-triage`, `ask-my-brain`.

**Quick commands** (typed only, never auto-triggered): `/today`, `/capture <text>`, `/remember <fact>`, `/prep <meeting or person>`.

**Subagents** in `claude/agents/`: `kb-researcher`, `slack-scout`, `writer`, `reviewer`. All four are read-only.

Full catalog and a "build your own skill in 10 minutes" walkthrough: [docs/10-extras.md](docs/10-extras.md).

## Docs

| # | Doc | Read it for |
|---|---|---|
| 01 | [Philosophy](docs/01-philosophy.md) | Why files beat chat, and why CLAUDE.md is a map rather than an encyclopedia |
| 02 | [Knowledge base](docs/02-knowledge-base.md) | Vault layout, the CLAUDE.md hierarchy, the STATUS.md pattern |
| 03 | [Memory](docs/03-memory.md) | One fact per file, the index budget, feedback memories |
| 04 | [Skills](docs/04-skills.md) | How skills work, and how to write your own |
| 05 | [Loops & automation](docs/05-loops-and-automation.md) | `/loop` vs `/schedule` vs launchd, hooks, failure modes |
| 06 | [MCP & integrations](docs/06-mcp-and-integrations.md) | Which connectors, least privilege, draft-never-send |
| 07 | [Security & privacy](docs/07-security-and-privacy.md) | Prompt injection, what never goes in the vault |
| 08 | [Best practices](docs/08-best-practices.md) | Research across Anthropic docs and the best community repos |
| 09 | [A day in the life](docs/09-day-in-the-life.md) | What a lead's week looks like with this running |
| 10 | [Extras](docs/10-extras.md) | More skills, subagents, commands, build-your-own |

## Principles

- **Files that compound beat chats that reset.** Context accumulates in git-versioned markdown that any tool, or any person, can read.
- **Map, not encyclopedia.** Keep CLAUDE.md files short and make them point to where the detail lives. Detail loads only when Claude works in that folder.
- **Draft, never send.** Unattended runs write drafts into the vault. A human presses send.
- **Ingested text is data, not instructions.** Slack messages and transcripts are untrusted input.
- **Some things never go in.** Compensation, health, HR cases and credentials are flagged, not stored.
- **Roll out one layer at a time.** Start with the vault, then on-demand skills, then the schedule.

## Credits

This kit stands on patterns from Anthropic's Claude Code docs and [anthropics/skills](https://github.com/anthropics/skills), Andrej Karpathy's LLM-wiki pattern, [claude-code-cos](https://github.com/jimprosser/claude-code-cos), [claudesidian](https://github.com/heyitsnoah/claudesidian), [claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian), [claude-chief-of-staff](https://github.com/mimurchison/claude-chief-of-staff) and [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code). Full source list: [docs/08](docs/08-best-practices.md#8-sources).

## License

MIT © 2026 Luka Budík
