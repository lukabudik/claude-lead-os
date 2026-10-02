# 03 — Memory

Claude Code has **auto-memory**: Claude saves small facts it learns while working with you and
loads them in future sessions. This kit points it at `~/brain/.memory/` so memory lives inside your
vault, under your control, next to everything else.

```json
// ~/.claude/settings.json
"autoMemoryDirectory": "~/brain/.memory"
```

## Memory vs the rest of the vault

| Kind of information | Goes in | Example |
|---|---|---|
| How Claude should behave with you | `.memory/` (type `feedback`) | "Default new tracker issues to Todo, not Backlog" |
| Stable facts about you | `me/` (or `.memory/` type `user` as a pointer) | role, scope, timezone |
| Where something lives / how a system works | `.memory/` (type `reference`) | "Tracker team WEB = UI work" |
| Pointer to a long-running project | `.memory/` (type `project`), linking to STATUS.md | "Checkout revamp lives in projects/checkout-revamp/" |
| Project state, next actions | `projects/<slug>/STATUS.md` | never in memory |
| Facts about a person | `people/<slug>.md` | never in memory |

**Why the split:** memory is loaded every session, so it should only hold things that change
Claude's behaviour. State that changes daily belongs in files Claude reads on demand.

## Format: one fact per file

```markdown
---
name: feedback-tracker-default-state
description: "New tracker issues for committed work default to Todo, not Backlog."
metadata:
  type: feedback        # user | feedback | project | reference
---

The fact, stated plainly.

**Why:** what happened that taught this (with the date).

**How to apply:**
- Concrete rule 1
- Concrete rule 2

Related: [[other-memory-slug]]
```

| Element | Why |
|---|---|
| One fact per file | Easy to update, merge or delete one thing without touching others |
| `description` | Claude decides relevance from the index line + description without opening the file |
| `type` | Lets you prune by kind (stale `project` pointers go first) |
| **Why:** | Without the reason, Claude can't tell when a rule doesn't apply. Rules without reasons get over-applied. |
| **How to apply:** | Turns a lesson into behaviour |
| `[[wikilinks]]` | Related memories reinforce each other; the gardener finds orphans |

See `vault/.memory/example-*.md`.

## The MEMORY.md index

`MEMORY.md` is one line per memory:

```markdown
- [No Backlog for planned work](feedback-tracker-default-state.md) — committed work defaults to Todo
```

**Only the first 200 lines or 25KB of `MEMORY.md` (whichever comes first) load each session.**
Anything past the cutoff is invisible. Individual memory files are read on demand, when the index
line makes them look relevant.

**Budget:** keep the index under ~150 lines and each line under ~150 characters. That leaves
headroom and keeps the always-loaded cost low.

## Pruning

Run monthly (the `kb-gardener` skill does this):

| Check | Action |
|---|---|
| Two memories say the same thing | merge into one, keep the better `Why` |
| A memory contradicts a newer one | delete the old one |
| `project` memory for a finished project | delete; the archived STATUS.md is the record |
| A memory restates something already in `rules/` or `me/` | delete the memory |
| A rule has fired a dozen times and is stable | promote it to `~/.claude/rules/` and delete the memory |
| Index past ~150 lines | prune before adding anything |

## Telling Claude what to remember

- "Remember that ..." → Claude writes a memory file + index line.
- "Forget that ..." → Claude deletes it.
- Corrections you give twice ("no, I said Todo") are exactly what should become `feedback` memories.
  Ask Claude to save them.
