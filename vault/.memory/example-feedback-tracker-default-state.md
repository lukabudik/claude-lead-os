---
name: example-feedback-tracker-default-state
description: "When creating tracker issues for committed work, default to Todo, not Backlog. Backlog means maybe-never."
metadata:
  type: feedback
---

> EXAMPLE MEMORY — shows the format. Delete once you have real memories.

When creating Linear/Jira issues that represent **committed work** (epic children, sprint items),
set the status to **Todo**. Only use **Backlog** for speculative or parked ideas.

**Why:** On 2026-05-21 I created 15 issues in Backlog by default and the user asked "why are these
in the backlog?". In this team, Backlog means "maybe one day"; committed work there is invisible
in the "what's next" views and makes the project look unstaffed.

**How to apply:**
- Pass the state explicitly when calling the tracker tool; most MCP tools have no smart default.
- Sub-issues under a parent epic also default to Todo.
- If a team has no state literally called "Todo", pick the one whose type is *unstarted*.

Related: [[example-reference-tracker-teams]]
