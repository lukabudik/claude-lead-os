---
name: capture
description: Drop a thought, task, or snippet into the vault inbox with a timestamp, without breaking flow. Invoke as /capture <text>.
disable-model-invocation: true
argument-hint: "<text to capture>"
allowed-tools: Bash(date *)
---

# /capture

Now: !`date "+%Y-%m-%d %H:%M"`

Text to capture: $ARGUMENTS

Vault root: `$BRAIN_DIR` (default `~/brain`).

1. If the text is empty, ask for it and stop.
2. Append to `inbox/<today>-capture.md` (create with frontmatter `type: inbox`,
   `date: <today>`, `source: manual` if missing) one line:
   `- HH:MM <text>`
   - Text that reads like a task ("ask Sam...", "send...", "follow up...") becomes
     `- HH:MM [ ] @me <text>`. Keep the user's wording; do not invent a due date.
   - Names you can match to an existing `people/<slug>.md` get a `[[slug]]` link. Do not
     create people files.
3. Reply with one line: `Captured to inbox/<file>.` Nothing else. Do not triage now; triage
   happens in the daily or weekly run.

Never store secrets or credentials even if pasted: reply "Looks like a secret, not captured."
