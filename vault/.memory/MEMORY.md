<!--
MEMORY.md is the index of Claude's auto-memory pool. Claude Code loads this file into context at
the start of every session (point `autoMemoryDirectory` in ~/.claude/settings.json at this folder).

Rules:
- One line per memory: - [Title](file.md) — one-line hook (what + when it matters)
- Each memory is its own file: one fact (or one tightly related cluster) per file.
- Frontmatter per file: name, description, metadata.type (user | feedback | project | reference).
- Body: the fact, then **Why:** and **How to apply:**. Link related memories with [[slug]].
- Only the first 200 lines or 25KB of this index (whichever comes first) load each session.
  Anything past that is invisible. Topic files are read on demand. Keep the index well under that. Prune or merge before adding when it passes ~150 lines.
- Memories are for things that change Claude's behaviour. Project state belongs in
  projects/<slug>/STATUS.md, facts about people in people/<slug>.md — link, don't copy.
Delete the two example entries once you have real memories.
-->

- [Example: no Backlog for planned work](example-feedback-tracker-default-state.md) — new tracker issues for committed work default to Todo, not Backlog
- [Example: tracker conventions reference](example-reference-tracker-teams.md) — which tracker team gets which kind of issue
