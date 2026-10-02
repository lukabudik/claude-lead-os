# projects/ — local rules

One folder per initiative: `projects/<slug>/`. **`STATUS.md` is the entry point. Read it first,
update it last.** It's the resumable state between sessions: a fresh Claude session with zero chat
history must be able to pick up the project from `STATUS.md` alone.

## Folder shape

```
projects/<slug>/
├── STATUS.md        # required — current phase, last done, next actions, open questions
├── CLAUDE.md        # optional — project-specific rules (read order, people, gotchas)
├── decisions.md     # optional — short local log; cross-team decisions go to ../../decisions/
├── sources/         # optional — original artifacts (docs, exports). Never rewrite; add new versions.
└── *.md             # analyses, drafts, findings — free naming, kebab-case
```

## STATUS.md rules

- Header: `Last updated: YYYY-MM-DD` and a one-line `Phase:`. Update both every time.
- `## Next actions` is a checklist with owners. This is what the next session starts on.
- `## Log` is newest-first, one bullet per session: date, what was done, where the output is.
- Keep it under ~150 lines. When it grows, move old log entries to `log-archive.md` and leave a link.
- Link people as `[[jane-doe]]`, decisions as `[[2026-09-14-checkout-ab-scope]]`, meetings likewise.

## New project

Create when work will span more than one session. Copy `templates/project-status.md` to
`projects/<slug>/STATUS.md`, fill in Goal / Why now / Owner, and add the project to
`me/current-focus.md` if it's a priority.

Finished or killed: set `Phase: done` or `Phase: killed — <reason>`, write the outcome, move the
folder to `projects/_archive/`.
