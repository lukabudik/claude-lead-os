# allowed-tools

Per-skill permission allowlists used by `../run-skill.sh`. Scheduled runs use
`--permission-mode dontAsk`: anything not allowed here is denied, never prompted.

| File | Applies to |
|---|---|
| `_base.txt` | every skill (vault read/write, a few harmless shell commands) |
| `<skill>.txt` | that skill only (its MCP read tools, draft tools) |
| `_deny.txt` | every skill, passed as `--disallowedTools` (send/delete tools) |

Format: one [permission rule](https://code.claude.com/docs/en/permissions) per line, `#` starts a comment.

## Match the tool names to your setup

MCP tool names depend on how the integration is connected:

| Connected as | Tool name shape | Example |
|---|---|---|
| claude.ai connector | `mcp__claude_ai_<Connector>__<tool>` | `mcp__claude_ai_Slack__slack_read_channel` |
| `claude mcp add slack ...` | `mcp__<server-name>__<tool>` | `mcp__slack__slack_read_channel` |

Run `/mcp` in an interactive session (or `claude mcp list`) to see your server names, then
edit the files. Allow rules accept a glob only after a literal `mcp__<server>__` prefix
(`mcp__plaud__*` works, `mcp__*` is ignored).

Test a skill by hand before scheduling it: `../run-skill.sh morning-brief`, then read
`$BRAIN_DIR/.logs/morning-brief-<date>.log`. Denied tool calls show up there.
