---
type: decision
date: 2026-09-14
tags: [example, checkout, ab-test]
people: [example-jane-doe]
project: example-checkout-revamp
status: accepted
supersedes:
---

# 2026-09-14 — Run the checkout A/B on first-time buyers only

> EXAMPLE FILE — fictional decision. Delete once you have real ADRs.

## Context
The one-page checkout targets first-time buyer abandonment. Returning buyers already complete at 88%
and have saved addresses, so they barely see the changed steps.

## Options considered
| Option | Pros | Cons |
|---|---|---|
| All buyers | Faster to reach sample size | Effect diluted by returning buyers; harder to read |
| First-time buyers only | Measures the population we're fixing | ~3 weeks to significance instead of ~1 |

## Decision
Test first-time buyers only, 50/50 split, minimum 3 weeks.

## Why
The hypothesis is about first-time buyers. A diluted result would be uninterpretable.

## Consequences
- Slower read; launch-to-decision is ~4 weeks.
- Check on 2026-11-03: if returning buyers show issues in canary logs, extend.

## Who
- Decider: me
- Consulted: [[example-jane-doe]]
- Informed: payments squad

## Source
- [[example-2026-10-01-checkout-revamp-sync]] (follow-up), original discussion in planning
