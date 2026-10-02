---
name: qbr-prep
description: Prepare a quarterly business review (QBR) draft outline from the vault - goals vs outcomes, shipped work, decisions, metric slots, risks, and next-quarter asks - and produce an explicit list of numbers the user must supply instead of inventing them. Use when the user says "QBR", "quarterly review", "prep the quarter", "board/exec review of my area", or "what did we do this quarter".
argument-hint: "[YYYY-Qn]"
---

# qbr-prep

A QBR is mostly archaeology: what did we say we'd do, what happened, what did we learn,
what do we need. The vault already holds most of it in weekly notes, decisions and STATUS
files. This skill assembles the skeleton and tells you which numbers to go and get.

## Inputs

| Input | Source | Default |
|---|---|---|
| Quarter | `$ARGUMENTS` as `YYYY-Qn` | the quarter that just ended (or the current one if more than 8 weeks in) |
| Vault root | `$BRAIN_DIR` | `~/brain` |
| Quarter goals | `me/current-focus.md` (and its History section), `projects/*/STATUS.md` goal lines, any `knowledge/okrs-*.md` | |
| Evidence | `weekly/` notes in the quarter, `decisions/` in the quarter, `meetings/` tagged `qbr`, `planning`, `review`, `teams/*.md` (metrics + Radar), `projects/*/STATUS.md` Log | |
| Fiscal calendar | `.memory/` or `me/` note on fiscal year | calendar quarters |
| Previous QBR | `projects/qbr-<prev-quarter>/` | for continuity: last quarter's asks and commitments |

## Procedure

1. **Fix the window.** Compute quarter start/end dates (respect a fiscal-year memory if it
   exists). List the ISO weeks in it.
2. **Goals.** Extract what was committed at the start of the quarter: focus bets, OKRs,
   project goals, and last QBR's "next quarter" commitments. Each goal keeps its source.
3. **Outcomes per goal.** For each goal, read the project STATUS Log entries and weekly notes
   in the window. Classify: delivered / partially / not delivered / dropped (with the decision
   link if it was dropped deliberately).
4. **Shipped work.** List launches and releases mentioned in weekly notes and STATUS logs, by
   team. One line each, with the source.
5. **Decisions.** All ADRs dated in the quarter, one line each: decision, why, link.
6. **Metrics.** For every metric in `teams/*.md` "Metrics they own" and every metric a goal
   references, create a slot: name, start-of-quarter value, end value, target, source. Fill a
   value **only** if a vault note states it with a date inside the window; cite it. Otherwise
   leave `[ ]` and add it to the "Numbers needed" list with where to get it (dashboard name
   from the team file if present).
7. **Risks and learnings.** Pull from team Radar blocks, project STATUS risk sections, and
   retro meeting notes. Phrase at team/system level. Keep the 3-5 that matter for next quarter.
8. **Next-quarter asks.** Draft placeholders for: headcount, budget, cross-team dependencies,
   decisions needed from leadership. Do not invent sizes or amounts; ask.
9. **Open questions.** List anything ambiguous (a goal with no outcome evidence, a project
   with no STATUS update in 6+ weeks). Ask the user these before finalising.
10. **Write** the outline and show the "Numbers needed" list in chat first.

## Output

`projects/qbr-YYYY-Qn/STATUS.md` (project entry point, `type: project`, `tags: [qbr]`) and
`projects/qbr-YYYY-Qn/outline.md`:

```markdown
---
type: note
date: 2026-10-02
tags: [qbr]
project: qbr-2026-q3
---
# QBR 2026-Q3 — <area> (draft)

## 1. Headline (fill last)
- One sentence: did we hit the quarter? [USER]

## 2. Goals vs outcomes
| Goal | Outcome | Evidence |
|---|---|---|
| Reduce checkout failures | partially | [[checkout-reliability]] STATUS, weekly/2026-W35.md |

## 3. Metrics
| Metric | Start | End | Target | Source |
|---|---|---|---|---|
| Checkout success rate | [ ] | [ ] | 98.5% | target from teams/payments.md |

## 4. Shipped (by team)
## 5. Key decisions
## 6. Risks and learnings
## 7. Next quarter: bets and asks
## Appendix: numbers needed
- [ ] Checkout success rate, Jul 1 and Sep 30 — payments dashboard (teams/payments.md)
```

Chat report: counts (goals, decisions, shipped items), the numbers-needed list, open questions.

## Guardrails

- **Never invent a number.** Not a rounded one, not a "roughly". Empty slot plus a source hint.
- **Never invent a target date** for next-quarter items. Leave `[DATE?]` unless the user gives one.
- **Problem first.** Each next-quarter bet opens with the customer/business problem and its
  evidence, then the proposal.
- **No individual performance content.** People appear as owners, never as assessments.
  Nothing from `## Private` or candidate files.
- Writes only under `projects/qbr-YYYY-Qn/`. Never edits existing STATUS files of other projects.
- Draft only. Turning it into slides is a separate step the user starts.
</content>
</invoke>
