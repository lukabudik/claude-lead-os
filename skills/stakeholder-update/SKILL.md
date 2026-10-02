---
name: stakeholder-update
description: Draft a short daily or weekly update to your manager (CPO/CTO/CEO) or a key stakeholder from the vault - problem, evidence, ask - with every number traced to a source and gaps marked instead of filled. Use when the user asks for "an update for my boss", "EOD update", "weekly update to <manager>", "status update", "what should I tell <stakeholder>", or when run by the end-of-day job. Drafts only; never sends.
argument-hint: "[daily|weekly] [recipient-slug]"
---

# stakeholder-update

Senior stakeholders read many updates a day. The ones that land are short, start from the
problem, show the evidence, and end with a clear ask. This skill drafts that from what is
already in the vault, so writing the update takes two minutes of editing instead of twenty
of remembering.

## Inputs

| Input | Source | Default |
|---|---|---|
| Cadence | `$0` | `daily` |
| Recipient | `$1`, a person slug | `reports_to` in `me/current-focus.md`, else ask |
| Vault root | `$BRAIN_DIR` | `~/brain` |
| Window | daily: today since 00:00; weekly: Monday to now | |
| Recipient preferences | `people/<recipient>.md` Snapshot ("Working style", "Cares about") and `.memory/` feedback about them | |
| Previous updates | `## Sent updates` log in the recipient's person file | for continuity |

Sources inside the vault: today's / this week's `daily/` notes (Brief, Digest, Log),
`meetings/` in the window, `projects/*/STATUS.md` changed in the window
(`find projects -name STATUS.md -newermt <date>`), `decisions/` in the window,
`weekly/` (weekly cadence), `me/current-focus.md`.

Optional live sources, read-only and only if the user asks: Slack (what shipped in team
channels), tracker (issues closed today).

## Procedure

1. **Load the recipient.** Read their person file and any memory about them. Note what they
   care about, their preferred format, and anything they rejected before (for example "do not
   show a prototype without the customer problem and data").
2. **Collect candidate items** from the window: shipped work, decisions made, risks that
   moved, things waiting on the recipient, numbers that changed. Each item keeps its source
   path.
3. **Filter through current focus.** Keep items that touch a focus bet or something the
   recipient cares about. Drop internal mechanics (refactors, ceremonies) unless they unblock
   a focus item. Aim for 3 workstreams maximum.
4. **Shape each item** as:
   - **Problem / context**: one line, the customer or business problem, not the solution.
   - **Evidence / status**: what happened, with numbers only if a source contains them.
   - **Ask** (if any): a decision phrased as yes/no, with the default if no answer by a date
     the user gives. No ask? Say "FYI, no action".
5. **Mark gaps, do not fill them.** A number that is not in the vault becomes `[NUMBER: what
   it is, where to get it]`. A date nobody set becomes `[DATE?]`. Never estimate.
6. **Add a "not done" line.** State plainly what slipped or is still open. Do not soften it and
   do not stack caveats to pre-empt objections.
7. **Trim.** Daily: under 120 words. Weekly: under 250 words. No background section, no
   preamble, no sign-off fluff. If over the limit, cut the lowest-priority workstream, not
   the asks.
8. **Self-check** before showing: every number has a source; every ask is a yes/no; the
   first line of each item is a problem, not an artifact link. Optionally run the
   `reviewer` subagent on the draft.
9. **Show the draft in chat** with sources listed below it. On approval, log it.

## Output

Draft written to today's daily note in a marked block, and shown in chat:

```markdown
<!-- stakeholder-update:start -->
## Update draft for [[alex-morgan]] (daily, 2026-10-02)

**Checkout reliability**: failed payments on mobile were the top support driver last week.
Retry fix is live for 50% of users; failure rate [NUMBER: 3-day failure rate, payments dashboard].
Ask: roll out to 100% on Monday? Default yes unless you object.

**Hiring, senior EM**: two finalists, debriefs done. Ask: 30 min with the preferred candidate
this week, yes/no?

**Not done**: onboarding-flow experiment slipped; design review moved to [DATE?].

Sources: daily/2026-10-02.md, projects/checkout-reliability/STATUS.md,
people/candidates/2026-09-30-senior-em-finalist-b.md
<!-- stakeholder-update:end -->
```

After the user confirms they sent it (in whatever form), append one line to the recipient's
person file under `## Sent updates`: `- 2026-10-02: daily update, asks: retry rollout, candidate call`.

## Guardrails

- **Draft, never send.** This skill has no permission to post to Slack or email. The user
  copies the text. If a Slack draft tool is available, it may create a draft only on an explicit yes.
- **Never invent numbers, dates, or quotes.** Placeholders are better than plausible guesses
  that end up in front of an executive.
- **Do not leak.** Nothing from `## Private`, `people/candidates/` beyond "finalist A/B", or
  team radar sentiment notes goes into an update.
- **No individual blame.** Problems are described at team or system level.
- Keep the recipient's language preference if their person file states one.
</content>
</invoke>
