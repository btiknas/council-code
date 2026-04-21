# council-code

> Five-advisor code decision council for Claude Code. Stress-test your architecture, refactor, or debug hypothesis with Contrarian, First Principles, Expansionist, Outsider, and Executor personas running in parallel — then get a synthesized verdict.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

---

## What it does

When you hit a code decision where one perspective isn't enough — **architecture choices, library selection, refactor vs. rewrite, debug hypotheses, pre-PR review** — invoke the council. Five advisors analyze your question **independently and in parallel**, then a chairman synthesis surfaces:

- Where the council agrees
- Where the council clashes
- Blind spots the original framing missed
- A clear recommendation
- The one thing to do Monday morning

## The 5 Advisors

| Advisor | Lens | Prevents |
|---------|------|----------|
| 🔴 **Contrarian** | Finds the fatal flaw | Shipping the obvious disaster |
| 🔵 **First Principles** | Strips the problem to its core | Cargo-cult decisions |
| 🟢 **Expansionist** | Finds the upside being missed | Leaving value on the table |
| ⚪ **Outsider** | Imports patterns from distant domains | Stack-bubble blindness |
| 🟡 **Executor** | Answers "what do I do Monday morning?" | Paralysis by analysis |

All five run **in parallel** (never sequential) to prevent anchoring. Each is a standalone subagent you can also invoke individually.

---

## Installation

### Option A — `install.sh` (recommended, user-global)

Gives you a bare `/council-code` slash command (no plugin namespace).

```bash
git clone https://github.com/btiknas/council-code.git
cd council-code
./install.sh
```

Restart Claude Code, then use `/council-code` or natural language ("get a second opinion," "stress test this").

By default `install.sh` **symlinks** the skill, the 5 persona agents, and the `/council-update` helper into `~/.claude/`, so `git pull` in the repo is enough to update — no reinstall needed. Flags:

```bash
./install.sh              # symlink mode (default)
./install.sh --copy       # copy files instead of symlinking
./install.sh --uninstall  # remove symlinks/files
```

**Updates:** Run `/council-update` inside Claude Code. It fetches `origin/main`, shows the changelog, asks for confirmation, and fast-forwards the repo. (Or run `git pull` in the repo manually — symlinks pick up the new files immediately.)

### Option B — As a Claude Code plugin

Appears as `/council-code:council-code` (plugins are always namespaced).

```bash
# In Claude Code:
/plugin marketplace add btiknas/council-code
/plugin install council-code@council-code
```

Updates via `/plugin update council-code`.

> **⚠ Prerequisite:** Claude Code clones plugin repos over **SSH** (`git@github.com:…`). If you see `Permission denied (publickey)` during install, you don't have an SSH key registered with GitHub. Two fixes:
>
> **Fix 1 — Add an SSH key** (cleanest):
> ```bash
> ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519 -N ""
> gh ssh-key add ~/.ssh/id_ed25519.pub --title "claude-code"
> ```
>
> **Fix 2 — Rewrite SSH to HTTPS globally** (if you already use `gh auth` with an HTTPS token):
> ```bash
> git config --global url."https://github.com/".insteadOf git@github.com:
> ```
> This makes every `git@github.com:` URL transparently use HTTPS + your `gh` credentials. Undo with `git config --global --unset url."https://github.com/".insteadOf`.

### Option C — Manual install (project-scoped)

Drop the skill and agents into the project you want the council active in:

```bash
cd your-project/
mkdir -p .claude/skills .claude/agents
cp -r /path/to/council-code/skills/council-code .claude/skills/
cp /path/to/council-code/agents/*.md .claude/agents/
```

---

## Usage

### Full council

```
/council Should we split the billing module out of our Django monolith?
```

or in natural language:

```
Get a council review on whether to migrate from Prisma to Drizzle.
```

```
Stress test this approach: I'm thinking of using Redis streams for the event log.
```

### Single advisor

Skip the synthesis and call one persona:

```
Have the Contrarian review this PR plan.
```

```
Get a First Principles take on my auth layer.
```

```
Ask the Executor: what do I ship first?
```

### What you get back

```markdown
## Decision
[your question, restated cleanly]

## Where the council agrees
...

## Where the council clashes
...

## Blind spots the council caught
...

## Recommendation
[a committed direction, not a hedge]

## The one thing to do first
[single concrete action]
```

---

## When to use it

✅ **Good fits**
- Architecture decisions (monolith vs. services, sync vs. async, SQL vs. NoSQL)
- Library / framework selection
- Refactor vs. rewrite debates
- Performance strategy
- API / data model design
- Debug hypotheses when root cause is ambiguous
- Pre-PR self-review of significant changes

❌ **Overkill for**
- Simple factual code questions
- Tiny mechanical changes (rename, typo, add log)
- Decisions you've already made — just implement them

---

## Structure

```
council-code/
├── .claude-plugin/plugin.json    # Plugin manifest
├── agents/                        # 5 persona definitions
│   ├── contrarian.md
│   ├── first-principles.md
│   ├── expansionist.md
│   ├── outsider.md
│   └── executor.md
├── skills/
│   ├── council-code/SKILL.md      # Orchestrator
│   └── council-update/SKILL.md    # /council-update — pull latest from GitHub
├── install.sh                     # User-global installer (symlink or copy)
├── docs/
│   ├── personas.md                # Why these 5
│   └── usage.md                   # Example transcripts
├── hooks/                         # (reserved)
├── mcp-server/                    # (reserved)
├── CLAUDE.md                      # Repo context for Claude
├── LICENSE                        # MIT
├── SECURITY.md                    # Security policy
└── README.md
```

---

## Design principles

1. **Parallel, never sequential.** Advisors must not see each other's output until synthesis — that's where independence lives.
2. **Each persona is pure.** The Contrarian only finds flaws; the Executor only picks actions. Role separation is the product.
3. **The skill orchestrator stays thin.** Logic lives in the persona prompts, not the orchestrator.
4. **Code-focused for now.** Future siblings (`council-strategy`, `council-design`, …) will share the five-persona shape with different domain framings.

Read [`docs/personas.md`](./docs/personas.md) for the extended rationale.

---

## Roadmap

- [ ] `hooks/` — optional pre-PR auto-council hook
- [ ] `mcp-server/` — expose council as MCP tool (Claude Desktop, other clients)
- [ ] Sibling councils: `council-strategy`, `council-design`, `council-research`
- [ ] Cost-aware mode: dispatch lighter personas (or skip some) based on question complexity

---

## Credits

- **Andrej Karpathy** — original LLM Council concept (multiple independent advisors + synthesis)
- **[itzshyam/llm-council](https://github.com/itzshyam/llm-council)** — the exact 5-persona roster, originally as a browser tool
- **"Tenth Man Rule"** — the Contrarian's discipline

This repo ports and extends that roster as a first-class Claude Code skill with code-focused persona prompts.

---

## License

MIT — see [LICENSE](./LICENSE).

## Security

See [SECURITY.md](./SECURITY.md) for reporting.
