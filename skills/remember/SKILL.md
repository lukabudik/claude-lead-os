---
name: remember
description: Save one durable fact about how the user works, a preference, or a piece of feedback as a memory file in the vault's .memory/ pool and add an index line to .memory/MEMORY.md. Invoke as /remember <fact>.
disable-model-invocation: true
argument-hint: "<fact to remember>"
allowed-tools: Bash(date *)
---

# /remember

Today: !`date "+%Y-%m-%d"`

Fact: $ARGUMENTS

Vault root: `$BRAIN_DIR` (default `~/brain`). Memory pool: `$BRAIN_DIR/.memory/`.

## Is this a memory?

Memories are small, durable facts that change how Claude should behave next time: a
preference ("updates to my manager under 120 words"), a correction ("don't invent dates"),
a reference ("fiscal year starts in May"), a working agreement. If the fact is about a
specific person, team, or project status, it belongs in that home file instead: say so and
offer to append it there (`people/<slug>.md` Context log, `projects/<slug>/STATUS.md` Log).

## Procedure

1. **Dedupe.** `grep -il` key words in `.memory/`. If a memory already covers it, update that
   file (add the new detail with today's date) instead of creating a new one.
2. **Classify** the type: `user` (about me), `feedback` (how to do the work), `project`
   (context about ongoing work), `reference` (where to find something).
3. **Write** `.memory/<kebab-slug>.md`, one fact per file:

   ```markdown
   ---
   name: <kebab-slug>
   description: <one line, specific enough to judge relevance from the index>
   metadata:
     type: feedback
   ---

   <The fact, 1-3 sentences, absolute dates.>

   **Why:** <the reason or incident, if given; else omit>

   **How to apply:** <when this should change behaviour>
   ```

4. **Index.** Append one line to `.memory/MEMORY.md` (create with a `# Memory index` heading
   if missing): `- [<Title>](<slug>.md) — <hook, under 15 words>`. Keep MEMORY.md short; if it
   is over 150 lines, tell the user to run `kb-gardener` to prune.
5. Reply with one line: the file path and the index line.
6. Append one line to `log.md`: `- 2026-10-02 09:12 remember memory added .memory/<slug>.md`.

## Guardrails

- Never store secrets, credentials, health, compensation, or HR details about anyone.
- Never store a claim about another person's character. Observable facts and agreements only.
- Do not paraphrase away the user's meaning; keep their wording for the core fact.
