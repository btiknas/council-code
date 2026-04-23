# Council Code — Multi-Council Decision Platform

## What This Is

A multi-council decision system for Claude Code that stress-tests decisions across different domains — code, strategy, design, research, and code review — by running independent specialized advisors in parallel and synthesizing a verdict. Each council has its own expert roster tuned to its domain, and a smart router suggests the right council for any given question.

## Core Value

Independent, parallel multi-perspective analysis that catches blind spots, fatal flaws, and missed opportunities before decisions become costly mistakes.

## Requirements

### Validated

- ✓ 5-advisor code council (Contrarian, First Principles, Expansionist, Outsider, Executor) — existing
- ✓ Parallel advisor spawning (no anchoring) — existing
- ✓ Chairman synthesis (agreements, clashes, blind spots, recommendation, first action) — existing
- ✓ Single advisor invocation — existing
- ✓ install.sh with symlink/copy modes — existing
- ✓ Statusline badge + update check hook — existing
- ✓ `/council-update` skill — existing

### Active

- [ ] Router council — smart classifier that analyzes the problem, suggests which council fits, and dispatches after user confirmation
- [ ] council-strategy — custom roster for business/product decisions (pricing, market, roadmap)
- [ ] council-design — custom roster for UI/UX decisions (layouts, flows, design systems)
- [ ] council-research — custom roster for technical research (evaluate tools, approaches, papers)
- [ ] council-review — custom roster for automated multi-perspective PR/code review
- [ ] Custom agent rosters per council (each council has unique specialized advisors, not just re-skinned prompts)
- [ ] Git hook triggers — auto-council on PRs, commits, or specific file changes
- [ ] Monorepo single install — all councils installed together via one install.sh

### Out of Scope

- MCP server — not a priority for this milestone
- Cost-aware mode / advisor skipping — always run full roster
- À la carte installation — all councils install together
- Mobile/web UI — CLI/Claude Code only
- Cross-council synthesis (running multiple councils on one question and merging) — defer to future

## Context

Built on the original council-code repo which implements the 5-advisor pattern inspired by Andrej Karpathy's LLM Council concept and itzshyam/llm-council's 5-persona roster. The existing system works well for code decisions — this project extends the pattern to cover the full spectrum of engineering and product decisions.

The codebase is a Claude Code plugin/skill system. No runtime dependencies — everything is prompt engineering (Markdown agent definitions + SKILL.md orchestrators). The install.sh handles symlinking into `~/.claude/`.

Key insight from the existing system: the 5-persona shape works because it's enough for diversity but few enough for tractable synthesis. Each new council should respect this — custom rosters of ~5 advisors, not 10+.

## Constraints

- **Architecture**: Pure Markdown skill/agent definitions — no compiled code for the council logic itself
- **Install**: Single install.sh must handle all councils, backward-compatible with existing installs
- **Advisor count**: Each council should have ~5 advisors (proven sweet spot for diversity vs synthesis quality)
- **Parallel execution**: All advisors within a council must run in parallel (non-negotiable — prevents anchoring)
- **Backward compatibility**: Existing `/council-code` and `/council` triggers must keep working exactly as they do today

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Custom rosters per council | Different domains need different expert lenses — a "UX Researcher" matters in design but not in code review | — Pending |
| Router as suggest + confirm | User keeps control over which council runs, but gets intelligent suggestion | — Pending |
| Monorepo with single install | Simplicity — one repo, one install command, all councils available | — Pending |
| Git hooks for auto-council | Catches issues at commit/PR time without manual invocation | — Pending |
| Always full council (no cost optimization) | Quality over cost — every advisor adds value | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-23 after initialization*
