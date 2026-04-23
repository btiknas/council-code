# Feature Landscape

**Domain:** Multi-agent council / advisory system (Claude Code plugin)
**Researched:** 2026-04-23
**Confidence:** HIGH for system-design reasoning from first principles; MEDIUM for multi-agent pattern benchmarks; confirmed against Anthropic building-effective-agents guidance and Claude Code hooks/skills documentation.

---

## Context: The Expansion Problem

The existing system is a single-council tool. It works well because its scope is narrow: code and engineering decisions, 5 advisors, one synthesis pattern. Expanding to a multi-council system introduces new feature categories that did not exist before:

- **Discovery**: How does a user find the right council?
- **Specialization**: How does each council differ from the code council?
- **Automation**: When should councils run without being explicitly invoked?
- **Coherence**: How does a growing council library stay usable?

The features below are organized by that framing: what a multi-council system must have, what makes one stand out, and what would actively hurt it.

---

## Table Stakes

Features users expect. Missing = product feels incomplete or broken.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Domain-specific advisor rosters per council | Without this, new councils are re-labeled copies of the code council; the entire value proposition collapses | High | 5 unique agent `.md` files per council; ~20 new agent definitions total across 4 councils |
| Router / council selector | With 5+ councils, users cannot be expected to know which `/council-*` command to invoke; discovery requires guidance | Medium | Single SKILL.md classifier, suggest-and-confirm output; NOT auto-dispatch |
| Parallel advisor execution within each council | The anti-anchoring property is the core correctness guarantee of the council pattern; sequential execution poisons outputs | High (already solved) | Existing Task-tool parallel spawn pattern; apply consistently to all new councils |
| Chairman synthesis per council | Without synthesis, users get 5 unstructured opinions; synthesis is the output that matters | Medium (pattern established) | Each council's SKILL.md implements the same synthesis structure with domain-appropriate section labels |
| Backward-compatible `/council-code` trigger | Existing users must not break; this is a monorepo extension, not a replacement | Low | Additive arrays in install.sh; no changes to existing skill files |
| Monorepo single install command | Users installing 5 councils independently is not viable; one `./install.sh` must wire everything | Low | Extend existing installer arrays; well-understood pattern |
| Per-council trigger phrases in SKILL.md descriptions | Without clear trigger phrases, Claude cannot auto-suggest the right council when users describe a problem type | Low | Each SKILL.md `description` frontmatter must enumerate domain signals |
| `disable-model-invocation: true` on all council orchestrators | Without this flag, Claude loads all council content into context on every turn, burning tokens and confusing context | Low | One-line frontmatter; critical to add to all new councils |
| Standalone advisor invocation (no full council) | Power users and quick checks need single-persona access without 5-agent overhead | Low (already solved) | Each agent file is standalone by design; document explicitly |
| Uninstall support for all new components | A growing library of councils must be cleanly removable | Low | Extend existing `uninstall` path in install.sh |

---

## Differentiators

Features that set this product apart. Not universally expected, but create meaningful value.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Git-triggered council-review on commit | Catches issues at the moment a decision is committed, without manual invocation; makes the review council ambient | Medium | PostToolUse hook for Claude-executed `git commit`; separate traditional `.git/hooks/pre-commit` for terminal-invoked commits (opt-in via `--with-git-hooks`) |
| Suggest-and-confirm routing (not auto-dispatch) | User keeps control; avoids 5-agent runs on misclassified problems; builds trust by explaining routing reasoning | Low | Router outputs rationale + confirmation prompt; never silently dispatches |
| Domain-native advisor identities (not re-skinned code advisors) | Genuine domain expertise in advisor prompts produces qualitatively better analysis than wrapping shared prompts with a domain prefix | High (writing quality) | "Design UX Researcher" reasons differently from "Code Contrarian" — requires purpose-built persona prompts |
| Explicit "when NOT to use this council" guidance in each SKILL.md | Prevents cognitive overhead of consulting a council for low-stakes decisions; mirrors the existing code council pattern | Low | One section per SKILL.md; important for user trust |
| Advisor count discipline (~5 per council) | More advisors dilute synthesis; fewer lose diversity; 5 is the established sweet spot in this system and consistent with the Karpathy/llm-council lineage | Low (constraint) | Enforce in every council; document the rationale for contributors |
| Council-specific success criteria in the synthesis prompt | The synthesis step should ask "good for what?" differently across domains: correctness for code, desirability for design, viability for strategy | Medium | Requires per-council customization of the chairman prompt |
| Statusline badge showing available councils | Beyond the existing version-check badge, a count or listing of installed councils provides ambient awareness | Medium | Extend `council-statusline.js`; low user value unless council count grows to 8+ |
| Single advisor "office hours" mode | Invoke one persona without naming it; the router picks the single most relevant advisor for a quick, cheap opinion | Medium | Router variant: instead of "which council?", "which advisor?" — separate invocation path |

---

## Anti-Features

Features to deliberately NOT build. Building these would hurt the product.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Auto-dispatch to council without user confirmation | Triggers 5-agent runs on ambiguous inputs; wrong council = all 5 advisors give useless analysis; destroys user trust in the router | Router always suggests + asks for confirmation before running |
| Cross-council synthesis (running 2+ councils and merging verdicts) | Produces synthesis-of-syntheses that is too abstract to act on; token cost is extreme (25+ agent calls); no clear chairman identity across domains | One council per question; if the question spans domains, pick the dominant domain |
| A 6th or 7th permanent advisor in any council | Dilutes synthesis tractability; the synthesis section grows; agreements and clashes become a list rather than a story; 5 is a proven ceiling | If a domain truly needs more perspectives, split into two sub-councils rather than adding to one |
| Shared/generic advisor personas across councils | Generic personas are weaker; "Contrarian" without domain framing gives shallow, hedged criticism; users sense the difference | Write per-council advisor files even if it means more files |
| À la carte installation (individual councils) | Adds installation complexity with minimal benefit; users who want only one council still benefit from having the router available | Single monorepo install for all councils |
| Cost-aware advisor skipping (skip N advisors to save tokens) | Breaks the covering-set property; if any advisor is dropped, a class of mistake becomes invisible; selective skipping creates unpredictable quality floors | Run full 5-advisor council always, or invoke a single advisor explicitly |
| MCP server wrapper for council orchestration | Adds a compiled build step and runtime dependency; the pure-Markdown architecture is the key constraint that makes this system zero-maintenance and portable | Keep council logic in SKILL.md and agent `.md` files |
| Persistent session memory across council invocations | Building a history of past council verdicts introduces state management complexity; councils are single-turn decision tools, not a conversation partner | Each invocation is independent; users maintain their own context |
| Web UI or visualization layer | Out of scope for a CLI/Claude Code tool; the output format is already structured markdown; a UI adds maintenance burden with minimal workflow improvement | Terminal output is the UI |
| Streaming partial advisor outputs to the user | Destroys the parallel independence property; partial outputs anchor later-spawned advisors if context leaks; synthesis requires all 5 to complete before display | Always gather all 5 results, then synthesize, then display |

---

## Feature Dependencies

```
Domain-specific rosters
  └── Chairman synthesis (requires knowing which domain's success criteria apply)
  └── Trigger phrases in descriptions (requires knowing the domain's vocabulary)

Router / council selector
  └── Depends on: all councils existing and having clear descriptions
  └── Enables: standalone advisor "office hours" mode (router variant)

Git-triggered council-review
  └── Depends on: council-review council existing
  └── Depends on: opt-in git hooks installer (--with-git-hooks flag)
  └── Does NOT depend on: router (hardcoded to council-review for commit triggers)

Monorepo single install
  └── Depends on: all councils and agents defined (arrays complete)
  └── Depends on: backward compatibility maintained (no modifications to existing skill files)

Standalone advisor invocation
  └── Depends on: per-council advisor agent files existing
  └── Does NOT depend on: router (advisors callable directly by name)

Suggest-and-confirm routing
  └── Depends on: router SKILL.md classifying across all available councils
  └── Hard dependency on: NOT auto-dispatching (correctness constraint, not UX preference)
```

---

## MVP Definition

The minimum set that delivers the multi-council promise without the full scope:

### Prioritize (Phase 1 core deliverable):

1. **council-strategy** with 5 domain-native advisor personas — validates the multi-council pattern, provides immediate user value for the most common non-code decision type (product/roadmap)
2. **council-router** with suggest-and-confirm — makes the expanded system discoverable; without it, users must memorize which `/council-*` to invoke
3. **Extended install.sh** with new arrays and backward compatibility — makes council-strategy and the router actually installable

### Phase 2 (complete the council library):

4. **council-design** — UI/UX decisions; clear domain differentiation from code council
5. **council-research** — evaluate tools, papers, approaches; high value for technical research
6. **council-review** — multi-perspective PR review; differentiating automation target

### Phase 3 (automation layer):

7. **Git-triggered council-review** via PostToolUse hook + opt-in `.git/hooks/pre-commit` — makes the review council ambient; builds on council-review being stable

### Defer indefinitely:

- Statusline badge for council count (low signal, adds complexity to statusline.js)
- Single advisor "office hours" router variant (nice-to-have; users can already invoke advisors by name)
- Cross-council synthesis (explicitly out of scope per PROJECT.md)

---

## Phase-Level Feature Mapping

| Feature | Phase | Rationale |
|---------|-------|-----------|
| council-strategy (5 advisors + SKILL.md) | Phase 1 | First new council; validates pattern |
| council-router (suggest + confirm) | Phase 1 | Enables discovery for all councils |
| install.sh extension (strategy + router) | Phase 1 | Makes Phase 1 installable |
| council-design (5 advisors + SKILL.md) | Phase 2 | Second domain; confirms pattern generalizes |
| council-research (5 advisors + SKILL.md) | Phase 2 | Third domain |
| council-review (5 advisors + SKILL.md) | Phase 2 | Fourth domain; prereq for git automation |
| install.sh extension (all councils) | Phase 2 | Makes Phase 2 installable |
| PostToolUse git commit hook | Phase 3 | Requires stable council-review |
| Opt-in `.git/hooks/pre-commit` installer | Phase 3 | Opt-in; lowest user disruption |

---

## Sources

- Existing `skills/council-code/SKILL.md` — Established synthesis structure, guardrail patterns, advisor count rationale
- Existing `agents/contrarian.md` — Advisor file structure and output format contract
- Existing `docs/personas.md` — "Why these five?" rationale, advisor covering-set property
- Existing `.planning/PROJECT.md` — Active requirements, out-of-scope constraints, key decisions
- Existing `.planning/research/STACK.md` — Technology decisions that constrain feature implementation
- [Anthropic: Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) — Routing workflow pattern, parallelization + voting, orchestrator-workers, routing rationale ("separation of concerns, specialized prompts")
- [Claude Code Hooks documentation](https://code.claude.com/docs/en/hooks) — PostToolUse hook mechanism for git commit detection, FileChanged, hook configuration scopes
- [llm-council (itzshyam)](https://github.com/itzshyam/llm-council) — Original parallel council + anonymous peer review pattern; confirms parallel execution is the core correctness property
- [CodeRabbit](https://coderabbit.ai/) — Reference for what automated code review tools provide; confirms PR-level triggering as the expected automation pattern
- [LLM Agent architecture survey (Lilian Weng)](https://lilianweng.github.io/posts/2023-06-23-agent/) — MRKL routing pattern, "collection of expert modules" with LLM-as-router
