---
name: team-health-radar
description: Build a per-team health radar from Slack, meeting notes, and the issue tracker (Linear or Jira) - blocked items, incident load, delivery slippage, cross-team dependencies, and professionally-worded morale signals - and write it into teams/<team>.md plus a short list of weekly flags. Use when the user asks "how are my teams doing", "team health", "which squad needs attention", "radar", or when run on the Friday weekly job.
---

# team-health-radar

A tribe lead cannot attend every standup. This skill gives a weekly, evidence-backed view of
each team so attention goes where it is needed. It surfaces signals; it never rates people.

## Inputs

| Input | Source | Default |
|---|---|---|
| Vault root | `$BRAIN_DIR` | `~/brain` |
| Teams | `teams/*.md` (one file per team, frontmatter `type: team`) | all |
| Team config | each team file's frontmatter: `slack_channels`, `tracker_team` (Linear team key or Jira project key), `lead` | ask once, then store |
| Window | argument | last 7 days |
| Previous radar | the existing `## Radar` block in each team file | for trend arrows |

Live sources (read-only): Slack MCP (read channel, search), Linear MCP (`list_issues`,
`list_cycles`) or Jira MCP (JQL search). Vault: `meetings/` with `team: <slug>`, `daily/`
digests, `decisions/`.

If a source is unavailable, mark the affected signals `n/a (no <source> access)` and continue.

## Signals

| Signal | How to measure | Flag when |
|---|---|---|
| Blocked work | tracker issues in Blocked state, or with "blocked" label/comment, open > 2 days | ≥ 3 items, or any blocked > 5 days |
| Delivery slippage | cycle/sprint scope completed vs committed; issues whose due date passed | < 70% completion, or 2 cycles trending down |
| Incident load | incidents/on-call pages in team channels, tracker issues labelled incident/bug-p1 | > 2 in window, or the same service twice |
| Cross-team dependencies | issues blocked on another team; Slack asks to other teams unanswered > 2 days | any dependency on the critical path of a focus project |
| Unplanned work | issues created and started inside the cycle | > 30% of completed work |
| Decision latency | open questions in team channel with no answer > 3 days; decisions waiting on me | any waiting on me |
| Team sentiment | tone in team channels and retro notes: frustration about process, tooling, scope churn, workload | repeated theme in ≥ 2 sources |

Thresholds are defaults. If the team file has a `## Radar thresholds` section, use that.

## Procedure

1. List teams. For each, read the team file. Missing `slack_channels` or `tracker_team`?
   Ask the user once and write them into frontmatter.
2. **Tracker pass**: pull issues updated in the window for `tracker_team`. Compute blocked,
   overdue, cycle completion, unplanned share. Keep issue keys for citations.
3. **Slack pass**: read each team channel for the window (top-level messages, open threads
   with 5+ replies or with incident/blocked/waiting keywords). Note dependency asks to other
   teams and whether they were answered.
4. **Vault pass**: meetings tagged with the team (retros, plannings), decisions affecting it,
   daily digest lines mentioning it.
5. **Score each signal** green / amber / red with one line of evidence and a citation
   (issue key, Slack permalink, or note path). Compare with last week's radar: `↑ ↓ →`.
6. **Sentiment rule.** Describe themes, not people. "Two threads this week question the
   scope change on <project>" is fine. "<Name> seems burned out" is not. Never infer health,
   personal life, or intent. If a signal is about one individual, leave it out of the radar and
   tell the user privately in chat that there is something worth a 1:1 conversation, with the
   source link. Nothing about it is written to the team file.
7. **Write** the radar block into each team file (replace previous block).
8. **Weekly flags**: pick at most 3 teams/issues that need the lead's attention this week,
   each with a suggested next action (ask in 1:1 with the team lead, unblock a dependency,
   escalate to a peer). Write to the weekly note.

## Output

In `teams/<team>.md`:

```markdown
<!-- team-health-radar:start -->
## Radar (2026-W40, generated 2026-10-02)

| Signal | Status | Trend | Evidence |
|---|---|---|---|
| Blocked work | amber | ↑ | 3 blocked, oldest 6d: PAY-412 (waiting on platform API) |
| Delivery | green | → | 18/21 committed done (86%), cycle 41 |
| Incidents | red | ↑ | 3 pages on checkout-api ([thread](https://<workspace>.slack.com/archives/...)) |
| Dependencies | amber | → | 2 open asks to platform, oldest 4d |
| Unplanned | green | → | 12% of completed |
| Decision latency | amber | new | Retry policy question waiting on @me since 2026-09-29 |
| Sentiment | amber | new | Retro + 2 threads: on-call load feels uneven |

**Suggested action:** raise on-call rotation in 1:1 with [[team-lead-slug]]; unblock PAY-412 with platform lead.
<!-- team-health-radar:end -->
```

In `weekly/YYYY-Www.md` (marked block `team-health-radar`): a `## Team flags` section with up
to 3 bullets: team, signal, evidence link, suggested action.

Final chat report: one line per team (overall colour + the worst signal), plus any private
1:1-worthy items from step 6.

After writing, append one line to `log.md` (format in `skills/README.md`), e.g.
`- 2026-10-02 16:20 team-health-radar radar updated, 1 amber->red [[<team>]]`.

## Guardrails

- **Read-only** on Slack and the tracker. No comments, no status changes, no reactions.
- **Signals, not verdicts.** Never write "team X is underperforming". Write what the data shows.
- **No individual metrics.** No per-person velocity, ticket counts, or message counts. These
  are easy to compute and corrosive to trust; the skill does not produce them.
- **Professional wording only.** Anything sensitive about a named person stays out of files.
- Never write to `## Private` sections or to `people/` files from this skill.
- The team file is visible to anyone you share the vault with. Write as if the team lead reads it.
</content>
</invoke>
