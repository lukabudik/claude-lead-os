# 05 — Loops and automation

A second brain that you have to remember to feed is a diary. This chapter makes it run on its
own: transcripts ingested before you wake up, a digest and a brief waiting at 07:45, a weekly
synthesis on Friday afternoon, all without you typing anything.

## The mental model

| Layer | Answers | Lives in | Example |
|---|---|---|---|
| **Skills** | *what* to do | `skills/<name>/SKILL.md` | `morning-brief`: calendar + open loops -> today's plan |
| **Loops and schedules** | *when* to do it | `/loop`, `/schedule`, launchd/cron | weekdays 07:30, run the morning chain |
| **Hooks** | guardrails and context, every time | `settings.json` `hooks` | SessionStart injects today's focus |

Keep them separate. A skill should not know what time it is scheduled; a schedule should not
contain instructions; a hook should never depend on Claude remembering to do something.
The same `morning-brief` skill runs when you type `/morning-brief` and when launchd fires at 07:30.

## The cadence

| When | What runs | Writes |
|---|---|---|
| Weekdays 07:30 | `plaud-daily-ingest` | `meetings/YYYY-MM-DD-<slug>.md`, people and project logs |
| then | `slack-daily-digest` | `## Digest` in `daily/YYYY-MM-DD.md`, facts into `knowledge/` and STATUS files |
| then | `morning-brief` | `## Brief` at the top of today's daily note |
| During the day, on demand | `meeting-prep`, `one-on-one-prep`, `decision-log` | prep blocks, ADRs in `decisions/` |
| During the day, optional | a `/loop` you start before a meeting block | drafts + `## Log` lines |
| Fridays 16:00 | `weekly-second-brain` | `weekly/YYYY-Www.md`, people/ and projects/ updates |
| then | `team-health-radar` | `teams/<team>.md`, weekly flags |
| then | `kb-gardener` | fixes safe lint issues, reports the rest |

The order matters: the brief reads what ingest and digest wrote, and the gardener lints the
week's fresh writes. That is why the scheduled jobs are chains (`automation/daily.sh`,
`automation/weekly.sh`), not independent timers that might overlap.

## Four ways to schedule

Full comparison and examples in [`automation/routines.md`](../automation/routines.md). Short version:

| | Sees local vault | Laptop must be on | Good for |
|---|---|---|---|
| `/loop` in a session | yes | yes, session open | "watch Slack while I'm in meetings" (expires after 7 days) |
| Cloud routine (`/schedule`) | no, GitHub clone only | no | runs with the lid closed; needs a git-backed vault |
| Desktop scheduled task | yes | yes, app open | click-to-configure local jobs |
| launchd / cron + `claude -p` | yes | yes | the daily and weekly chains in this repo |

## Setting up the local jobs

```bash
./install.sh --with-launchd                               # macOS: renders + loads both plists
launchctl kickstart gui/$(id -u)/com.claude-lead-os.morning   # run the morning chain now
```

Linux: copy `automation/cron/crontab.example` into `crontab -e`.

Before you schedule anything, run each skill by hand once:

```bash
automation/run-skill.sh plaud-daily-ingest
tail -n 40 ~/brain/.logs/plaud-daily-ingest-$(date +%F).log
```

What `run-skill.sh` guarantees on every run:

| Guarantee | How |
|---|---|
| Never hangs on a permission prompt | `--permission-mode dontAsk --permission-prompts none`: anything not allowlisted is denied |
| Only the tools the skill needs | `--allowedTools` from `automation/allowed-tools/_base.txt` + `<skill>.txt` |
| Never sends on your behalf | send/delete tools in `_deny.txt` go to `--disallowedTools`; prompt says "drafts only" |
| Bounded cost | `--max-turns 40`, `--max-budget-usd 3.00` (weekly synthesis: 80 / 6.00) |
| Bounded time | watchdog: SIGINT then SIGTERM after 30 minutes (`CLO_TIMEOUT`) |
| No double runs | per-skill lock; a second run exits 0 with "skip" in the log |
| Mac stays awake while it works | `caffeinate -i -w <pid>` |
| You hear about failures | macOS notification (or `notify-send`), FAIL line in the log |
| Logged out? Fails fast | `claude auth status` before the run |

Tune it with env vars in `~/.config/claude-lead-os/env` (`CLO_MAX_TURNS`, `CLO_MAX_BUDGET`,
`CLO_MODEL`, `CLO_TIMEOUT`, `CLO_MORNING_CUTOFF`).

The jobs deliberately do not use `--bare`: bare mode skips the vault's CLAUDE.md, skills, hooks
and MCP servers, and only accepts an API key, not your subscription login.

## Hooks: guardrails and context injection

Hooks are shell commands the harness runs on lifecycle events. They cost zero tokens unless they
print something, and they run whether or not Claude "remembers". Configure them in
`~/.claude/settings.json` under `hooks` ([reference](https://code.claude.com/docs/en/hooks)).

### SessionStart: inject today's context

Already in `claude/settings.example.json`. `claude/hooks/session-start.sh` prints today's date,
`me/current-focus.md` and today's daily note (or yesterday's `## Tomorrow`). Plain stdout from a
SessionStart hook is added to Claude's context.

```json
"SessionStart": [
  {
    "matcher": "startup|clear|compact",
    "hooks": [{ "type": "command", "command": "bash ~/.claude/hooks/session-start.sh", "timeout": 10 }]
  }
]
```

The `compact` matcher matters: after a compaction the focus and daily note are re-injected, so a
long session does not forget what today is about.

### PreCompact: remind yourself to save state

A PreCompact hook runs before the context is summarised. Its `additionalContext` does **not**
reach Claude (the event fires between turns), but a `systemMessage` is shown to you, and exit
code 2 blocks the compaction.

Gentle version, on auto-compaction:

```json
"PreCompact": [
  {
    "matcher": "auto",
    "hooks": [{
      "type": "command",
      "command": "echo '{\"systemMessage\": \"Compacting. If this session moved a project, ask Claude to update its STATUS.md before you continue.\"}'"
    }]
  }
]
```

Strict version: block manual `/compact` until you have saved. Use a matcher of `manual`, have the
script `exit 2` with a reason on stderr, and remove it once the habit sticks. Blocking auto
compaction is a bad idea: the session simply runs out of room.

The real fix is upstream: skills write to files as they go (STATUS.md, daily note `## Log`), so a
compaction loses chat, not knowledge.

### Notification and Stop: know when Claude needs you

`Notification` fires when Claude is waiting on a permission prompt or has gone idle; `Stop` fires
when a turn finishes. Neither should block anything here, they just tell you.

```json
"Notification": [
  {
    "matcher": "permission_prompt|idle_prompt",
    "hooks": [{
      "type": "command",
      "command": "osascript -e 'display notification \"Claude is waiting for you\" with title \"Claude Code\"'"
    }]
  }
],
"Stop": [
  {
    "hooks": [{
      "type": "command",
      "command": "osascript -e 'display notification \"Turn finished\" with title \"Claude Code\"'"
    }]
  }
]
```

On Linux swap `osascript ...` for `notify-send "Claude Code" "..."`. A Stop hook *can* block
(`exit 2` or `"decision": "block"`) and force Claude to keep going; if you ever do that, check
`stop_hook_active` in the input so you do not loop forever.

### Guardrails that must hold

Instructions are requests; permissions and hooks are enforcement. "Never send a Slack message" in
CLAUDE.md is advice. `mcp__claude_ai_Slack__slack_send_message` in `permissions.ask` (interactive)
or `--disallowedTools` (scheduled) is a rule. See [07 — Security and privacy](07-security-and-privacy.md).

## Failure modes

| Failure | Symptom | Mitigation |
|---|---|---|
| Laptop asleep or lid closed at 07:30 | brief appears at 10:15 | launchd runs once on wake; `daily.sh` skips the brief after `CLO_MORNING_CUTOFF` (11:00). For lid-closed runs, use a cloud routine. cron does not catch up at all |
| Lid closed during a run | log stops mid-run | `caffeinate -i` prevents idle sleep only; closing the lid still sleeps. Next run picks up via the skill's state file |
| Claude CLI logged out | FAIL "not logged in" + notification | `claude auth login`. For headless boxes, `claude setup-token` and `CLAUDE_CODE_OAUTH_TOKEN` in the env file |
| MCP connector auth expired (Slack, Calendar, Plaud) | skill writes "skipped: not authenticated" | re-auth with `/mcp` or `claude mcp login <name>`. Skills are written to report and finish, not retry |
| Tool not on the allowlist | output says it could not do X; log shows a denial | add the exact tool name to `automation/allowed-tools/<skill>.txt` (names: `/mcp`) |
| Runaway cost or loop | run ends with a max-turns or budget error | that is the cap working. Raise `CLO_MAX_TURNS` / `CLO_MAX_BUDGET` only after reading why |
| Hung run | `[watchdog] timeout` in the log, exit 124 | lower scope of the skill or raise `CLO_TIMEOUT` |
| Two runs overlap | "skip: already running" | expected; the lock did its job |
| Vault under `~/Documents` or `~/Desktop` | launchd job cannot read files | macOS privacy controls: move the vault, or grant Full Disk Access to `/bin/bash` (prefer moving) |
| Prompt injection in a Slack message or transcript | skill tries something odd | allowlist + deny list cap the blast radius; skills treat fetched content as data |

## Reviewing the logs

Every run appends to `~/brain/.logs/<skill>-<YYYY-MM-DD>.log`: a start line with limits and the
allowlist, Claude's final output, and a `done` or `FAIL` line.

```bash
ls -t ~/brain/.logs | head                              # latest runs
grep -h "FAIL\|watchdog\|skip:" ~/brain/.logs/*.log     # everything that went wrong
tail -n 60 ~/brain/.logs/morning-brief-$(date +%F).log   # today's brief run
cat ~/brain/.logs/launchd-morning.err.log                # chain-level errors from launchd
launchctl print gui/$(id -u)/com.claude-lead-os.morning | grep -E "state|last exit"
```

A weekly habit worth keeping: on Friday, skim the week's FAIL lines next to the weekly review.
Logs are not committed (`.logs/` belongs in the vault's `.gitignore`); delete old ones whenever.
