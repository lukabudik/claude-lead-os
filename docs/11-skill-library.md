# 11 — Skill library: standing on shoulders

The kit's own skills cover the loop (ingest, brief, prep, review). For everything around it
(decks, documents, writing, stress-testing a plan, skill authoring) other people have already
built good skills. This page says which ones to install, which to try, which ideas the kit
already absorbed, and which repos to read but not install.

Checked on 2026-10-02 with Claude Code 2.1.287. **Verified** means the exact command below
was run into a throwaway `CLAUDE_CONFIG_DIR` and the plugin installed cleanly. Stars and
"always-on" token costs are from that day (`claude plugin details <plugin@marketplace>`
prints the cost). Plugins move fast, so re-check before relying on any row.

**TL;DR**

- Run `./automation/install-recommended.sh` (dry run), then `--apply`. It installs three
  Anthropic plugins and nothing else.
- Add anything from "Worth trying" one plugin at a time, and only after reading its SKILL.md.
- Every always-on token is paid in every session. Five big plugins cost more context than
  this whole kit.

---

## 1. Install syntax (verified)

Two equivalent ways. The CLI works from a script, the slash commands work inside a session.

| Step | CLI (non-interactive) | Inside a session |
|---|---|---|
| Add a marketplace | `claude plugin marketplace add owner/repo` | `/plugin marketplace add owner/repo` |
| Install a plugin | `claude plugin install name@marketplace` | `/plugin install name@marketplace` |
| See what it adds | `claude plugin details name@marketplace` | `/plugin` |
| Pin a marketplace | `claude plugin marketplace add owner/repo#v1.2.3` (branch or tag, not a SHA) | same with `#ref` |
| Update | `claude plugin marketplace update [name]`, then `claude plugin update name@marketplace` | `/plugin marketplace update` |
| Turn off / remove | `claude plugin disable name@marketplace` / `claude plugin uninstall name@marketplace` | `/plugin` |
| Scope | `--scope user` (default), `project` (writes `./.claude/settings.json`), `local` | |

Notes:

- `owner/repo` clones over SSH when your git is set up for it. If that fails, pass the HTTPS
  URL instead: `claude plugin marketplace add https://github.com/owner/repo.git`. The
  installer script does this fallback for you.
- The marketplace name is declared inside the repo, so it often differs from the repo name
  (`anthropics/skills` registers as `anthropic-agent-skills`). Every command below uses the
  real name.
- A fresh Claude Code config may not have `claude-plugins-official` added yet. The script adds
  it. It is Anthropic's curated directory and pins most third-party plugins to a commit SHA.
- After installing, restart Claude Code or run `/reload-plugins`.

---

## 2. Install first

Anthropic-maintained, no hooks, no MCP servers, small always-on cost, and each one fills a
gap the kit leaves on purpose. This is the only tier `install-recommended.sh` touches.

| Plugin | Author | What it does for a leader | License | Install (verified) | Risk notes |
|---|---|---|---|---|---|
| [document-skills](https://github.com/anthropics/skills/tree/main/skills) (`docx`, `pptx`, `xlsx`, `pdf`) | Anthropic | Real Office files: a QBR deck, a board memo in Word, a headcount model in Excel, filling or merging PDFs. The kit writes markdown; this turns it into what your company actually circulates | Source-available, Anthropic terms (not open source). Install it, never copy it | `claude plugin marketplace add anthropics/skills` then `claude plugin install document-skills@anthropic-agent-skills` | Runs local Python/Node scripts. May `pip`/`npm install` packages on first use. Render checks want LibreOffice. ~760 always-on tokens |
| [skill-creator](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator) | Anthropic | Writes a new skill with you, then runs evals against a no-skill baseline and tunes the description so it triggers. The guided version of [docs/04](04-skills.md) | Apache-2.0 | `claude plugin install skill-creator@claude-plugins-official` | Eval runs spawn extra `claude -p` sessions, which costs tokens. Writes a temporary command into `.claude/commands/` while testing. ~90 tokens |
| [claude-md-management](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management) | Anthropic | `/revise-claude-md` turns what you corrected today into CLAUDE.md lines. The improver skill audits CLAUDE.md files for staleness and bloat. Keeps the "map, not encyclopedia" rule honest | Apache-2.0 | `claude plugin install claude-md-management@claude-plugins-official` | Proposes edits to your CLAUDE.md files, so review the diff. Written with code repos in mind; works fine on the vault. ~120 tokens |

---

## 3. Worth trying

All verified to install. Each solves a real leader problem, but each also has a cost: overlap
with the kit, a big always-on footprint, bundled MCP servers, or a hook. Add one, use it for a
week, keep it only if you reached for it.

### Thinking and deciding

| Plugin | Author | What it does for a leader | License | Install (verified) | Risk notes |
|---|---|---|---|---|---|
| [compound-knowledge](https://github.com/EveryInc/compound-knowledge-plugin) | Every (Austin Tedesco) | Knowledge-work loop: `/kw:brainstorm` a messy problem, `/kw:plan` it in Pyramid Principle form, `/kw:confidence` for what Claude does and does not know, `/kw:review` with a strategic-alignment and a data-accuracy reviewer, `/kw:compound` to save the learning | MIT (plugin folder) | `claude plugin marketplace add EveryInc/compound-knowledge-plugin` then `claude plugin install compound-knowledge@compound-knowledge-plugin` | Saves learnings to `docs/knowledge/`, a second store next to `decisions/` and `.memory/`. Run it from a project folder, or tell it to use the vault. Markdown only, no scripts. ~290 tokens |
| [mattpocock-skills](https://github.com/mattpocock/skills) | Matt Pocock | `/grill-me` stress-tests a plan or reorg by asking the open decisions in rounds, each with a recommended answer. `/to-questionnaire` turns a decision you can't make alone into a questionnaire for the person who knows. `/handoff` compacts a session for the next one | MIT | `claude plugin install mattpocock-skills@claude-plugins-official` | 25 skills, most for coding, ~1,150 always-on tokens. Hide the rest with `skillOverrides`. The plugin cache includes the repo's dev `node_modules` |
| [superpowers](https://github.com/obra/superpowers) | Jesse Vincent (obra) | `brainstorming` (Socratic questions before any plan), `writing-plans` / `executing-plans`, `verification-before-completion`, and `writing-skills`, a test-first method for authoring skills | MIT | `claude plugin install superpowers@claude-plugins-official` (or `claude plugin marketplace add obra/superpowers-marketplace` then `claude plugin install superpowers@superpowers-marketplace`) | A `SessionStart` hook loads its "using superpowers" instructions on every startup, clear and compact. 15 skills, mostly coding, ~700 tokens. Brainstorming can start a local web server for visual mockups |

### Writing

| Plugin | Author | What it does for a leader | License | Install (verified) | Risk notes |
|---|---|---|---|---|---|
| [avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing) | Conor Bronsdon | Audits and rewrites drafts to strip AI-isms (49+ pattern families). Run it on anything the `writer` agent drafts before it goes out under your name | MIT | `claude plugin marketplace add conorbronsdon/avoid-ai-writing#v3.36.0` then `claude plugin install avoid-ai-writing@conorbronsdon-skills` | Pinned to a tag above. Bundles a local Node detector script. ~110 tokens |
| [elements-of-style](https://github.com/obra/the-elements-of-style) | Jesse Vincent (obra) | Strunk's 1918 rules as one skill (`writing-clearly-and-concisely`). Short, cheap, good for status updates | No LICENSE file in the repo. The 1918 text is public domain | `claude plugin marketplace add obra/superpowers-marketplace` then `claude plugin install elements-of-style@superpowers-marketplace` | ~65 tokens. Overlaps `claude/rules/writing-voice.md`; your voice rules win on conflict |
| [example-skills](https://github.com/anthropics/skills/tree/main/skills) | Anthropic | Contains `internal-comms` (3P updates, newsletters, FAQs, incident reports), `doc-coauthoring` (a structured flow for co-writing a doc) and `brand-guidelines` | Apache-2.0 per skill | `claude plugin install example-skills@anthropic-agent-skills` (after adding `anthropics/skills`) | 12 skills; the other 9 are art, GIFs, web apps and testing. ~940 tokens. Duplicates `skill-creator`. Hide what you don't use with `skillOverrides` |

### Slides and visuals

| Plugin | Author | What it does for a leader | License | Install (verified) | Risk notes |
|---|---|---|---|---|---|
| [visual-explainer](https://github.com/nicobailon/visual-explainer) | nicobailon | `generate-slides`, `project-recap`, `generate-web-diagram`, `fact-check`: turns a plan or a recap into a self-contained HTML page or deck you can screen-share | MIT | `claude plugin marketplace add nicobailon/visual-explainer` then `claude plugin install visual-explainer@visual-explainer-marketplace` | The generated HTML loads fonts and libraries from Google Fonts and jsDelivr when opened. Don't open pages with confidential content on a machine that must stay offline. ~220 tokens |
| [hands-on-deck](https://github.com/EveryInc/hands-on-deck) | Every Consulting | Edits an existing corporate `.pptx` template through atomic JSON patches, then renders it to check the geometry. Better than `pptx` when the template is fixed and you need to fill it | MIT | `claude plugin marketplace add EveryInc/hands-on-deck` then `claude plugin install hands-on-deck@hands-on-deck` | Needs `pip install python-pptx Pillow`. Rendering needs LibreOffice and Poppler. ~120 tokens |

### Role packs

| Plugin | Author | What it does for a leader | License | Install (verified) | Risk notes |
|---|---|---|---|---|---|
| [product-management](https://github.com/anthropics/knowledge-work-plugins/tree/main/product-management) | Anthropic | `write-spec`, `roadmap-update`, `metrics-review`, `synthesize-research`, `competitive-brief`, `sprint-planning`, `stakeholder-update` | Apache-2.0 | `claude plugin marketplace add anthropics/knowledge-work-plugins` then `claude plugin install product-management@knowledge-work-plugins` | Declares **16 remote MCP servers** (Slack, Linear, Gmail, Amplitude, Fireflies...). Each needs OAuth before it can act, but it widens the surface; see [docs/06](06-mcp-and-integrations.md). Its `stakeholder-update` overlaps the kit's. ~670 tokens |
| [human-resources](https://github.com/anthropics/knowledge-work-plugins/tree/main/human-resources) | Anthropic | `performance-review`, `interview-prep`, `onboarding`, `org-planning`, `people-report` | Apache-2.0 (repo) | `claude plugin install human-resources@knowledge-work-plugins` (after adding the marketplace) | Declares 5 MCP servers. Includes `comp-analysis` and `draft-offer`: compensation data must stay out of the vault ([docs/07](07-security-and-privacy.md)). ~650 tokens |

### Search and self-review

| Plugin | Author | What it does for a leader | License | Install (verified) | Risk notes |
|---|---|---|---|---|---|
| [qmd](https://github.com/tobi/qmd) | Tobi Lütke | Local hybrid search over markdown (BM25 + vectors + rerank) exposed as an MCP server. The upgrade path when `grep` and `index.md` stop scaling (a few hundred notes) | MIT | `npm install -g @tobilu/qmd`, `qmd collection add ~/brain --name brain`, `qmd embed`, then `claude plugin marketplace add tobi/qmd` and `claude plugin install qmd@qmd` | The plugin only registers `qmd mcp`; the CLI must be installed first. The first embed downloads about 2 GB of GGUF models from Hugging Face. After that it runs fully local. ~110 tokens |
| [receipts](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/receipts) | Anthropic | Mines your local Claude Code transcripts into an impact report (what shipped, which projects, share of usage). Useful for your own review or justifying a seat | Apache-2.0 | `claude plugin install receipts@claude-plugins-official` | Reads every transcript under `~/.claude/projects/`. The report can quote confidential snippets, so read it before you share it. ~160 tokens |

---

## 4. Patterns we adopted natively

These are ideas, not installs. The kit implements them in its own files, so you get the benefit
without the dependency. Credit where it is due:

| Idea | Source | Where it lives in this repo |
|---|---|---|
| LLM-maintained wiki: raw sources, curated pages, a schema file, ingest / query / lint | [Andrej Karpathy, llm-wiki (gist)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) | `vault/CLAUDE.md` (schema), `vault/inbox/` (raw layer), `vault/index.md`, `vault/log.md`, `skills/kb-gardener/` (lint), `skills/ask-my-brain/` (query) |
| Layered rollout, drafts never sends, spend caps on unattended runs | [Jim Prosser, claude-code-cos](https://github.com/jimprosser/claude-code-cos) | `automation/run-skill.sh` (`--max-budget-usd`, `--max-turns`), `claude/rules/privacy.md`, `claude/agents/writer.md`, rollout order in [docs/05](05-loops-and-automation.md) |
| Goals file, morning briefing, tiered inbox triage, contacts as files | [Mike Murchison, claude-chief-of-staff](https://github.com/mimurchison/claude-chief-of-staff) | `vault/me/goals.md`, `skills/morning-brief/`, `skills/inbox-triage/`, `vault/people/` |
| Inbox-first capture, upgrades that never touch your notes | [Noah Brier, claudesidian](https://github.com/heyitsnoah/claudesidian) | `vault/inbox/`, `skills/capture/`, `install.sh` (copies only missing files, never overwrites) |
| Immutable sources, plan-then-apply edits, scheduled lint | [AgriciDaniel, claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) | `skills/plaud-daily-ingest/` keeps raw transcripts in `inbox/`; `skills/kb-gardener/` proposes edits instead of applying them |
| Commitments tracked in both directions, relationship memory | [Kamil Banc, claudia](https://github.com/kbanc85/claudia) (idea only, no code used; see license note below) | `skills/one-on-one-prep/`, open-loops section in `vault/templates/person.md` |
| Freshness policy: every fact is timeless, dated or a pointer | [obsidian-second-brain](https://github.com/eugeniughelbur/obsidian-second-brain) | `updated:` frontmatter and dated filenames in `vault/CLAUDE.md`; staleness thresholds in `skills/kb-gardener/` |
| The lethal trifecta: private data + untrusted input + a way out | [Simon Willison](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/) | `claude/hooks/block-outbound-headless.sh`, [docs/07](07-security-and-privacy.md) |
| Skill format, progressive disclosure, evaluation first | [Anthropic skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), [anthropics/skills](https://github.com/anthropics/skills) | Every `skills/*/SKILL.md`, [docs/04](04-skills.md) |
| Instruction budget, CLAUDE.md as a short map | [HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md) | `claude/CLAUDE.md`, `vault/CLAUDE.md` |

---

## 5. Read for ideas (don't install alongside the kit)

Good work, but each one is a complete system with its own vault, memory or setup. Running it
next to this kit gives you two sources of truth.

| Repo | Author | Why read it | License | How it installs | Why not alongside the kit |
|---|---|---|---|---|---|
| [claude-code-cos](https://github.com/jimprosser/claude-code-cos) (~190 stars) | Jim Prosser | The clearest chief-of-staff architecture guide for non-programmers | MIT | Nothing to install: it is a written guide | n/a, read it |
| [claude-chief-of-staff](https://github.com/mimurchison/claude-chief-of-staff) (~440 stars) | Mike Murchison | CEO operating system: goals, contacts, `/gm`, `/triage` | MIT | `git clone` + its `install.sh` | Installs its own commands and config; duplicates the kit's brief and triage |
| [claudesidian](https://github.com/heyitsnoah/claudesidian) (~2.6k stars) | Noah Brier | Obsidian vault template with a setup wizard | MIT | `git clone` as your vault | PARA layout instead of people / teams / projects |
| [claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) (~15k stars) | AgriciDaniel | The most rigorous LLM-wiki implementation: provenance ledgers, recoverable transactions | MIT | `claude plugin marketplace add AgriciDaniel/claude-obsidian` then `claude plugin install claude-obsidian@agricidaniel-claude-obsidian` (verified) | `SessionStart` and `Stop` hooks, 15 skills, 3 agents, ~1,600 always-on tokens, and its own vault model. Use it **instead of** the kit's vault, not with it |
| [productivity](https://github.com/anthropics/knowledge-work-plugins/tree/main/productivity) | Anthropic | `TASKS.md` plus a two-tier workplace memory and a local dashboard | Apache-2.0 | `claude plugin install productivity@knowledge-work-plugins` (verified) | A second memory system next to `vault/.memory/`, plus 9 bundled MCP servers |
| [claudia](https://github.com/kbanc85/claudia) (~290 stars) | Kamil Banc | Relationship and commitment tracking, overnight consolidation | **PolyForm Noncommercial 1.0.0** | `npx get-claudia` | Using it for your employer's work is likely commercial use. Link only: nothing from it is copied into this repo |
| [compound-engineering](https://github.com/EveryInc/compound-engineering-plugin) (~25k stars) | Every | The coding original of the compound loop | MIT | `claude plugin marketplace add EveryInc/compound-engineering-plugin` (not tested) | Built for engineers; `compound-knowledge` above is the leader version |
| [claude-bedrock](https://github.com/iurykrieger/claude-bedrock) (~100 stars) | Iury Krieger | Entity-typed Obsidian second brain (people, teams, topics), close to this kit's shape | MIT | Plugin marketplace (not tested) | Small and quiet since May 2026; a useful comparison, not a dependency |

### Considered and dropped

| Candidate | Why dropped |
|---|---|
| Simon Willison's [`llm`](https://github.com/simonw/llm) CLI | A great general tool, not a Claude Code skill. In this kit `claude -p` already covers scripted runs |
| [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | Not by Karpathy (a third party distilling his posts) and about coding behaviour. The real Karpathy idea is adopted above |
| Harper Reed's project-workflow commands | The awesome-claude-code link is stale: the folder in his dotfiles now holds two unrelated commands |
| Slack / Notion / Linear / Atlassian plugins in `claude-plugins-official` | They are MCP connectors. Connect them through `/mcp` or claude.ai connectors with least privilege, see [docs/06](06-mcp-and-integrations.md) |
| Ethan Mollick | No public Claude Code skills found. (Dan Shipper's company Every is covered above) |
| [gstack](https://github.com/garrytan/gstack), RIPER, Claude Code PM | Software-delivery workflows, not leader work |

---

## 6. How to vet a third-party skill

A skill is instructions plus optional scripts that run with your permissions. A plugin can also
add hooks (run on every session event) and MCP servers (new tools, often remote). Treat an
install like adding a dependency to production.

| # | Check | How |
|---|---|---|
| 1 | Prefer official marketplaces | `claude-plugins-official` and `anthropics/*` first. The official directory pins third-party plugins to a commit SHA |
| 2 | Read every SKILL.md before installing | On GitHub, or after install under `~/.claude/plugins/cache/<marketplace>/<plugin>/`. Look for instructions to fetch URLs, send messages or edit files outside the task |
| 3 | Read the scripts | `find <plugin dir> -name '*.py' -o -name '*.js' -o -name '*.sh'`. Skills can run code |
| 4 | Look for outbound network calls | `grep -rnE 'curl \|wget \|fetch\(\|requests\.\|urllib\|https?://' <plugin dir>`. Any call that sends data out is a lethal-trifecta leg |
| 5 | Check hooks and MCP servers | `claude plugin details name@marketplace` lists hooks, MCP servers and the always-on token cost. A `SessionStart` hook runs in every session, including headless vault jobs |
| 6 | Check the license | MIT / Apache-2.0: fine. Source-available (Anthropic's document skills): install, don't redistribute. Non-commercial (PolyForm NC): not for work use. No license: assume all rights reserved |
| 7 | Check it is alive | Last commit, open issues, who maintains it. A stale skill is fine; a stale plugin with hooks is not |
| 8 | Pin versions | `claude plugin marketplace add owner/repo#v1.2.3` (tag or branch). Re-read the diff before `claude plugin marketplace update` |
| 9 | Keep it out of unattended runs | Headless jobs (`automation/run-skill.sh`) inherit installed plugins. Disable anything with hooks or MCP servers you have not vetted, or the job's allowlist won't save you |
| 10 | Never vendor | Don't copy third-party skill files into this repo or your vault. Install from the source so the license and the updates stay with the author |
| 11 | Budget the context | Sum the always-on cost of what you installed. If you stop using a plugin, `claude plugin disable` it. `/skill-doctor` finds unused skills |
