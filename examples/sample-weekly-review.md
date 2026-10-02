---
type: weekly
date: 2026-10-02
week: 2026-W40
tags: [weekly]
people: [alex-morgan, priya-shah, marco-rossi, jordan-kim, sam-lee, elena-ivanova, tomas-berg, nia-okafor]
source: weekly-second-brain
---

> **Example output.** Fictional company (Acme), fictional people. Produced by
> `weekly-second-brain` at 15:30 on Friday from the week's daily notes, meeting notes, and
> DMs, with the `team-health-radar` flags block added by that skill. `## My reflection` is
> human-written.

# Week 2026-W40 (Sep 28 – Oct 2)

<!-- weekly-second-brain:start -->
## Wins
- Checkout incident handled well end to end: 34-min outage, fix live at 50% within 24h, blameless review, alert threshold fixed in the meeting ([[2026-10-01-checkout-incident-review]])
- Onboarding-v2 experiment reached sample size two days early; readout delivered Friday ([[2026-10-02]] digest)
- Release train moved to Wednesdays with agreement from all EMs, no escalation needed ([link](https://acme.slack.com/archives/C0EXAMPLE3/p1759370000000400))
- Senior EM search: final round done for candidate B; scorecard complete (`people/candidates/`)

## Decisions
- Payment-retry fix to 100% on 2026-10-05 with automatic rollback guard (owner: [[priya-shah]]) — [[2026-10-01-checkout-incident-review]] (no ADR)
- Token-service client is owned by platform; checkout gets a migration guide (owner: [[marco-rossi]]) — [[2026-10-02-token-service-client-ownership]]
- Release train Tue → Wed from 2026-10-07 (owner: [[marco-rossi]]) — (no ADR)
- Payment-failure dashboard switches to deduplicated source 2026-10-05 (owner: [[tomas-berg]]) — (no ADR)

## Risks
- **Checkout on-call load**: 5 pages in 2 weeks, 3 out of hours, rotation of 4. Mitigation agreed in 1:1, depends on borrowing 2 engineers from growth ([[priya-shah]] 1:1 log)
- **Token-service, second spike** on Thursday, different cause (DB failover). Two incidents on one service in a week; post-mortem due 2026-10-06
- **Q4 planning offsite moved to 2026-10-14** and now clashes with the platform architecture review. Unresolved
- **Mobile contractor extension** needs approval by today and a budget line nobody has confirmed ([[2026-10-02]] inbox)

## Open loops by person
- **[[alex-morgan]]**: [ ] @me hiring plan — due 2026-10-04 · [ ] @me contractor extension approval — due 2026-10-02
- **[[marco-rossi]]**: [ ] @me headcount input for Q4 planning — due 2026-10-05
- **[[priya-shah]]**: [ ] @me written feedback on on-call proposal — due 2026-10-05 · [ ] @priya-shah post-mortem — due 2026-10-06
- **[[sam-lee]]**: [ ] @me ask about lending 2 engineers to checkout on-call — due 2026-10-06
- **[[jordan-kim]]**: [x] @jordan-kim migration guide — done 2026-10-02
- **[[tomas-berg]]**: [ ] @tomas-berg retry-impact query — due 2026-10-05

## Themes
- **Ownership gaps cause incidents, not code.** The token-service client, the payment dashboard source, and the release-train comms all had "both teams thought the other owned it" moments this week (incident review, eng-leads thread, group DM).
- **Decisions waiting on me.** Three items sat 2+ days for my answer (client ownership, headcount input, rotation feedback). Pattern seen in W38 too.

## Projects
- [[checkout-reliability]] — fix at 50%, 100% Monday; STATUS updated 2026-10-01
- [[payments-migration]] — retry policy added to risk list; no date change
- [[onboarding-v2]] — readout delivered; decision on rollout next week
- [[hiring-senior-em]] — finals done, decision pending
- [[q4-planning]] — draft circulated to EMs; offsite date clash unresolved
- [[mobile-app-performance]] — no activity

## Focus check
| Focus (from `me/current-focus.md`) | This week |
|---|---|
| 1. Checkout reliability to target by end of Q4 | **moved**: root cause found, fix shipping |
| 2. Hire senior EM for platform | **moved**: final round done |
| 3. Q4 plan agreed with leadership | **stalled**: offsite moved, my headcount input still open |
| 4. Mobile performance | **not touched**: third week in a row |

## Next week
1. Monday: confirm retry 100% rollout and the guard held; tell [[alex-morgan]] in the daily update
2. Send headcount input to [[marco-rossi]] before Monday EOD; resolve offsite clash
3. Make the senior EM hire / no-hire call with the panel
4. Talk to [[sam-lee]] about on-call support for checkout
5. Either schedule mobile performance time with [[nia-okafor]] or drop it from focus explicitly
<!-- weekly-second-brain:end -->

<!-- team-health-radar:start -->
## Team flags
- **Checkout** — incidents red ↑, sentiment amber: on-call load raised in retro and review. Action: rotation change via [[sam-lee]] (in progress). [teams/checkout.md](../teams/checkout.md)
- **Platform** — dependencies amber →: 2 open asks from checkout and growth, oldest 6 days. Action: ask [[marco-rossi]] at Monday leads sync for an owner per ask.
- **Mobile** — delivery amber ↓: 64% of cycle 41 committed scope done, second cycle trending down; contractor extension pending. Action: 1:1 with [[nia-okafor]] next week, open question rather than diagnosis.
<!-- team-health-radar:end -->

## My reflection
<!-- human-owned -->
Good week on the incident; Priya carried it. The real lesson is the theme: I am the bottleneck on three decisions. Next week: answer within 24h or say when I will. Mobile performance keeps slipping; if it is not in focus in practice, take it off the list so the team knows.
</content>
</invoke>
