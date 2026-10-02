---
name: prep
description: One command to prepare for whatever is next - a meeting, a 1:1, or a person. Routes to one-on-one-prep for a person or 1:1 and to meeting-prep for any other meeting. Invoke as /prep <meeting name, time, or person>.
disable-model-invocation: true
argument-hint: "<meeting name | HH:MM | person name>"
allowed-tools: Bash(date *)
---

# /prep

Now: !`date "+%Y-%m-%d %H:%M %A"`

Target: $ARGUMENTS

Vault root: `$BRAIN_DIR` (default `~/brain`).

1. **Resolve the target.**
   - Empty: use the next calendar event starting after now (Calendar MCP, read-only).
   - `HH:MM`: the event at that time today.
   - A name: check `people/` (`ls people | grep -i`) and today's/tomorrow's calendar titles.
   - Ambiguous (two matches): list them and ask. Do not guess.
2. **Route.**
   - Person, or an event with exactly two attendees where the other has a person file with
     `relationship: report | skip-level | manager | peer`: run `one-on-one-prep` for that person.
   - Interview (title contains "interview" or attendee is in `people/candidates/`): open the
     role scorecard in `knowledge/hiring/` and list the competencies still `not assessed` from
     earlier debriefs as suggested questions.
   - Anything else: run `meeting-prep` for that event.
3. Reply with the prep in chat (under 15 lines) and the path where the skill saved it.

Read-only on calendar and Slack. Never send invites, messages, or agenda emails.
