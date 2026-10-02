---
name: interview-debrief
description: Turn interview notes or a transcript into a structured, evidence-based scorecard against the role's competencies, with a hire / no-hire recommendation for the user to confirm. Strips anything about protected characteristics. Stores under people/candidates/ with a retention date. Use when the user says "debrief this interview", "write up the interview", "scorecard for <candidate>", or drops interview notes or a recording.
argument-hint: "<notes file, transcript file, or recording name> [role-slug]"
---

# interview-debrief

Good hiring decisions come from evidence collected against criteria agreed before the
interview, written up the same day. This skill does the write-up: it maps what the candidate
said and did to each competency, flags gaps you did not probe, and keeps the record clean of
anything that must not influence a hiring decision.

## Inputs

| Input | Source | Default |
|---|---|---|
| Notes / transcript | `$0`: a file path, an `inbox/` file, or a recording name (Plaud / Granola / Fireflies MCP) | ask |
| Role | `$1`, slug of a scorecard in `knowledge/hiring/<role-slug>.md` | ask; offer to create from the template below |
| Interview type | from notes or ask: screen, technical, system design, leadership, values, final | |
| Other interviewers' feedback | only if the user pastes it | |
| Vault root | `$BRAIN_DIR` | `~/brain` |

Role scorecard file (`knowledge/hiring/<role-slug>.md`) lists 4-7 competencies, each with a
one-line definition and what "strong" vs "weak" evidence looks like, and the 1-4 rating scale.
If it does not exist, draft one with the user first. Do not score against invented criteria.

## Procedure

1. **Consent check.** If the source is a recording, confirm the candidate was told it was
   recorded. If the user is unsure, stop and say so. Many jurisdictions require consent.
2. **Read the notes** in full. Identify the questions asked and the candidate's answers.
3. **Redact before analysing.** Drop anything about: age, family or pregnancy plans, marital
   status, health or disability, religion, ethnicity or national origin, sexual orientation,
   gender identity, political views, union membership, or anything similar under local law.
   Also drop appearance, accent, and "culture fit" phrased as similarity to the team. If the
   candidate volunteered such information, do not record it; note only "candidate shared
   personal information, not recorded".
4. **Map evidence to competencies.** For each competency: 1-3 concrete evidence bullets
   (what they said or did, with a short quote where useful and a timestamp if from a
   transcript), then a rating on the role's scale, then confidence (high / medium / low,
   based on how much evidence exists).
5. **Flag gaps.** Competencies with no or thin evidence get `not assessed` instead of a guess,
   with a suggested question for the next interviewer.
6. **Red flags / concerns.** Only job-relevant ones (for example: contradicted their own
   example, could not explain a decision they claimed to own). Evidence required.
7. **Recommendation.** Strong hire / hire / no hire / strong no hire, as a draft for the user
   to confirm, with the 2-3 reasons that drive it. If the user disagrees, record their call
   and reasoning, not yours.
8. **Write** the scorecard and update the pipeline index. Do not write to `people/` proper
   until the person is hired.

## Output

`people/candidates/YYYY-MM-DD-<role-slug>-<candidate-initials-or-id>.md`:

```markdown
---
type: interview
date: 2026-10-02
tags: [hiring, senior-em]
role: senior-em
stage: leadership
interviewer: me
recommendation: hire          # draft until confirmed: true
confirmed: false
retain_until: 2027-04-02      # date + retention period from .config, default 6 months
source: plaud
---
# Senior EM — Candidate B — leadership interview

## Summary
Two sentences: overall signal and the main reason.

## Scorecard
| Competency | Rating (1-4) | Confidence | Evidence |
|---|---|---|---|
| Delivery leadership | 3 | high | Ran a 3-team migration; explained how they cut scope at week 6 ("we dropped the admin UI, nobody used it") |
| Coaching | not assessed | — | Suggested question: "Tell me about someone you helped grow into a bigger role." |

## Concerns
## Recommendation (draft)
## Next interviewer should probe
```

Also append one line to `people/candidates/README.md` (pipeline index): date, role, candidate
id, stage, recommendation, retain_until.

After writing, append one line to `log.md` that names the role only, never the candidate or the
file (`log.md` is not gitignored, `people/candidates/` is):
`- 2026-10-02 18:00 interview-debrief scorecard written for role senior-em`.

## Guardrails

- **No protected-characteristic content, ever**, even if it was said in the interview.
- **Evidence over impressions.** Every rating needs at least one evidence bullet. No
  personality labels ("seems arrogant"); describe behaviour ("interrupted twice to redirect to
  their own project").
- **Use a candidate id or initials in filenames**, not full names. Full name only inside the
  file if the user wants it.
- **Retention.** Every file has `retain_until` (default 6 months, set
  `candidates_retention_months` in `.config/interview-debrief.yaml` per your company policy
  and local law, e.g. GDPR). `kb-gardener` lists expired files for deletion.
- **Never share outside the vault** except into the company's applicant tracking system, and
  only when the user copies it there. No Slack posts, no email drafts with scorecard content.
- `people/candidates/` should be excluded from any sync or shared remote. Recommend adding it
  to `.gitignore` if the vault is a git repo.
- The recommendation is a draft. The hiring decision is the user's and the panel's.
</content>
</invoke>
