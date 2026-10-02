---
type: person
date: 2025-03-10
updated: 2026-10-02
tags: [checkout, em]
team: checkout
role: Engineering Manager, Checkout
reports_to: me
relationship: report
---

> **Example output.** Fictional company (Acme), fictional person. This is an excerpt of
> `people/priya-shah.md` right after `one-on-one-prep` ran at 08:05 for the 10:30 1:1
> (triggered by `/prep priya`). The agenda block is machine-written; everything else in the
> file is human-written or appended by other skills. The `## Private` section may inform your
> judgement but is never copied into the agenda.

# Priya Shah

## Snapshot
- **Role:** Engineering Manager, Checkout squad (6 engineers)
- **Team:** [[checkout]]
- **Since:** 2025-03 (in role)
- **Cares about:** reliability, her team not being the "pager team", clear ownership lines
- **Working style:** prefers written context before the meeting; direct; wants decisions, not discussions
- **Current focus:** checkout reliability, payments migration readiness

## Growth
- Goal: lead cross-team work beyond her squad (stated 2026-07 1:1)
- Strengths (observed): incident leadership (ran 2026-10-01 review, timeline-first, blameless), clear written proposals
- Development areas (agreed with her): saying no to scope earlier; delegating incident comms

## Open loops
- [ ] @me feedback on her on-call rotation proposal — due 2026-09-30
- [x] @me intro to [[tomas-berg]] for retry-impact data — done 2026-09-26
- [ ] @me decide token-service client ownership — due 2026-10-02 ([[2026-10-01-checkout-incident-review]])
- [ ] @priya-shah publish post-mortem — due 2026-10-06
- [ ] @priya-shah hiring loop for backend engineer: share shortlist — due 2026-10-09

## 1:1 log

### 2026-10-02
<!-- one-on-one-prep:start -->
**Their topics first.** Ask: what's on your mind this week?

**I owe**
- [ ] @me feedback on the on-call rotation proposal — due 2026-09-30 (**overdue**, 2 days; give it today or say when)
- [ ] @me token-service client ownership — due today; you'll know after the 13:00 platform sync, say so
- [x] @me intro to Tomas — done 2026-09-26

**Follow-ups from last time** ([[2026-09-25-priya-shah-1-1]])
- Backend engineer hiring loop — shortlist due 2026-10-09, anything blocking?
- She wanted to try a "no-meeting Wednesday" for the squad — did it happen?

**Signals since 2026-09-25**
- Ran the incident review on 2026-10-01: timeline first, blameless, 6 clear action items ([[2026-10-01-checkout-incident-review]])
- Raised on-call load in the review: 5 pages in 2 weeks, 3 out of hours, one rotation of 4 ([[2026-10-01-checkout-incident-review]])
- Lowered the alert threshold during the meeting instead of filing a ticket ([[2026-10-01-checkout-incident-review]])
- Asked for an ownership decision in #checkout-squad, unanswered for 2 days ([link](https://acme.slack.com/archives/C0EXAMPLE2/p1759300000000200))
- Recognition: [[jordan-kim]] thanked her publicly for the clear incident timeline ([link](https://acme.slack.com/archives/C0EXAMPLE7/p1759345000000900))

**Growth**
- Goal "lead cross-team work": the token-service ownership fix needs someone to run the checkout-platform handover. Offer it to her, with [[jordan-kim]] as the platform counterpart.

**Questions**
- What would a sustainable on-call look like for your squad by end of Q4?
- The ownership question sat unanswered for 2 days. What should I do differently so you get faster decisions from me?
- Anything from the incident you want me to take to leadership?
<!-- one-on-one-prep:end -->
Notes:
- (human-written after the meeting) Agreed: rotation goes to 6 people by pulling in 2 from growth squad for Q4 (I talk to Sam). She takes the handover lead. Feedback on the proposal given in the meeting; written version by Mon.

### 2026-09-25
- Hiring loop kickoff; she'll own the backend role. Wants to try no-meeting Wednesdays.
- Raised that payments migration timeline feels tight; asked for the risk list to be shared with her squad.

## Context log
- 2026-10-01: ran the checkout incident review; proposed 100% rollout with rollback guard ([[2026-10-01-checkout-incident-review]])
- 2026-09-22: took over post-mortem template ownership for the tribe ([[2026-W39]])

## Private
<!-- never read into agendas, drafts, or summaries -->
</content>
</invoke>
