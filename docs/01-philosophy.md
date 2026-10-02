# 01 — Philosophy

Claude is only as useful as the context it starts with. A leader's job is mostly context:
who said what, what we decided, what's stuck, who needs attention. This kit moves that context
out of your head and out of chat history into plain files Claude reads every session.

## Five principles

| Principle | What it means | Why |
|---|---|---|
| **Files over chat** | Everything worth keeping ends up in a markdown file in `~/brain` | Chat history is gone next session. Files persist, are greppable, diffable, and work with any tool (Obsidian, VS Code, `grep`). |
| **Map, not encyclopedia** | `CLAUDE.md` files say *where* things live, not *everything* | They load into every session. A 50-line map costs little; a 2,000-line dump crowds out the actual task and goes stale fast. |
| **Read first, write last** | Start from `STATUS.md` / the person file; update it before you stop | Makes every session resumable by a fresh Claude with zero memory. |
| **One home per fact** | A fact lives in exactly one file; everything else links `[[to-it]]` | Duplicates drift apart. Then Claude finds two truths and picks the wrong one. |
| **Draft, don't send** | Claude prepares; you press send | You're accountable for what leaves your name. Read access is cheap, write access to Slack/email is not. |

## Context engineering, in practice

Claude Code assembles context from several layers. This kit uses each for what it's good at:

| Layer | Loads | Use it for | In this kit |
|---|---|---|---|
| `~/.claude/CLAUDE.md` | every session, everywhere | the knowledge map | `claude/CLAUDE.md` |
| `~/.claude/rules/*.md` | every session (no `paths:` frontmatter) | how to behave: tone, privacy, git | `claude/rules/` |
| `<dir>/CLAUDE.md` | when working in that directory tree | local conventions | `vault/CLAUDE.md`, `vault/people/CLAUDE.md`, ... |
| Auto-memory `MEMORY.md` | every session (first 200 lines or 25KB) | small learned facts about how you work | `vault/.memory/` |
| SessionStart hook | every new session | today's focus + daily note | `claude/hooks/session-start.sh` |
| Skills | on demand, when the task matches | repeatable workflows | `skills/` |
| MCP tools | on demand | live data: Slack, tracker, calendar, recorder | see `06-mcp-and-integrations.md` |

Rule of thumb: **always-loaded layers stay small and stable; detail is loaded on demand.**

## Prior art

The vault follows Andrej Karpathy's **llm-wiki** pattern: raw sources (`inbox/`) are ingested by
the LLM into a wiki it maintains (`meetings/`, `people/`, `projects/`, ...), governed by a schema file
(`vault/CLAUDE.md`). Three operations: **ingest** (the capture skills), **query** (you asking
questions against the vault), **lint** (`kb-gardener`). Good answers get filed back as new pages
instead of dying in chat history.

## What this is not

- Not a note-taking app. You'll rarely write notes by hand; skills write them, you correct them.
- Not a replacement for your team's tools. Linear/Jira stays the source of truth for tickets,
  Slack for conversation. The vault holds *your* synthesis: what it means and what to do.
- Not a framework to admire. If a folder or a template doesn't earn its keep in two weeks, delete it.

## The loop

```
capture (recorder, Slack, calendar)  →  inbox/
triage (skills)                      →  meetings/, people/, projects/, decisions/
synthesise (daily brief, weekly)     →  daily/, weekly/
act (you, with Claude's drafts)      →  Slack, tracker, 1:1s
garden (weekly lint)                 →  fewer duplicates, fresher STATUS files
```
