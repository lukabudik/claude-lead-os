# Running recurring agents: four options

Skills say what to do. Something still has to start them on time. Claude Code gives you four
schedulers, and they differ in one thing that matters a lot for a second brain: whether the run
can see your local vault.

Facts below were checked against the Claude Code docs (Oct 2026, CLI v2.1.287):
[scheduled tasks](https://code.claude.com/docs/en/scheduled-tasks),
[routines](https://code.claude.com/docs/en/routines),
[Desktop scheduled tasks](https://code.claude.com/docs/en/desktop-scheduled-tasks),
[headless mode](https://code.claude.com/docs/en/headless). Routines are a research preview,
so their limits can change.

## Comparison

| | `/loop` (in session) | Cloud routine (`/schedule`) | Desktop scheduled task | launchd / cron + `claude -p` (this repo) |
|---|---|---|---|---|
| Runs on | your machine, inside an open session | Anthropic cloud | your machine, Desktop app | your machine, OS scheduler |
| Laptop must be awake | yes | no | yes, and the app must be open | yes |
| Survives closing the terminal | no (restored on `--resume`, except self-paced loops) | yes | yes | yes |
| Sees your local vault | yes | **no**: fresh clone of GitHub repos only | yes | yes |
| MCP / integrations | whatever the session has | claude.ai connectors (all included by default) or a committed `.mcp.json` | config files + connectors | config files + connectors |
| Permission prompts | inherits the session | none, runs autonomously | per task mode; can stall waiting for you | none: `dontAsk` + allowlist, denied instead of asked |
| Minimum interval | 1 minute | 1 hour | 1 minute | 1 minute (cron) |
| Lifetime | recurring tasks expire after 7 days; 50 tasks per session | until you delete it | until you delete it | until you remove the plist / crontab line |
| Missed run (asleep) | fires once when idle again, no catch-up | n/a | one catch-up run on wake (last 7 days) | launchd: one run on wake; cron: skipped |
| Best for | babysitting something for an afternoon | jobs that must run with the lid closed | point-and-click local schedules | the daily/weekly vault jobs |

## a) `/loop`: babysit something while you are in meetings

`/loop` re-runs a prompt inside the session you have open. It dies with the session.

```text
/loop 30m <prompt>     fixed interval (s, m, h, d; rounded to a clean cron step)
/loop <prompt>         Claude picks the next delay each time, between 1 minute and 1 hour
/loop                  runs ~/.claude/loop.md (or .claude/loop.md) or the built-in maintenance prompt
```

How it behaves:

- Fires between your turns, never mid-response. Times are local.
- Recurring tasks get up to 30 minutes of jitter (or half the interval if it is under an hour).
  Pick an odd minute if timing matters.
- Recurring tasks expire after 7 days. Self-paced loops stop when Claude decides the job is done,
  or when you press `Esc`.
- A fired prompt can invoke a skill (`/loop 1h /slack-daily-digest`) only if Claude is allowed to
  invoke that skill itself. Skills with `disable-model-invocation: true` arrive as plain text.
- `/loop` runs with the session's permissions. If the session asks before sending Slack messages,
  so does the loop. If nobody is at the keyboard, the loop waits at that prompt.
- Ask "what scheduled tasks do I have?" or "cancel the Slack loop" to manage them.

Example loops for a tribe lead. Start one in the vault (`cd ~/brain && claude`) before a meeting
block:

```text
/loop 30m check my Slack mentions and DMs since the last check. For anything that needs me,
draft a reply with slack_send_message_draft and add a line under ## Log in today's daily note.
Do not send anything.

/loop 1h scan #team-channel and the incident channel for new incidents or blocked releases.
If you find one, summarise it in 3 lines in today's daily note under ## Log. Otherwise say
"quiet" in one line.

/loop 20m before each of my meetings today that starts in the next 30 minutes and has no
prep block yet, run /meeting-prep for it.

/loop watch the open PRs in <org>/<repo> that my team is waiting on me to review. Tell me when
one gets new commits or a review request for me. Stop when all are reviewed.

/loop 2h check the tracker for issues in my teams' current cycle that moved to Blocked since
the last check, and list them with owner and blocker.
```

Good habits: say "draft, do not send" in every loop that touches comms; give each loop a stopping
condition; keep loops in a session started from the vault so they write to the right files.

## b) Cloud routines via `/schedule`: no laptop needed

A routine is a saved prompt + repositories + connectors that runs on Anthropic infrastructure on
a schedule, an API call, or a GitHub event. Create one with `/schedule` in the CLI
(for example `/schedule weekdays at 7:37, run the morning brief`) or at
[claude.ai/code/routines](https://claude.ai/code/routines). Manage with `/schedule list`,
`/schedule update`, `/schedule run`.

What you need to know before pointing one at a second brain:

- **It cannot see your laptop.** Each run starts from a fresh clone of the GitHub repositories you
  picked. `~/brain` does not exist there. Neither do your `~/.claude/skills`, your auto memory, or
  MCP servers you added with `claude mcp add`.
- **It runs without permission prompts.** There is no permission-mode picker. Every connected
  claude.ai connector is included by default, write tools included, and Claude can call all of
  them without asking. Remove every connector the routine does not need, on every routine.
- **It acts as you.** Commits carry your GitHub user; Slack messages and tickets use your linked
  accounts. Write "draft only, never send" into the prompt and drop the send-capable connectors
  if you can.
- **Minimum interval is 1 hour.** Scheduling exactly on the hour can start a few minutes late.
- Runs count against your subscription usage. A green run status only means the session did not
  crash; open the run to see what it did.
- Requires a claude.ai subscription login (Pro, Max, Team, Enterprise). Team and Enterprise owners
  can switch routines off for the org.

### Making a vault reachable from the cloud

If you want cloud runs, keep the vault in a **private** GitHub repository:

1. `cd ~/brain && git init && git remote add origin git@github.com:<you>/brain.git`, push it.
   Check `.gitignore` covers `.logs/` and anything sensitive (see `docs/07-security-and-privacy.md`).
2. Commit the skills the routine needs into the vault repo under `.claude/skills/<name>/`
   (copy or vendor them; symlinks into another repo will not resolve in the clone). A routine
   only sees skills committed to the cloned repository.
3. For a local-only integration (for example a Plaud MCP server), either add it as a claude.ai
   connector or declare it in a committed `.mcp.json`. Never commit tokens; use `${VAR}`
   expansion and the cloud environment's credentials.
4. Routines push to a `claude/`-prefixed branch unless the prompt says otherwise. For a personal
   vault, either tell the prompt to commit to `main`, or merge the branch when you review.
   Protect `main` with a GitHub ruleset if you want a review step.
5. On your laptop, `git pull` before you work (or add it to a SessionStart hook) so local and
   cloud runs do not fork the vault.

Trade-off: you gain reliability (runs with the lid closed) and pay with a git workflow and a
vault that now lives on GitHub. For many leaders the local job below is enough.

## c) launchd / cron + `claude -p`: full local access

This is what `install.sh --with-launchd` sets up. The OS scheduler calls `automation/daily.sh`
and `automation/weekly.sh`, which call `automation/run-skill.sh` once per skill:

| Job | When | Chain |
|---|---|---|
| `com.claude-lead-os.morning` | weekdays 07:30 | plaud-daily-ingest -> slack-daily-digest -> morning-brief |
| `com.claude-lead-os.weekly` | Fridays 16:00 | weekly-second-brain -> team-health-radar -> kb-gardener |

What `run-skill.sh` does per skill:

```bash
cd "$BRAIN_DIR"
claude -p "/<skill> <extra prompt>" \
  --permission-mode dontAsk --permission-prompts none \
  --allowedTools <automation/allowed-tools/_base.txt + <skill>.txt> \
  --disallowedTools <automation/allowed-tools/_deny.txt> \
  --max-turns 40 --max-budget-usd 3.00 \
  --append-system-prompt "unattended run: no questions, drafts only"
```

- `/skill-name` in a `-p` prompt is expanded before the run (documented headless behavior).
- `dontAsk` denies anything not on the allowlist instead of waiting for an answer, so a job never
  hangs on a prompt. `--permission-prompts none` (v2.1.259+) also tells Claude not to retry.
- No `--bare`: it would skip the vault CLAUDE.md, skills, hooks and MCP servers, and it does not
  use your subscription login.
- Plus: per-skill lockfile, `caffeinate -i` while running, a wall-clock timeout, logs in
  `$BRAIN_DIR/.logs/<skill>-<date>.log`, and a macOS notification on failure.

Laptop asleep at 07:30? launchd runs the job once when the Mac wakes. `daily.sh` then skips the
morning brief if it is past 11:00 (`CLO_MORNING_CUTOFF`), but still ingests. cron on Linux does
not catch up; use anacron or a systemd timer with `Persistent=true` if that matters.

## d) Desktop scheduled tasks

If you use the Claude Desktop app, its Routines page can also create **Local** tasks: a prompt,
a folder, a schedule and a permission mode, run on your machine while the app is open. It gives
you one catch-up run after sleep. In Manual mode a task stalls on the first permission prompt
until you answer it, so do one **Run now** and approve the tools before trusting the schedule.
It is a fine alternative to launchd if you prefer clicking to plists.

## Which one?

- Daily and weekly vault jobs: **launchd/cron** (or Desktop tasks). They need your local files.
- "Keep an eye on X for the next few hours": **`/loop`**.
- Must run while you are on a plane with the lid shut, and you accept a git-backed vault:
  **cloud routine**, with connectors trimmed to the minimum.
