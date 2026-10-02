# 08 — Best practices (researched)

What the official docs, the best public repos and practitioners agree on, and where this kit
follows or departs from them. Every claim links to a source in [Sources](#8-sources). Numbers
were checked against the docs on 2026-10-02. Claude Code ships fast, so re-check limits before
relying on them.

**TL;DR**

- Context is the scarce resource. Load little by default and let Claude pull the rest on demand.
- Files beat chat. Anything worth knowing next week goes into a markdown file in git.
- CLAUDE.md is advice and settings are enforcement. Guardrails belong in `permissions` and hooks.
- Automate the reading and leave the sending to a human. Drafts, never sends.
- A work second brain has all three legs of the "lethal trifecta". Design for prompt injection
  from day one.

---

## 1. Context engineering principles

> "Find the smallest possible set of high-signal tokens that maximize likelihood of desired
> outcome." (Anthropic, *Effective context engineering*)

| Principle | What it means in practice | Source |
|---|---|---|
| Context is finite and degrades | Performance drops as the window fills, so every always-loaded line has a cost | Best practices; Context engineering |
| Lean CLAUDE.md | Keep each file under 200 lines. For every line, ask "would removing this cause mistakes?" | Memory docs; Best practices |
| Map, not encyclopedia | The root CLAUDE.md says where things live and how to write. The content stays in files Claude reads when it needs them | Context engineering ("just-in-time"); HumanLayer |
| Progressive disclosure | Subdirectory CLAUDE.md files load only when Claude reads files there, path-scoped rules load on matching files, and skills load the body on use | Memory docs; Skills docs |
| Hierarchy is additive | Managed, user, project and local files are concatenated rather than overridden, and conflicts get resolved arbitrarily, so keep them consistent | Memory docs |
| Imports don't save tokens | `@path` imports load at launch (up to 4 hops), which makes them useful for organizing and useless for slimming | Memory docs |
| Right altitude | Write specific heuristics, avoiding both hardcoded if/else logic and vague platitudes | Context engineering |
| Emphasis is zero-sum | Mark one line IMPORTANT and it stands out. Mark ten and none do | Best practices |
| Isolate exploration | Send research to subagents and get summaries back, so the main session stays clean | Best practices; Features overview |
| `/clear` liberally | After two failed corrections, start fresh with a better prompt | Best practices |

**How this kit applies it**

- `~/.claude/CLAUDE.md` targets about 40 lines. It covers who you are, points to the vault, and lists
  the hard rules. `vault/CLAUDE.md` is the vault's schema: layout, write locations and naming.
- Each `vault/projects/<topic>/STATUS.md` is the entry point for that topic, and Claude reads it
  first. Nested `CLAUDE.md` files are allowed only where a folder has non-obvious conventions.
- Personal preferences live in `claude/rules/*.md` (user-level, always loaded, kept short).
  Procedures live in skills.
- Use HTML comments (`<!-- -->`) in CLAUDE.md for notes to yourself. They are stripped before
  injection and cost no tokens.
- Run `/doctor prompt-audit` monthly to catch stale or contradicting instructions.

---

## 2. Knowledge base patterns

### What the top repos do

| Pattern | Seen in | Why it works |
|---|---|---|
| Plain markdown in git, with Obsidian as an optional viewer | All of them (Karpathy, claudesidian, claude-obsidian, chief-of-staff repos) | Portable, diffable and grep-able. Nothing is locked in a vendor DB |
| Raw layer vs curated layer | Karpathy (`raw/` immutable, wiki LLM-owned), claude-obsidian, claudesidian `00_Inbox` | Sources survive the summary, and you can re-derive from them |
| Root CLAUDE.md as the "schema" | Karpathy, claudesidian | Turns Claude from a "generic chatbot" into a "disciplined wiki maintainer" |
| Index read first, then drill down | Karpathy `index.md`, auto memory `MEMORY.md` | Works without vector search up to hundreds of pages |
| Append-only log | Karpathy `log.md` with grep-able `## [YYYY-MM-DD] op \| title` prefixes | Gives a timeline with no tooling |
| File good answers back | Karpathy ("good answers can be filed back into the wiki") | Analyses compound instead of dying in chat history |
| People as first-class entities | mimurchison `contacts/`, claudia, obsidian-second-brain | A leader's work is keyed on people and relationships |
| Daily note as the default write target | claudesidian, ArtemXTech starter, obsidian-second-brain | Gives every capture an obvious place to land |
| Lint / gardener pass | Karpathy (lint), claude-obsidian (`wiki-lint`), claudia (overnight consolidation) | Finds orphans, stale claims, contradictions and duplicates. Maintenance becomes near-free |
| Safe upgrades that never touch content folders | claudesidian `/upgrade` | Separates system files from your notes |

### What we adopted and why

| Adopted | From | Our version |
|---|---|---|
| Inbox, then triage, then curated notes | Karpathy, claudesidian | `inbox/` holds raw transcripts and digests. Skills move the distilled facts into `meetings/`, `people/`, `projects/` |
| Schema in root CLAUDE.md | Karpathy | `vault/CLAUDE.md` defines folders, filenames and the "where to write" table |
| STATUS.md per project | Our own practice, close to Karpathy's overview page | One file answers "where are we": state, open decisions, next steps, links |
| People and team files | Chief-of-staff repos | `people/<name>.md` and `teams/<team>.md` with an open-loops section and 1:1 log |
| Decision log | ADR practice | `decisions/YYYY-MM-DD-<slug>.md`, filled by the `decision-log` skill |
| Lint as a scheduled job | Karpathy, claude-obsidian | The `kb-gardener` skill runs weekly and proposes edits instead of applying them silently |
| Dated facts | obsidian-second-brain freshness policy ("timeless, dated, or a pointer") | Volatile facts carry a date, and the gardener flags old ones |
| Index-first navigation | Karpathy, auto memory | `MEMORY.md` index plus folder READMEs. Grep before reading |

### What we deliberately skipped

| Skipped | Seen in | Why not |
|---|---|---|
| PARA numbered folders (`01_Projects`, `02_Areas`) | claudesidian | A leader's primary keys are person, team and project. "Areas" is ambiguous for work, so role-shaped folders route captures better |
| Vector DB, embeddings, memory daemons | claudia, basic-memory, graphify-style repos | Unneeded below a few hundred pages, as Karpathy says. Adds infra and an opaque store. If grep stops scaling, add `qmd` (local BM25+vector CLI) |
| Auto-rewriting existing pages, auto-reconciling contradictions | obsidian-second-brain | For work facts a silent rewrite is a liability. We flag contradictions and a human resolves them |
| 40+ commands | obsidian-second-brain, mega skill packs | The skill listing gets about 1% of context, and the least-used descriptions are dropped. 8 sharp skills beat 45 |
| Contact auto-enrichment every 15 minutes | claude-chief-of-staff | Cost plus a large prompt-injection surface, with little gain for colleagues you see weekly |
| Required Obsidian plugins | Several | Optional viewer only. The vault must work with `grep` and Claude alone |
| Multi-agent "fleets" | HN chief-of-staff orchestration threads | Comments there document the spiral: kanban, then specialists, then memory, then semantic search, then broken logic. A single session plus subagents covers leader work |

---

## 3. Skills

| Rule | Detail | Source |
|---|---|---|
| Layout | `skills/<name>/SKILL.md` with YAML `name` + `description`. Supporting files sit next to it | Skills docs |
| Description is the trigger | Write it in third person, covering what the skill does and when to use it, with the keywords a user would say. Max 1,024 chars | Skill authoring best practices |
| Name | Lowercase plus hyphens, max 64 chars, no "claude"/"anthropic" | Skill authoring best practices |
| Short body | SKILL.md under 500 lines. Put reference material in sibling files, linked **one level deep** | Skill authoring best practices |
| Assume Claude is smart | Leave out explanations of things Claude already knows. "The context window is a public good." | Skill authoring best practices |
| Degrees of freedom | Use loose heuristics for judgment (meeting prep) and exact scripts for fragile steps (file naming, dedupe) | Skill authoring best practices |
| Side effects are manual | `disable-model-invocation: true` for anything that writes outside the vault or sends. Note that scheduled `/loop` fires cannot run these, which is intended | Skills docs; Scheduled tasks |
| Ground in live data | `` !`command` `` injects command output before Claude reads the skill, e.g. today's date or the list of unprocessed inbox files | Skills docs |
| Isolate heavy reads | `context: fork` runs the skill in a subagent and returns only the summary | Skills docs |
| Evaluate first | Write 3 real scenarios, take a baseline without the skill, then write the minimum that fixes the failures | Skill authoring best practices |
| Author/tester split | Claude A writes the skill and a fresh Claude B uses it on real tasks. Feed what B got wrong back to A | Skill authoring best practices |
| Prune | `/skill-doctor` finds unused skills. `skillOverrides` can hide them | Skills docs |
| Audit third-party skills | Skills can run scripts, so read them before installing | Agent Skills engineering post |

**Where this kit departs:** ingest skills (`plaud-daily-ingest`, `slack-daily-digest`) write only
inside the vault and never send. Every skill that posts, emails or edits a tracker is
`disable-model-invocation: true` and ends by showing you a draft.

---

## 4. Memory

Claude Code has two memory systems. Don't mix them up.

| | CLAUDE.md + rules | Auto memory |
|---|---|---|
| Who writes | You | Claude |
| Contains | Instructions, conventions | Learned facts: `user`, `feedback`, `project`, `reference` |
| Loaded | Every session, in full | First **200 lines or 25KB** of `MEMORY.md`. Topic files on demand |
| Location | `~/.claude/`, project root | `~/.claude/projects/<project>/memory/` (or `autoMemoryDirectory`) |

Practices:

- **One fact per file, one line per fact in the index.** This matches the official layout, so
  facts can be updated and deleted independently.
- **Pool memory where you work.** Point `autoMemoryDirectory` at `vault/.memory/` so memory is
  versioned with the vault rather than scattered per repo.
- **Date volatile facts.** Claude Code adds a `modified` timestamp to memory frontmatter. The
  gardener uses it to flag stale entries.
- **Prune before the ceiling.** Lines past the limit are silently dropped on the next load.
  Merge, delete, or move detail into topic files.
- **Promote repeated memories.** A memory that keeps being recalled should become a CLAUDE.md
  line, a rule, or a skill. A repeated correction is a config change, not a chat message.
- **Memory is not a secrets store.** No tokens and no credentials. Keep people's personal data
  to what you would be comfortable with them reading.
- **Survive compaction.** Project-root CLAUDE.md is re-read after `/compact`, and conversation-only
  instructions are not. For critical session state, use a `SessionStart` hook with the `compact`
  matcher to re-inject it.

---

## 5. Automation and loops

### Pick the right scheduler

| Option | Runs on | Local files | Min interval | Lifetime | Use for |
|---|---|---|---|---|---|
| `/loop` | Your open session | Yes | 1 min | Recurring tasks expire after **7 days**. Max 50 per session | Polling during a working session |
| Desktop scheduled task | Your machine | Yes | 1 min | Persistent | Local jobs without writing plists |
| `claude -p` + launchd/cron | Your machine | Yes | Any | Persistent | Daily ingest/brief jobs over the vault (`automation/`) |
| Routines (`/schedule`) | Anthropic cloud | **No** (fresh repo clone) | 1 hour | Persistent, research preview | Jobs that only need connectors, not the vault |

### Rules for unattended runs

| Rule | How | Source |
|---|---|---|
| Scope tools explicitly | `--allowedTools` for what the job needs, `--disallowedTools` for send/write tools it must never call (`"mcp__*"` removes all MCP tools) | Headless; CLI reference |
| Nobody can answer prompts | `--permission-prompts none` denies instead of hanging | Headless |
| Cap spend and turns | `--max-budget-usd` (counts subagent spend) and `--max-turns` | CLI reference; Prosser |
| Parse results, don't scrape | `--output-format json`, optionally with `--json-schema` | Headless |
| Know what `--bare` does | Skips CLAUDE.md, skills, hooks and MCP, and needs an API key (no subscription login). Good for CI, wrong for vault jobs that rely on your skills | Headless |
| `-p` skips trust dialogs | It runs project hooks and `.mcp.json` servers silently, so run only in directories you control | Headless; Security |
| Lock, log, keep awake | Lockfile against overlapping runs, a log per run, `caffeinate` on macOS | `automation/run-skill.sh` |
| Read the transcript | A routine's green status means "no infra error", not "task succeeded" | Routines docs |
| Bound every loop | Use a fixed interval or a stop condition. Stop hooks get overridden after 8 consecutive blocks, so check `stop_hook_active` | Scheduled tasks; Hooks guide |
| Strip routine connectors | Routines include **all** your connectors by default and can call writes without asking. Remove all but what's needed | Routines docs |

### Rollout order (from Prosser, and it matches our experience)

1. One read-only job (morning brief or Slack digest) writing to `daily/`. Run it for a week.
2. Tune the prompt against real misses.
3. Add the next layer (transcript ingest, weekly synthesis).
4. Interactive skills (meeting prep, 1:1 prep) last, since they need the KB to exist first.

Model choice: structured overnight triage runs well on a faster model. Judgment calls (what needs
your brain, what to escalate) deserve the strongest one. Set the model per job.

---

## 6. Security and privacy for a work second brain

### The threat model in one table

Simon Willison's lethal trifecta: **private data + untrusted content + a way to send data out.**
A leader's setup has all three out of the box.

| Leg | In this kit | Mitigation |
|---|---|---|
| Private data | The vault: people files, decisions, meeting notes | Local only, in a private git remote or none. Never in the public kit repo |
| Untrusted content | Slack messages, email, meeting transcripts, web pages, shared docs. Anyone who can post in a channel or speak in a meeting can write instructions Claude will read | Treat every ingested text as data. Ingest skills say so explicitly and summarize, never execute |
| Exfiltration path | Slack/Gmail send tools, WebFetch, `curl`, tracker comments, artifact publishing | Ingest runs get **no** send tools. Sending is a separate, manual, human-reviewed step |

### Concrete controls

| Control | Setting / practice |
|---|---|
| Never auto-send | Every send/post/email skill is `disable-model-invocation: true` and ends with a draft. Prosser: "My system never sends an email — it drafts." |
| Deny send tools in headless jobs | `--disallowedTools` with the exact MCP tool names (check `/mcp`), or `permissions.deny` in the job's settings |
| Enforce with settings, not prose | `permissions.deny` for `Read(./.env)`, credential paths and send tools. CLAUDE.md "never do X" is a request, a deny rule or `PreToolUse` hook is enforcement |
| Least-privilege connectors | Read-only scopes where the vendor offers them, and only the channels and calendars you need. Anthropic "does not security-audit or manage any MCP server" |
| Review before acting on ingested text | Digest output is a summary for you. Action items extracted from a transcript are proposals until you confirm them |
| Don't pipe raw untrusted content | Official guidance: "Avoid piping untrusted content directly to Claude." Fetch through tools that summarize (WebFetch returns a model summary, not raw HTML) |
| Routines see no vault | Cloud routines get a fresh clone and no local files. Keep them that way for vault data |
| Third-party skills and plugins | Read before installing. They can run scripts and register hooks |

### Data residency and retention

| Fact | Implication |
|---|---|
| Consumer plans (Pro/Max): training is opt-in via a toggle. Retention is 30 days, or 5 years if opted in | Check the toggle before putting work data through a personal plan. Better still, use your company's commercial plan |
| Commercial (Team/Enterprise/API): no training on your data, 30-day retention. ZDR available per org on Enterprise | Ask IT which plan and provider (Anthropic, Bedrock, Vertex, Foundry) is approved, and use that |
| Local transcripts are stored in **plaintext** under `~/.claude/projects/` for 30 days (`cleanupPeriodDays`) | Everything you ingested is also on disk in session logs. Disk encryption is mandatory, and you can lower the retention |
| `/feedback` uploads the transcript (kept 5 years) | Don't use it in sessions that touched confidential data, or set `DISABLE_FEEDBACK_COMMAND=1` |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Turns off telemetry, error reports and surveys |

### What never goes into the vault

Credentials and tokens. Compensation and HR case details beyond what you would write in an
official system. Customer personal data. Anything your company classifies above "internal".
`people/` files hold facts and open loops, not performance judgments. Write them as if the
person might read them.

---

## 7. Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| Giant CLAUDE.md | Claude ignores rules that are in the file. Docs: "important rules get lost in the noise" | Prune ruthlessly. Move procedures to skills and scoped content to subfolder CLAUDE.md or `paths:` rules |
| Encyclopedia in context | Every session starts with thousands of tokens of background | Map plus on-demand reads. Index files, STATUS.md, grep |
| Auto-writing everything | The KB fills with low-signal summaries nobody reads, and contradictions get silently overwritten | Ingest writes to `inbox/` or `daily/`, and promotion to curated notes is reviewed. Flag contradictions, don't resolve them |
| No human review | Wrong action items, misattributed quotes, a message sent in your name | Drafts only. Show evidence (source line, transcript timestamp) next to each extracted fact |
| Unbounded loops | Runaway cost, repeated side effects, a session that never ends | Fixed intervals, `--max-turns`, `--max-budget-usd`, the 7-day `/loop` expiry, lockfiles |
| Kitchen-sink session | One session for triage, a doc and a 1:1. Context full of noise | `/clear` between unrelated tasks. Name sessions with `/rename` |
| Correction spiral | A third "no, I meant..." in a row | `/clear` and rewrite the prompt. If it recurs, make it a CLAUDE.md line |
| Skill sprawl | 40 overlapping skills, the wrong one triggers, descriptions get dropped from the listing | Fewer, sharper skills with distinct descriptions. Run `/skill-doctor` |
| Instructions as guardrails | "Never send without asking" in CLAUDE.md, enforced by nothing | `permissions.deny`, `disable-model-invocation`, `PreToolUse` hooks |
| Building the fleet first | Orchestrators, specialists, memory daemons, semantic search before one useful daily job | One read-only job, then iterate on real misses (Prosser; HN thread) |
| Chat as storage | An insight lives only in a closed session | File it: decision, STATUS.md update or knowledge note |
| Reviewer chasing every nit | An adversarial review subagent always finds "gaps" | Ask it to flag only correctness and requirement gaps |

---

## 8. Sources

Each link was opened and read for this document.

### Anthropic: docs

| Link | Why read it |
|---|---|
| [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices) | CLAUDE.md include/exclude table, "would removing this cause mistakes?", failure patterns, verification, subagents |
| [How Claude remembers your project (memory)](https://code.claude.com/docs/en/memory) | CLAUDE.md hierarchy, 200-line target, imports, `.claude/rules` + `paths`, auto memory limits (200 lines / 25KB) |
| [Extend Claude Code (features overview)](https://code.claude.com/docs/en/features-overview) | When to use CLAUDE.md vs skill vs hook vs subagent vs MCP, context cost per feature, "put guardrails in hooks" |
| [Skills](https://code.claude.com/docs/en/skills) | SKILL.md format, frontmatter fields, `disable-model-invocation`, `context: fork`, dynamic injection, compaction budget |
| [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) | Descriptions, naming limits, 500-line body, one-level references, evaluations first, Claude A/B iteration |
| [Hooks guide](https://code.claude.com/docs/en/hooks-guide) | Event list, SessionStart re-injection after compaction, exit-code semantics, Stop-hook block cap |
| [Run Claude Code programmatically (headless)](https://code.claude.com/docs/en/headless) | `claude -p`, output formats, `--bare` caveats, `--permission-prompts none`, unattended runs |
| [CLI reference](https://code.claude.com/docs/en/cli-reference) | Verified `--max-budget-usd`, `--max-turns`, `--disallowedTools`, `--no-session-persistence` |
| [Run prompts on a schedule (/loop)](https://code.claude.com/docs/en/scheduled-tasks) | `/loop`, 7-day expiry, 50-task cap, cloud vs desktop vs loop comparison |
| [Routines](https://code.claude.com/docs/en/routines) | `/schedule`, autonomy, connectors-included-by-default warning, limits, untrusted fire payload |
| [Security](https://code.claude.com/docs/en/security) | Prompt-injection safeguards, untrusted-content guidance, MCP trust |
| [Data usage](https://code.claude.com/docs/en/data-usage) | Training policy, retention periods, local plaintext transcripts, telemetry opt-outs |

### Anthropic: engineering and blog

| Link | Why read it |
|---|---|
| [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) | Context rot, attention budget, right altitude, just-in-time retrieval, note-taking |
| [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) | Workflows vs agents, start simple, compounding errors |
| [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) | The three-level progressive disclosure model, auditing third-party skills |
| [How Anthropic teams use Claude Code](https://claude.com/blog/how-anthropic-teams-use-claude-code) | Non-engineering teams using Claude Code. Light on second-brain specifics |

### GitHub

| Link | Why read it |
|---|---|
| [anthropics/skills](https://github.com/anthropics/skills) | Official skill examples, spec and template |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | The curated index. Its Obsidian and Memory sections map the landscape |
| [Karpathy: llm-wiki (gist)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) | The raw / wiki / schema pattern, ingest-query-lint, index.md + log.md. The clearest statement of why LLM-maintained KBs survive |
| [heyitsnoah/claudesidian](https://github.com/heyitsnoah/claudesidian) | Most-used Claude Code + Obsidian starter. PARA layout, inbox processor, safe upgrade |
| [AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) | LLM Wiki as a plugin. Immutable sources, plan-then-apply writes, single-writer orchestrator |
| [eugeniughelbur/obsidian-second-brain](https://github.com/eugeniughelbur/obsidian-second-brain) | Freshness policy (timeless / dated / pointer). Counter-example for command sprawl and auto-rewrites |
| [jimprosser/claude-code-cos](https://github.com/jimprosser/claude-code-cos) | Best chief-of-staff architecture write-up: layered rollout, drafts-not-sends, budget caps, specs over code |
| [mimurchison/claude-chief-of-staff](https://github.com/mimurchison/claude-chief-of-staff) | CEO setup: goals file, contacts, `/gm` and `/triage`, tiered triage |
| [kbanc85/claudia](https://github.com/kbanc85/claudia) | Commitment and relationship tracking, sourced facts, overnight consolidation. Non-commercial license |
| [ArtemXTech/claude-code-obsidian-starter](https://github.com/ArtemXTech/claude-code-obsidian-starter) | Small work-shaped vault (Daily, Meetings, Projects, Tasks, Clients) |
| [tobi/qmd](https://github.com/tobi/qmd) | Local markdown search (BM25 + vector). The upgrade path when grep and an index stop scaling |

### Practitioners

| Link | Why read it |
|---|---|
| [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) | Instruction budget (~150-200), progressive disclosure via doc folders, "never send an LLM to do a linter's job" |
| [Simon Willison: The lethal trifecta](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/) | The threat model for any agent with private data, untrusted input and outbound channels |
| [Simon Willison: Claude Skills are awesome](https://simonwillison.net/2025/Oct/16/claude-skills/) | Why skills are token-cheap and simpler than MCP |
| [Kyle Gao: Using Claude Code with Obsidian](https://kyleygao.com/blog/2025/using-claude-code-with-obsidian/) | Practitioner account: removing friction is why the KB actually gets used |
| [HN: Orchestrating Claude Code agents, the chief of staff pattern](https://news.ycombinator.com/item?id=49772806) | Comments documenting the over-engineering spiral of agent fleets |
| [HN: Anyone using Claude Code for non-coding workflows?](https://news.ycombinator.com/item?id=45528463) | Folder-per-topic beats chat history. Voice capture into an Obsidian vault |
