---
name: kb-gardener
description: Weekly lint of the second-brain vault. Regenerates index.md (the vault catalog) and lints log.md. Finds stale project STATUS files, orphan notes, broken [[wikilinks]], inbox items untriaged for more than 3 days, duplicate or contradicting memories, people/project duplicates, and a .memory/MEMORY.md index over its size budget. Fixes only safe mechanical issues, reports everything else with a proposed fix. Use when the user says "garden the vault", "lint my brain", "clean up the KB", "check the knowledge base", or when run by the Friday job.
---

# kb-gardener

A second brain rots quietly: duplicates, dead links, STATUS files that lie. This skill checks the
vault the way a linter checks code. It fixes what cannot be wrong and reports the rest.

## Inputs

| Input | Source | Default |
|---|---|---|
| Vault root | `$BRAIN_DIR` | `~/brain` |
| Mode | user arg: `report` or `fix` | `fix` (safe fixes only); headless runs use `fix` |
| Thresholds | `$BRAIN_DIR/.config/kb-gardener.yaml` (optional) | values below |

Default thresholds:

```yaml
status_stale_days: 14        # projects in me/current-focus.md
status_stale_days_other: 30  # everything else
inbox_max_age_days: 3
inbox_delete_after_triaged_days: 14
memory_index_max_bytes: 25000
memory_index_max_lines: 200
status_max_lines: 150
```

No MCP servers needed. Read, Grep, Glob and Edit/Write inside the vault only (this matches the
headless allowlist: no `mv`, no `rm`).

## State file

`$BRAIN_DIR/.state/kb-gardener.json`

```json
{
  "last_run": "2026-10-02T16:30:00Z",
  "open_findings": { "broken-link:meetings/2026-09-12-x.md:[[jon-doe]]": "2026-09-25" },
  "ignored": ["orphan:knowledge/old-glossary.md"]
}
```

- `open_findings` = finding key -> first seen. The report shows age, so repeat offenders stand out.
- `ignored` = keys the owner said to ignore ("ignore that orphan"). Never report them again.
- Findings that disappear are removed from `open_findings`.

## Checks

Run all checks, collect findings as `{key, severity, file, detail, fix, safe}`.

| # | Check | How | Severity |
|---|---|---|---|
| 1 | **Stale STATUS** | `Last updated:` in `projects/*/STATUS.md` (excluding `_archive/`) older than threshold; focus projects from `me/current-focus.md` use the stricter one | high (focus) / low |
| 2 | **STATUS too long** | over `status_max_lines` | low |
| 3 | **Broken wikilinks** | every `[[target]]` / `[[target\|alias]]` must resolve to a file named `target.md` anywhere in the vault, or to a project folder `projects/target/`. Ignore `[[?unknown-name]]` (intentional placeholders, but count them); ignore links inside `log.md`, which is history and may name deleted pages | medium |
| 4 | **Orphan notes** | files in `knowledge/`, `decisions/`, `projects/*/` (not STATUS) with no inbound `[[link]]` from anywhere except `index.md` and `log.md` (those link to everything) | low |
| 5 | **Untriaged inbox** | `inbox/*.md` without `triaged:` frontmatter and older than `inbox_max_age_days` (by filename date) | medium |
| 6 | **Triaged inbox expired** | `triaged:` older than `inbox_delete_after_triaged_days` | low |
| 7 | **Duplicate entities** | people/projects with near-identical slugs (`jane.md` vs `jane-doe.md`, same first+last in different order, edit distance <= 2) or same email in frontmatter | high |
| 8 | **Missing frontmatter** | notes without `type` or `date` | low, safe when inferable |
| 9 | **Frontmatter drift** | `people:` entries with brackets or display names instead of slugs; tags not lowercase kebab | low, safe |
| 10 | **Overdue open loops** | `- [ ] @me ... — due YYYY-MM-DD` older than 7 days, count per person | medium |
| 11 | **Memory index budget** | `.memory/MEMORY.md` over `memory_index_max_bytes` or `memory_index_max_lines` | high |
| 12 | **Memory index integrity** | index lines pointing to missing files; memory files not in the index | medium, safe for missing-from-index |
| 13 | **Duplicate / contradicting memories** | memory files with overlapping names or descriptions; pairs that state different values for the same fact (dates, owners, tool choices) | medium |
| 14 | **Sensitive content leak** | grep for patterns: `password`, `api[_-]?key`, `token:`, `BEGIN .* PRIVATE KEY`, long hex/base64 strings, salary/comp keywords outside `## Private` sections | high, never auto-fix |
| 15 | **Example files left** | files starting with `example-` once the folder has 3+ real files | low |
| 16 | **Expired candidate files** | `people/candidates/*.md` older than the retention in `.config/interview-debrief.yaml` (default 180 days, by `date:`) | high, report-only: list for deletion, never delete automatically |
| 17 | **Log lint** | `log.md` lines after the header that are not `- YYYY-MM-DD HH:MM <skill> ...`; timestamps out of order; a skill whose `.state/<skill>.json` shows a run since the last gardener pass but has no log line for that day (silent writer); over 2,000 lines | low (malformed, order) / medium (silent writer, size); report-only, never rewrite past lines |

For check 13, read candidate pairs and judge; do not flag two memories just for sharing a word.

## Index (regenerated on every run, both modes)

`index.md` is the vault's catalog, read first by `ask-my-brain` and by any session looking for
something (Karpathy's llm-wiki: "the index file is enough" at hundreds of pages, no vector DB).
Rebuild everything between `<!-- kb-gardener:index:start -->` and `<!-- kb-gardener:index:end -->`;
leave the text outside the markers alone. Create the file with both markers if missing.

- Header line: `_Generated <date> by kb-gardener · <N> pages · dated streams summarised, not listed_`.
- One section per entity folder, in this order: Me (`me/current-focus`, `me/goals`), Projects,
  People, Teams, Decisions, Knowledge. One line per page, sorted by slug:
  `- [[slug]] — <one-line summary> · updated <date>`. Summary source, in order: frontmatter
  `description` or `role`, the STATUS `Phase:` line, the ADR title, the first sentence of the body.
  Max ~15 words. Skip `example-` files once real ones exist, `_archive/`, and `people/candidates/`
  (never list candidates).
- `## Dated streams` table for `meetings/`, `daily/`, `weekly/`, `inbox/`: count, date range,
  latest note. These folders grow daily; list them as counts, not pages.
- Over 300 entity lines: list projects in `current-focus.md` and people with `relationship:`
  set in full, and the rest as counts per folder. Report that grep or `qmd` should take over.

## Safe fixes (applied in `fix` mode)

Only these. Everything else is reported.

| Finding | Fix |
|---|---|
| Missing `type`/`date` | add from folder (`meetings/` -> `meeting`) and filename date |
| `people:` drift | normalise `[[Jane Doe]]` / `Jane Doe` to `jane-doe` **only** when `people/jane-doe.md` exists |
| Tag case | lowercase / kebab-case tags |
| Memory file missing from index | append an index line using the file's `description` |
| Broken link with exactly one obvious target | e.g. `[[jane]]` and only `people/jane-doe.md` matches -> rewrite to `[[jane-doe]]`; record the change in the report |

Before any write: make sure the file has no unsaved conflicts (skip files modified in the last 10
minutes; the owner may be editing). Never rename, move, merge, or delete notes. Never touch content inside another skill's machine block, `## Private` sections, or
`decisions/` bodies.

## Report-only fixes (proposals)

| Finding | Proposed fix in the report |
|---|---|
| Stale STATUS | "Update or set `Phase: paused`" + last 3 sources mentioning the project since the date |
| Duplicate entities | which file to keep (more inbound links), what to merge, links to rewrite |
| Orphans | suggested parent to link from, or archive |
| Untriaged inbox | one-line summary per item and where it probably belongs |
| Triaged inbox expired | list of files safe to delete (the owner deletes; the skill never does) |
| Memory over budget | specific entries to merge, shorten, or remove, with bytes saved per proposal, until under budget |
| Contradicting memories | which one the vault's newest evidence supports |
| Sensitive leak | file + line number, pattern matched; recommend removing and rotating if it is a credential |
| Log lint | malformed or out-of-order line numbers; for a silent writer, name the skill so its log step gets fixed; over 2,000 lines, propose moving past years to `log/<year>.md` |

## Output

1. Write the report to `daily/<today>.md` between `<!-- kb-gardener:start -->` and
   `<!-- kb-gardener:end -->` (replace on re-run):

```markdown
<!-- kb-gardener:start -->
## KB gardener — 2026-10-02
**Fixed (6):** 3 frontmatter, 2 people slugs, 1 memory index line
**High (2)**
- [ ] STATUS stale 19 days: [[q3-hiring-plan]] (in focus) — mentioned in 2 meetings since
- [ ] MEMORY.md 27.1 KB > 25 KB — merge `release-*.md` (3 files, -1.4 KB), drop `old-vpn-setup.md` (-0.6 KB)
**Medium (4)**
- [ ] Broken link [[jon-doe]] in [[2026-09-12-vendor-review]] (seen since 09-25) — no match
- [ ] inbox/2026-09-27-slack-pricing-thread.md untriaged 5 days — probably projects/pricing
**Low (7):** 4 orphans, 2 example files, 1 long STATUS — see `.state/kb-gardener.json`
<!-- kb-gardener:end -->
```

2. Update the state file.
3. Append one line to `log.md`: `- 2026-10-02 16:30 kb-gardener index rebuilt (412 pages), 6 fixes, 2 high [[2026-10-02]]`.

## Never

- Never print matched secret values in the report; file and line only.
- Never delete files. Never edit `## Private`. Never "fix" a contradiction by choosing a side.

## Final report (≤8 lines)

```
kb-gardener — 2026-10-02 (fix mode)
Scanned 412 notes · index rebuilt · fixed 6 · findings: 2 high, 4 medium, 7 low (3 new, 1 open > 2 weeks)
Report: daily/2026-10-02.md
```
