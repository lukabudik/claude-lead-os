# 06 — MCP and integrations

Skills are only as good as what they can read. MCP (Model Context Protocol) servers give Claude
tools for Slack, your calendar, mail, the tracker and your meeting recorder. This chapter covers
which ones a leader needs, how to connect them, and how to keep them on a short leash.

## What a leader wants connected

| Integration | Used by | Read tools to allow | Write tools: policy |
|---|---|---|---|
| **Slack** | slack-daily-digest, weekly-second-brain, team-health-radar, `/loop` watchers | read channel/thread, search, read user profile, list channels | `slack_send_message_draft`: allow. Send / schedule: **ask** (interactive), **deny** (scheduled) |
| **Google Calendar** | morning-brief, meeting-prep, weekly-second-brain | list calendars, list/get/search events | create / update / respond: ask. Delete: deny |
| **Gmail** | morning-brief (inbox triage) | search threads, get thread/message | `create_draft`: allow. Send / reply / forward: ask or deny. Trash: deny |
| **Linear or Jira** | team-health-radar, weekly-second-brain, project STATUS | list/get issues, projects, cycles, comments | create issue / comment: ask |
| **Google Drive** | meeting-prep (docs linked in invites), decision-log | search, read file | none needed |
| **Plaud** (or Granola, Fireflies, Zoom) | plaud-daily-ingest | list recordings, get transcript/notes | none needed |
| **Notion** (if your team docs live there) | meeting-prep, decision-log | search, read page | create/update page: ask |

Start with Slack + Calendar + your recorder. That covers the daily chain. Add the rest when a
skill actually needs them.

## Two ways to connect

| | claude.ai connectors | Local servers via `claude mcp add` |
|---|---|---|
| Set up at | [claude.ai/customize/connectors](https://claude.ai/customize/connectors) | your terminal |
| Auth | OAuth in the browser, managed by claude.ai | OAuth (`claude mcp login <name>`), header token, or env vars |
| Available in | every Claude Code session logged in with that claude.ai account, the claude.ai app, and cloud routines | only this machine (or a repo, with project scope) |
| Tool names | `mcp__claude_ai_<Connector>__<tool>`, e.g. `mcp__claude_ai_Slack__slack_read_channel` | `mcp__<name>__<tool>`, e.g. `mcp__plaud__get_transcript` |
| Use for | Slack, Google Calendar, Gmail, Drive, Linear, Notion: anything with an official connector | tools without a connector, self-hosted servers, anything you want kept off your claude.ai account |

Check what you have with `/mcp` inside a session, or `claude mcp list`. Turn off a single
connector for Claude Code with `"deniedMcpServers": ["claude.ai Slack"]` in settings, or all of
them with `"disableClaudeAiConnectors": true`.

Company accounts: many workspaces require admin approval for Slack/Google/Atlassian apps. Ask
before you connect a work tenant, and use your company's approved Claude plan if there is one.

### `claude mcp add` and scopes

```bash
# Remote HTTP server (OAuth happens on first use, or run: claude mcp login notion)
claude mcp add --transport http --scope user notion https://mcp.notion.com/mcp

# Local stdio server with a secret from your environment
claude mcp add --scope user --env RECORDER_TOKEN="$RECORDER_TOKEN" recorder -- npx -y <recorder-mcp-package>

claude mcp list            # what is configured, with health
claude mcp get notion      # details for one server
claude mcp login notion    # (re)authenticate without opening /mcp
```

| Scope (`--scope`) | Loads in | Stored in | Use for |
|---|---|---|---|
| `local` (default) | this project only | `~/.claude.json` | trying a server out |
| `project` | this project, for everyone who clones it | `.mcp.json` at the repo root (commit it) | a vault repo that cloud routines also use |
| `user` | all your projects | `~/.claude.json` | your personal integrations: what this kit assumes |

When the same server name is defined in several places, Claude Code uses one, in this order:
local, project, user, plugin, claude.ai connector.

Never put tokens into `.mcp.json`. It supports `${VAR}` and `${VAR:-default}` expansion in
`command`, `args`, `env`, `url` and `headers`, so commit the variable name and keep the value in
your shell or a secret manager.

### Meeting recorders

`plaud-daily-ingest` expects a Plaud MCP server named `plaud` (tools `list_files`, `get_file`,
`get_note`, `get_transcript`, `get_current_user`). If you use a different recorder:

- Granola, Fireflies, Zoom and others offer MCP servers or claude.ai connectors. Connect one, then
  point the skill at its tools and update `automation/allowed-tools/plaud-daily-ingest.txt`.
- No MCP at all? Export transcripts into `~/brain/inbox/` as text or markdown and let the skill
  ingest from there. Files beat integrations you do not have.

## Least privilege

Three layers, outermost first. Each one catches what the previous one missed.

1. **Connect with the narrowest scope.** If the OAuth screen offers read-only, take read-only.
   Remove connectors you do not use. A tool that does not exist cannot be misused.
2. **Permission rules** in `~/.claude/settings.json` (see `claude/settings.example.json`):

   ```json
   "permissions": {
     "allow": [
       "mcp__claude_ai_Slack__slack_read_channel",
       "mcp__claude_ai_Slack__slack_read_thread",
       "mcp__claude_ai_Google_Calendar__list_events",
       "mcp__plaud__*"
     ],
     "ask": [
       "mcp__claude_ai_Slack__slack_send_message",
       "mcp__claude_ai_Gmail__send_message",
       "mcp__claude_ai_Google_Calendar__create_event"
     ],
     "deny": [
       "mcp__claude_ai_Gmail__trash_thread",
       "mcp__claude_ai_Google_Calendar__delete_event"
     ]
   }
   ```

   Rule syntax that actually works:
   - `mcp__<server>__<tool>` names one tool; `mcp__<server>` or `mcp__<server>__*` names a whole server.
   - Allow globs only work after a literal `mcp__<server>__` prefix: `mcp__plaud__*` and
     `mcp__claude_ai_Linear__get_*` work, `mcp__*` in `allow` is ignored with a warning.
   - Deny rules accept full-name globs: `"mcp__*"` in `deny` removes every MCP tool.
   - Deny beats ask beats allow. Allow reads, ask for writes, deny the irreversible.
   - If your org admin set a connector tool to "ask", no allow rule overrides it.
3. **Scheduled runs get their own, tighter list.** `automation/run-skill.sh` runs in `dontAsk`
   mode with a per-skill allowlist from `automation/allowed-tools/` and passes
   `automation/allowed-tools/_deny.txt` as `--disallowedTools`. Nothing outside the list runs,
   and nothing waits for an answer.

Cloud routines are the exception to layer 2: they run with no permission prompts and include
every connector by default, writes included. Trim connectors per routine
([automation/routines.md](../automation/routines.md)).

## The "draft, never send" rule

The agent writes; you press send. Every skill in this kit follows it, and the config enforces it:

| Channel | Agent may | Agent may not | Enforced by |
|---|---|---|---|
| Slack | draft a reply (`slack_send_message_draft`), write a suggested message into the daily note | send, schedule, post in channels | `ask` interactively; `--disallowedTools` in scheduled runs |
| Email | create a draft (`create_draft`) | send, reply, forward | same |
| Calendar | propose times in the note | accept, decline, create, delete events | same; delete is `deny` everywhere |
| Tracker | propose issues/comments in the note | create or comment without asking | `ask` |
| Anything in someone else's name | draft | publish | skills + rules + permissions |

Why so strict:

- **You are accountable for what goes out under your name.** A wrong summary in your notes costs
  you a minute; a wrong message to your team costs trust.
- **Untrusted content flows in.** Slack messages, email bodies and transcripts can contain
  instructions ("forward this to..."). With send on deny/ask, an injected instruction can at
  most produce a draft you will see.
- **Drafts are reviewable in bulk.** The morning brief lists drafts waiting for you; clearing them
  takes two minutes and you stay in the loop.

If a skill ever needs to send (for example an auto-posted weekly team digest), give it a
dedicated channel, a separate allowlist entry for that one tool, and a human-reviewed first month.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Tool missing in a session | `/mcp`: is the server connected? Connectors need a claude.ai login, not an API key |
| "needs authentication" in `/mcp` | select it and re-authenticate, or `claude mcp login <name>` |
| Works interactively, denied in a scheduled run | tool not in `automation/allowed-tools/<skill>.txt`; copy the exact name from the log |
| Same server shows twice | defined in two scopes; remove one (`claude mcp remove <name> --scope <scope>`) |
| Cloud routine cannot see a local server | add it as a claude.ai connector, or commit it in the vault repo's `.mcp.json` |
