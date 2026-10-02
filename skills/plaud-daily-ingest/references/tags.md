# Tag taxonomy

Shared by every skill that writes notes. Lowercase, kebab-case, `namespace/value`. 3-6 tags per
note. Prefer existing tags: before inventing one, grep the vault
(`grep -rhoE "tags: \[.*\]" $BRAIN_DIR/meetings | tr ',' '\n' | sort | uniq -c | sort -rn`).

## meeting/ (exactly one, mandatory on meeting notes)

| Tag | Use for |
|---|---|
| `meeting/1on1` | Two people, recurring, one is a report/manager/peer |
| `meeting/standup` | Daily or short status sync |
| `meeting/planning` | Roadmap, sprint/cycle, quarterly planning |
| `meeting/review` | Demo, design review, retro, post-mortem |
| `meeting/decision` | Meeting held to make a specific call |
| `meeting/incident` | Live incident call or war room |
| `meeting/interview` | Hiring interview (store only logistics, never candidate assessment) |
| `meeting/external` | Vendor, partner, customer, agency |
| `meeting/all-hands` | Town hall, tribe/department meeting |
| `meeting/workshop` | Brainstorm, discovery, offsite session |

## topic/ (1-3)

`topic/roadmap` · `topic/delivery` · `topic/quality` · `topic/architecture` · `topic/hiring` ·
`topic/org` · `topic/process` · `topic/budget` · `topic/metrics` · `topic/customer` ·
`topic/vendor` · `topic/security` · `topic/experiment` · `topic/strategy` · `topic/onboarding`

`topic/hiring` and `topic/org` mark that the subject came up. They are not permission to store
candidate opinions, reorg names, or anyone's performance.

## team/ (0-2)

`team/<team-slug>`, matching a file in `teams/`. Add new team tags only when a `teams/` file
exists.

## has/ (0-3, machine-checkable flags)

| Tag | Meaning |
|---|---|
| `has/decisions` | Note contains at least one decision |
| `has/actions-mine` | At least one action item owned by the vault owner |
| `has/risk` | A risk or blocker was raised |
| `has/sensitive` | Something was flagged and not stored |
| `has/followup` | Explicit follow-up meeting or check-in agreed |

## Not tags

- **Project**: goes in the `project:` frontmatter key, not in tags.
- **People**: go in `people:`, not in tags.
- **Dates, weekdays, "important"**: never.

## Examples

```yaml
tags: [meeting/planning, topic/roadmap, team/platform, has/decisions, has/actions-mine]
tags: [meeting/1on1, topic/onboarding, has/followup]
tags: [meeting/incident, topic/quality, team/checkout, has/risk]
```
