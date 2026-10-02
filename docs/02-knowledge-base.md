# 02 — Knowledge base

The vault (`~/brain` by default, override with `BRAIN_DIR` in `install.sh`) is a folder of
markdown files. Open it in Obsidian if you like; Claude only needs the filesystem.

## Layout

| Folder | Holds | Naming |
|---|---|---|
| `me/` | about-me, current-focus, key-people, preferences | fixed names |
| `inbox/` | raw transcripts, digests, pastes before triage | `YYYY-MM-DD-<source>-<slug>.md` |
| `daily/` | daily brief + log | `YYYY-MM-DD.md` |
| `weekly/` | weekly review | `YYYY-Www.md` (ISO week) |
| `meetings/` | one processed note per meeting | `YYYY-MM-DD-<slug>.md` |
| `people/` | one file per person | `<first>-<last>.md` |
| `teams/` | one file per team/squad | `<team-slug>.md` |
| `projects/<slug>/` | one folder per initiative, `STATUS.md` first | `STATUS.md` + free files |
| `decisions/` | ADR log, append-only | `YYYY-MM-DD-<slug>.md` |
| `knowledge/` | glossary, how things work, playbooks | `<topic-slug>.md` |
| `templates/` | templates for every note type | `<type>.md` |
| `.memory/` | Claude auto-memory pool | `<slug>.md` + `MEMORY.md` |

Files prefixed `example-` are fictional and show what a filled-in note looks like. Delete them
when you have real content.

**Why dated filenames:** they sort chronologically in any file browser, make "last 7 days" a
glob (`daily/2026-09-2*.md`), and never collide.

**Why one file per person/team:** a 1:1 prep, a Slack digest and a meeting ingest can all append
to the same place. "What do I know about Jane?" becomes one file read, not a search.

## The CLAUDE.md hierarchy

Claude Code loads `CLAUDE.md` files by directory: user-level (`~/.claude/CLAUDE.md`), then every
`CLAUDE.md` from the working directory up, plus ones in subdirectories when it reads files there.
More specific wins.

| File | Scope | Contents |
|---|---|---|
| `~/.claude/CLAUDE.md` | every session | knowledge map: "for X, read Y" |
| `~/brain/CLAUDE.md` | anything in the vault | folder map, naming, frontmatter, update-vs-create, inbox flow, sensitivity |
| `~/brain/people/CLAUDE.md` | people files | append-only logs, open loops, `## Private` rules |
| `~/brain/projects/CLAUDE.md` | project folders | STATUS.md protocol |
| `~/brain/meetings/CLAUDE.md` | meeting notes | structure, action-item format, transcript caveats |
| `~/brain/projects/<slug>/CLAUDE.md` | one project (optional) | read order, people, gotchas |

**Why a hierarchy:** global rules stay short, and local rules only cost tokens when Claude is
actually working in that folder.

## Frontmatter

Every note starts with YAML. Same keys everywhere so skills can grep across folders.

| Key | Values | Required |
|---|---|---|
| `type` | `meeting` `one-on-one` `person` `team` `project` `decision` `daily` `weekly` `note` `inbox` | yes |
| `date` | `YYYY-MM-DD` (creation or meeting date) | yes |
| `updated` | `YYYY-MM-DD` last meaningful edit | people, teams, projects |
| `tags` | list, lowercase kebab-case | no |
| `people` | list of person slugs (no brackets) | when people are involved |
| `project` | one project slug | when relevant |
| `team` | one team slug | when relevant |
| `source` | `plaud` `granola` `fireflies` `zoom` `slack` `email` `manual` | meetings, inbox |

Body text links with `[[slug]]` wikilinks. Action items use `- [ ] @owner-slug what — due YYYY-MM-DD`.

## The STATUS.md pattern

Each project folder has a `STATUS.md` with: `Last updated`, one-line `Phase`, Goal, Why now,
Current state, **Next actions**, Open questions, Decisions, Key files, and a newest-first Log.

**Why it exists:** Claude sessions are stateless. Long projects span dozens of sessions, compactions
and days off. `STATUS.md` is the resumable state: a fresh session reads it and continues without
you re-explaining. The rule is "read it first, update it last". Without the second half the pattern
quietly decays.

Keep it under ~150 lines. Move old log entries to `log-archive.md`. See
`vault/projects/example-checkout-revamp/STATUS.md`.

## Update vs create

| Situation | Action |
|---|---|
| New fact about an existing person/team/project | update that file, dated log line |
| New meeting / decision / day / week | create a dated file from `templates/` |
| Entity mentioned once | just `[[link]]` it, no file |
| Entity mentioned twice+ | create from template |
| Contradiction | update, keep the old line under History with a date |
| Unsure | drop in `inbox/` and flag it |

Always search before creating (`grep -ril "jane" ~/brain`). Duplicates are how vaults rot.

## Inbox → triage

1. Skills drop raw material in `inbox/` (transcripts, digests).
2. Triage turns each item into: a meeting note, appended facts in people/project files, action items
   copied to owners' open loops, ADRs for real decisions.
3. The inbox file gets `triaged: YYYY-MM-DD` and is deleted after ~14 days.

**Why an inbox:** ingestion and judgement are separate jobs. Automated skills can capture at 6am
without deciding where things go; triage (by a skill or by you) is where mistakes get caught.

## Getting started

1. Fill in `me/about-me.md` and `me/current-focus.md` (15 minutes; highest leverage files).
2. Create person files for your direct reports from `templates/person.md`.
3. Create one `projects/<slug>/STATUS.md` for your top priority.
4. Let the skills do the rest for a week, then prune what you don't use.
