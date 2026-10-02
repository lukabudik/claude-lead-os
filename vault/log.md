---
type: note
date: 2026-10-02
tags: [log]
---

# Log

Append-only timeline of what changed in the vault. Every skill that writes to the vault adds one
line at the bottom when it finishes. Never edit or reorder past lines. Pattern from Andrej
Karpathy's llm-wiki `log.md` (gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

Format, one line per run: `- YYYY-MM-DD HH:MM <skill> <what changed> [[links]]`

- Recent activity: `grep '^- 2026-10' log.md | tail -20`
- One skill's history: `grep ' plaud-daily-ingest ' log.md`
- Everything touching a page: `grep '\[\[example-jane-doe\]\]' log.md`

The SessionStart hook injects the last 10 lines, so a new or compacted session knows what just
happened. Example lines (fictional) below; delete them once real runs start.

- 2026-10-01 07:31 plaud-daily-ingest 1 meeting ingested, 1 person and 1 STATUS updated [[example-2026-10-01-checkout-revamp-sync]] [[example-jane-doe]] [[example-checkout-revamp]]
- 2026-10-02 08:00 morning-brief brief written, 3 priorities (2 on goals G1, G2) [[example-2026-10-02]]
