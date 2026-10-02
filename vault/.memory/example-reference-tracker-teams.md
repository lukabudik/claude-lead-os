---
name: example-reference-tracker-teams
description: "Which tracker team gets which kind of issue (UI vs platform vs growth), so issues land in the right queue."
metadata:
  type: reference
---

> EXAMPLE MEMORY — shows the format. Delete once you have real memories.

| Kind of work | Team key |
|---|---|
| Web/app UI, UX, front-end performance | `WEB` |
| APIs, data pipelines, infra | `PLAT` |
| Experiments, SEO, acquisition content | `GROW` |

**Why:** Issues filed to the wrong team sat untriaged for two weeks (2026-06). Each team only
watches its own queue.

**How to apply:**
- Pick the team by where the code change lands, not by who asked for it.
- Mixed work: file under the team doing most of it and link the rest.

Related: [[example-feedback-tracker-default-state]]
