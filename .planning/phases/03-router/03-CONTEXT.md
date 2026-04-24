# Phase 3: Router - Context

**Gathered:** 2026-04-24
**Status:** Ready for planning

<domain>
## Phase Boundary

Smart council classifier that analyzes the user's question, suggests the most appropriate council with reasoning, and dispatches after user confirmation. The router is a new skill (`council-router`) that coexists with direct council invocation — it's an entry point for when the user doesn't know which council to use, not a gate that all invocations must pass through.

</domain>

<decisions>
## Implementation Decisions

### Classification approach
- **D-01:** LLM reasoning over SKILL.md descriptions — the router reads each council's SKILL.md description and trigger phrases to classify the user's question. No hardcoded keyword map. Adding a new council means adding it to the router's static list, and the council's own description drives classification.
- **D-02:** Static list of installed councils maintained in the router's own SKILL.md. Currently: `council-code`, `council-strategy`. Updated manually when new councils ship.
- **D-03:** Best guess with override — when ambiguity exists, router picks its best match and presents it with reasoning. User can override.
- **D-04:** When no council is a strong fit, router suggests the closest match with a caveat flagging low confidence. Never refuses to suggest.

### Suggestion UX
- **D-05:** Compact recommendation block format — council name, 1-2 sentence reasoning, then confirm/override prompt. Not a table, not prose.
- **D-06:** Two-option confirm flow: "Run [suggested council]" or "Pick a different council" (which shows all installed councils). One round-trip for the happy path.
- **D-07:** Router passes the user's original question through as-is to the dispatched council. No reformulation, no added context. The council's own SKILL.md handles context extraction.

### Dispatch mechanism
- **D-08:** Skill tool invocation — router uses the Skill tool to invoke the chosen council (e.g., `Skill(skill="council-code")`). Council runs in the same conversation, not as a subagent.
- **D-09:** Classify only installed councils — router does not reference or promise future councils (design, research, review). Only councils in the static list are classification targets.

### Skill identity
- **D-10:** Skill name is `council-router`. Primary invocation via `/council-router`.
- **D-11:** `/council` is reassigned from council-code to council-router. This makes `/council` the smart entry point. `/council-code` remains the direct shortcut to the code council. `/council-strategy` remains the direct shortcut to the strategy council.
- **D-12:** Router coexists with direct council invocation — power users bypass the router via `/council-code` or `/council-strategy` directly. Router is for when you don't know which council fits.
- **D-13:** Explicit router triggers only — "which council should I use", "route this", "help me pick a council". Router does NOT intercept ambiguous triggers like "second opinion" or "stress test" that currently map to council-code.

### Claude's Discretion
- Exact wording of the classification prompt within the router SKILL.md
- Format details of the recommendation block (bold, emoji, spacing)
- How the "Pick a different council" list is presented (inline options vs numbered list)
- Error handling when Skill tool invocation fails

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing council skills (templates and classification targets)
- `skills/council-code/SKILL.md` — Code council orchestrator. Read its `description` frontmatter for trigger phrases the router will classify against. Also the structural template for how a council SKILL.md works.
- `skills/council-strategy/SKILL.md` — Strategy council orchestrator. Read its `description` frontmatter for trigger phrases. Second classification target.

### Infrastructure
- `install.sh` — Must be updated to include `council-router` in SKILLS array. Also: `/council` trigger reassignment from code to router.
- `.claude-plugin/plugin.json` — Plugin manifest (may need update for new skill)

### Requirements
- `.planning/REQUIREMENTS.md` §Router — ROUT-01 through ROUT-03

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `skills/council-code/SKILL.md` — Structural template for a skill file. Router will follow the same frontmatter schema (`name`, `description`, `disable-model-invocation: true`).
- Both existing council SKILL.md files have trigger phrases in their `description` field — this is exactly what the router's LLM classification will read.

### Established Patterns
- **Skill frontmatter:** `name`, `description`, `disable-model-invocation: true` — router must follow this
- **Naming convention:** `council-{domain}` for skill directories — router is `council-router`
- **Agent naming:** `{council}-{persona}.md` — router has no agents (it's a pure orchestrator)
- **Skill tool chaining:** GSD workflows use `Skill(skill="...")` to chain skills — router will use this for dispatch

### Integration Points
- `install.sh` SKILLS array — `council-router` skill directory must be added
- `~/.claude/skills/council-router/` — Where skill directory gets symlinked
- Council SKILL.md `description` fields — Router reads these for classification. Any changes to trigger phrases in council descriptions affect router accuracy.
- `/council` trigger — currently points to `council-code`, needs reassignment to `council-router`

</code_context>

<specifics>
## Specific Ideas

- `/council` as the "smart entry point" — short name goes to the router, specific names (`/council-code`, `/council-strategy`) are direct shortcuts for power users who already know which council they want.
- Classification is intentionally lightweight — read descriptions, reason about fit, suggest. No scoring system, no weights, no ML. The LLM's own understanding of the question and the council descriptions is the entire classification engine.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-router*
*Context gathered: 2026-04-24*
