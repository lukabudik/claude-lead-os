---
type: project
date: 2026-08-20
updated: 2026-10-01
tags: [example, checkout, ab-test]
people: [example-jane-doe, sam-rivera]
team: example-payments
status: active
---

# Checkout Revamp — STATUS

> EXAMPLE FILE — fictional project. Delete the `example-` folder once you have real projects.

**Last updated:** 2026-10-01
**Phase:** Build done, A/B launch blocked on payment-provider sandbox (new date 2026-10-13)

## Goal
Lift checkout completion for first-time buyers from 61% to 65% by collapsing three checkout steps
into one page. Measured as completed orders / checkout starts, first-time buyers only.

## Why now
- 39% of first-time buyers who start checkout never finish; returning buyers abandon at 12%.
- Session recordings show the address step is where most drop (support tickets agree).
- Competitors moved to one-page checkout in the last year.

## Owner & people
- Owner: [[example-jane-doe]] (eng), Sam Rivera (product design, no file yet)
- Decider on launch: me

## Current state
- One-page checkout built behind feature flag `checkout_one_page`, 100% of unit/e2e tests green.
- A/B design agreed: 50/50 split, first-time buyers only, 3 weeks minimum, guardrail on payment errors.
- Blocker: payment-provider sandbox fails ~1 in 5 test payments; their support ticket is open.
- Finance wants fee impact numbers before full rollout (not before the test).

## Next actions
- [ ] @example-jane-doe guardrail metrics proposal — due 2026-10-07
- [ ] @me intro Jane to finance partner — due 2026-10-04
- [ ] @sam-rivera final copy review on error states — due 2026-10-08
- [ ] @example-jane-doe launch A/B — target 2026-10-13

## Open questions
- Do we exclude mobile app traffic in the first test? (leaning yes: different checkout code path)

## Decisions
- 2026-09-14 — [[example-2026-09-14-checkout-ab-scope]] test first-time buyers only, not everyone

## Key files
- `analysis.md` — funnel breakdown by step (not included in example)

## Log
- 2026-10-01 — sync with Jane: launch slipped a week (sandbox). See [[example-2026-10-01-checkout-revamp-sync]].
- 2026-09-14 — scoped the A/B to first-time buyers; ADR written.
- 2026-08-20 — project created from Q3 planning.
