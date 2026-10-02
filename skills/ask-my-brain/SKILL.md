---
name: ask-my-brain
description: Answer a question from the vault only, with a citation (file path) for every claim, and say "not in the vault" rather than guessing. Offers to save new facts as a memory or note. Use when the user asks "what do we know about...", "when did we decide...", "what did <person> say about...", "remind me...", "search my notes", or any question whose answer should come from their own notes rather than general knowledge.
argument-hint: "<question>"
---

# ask-my-brain

The vault is only useful if you can get answers out of it faster than you can remember them.
This skill searches it, answers in a few lines, and shows exactly where each fact came from.
It does not fill gaps with general knowledge.

## Inputs

| Input | Source |
|---|---|
| Question | `$ARGUMENTS` |
| Vault root | `$BRAIN_DIR`, default `~/brain` |

For a wide question across many files, delegate the search to the `kb-researcher` subagent
(if installed) to keep the main context clean; it returns the same cited format.

## Procedure

1. **Parse the question** into entities (people, teams, projects), time range, and question
   type (fact, decision, history, "who owns", "what's open").
2. **Search in this order**, stopping when you have enough:
   1. Entity home files: `people/<slug>.md`, `teams/<slug>.md`, `projects/<slug>/STATUS.md`.
      Resolve names to slugs with `ls` and `grep -il`.
   2. `decisions/` for "why / when did we decide".
   3. `meetings/` and `weekly/` filtered by frontmatter: `grep -l "people:.*<slug>"`,
      `grep -l "project: <slug>"`, then by date.
   4. Full-text: `grep -ril "<keyword>" "$BRAIN_DIR" --include=*.md`, excluding `.state/`.
   5. `.memory/MEMORY.md` and memory files for preferences and how-we-work facts.
   Read the actual lines; never answer from filenames.
3. **Resolve conflicts.** If two notes disagree, prefer the newer dated note, and say both
   exist: "Changed on 2026-09-12: was X ([[old]]), now Y ([[new]])."
4. **Answer** in 1-5 sentences or a short table. Every factual sentence ends with a citation:
   `(meetings/2026-09-12-pricing-review.md)` or a `[[wikilink]]`. Quote short phrases when
   wording matters.
5. **Say what is missing.** If the vault has nothing, answer exactly: "Not in the vault." Then
   list where you looked. If it has part, answer that part and say which part is missing. Do
   not add general knowledge unless the user asks, and then label it "outside the vault".
6. **Offer to remember.** If the user's follow-up supplies the missing fact, offer: save as a
   memory (`/remember`, for how-I-work facts and preferences) or as a dated line in the right
   home file (for facts about people/projects). Write only on a yes.

## Output

Chat only, by default:

```markdown
We moved the payments migration to after peak season on 2026-09-12, because the vendor
could not guarantee a rollback window (decisions/2026-09-12-payments-migration-timing.md).
Owner is [[sam-lee]] (projects/payments-migration/STATUS.md). The new target date is
not in the vault; STATUS only says "after peak".

Searched: projects/payments-migration/, decisions/, meetings/ (people: sam-lee).
```

If the user asks to keep the answer, write it to `knowledge/<topic-slug>.md` with the same
citations.

## Guardrails

- **Vault only.** No web search, no Slack/email lookups unless the user asks for them.
- **Never invent** names, dates, numbers, or quotes. A citation must point to a line that
  actually says it.
- **Respect `## Private`.** Content under `## Private` headings and `people/candidates/` is
  used only when the question is explicitly about that person's private/HR context, and is
  never included in anything drafted for others.
- Read-only unless the user approves a write in step 6.
</content>
</invoke>
