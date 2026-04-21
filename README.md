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

### Option A — As a Claude Code plugin (recommended)

```bash
# In Claude Code:
/plugin marketplace add btiknas/council-code
/plugin install council-code@council-code
```

That's it. The skill is now available via `/council` or natural language ("get a second opinion," "stress test this").

### Option B — Manual install (user-global)

Clone and copy into your global Claude Code config:

```bash
git clone https://github.com/btiknas/council-code.git
mkdir -p ~/.claude/skills ~/.claude/agents
cp -r council-code/skills/council-code ~/.claude/skills/
cp council-code/agents/*.md ~/.claude/agents/
```

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
├── skills/council-code/SKILL.md   # Orchestrator
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
