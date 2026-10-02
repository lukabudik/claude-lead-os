---
type: meeting
date: 2026-10-01
tags: [meeting/review, topic/incident, team/checkout, has/decisions]
people: [priya-shah, jordan-kim, elena-ivanova, tomas-berg]
project: checkout-reliability
team: checkout
source: plaud
source_ref: plaud:EXAMPLE-7f3a9c
---

> **Example output.** Fictional company (Acme), fictional people. Produced by
> `plaud-daily-ingest` from a 52-minute Plaud recording. The raw transcript stays in Plaud;
> only this processed note lives in the vault. One name the transcript mis-heard is flagged
> as `[[?unknown]]` instead of being guessed.

# Checkout Incident Review — retry storm (2026-09-29)

<!-- plaud-daily-ingest:start -->
**When:** 2026-10-01 14:00, 52 min · **Who:** [[priya-shah]], [[jordan-kim]], [[elena-ivanova]], [[tomas-berg]], [[?dev-on-call]] · **Project:** [[checkout-reliability]]

## TL;DR
- Tuesday's 34-minute checkout outage was a retry storm: clients retried token refresh with no backoff, and the token service fell over under 9x normal load.
- The fix (exponential backoff + jitter, cap of 3 retries) has been live for 50% of mobile users since Wednesday with no repeat. Team recommends 100% Monday with an automatic rollback guard.
- The underlying problem is ownership: nobody owns the token-service client library. Needs a decision this week.

## Decisions
- Ship backoff fix to 100% on 2026-10-05, guarded by an automatic rollback if payment failure rate exceeds the 7-day baseline. (owner: [[priya-shah]]; needs tribe-lead sign-off, see action items)
- Payment-failure dashboard moves to the deduplicated event source on 2026-10-05, so before/after numbers are comparable. (owner: [[tomas-berg]])
- Post-mortem is blameless and published to #engineering, not only #incidents. (owner: [[priya-shah]])

## Action items
- [ ] @me decide token-service client ownership (checkout vs platform) — due 2026-10-02
- [ ] @me sign off 100% rollout and tell leadership — due 2026-10-02
- [ ] @priya-shah publish post-mortem — due 2026-10-06
- [ ] @jordan-kim write migration guide for the token-service API change — due 2026-10-02
- [ ] @tomas-berg share retry-impact query and switch dashboard source — due 2026-10-05
- [ ] @elena-ivanova add "client retry policy" to the payments-migration risk list — due 2026-10-03

## Notes
- **Timeline:** 2026-09-29 19:12 token-service p99 latency up → 19:15 clients start retrying in tight loops → 19:18 token service saturated, checkout errors → 19:31 on-call paged (alert threshold too high, 13 min lost) → 19:46 rate limit applied at the gateway → 19:52 recovered.
- **Impact:** checkout unavailable for most mobile users for 34 min. Order and revenue impact: [[tomas-berg]] to quantify; no number agreed in the meeting.
- **Why it hurt:** three things lined up: no backoff in the shared client, alert threshold set for daytime traffic, and the token-service deploy at 19:05 that added latency.
- **Second spike Thursday** (2026-10-01 21:40, 18 min) was on the same service but a different cause (database failover). [[jordan-kim]] does not think it is related; will confirm in the post-mortem.
- **Ownership gap:** the client library was written by checkout two years ago, platform owns the service. Both teams assumed the other maintained the retry logic. [[jordan-kim]] said platform can own it if checkout stops forking it.
- **On-call load:** [[priya-shah]] raised that checkout has had 5 pages in 2 weeks, 3 of them outside working hours, all on one rotation of 4 engineers. Asked for a rotation change. Parked for her 1:1 with me.
- **Open question:** should the 100% rollout wait for the dashboard source switch? Consensus: no, the rollback guard uses raw error rate, not the dashboard.
- **Alert threshold:** lowered from 5% to 2% error rate, effective immediately ([[priya-shah]] already did it during the meeting).
<!-- plaud-daily-ingest:end -->

## My notes
<!-- human-owned -->
- Good meeting. Priya ran it well: timeline first, no blame, clear asks. Tell her.
- Ownership question is mine to settle today. Lean: platform owns the client, checkout gets a migration guide. Check with Marco at 13:00 sync.

---

**What the skill also did** (from its run report):
- Appended action items to the `## Open loops` of [[priya-shah]], [[jordan-kim]], [[tomas-berg]], [[elena-ivanova]]
- Added a dated line to `projects/checkout-reliability/STATUS.md` `## Log`
- Linked this note from `daily/2026-10-01.md`
- Flagged `[[?dev-on-call]]`: "transcript says 'Daan or Dan', no matching person file, not created"
</content>
</invoke>
