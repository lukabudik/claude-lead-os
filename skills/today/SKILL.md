---
name: today
description: Open today's daily note and give a 10-line brief - top 3, calendar, open loops due, what needs a reply. Creates the note from the template if missing and runs morning-brief if the Brief section is empty. Invoke as /today.
disable-model-invocation: true
allowed-tools: Bash(date *)
---

# /today

Today is !`date "+%Y-%m-%d %A, ISO week %G-W%V"`.

Vault root: `$BRAIN_DIR` (default `~/brain`).

1. Path: `daily/<today>.md`. If it does not exist, create it from `templates/daily.md`
   (replace the `YYYY-MM-DD` placeholders, set the weekday).
2. If the `## Brief` section is empty or only has template placeholders, run the
   `morning-brief` skill and let it fill the note. Otherwise do not regenerate.
3. Reply in chat with at most 10 lines:
   - **Top 3** (from Brief)
   - **Next meeting** and whether prep exists (link to it, or suggest `/prep <meeting>`)
   - **Open loops due today or overdue** (`- [ ]` items with `due <= today` across
     `people/` and today's note; `grep -rn "\- \[ \].*due 20" people daily`)
   - **Needs a reply** (Act items from the Digest / Inbox blocks, if present)
4. End with the file path of today's note. Do not paste the whole note.

Read-only apart from creating the note and running morning-brief. Never send messages.
