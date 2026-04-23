# Project Research Summary

**Project:** council-code — Multi-Council Decision Platform
**Domain:** Claude Code plugin / multi-agent advisory system
**Researched:** 2026-04-23
**Confidence:** HIGH

## Executive Summary

This project extends an existing, working single-council Claude Code plugin into a five-council decision platform. The existing system already proves the core pattern: 5 advisors spawned in parallel (no anchoring), independent analyses, chairman synthesis. The extension adds four new domain-specific councils (strategy, design, research, review), a router for council discovery, git hook triggers for automated review, and a unified installer. The no-compiled-code constraint is non-negotiable — everything must remain pure Markdown SKILL.md and agent `.md` files, with Node.js hooks as the only executable layer.

The recommended approach is additive and disciplined. New councils are built using the same SKILL.md orchestrator + agent file pattern already proven by the code council. Each council gets its own 5 advisors written from scratch for their domain — not re-skinned versions of the code council personas. A router SKILL.md classifies questions and suggests a council with a confirm step (never auto-dispatches). Git hooks are opt-in only. The installer remains a single `install.sh` extended with new array entries.

The two most critical risks are: (1) advisor persona namespace collision across councils — if agent files are not prefixed by council slug, multi-council install silently overwrites personas and degrades quality; and (2) synthesis quality degradation from copying code council output formats into non-code domains. Both risks must be addressed before any new council ships. A third systemic risk is install.sh complexity explosion as the inline Node.js settings patcher grows to handle 4+ councils — extracting it to a standalone script before adding the second council prevents cascading fragility.

## Key Findings

### Recommended Stack

The existing pure-Markdown stack is correct and should be extended, not replaced. SKILL.md files with `disable-model-invocation: true` serve as council orchestrators; agent `.md` files with restricted tool allowlists (`Read, Grep, Glob, WebSearch, WebFetch`) serve as advisors. No agents get Write/Edit tools. Claude Code's Task tool (aliased as "Agent" since v2.1.63) handles parallel advisor spawning. Node.js (stdlib only) handles hook scripts and settings.json patching.

**Core technologies:**
- **SKILL.md orchestrators** (`disable-model-invocation: true`): council entry points — prevents auto-loading into context, enforces explicit invocation, supports `$ARGUMENTS` substitution and inline shell execution
- **Agent `.md` files** (per-council namespaced): advisor personas — self-contained, standalone-invocable, domain-specific; prefixed by council slug to prevent namespace collision in `~/.claude/agents/`
- **Task tool (parallel batch)**: parallel advisor spawn — the anti-anchoring invariant; all 5 calls in one message, never sequential
- **Node.js hooks** (stdlib only): PostToolUse git trigger and session hooks — safe JSON handling, zero-dependency
- **install.sh + inline Node.js**: idempotent installer — array-driven, backup-before-patch, append-only settings mutation

**Key constraint:** No `context: fork` on council orchestrators (would lose conversation context). No `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` (enables inter-advisor communication, which is the opposite of what anchoring prevention requires). No MCP server (adds compiled build step, breaks zero-dependency constraint).

### Expected Features

**Must have (table stakes):**
- Domain-specific advisor rosters per council (5 agents per council, written for the domain — not re-skinned code personas)
- Router / council selector SKILL.md with suggest-and-confirm (never auto-dispatch)
- Parallel advisor execution within each council (the anti-anchoring invariant, non-negotiable)
- Chairman synthesis per council with domain-appropriate vocabulary and success criteria
- Backward-compatible `/council-code` trigger (existing users must not break)
- Monorepo single install command covering all councils
- Per-council trigger phrases in SKILL.md descriptions for auto-suggestion
- `disable-model-invocation: true` on all council orchestrators
- Standalone advisor invocation (single agent without full council overhead)
- Uninstall support for all new components

**Should have (competitive):**
- Git-triggered council-review on commit via PostToolUse hook (opt-in, async, not blocking)
- Domain-native advisor identities — genuine per-domain expert lenses, not domain wrappers on shared prompts
- Explicit "when NOT to use" guidance in each SKILL.md
- Council-specific success criteria in the chairman synthesis prompt

**Defer (v2+):**
- Statusline badge showing available councils (low signal until 8+ councils)
- Single advisor "office hours" router variant (users can already invoke by name)
- Cross-council synthesis (explicitly out of scope — produces synthesis-of-syntheses too abstract to act on)
- Web UI or visualization layer

### Architecture Approach

The system uses a two-layer model: a thin router skill that classifies questions and delegates to council orchestrators; and council orchestrators that extract context, spawn ~5 advisors in parallel via Task tool, and synthesize a chairman verdict. Advisors are self-contained agents that receive context but communicate with nothing — the independence is the correctness property. The router is a classifier, not a council; it has no advisors and does no synthesis of its own.

**Major components:**
1. **council-router/SKILL.md** — classifies question type, suggests council, waits for user confirmation, delegates
2. **council-{domain}/SKILL.md** (x5 total) — orchestration protocol: extract, parallel-spawn 5 agents, chairman synthesis
3. **agents/{council}-{role}.md** (~25 total) — domain-specific advisor personas, self-contained, read-only tools
4. **hooks/council-git-trigger.js** — PostToolUse detector for git commit operations, prompts council-review
5. **install.sh** — idempotent array-driven installer; extend SKILLS, PERSONAS, HOOKS arrays; append-only settings patching

**Key patterns:**
- Thin orchestrator (< 150 lines of pure protocol, no persona logic)
- Self-contained advisor (each agent file fully portable, standalone-invocable)
- Router as suggest-and-confirm (classification only, never auto-dispatch)
- Install idempotency (arrays extended, logic unchanged, re-runnable)
- Hook composition via delegation (append-only, never overwrite existing hooks)

### Critical Pitfalls

1. **Advisor persona namespace collision** — All councils install agent files into the flat `~/.claude/agents/` namespace. Bare names like `executor.md` or `contrarian.md` will be silently overwritten when a second council ships. Prevention: rename existing code council agents to `code-` prefix (e.g., `code-contrarian.md`) before any new council ships, and namespace all new agents as `{council}-{role}.md`. This is a one-time breaking change requiring a MIGRATION.md — do it first.

2. **Domain output format mismatch** — New councils built by copy-pasting code council personas with domain vocabulary swapped produce structurally wrong synthesis. Strategy advisors applying `## Fatal Flaw [Severity: Critical]` to pricing decisions give code-review framing to business problems. Prevention: define each council's domain-specific output contract before writing any advisor files; write the chairman synthesis template using domain vocabulary (assumptions, risks, viability) not code vocabulary.

3. **install.sh settings.json complexity explosion** — The inline Node.js settings patcher is already documented as the most fragile part of the codebase. Adding 4 councils multiplies detection logic, backup accumulation, and delegation-chain management. Prevention: extract settings patching to a standalone `hooks/patch-settings.js` with a `~/.claude/council-registry.json` state file before adding the second council.

4. **Router misfires on cross-domain questions** — LLM classifiers over-index on surface keywords: "should we rewrite the billing service?" routes to council-strategy when it's a code question. Prevention: build the router around problem type (what is being decided?), not phrasing; include explicit overlap rules ("code question with business context defaults to council-code"); test against 10 real ambiguous questions before release.

5. **Sequential advisor spawn** — Accidentally awaiting each Task call in sequence rather than batching poisons all later advisors with earlier advisors' framing. Prevention: require parallel spawn verification in integration review; the integration test must confirm all advisor task calls appear in a single turn.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundation — Agent Namespacing + Installer Refactor

**Rationale:** Pitfall 1 (namespace collision) and Pitfall 3 (install complexity) must be resolved before any new council is built. These are pre-conditions, not features. Attempting to add council-strategy before renaming existing agents locks in the collision. Attempting to wire 4 councils into the existing inline patcher creates compounding fragility. This is groundwork that costs little now and prevents rewrites later.

**Delivers:**
- Existing code council agents renamed to `code-` prefix (`code-contrarian.md`, `code-executor.md`, etc.)
- MIGRATION.md documenting the rename for existing users
- Settings patcher extracted to `hooks/patch-settings.js` with `~/.claude/council-registry.json`
- install.sh slimmed to thin orchestration calling the standalone patcher
- Version bump in `.claude-plugin/plugin.json` (0.4.0 → 0.5.0)

**Addresses:** Pitfall 1 (namespace collision), Pitfall 3 (install fragility)
**Avoids:** Having to coordinate a breaking rename across 4 councils simultaneously later

### Phase 2: First New Council — council-strategy + Router

**Rationale:** council-strategy is the highest-value first new council (most common non-code decision type: product, pricing, roadmap). The router becomes meaningful the moment a second council exists. Together they prove the multi-council pattern end-to-end. The router must be built after council-strategy exists so it has a real second council to route to. Build order within this phase: agent files first (leaves), then council-strategy SKILL.md (depends on agents), then council-router SKILL.md (depends on council-strategy existing).

**Delivers:**
- 5 strategy advisor agents (`strategy-market-analyst.md`, `strategy-risk-assessor.md`, `strategy-growth-hacker.md`, `strategy-operator.md`, `strategy-skeptic.md`) with domain-native output contracts
- `skills/council-strategy/SKILL.md` with strategy-vocabulary chairman synthesis
- `skills/council-router/SKILL.md` with suggest-and-confirm pattern and domain boundary definitions
- Extended install.sh arrays covering strategy agents and router skill
- Validation that router correctly distinguishes code vs. strategy on 10 real questions

**Addresses:** Domain-specific rosters, router/council selector, backward compatibility
**Avoids:** Pitfall 2 (router misfires — domain boundaries defined before personas written), Pitfall 4 (domain output format mismatch — strategy output contract written first)
**Uses:** SKILL.md orchestrator pattern, namespaced agent files, suggest-and-confirm router pattern

### Phase 3: Complete the Council Library — Design, Research, Review

**Rationale:** Once the pattern is proven with council-strategy, councils-design, -research, and -review follow the same template. council-review is a prerequisite for the git hook trigger in Phase 4, so it must be in this phase. All three can be built in parallel if bandwidth allows; the only dependency is that each council's agent files exist before its SKILL.md references them.

**Delivers:**
- council-design: 5 advisors (UX researcher, systems thinker, accessibility advocate, motion critic, pragmatist)
- council-research: 5 advisors (domain expert, skeptic, historian, practitioner, synthesizer)
- council-review: 5 advisors (security auditor, performance critic, readability reviewer, test coverage analyst, architect)
- SKILL.md orchestrators for each with domain-appropriate synthesis templates
- Extended install.sh arrays covering all new agents and skills
- Full router update covering all 5 councils

**Addresses:** Complete council library, confirms pattern generalizes across domains
**Avoids:** Pitfall 4 (repeated — each council needs fresh domain output contract), Pitfall 7 (agent description auto-trigger misfires — explicit "when NOT to use" in each advisor description)

### Phase 4: Automation Layer — Git Hook Triggers

**Rationale:** council-review must be stable before the git hook is built (the hook hardcodes a reference to council-review). Git hooks are opt-in, async, and non-blocking by design — they must never block a push. The hook surfaces a suggestion ("council-review available") rather than auto-running the council. Install uses `--with-git-hooks` flag.

**Delivers:**
- `hooks/council-git-trigger.js` (PostToolUse on Bash matching `git commit *`)
- Opt-in `.git/hooks/pre-commit` installer (`--with-git-hooks` flag in install.sh)
- Async suggestion pattern (not blocking pre-push)
- Threshold filtering (no trigger on docs-only or trivial commits)

**Addresses:** Git-triggered council-review, automation without friction
**Avoids:** Pitfall 6 (git hook noise — opt-in per-project, async, suggestion not autorun)

### Phase Ordering Rationale

- Phase 1 before everything else: namespace collision and install fragility are defects in the current system that become permanently harder to fix once new councils are layered on top
- Agents before orchestrators before router: the dependency graph (leaves → orchestrators → router) dictates this order within phases
- council-strategy before other councils: highest user value, lowest domain ambiguity, cleanest first proof of pattern generalization
- Router ships with the first new council, not before it: a router with only one destination is pointless
- Git hooks last: they are a convenience automation that requires a stable council-review; no point building the trigger before the thing it triggers

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 1 (installer refactor):** The migration path for existing users renaming agent files needs careful design — users who reference `contrarian.md` in custom prompts will break. How to communicate this and provide a compatibility shim (if any) needs a decision.
- **Phase 4 (git hooks):** The PostToolUse hook's `if` conditional syntax for matching git commit subcommands needs verification at implementation time — the filter pattern `Bash(git commit *)` glob behavior may need adjustment.

Phases with standard patterns (skip research-phase):
- **Phase 2 (council-strategy + router):** The orchestrator pattern is fully proven by the existing code council. Persona writing is craft, not research. Router classification is well-understood prompt engineering.
- **Phase 3 (design, research, review councils):** Direct replication of the Phase 2 pattern. Domain output contracts are the only novel work, and that is authoring not research.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All SKILL.md, agent, and hook patterns verified against current official Claude Code docs (April 2026). Task tool rename confirmed. `disable-model-invocation` behavior confirmed. |
| Features | HIGH | Feature set grounded in existing working system plus first-principles reasoning from Anthropic's building-effective-agents guidance. Anti-features are well-reasoned constraints. |
| Architecture | HIGH | Two-layer model (router + councils) verified against official docs. Component boundaries are clear. Anti-patterns are concrete and verifiable. |
| Pitfalls | HIGH | Sourced from direct codebase inspection (CONCERNS.md), existing install.sh analysis, and official Claude Code plugin documentation on agent namespace and description triggering. |

**Overall confidence:** HIGH

### Gaps to Address

- **Agent rename migration UX**: Research did not produce a definitive answer on whether a compatibility shim (symlink from old name to new name) is feasible in the Claude Code agent discovery model, or whether a hard cutover with MIGRATION.md is the only option. Validate during Phase 1 planning.
- **Router confirmation interaction design**: The specific UX of the confirm step (single-keypress vs. typed response) depends on what Claude Code's skill output renders interactively. The suggest-and-confirm pattern is validated conceptually; the exact interaction needs to be tested against a real Claude Code session during Phase 2 planning.
- **Token budget for council-review on large PRs**: The 5x token multiplier for passing full diff context to all advisors was flagged as a trap but not benchmarked. Phase 3 planning should establish context size limits for the review council's brief.

## Sources

### Primary (HIGH confidence)
- [Claude Code Skills docs](https://code.claude.com/docs/en/skills) — SKILL.md frontmatter, `disable-model-invocation`, `context: fork`, `$ARGUMENTS`, inline shell execution
- [Claude Code Sub-agents docs](https://code.claude.com/docs/en/sub-agents) — Agent frontmatter, tool restrictions, Task→Agent rename, parallel invocation
- [Claude Code Hooks docs](https://code.claude.com/docs/en/hooks) — PostToolUse, FileChanged, JSON payload format, `if` conditional, exit code behavior
- [Claude Code Plugins docs](https://code.claude.com/docs/en/plugins) — Plugin structure, hooks.json, agent auto-discovery, namespace behavior
- [Claude Code Agent Teams docs](https://code.claude.com/docs/en/agent-teams) — Why NOT to use for council pattern (inter-agent comms vs. independence)
- Existing codebase: `install.sh`, `skills/council-code/SKILL.md`, `agents/contrarian.md`, `.planning/codebase/CONCERNS.md`

### Secondary (MEDIUM confidence)
- [Anthropic: Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) — Routing workflow pattern, parallelization + voting, orchestrator-workers model
- [llm-council (itzshyam)](https://github.com/itzshyam/llm-council) — Original parallel council + anonymous peer review pattern confirming parallel execution as core correctness property
- [LLM Agent architecture survey (Lilian Weng)](https://lilianweng.github.io/posts/2023-06-23-agent/) — MRKL routing, collection of expert modules with LLM-as-router

### Tertiary (context only)
- [CodeRabbit](https://coderabbit.ai/) — Reference for PR-level automated review triggering patterns

---
*Research completed: 2026-04-23*
*Ready for roadmap: yes*
