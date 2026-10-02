# Claude Code — user-level config

Loads at the start of every Claude Code session on this machine, in every directory.
This file is the **map**, not the encyclopedia: it says where context lives. Read the right file
before answering anything personal, professional or context-dependent. Don't guess.

## Knowledge map

| Need | Read |
|---|---|
| Vault rules: layout, naming, where to write | `~/brain/CLAUDE.md` |
| Who I am, role, scope | `~/brain/me/about-me.md` |
| What's top-of-mind right now | `~/brain/me/current-focus.md` |
| Who matters and why | `~/brain/me/key-people.md`, then `~/brain/people/<slug>.md` |
| How I like Claude to work | `~/brain/me/preferences.md` + `~/.claude/rules/` |
| A project's current state | `~/brain/projects/<slug>/STATUS.md` (**read first, update last**) |
| A team | `~/brain/teams/<slug>.md` |
| What happened today / this week | `~/brain/daily/YYYY-MM-DD.md`, `~/brain/weekly/YYYY-Www.md` |
| Past decisions and why | `~/brain/decisions/` |
| Terms, acronyms, how things work | `~/brain/knowledge/` |
| Code repos | each repo's own `CLAUDE.md` |

## Behavioural rules

Rules in `~/.claude/rules/` load automatically into every session (files without `paths:`
frontmatter are unconditional):

- `rules/communication.md` — how to format answers for me
- `rules/writing-voice.md` — how to write as me (Slack, email, docs, posts)
- `rules/privacy.md` — what never goes into the vault, a prompt, or outside this machine
- `rules/git.md` — git safety

## Defaults

- **Second brain:** `~/brain/`. When I say "note this", "remember", "log it", it goes there,
  following `~/brain/CLAUDE.md`.
- **Never send anything on my behalf** (Slack, email, calendar, tracker comments) without
  showing me the draft and getting an explicit yes.
- **Dates are absolute** (`2026-10-02`), never "yesterday".
- **Search the vault before creating a file.** Update over create. Link with `[[slug]]`.

## What's NOT here on purpose

Bio, focus, people and project detail live in `~/brain/` so they're portable, visible to other
tools (Obsidian, grep), and survive a Claude Code reinstall. Keep this file under ~60 lines.
