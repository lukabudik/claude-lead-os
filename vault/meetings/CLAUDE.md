# meetings/ — local rules

One processed note per meeting: `YYYY-MM-DD-<slug>.md`, from `templates/meeting.md`
(1:1s use `templates/one-on-one.md`, but the 1:1 log also lives in the person file).

- Slug = meeting name, kebab-case: `2026-10-02-platform-weekly-sync.md`. Two meetings with the same
  name on one day: add `-2`.
- Frontmatter must include `type`, `date`, `people` (slugs of attendees), and `source`
  (plaud | granola | fireflies | zoom | manual). Add `project` / `team` when there's a clear one.
- Structure: **TL;DR** (3 bullets max) → **Decisions** → **Action items** → **Notes**. A reader
  should get 80% from the TL;DR.
- Action items: `- [ ] @owner-slug what — due YYYY-MM-DD`. Copy each one into the owner's person
  file under `## Open loops` so it's findable from both sides.
- Decisions that change direction for a team or project also become an ADR in `decisions/`;
  link it here.
- Don't paste the raw transcript. Link the original (recorder URL or `inbox/` file) under `source_ref`.
- Transcripts mis-hear names. If a name doesn't match a file in `people/`, flag it as
  `[[?unknown-name]]` instead of inventing a person.
