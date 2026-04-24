# Phase 3: Router - Research

**Researched:** 2026-04-24
**Domain:** Claude Code skill orchestration — LLM-based classification and skill chaining
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** LLM reasoning over SKILL.md descriptions — the router reads each council's SKILL.md description and trigger phrases to classify the user's question. No hardcoded keyword map. Adding a new council means adding it to the router's static list, and the council's own description drives classification.
- **D-02:** Static list of installed councils maintained in the router's own SKILL.md. Currently: `council-code`, `council-strategy`. Updated manually when new councils ship.
- **D-03:** Best guess with override — when ambiguity exists, router picks its best match and presents it with reasoning. User can override.
- **D-04:** When no council is a strong fit, router suggests the closest match with a caveat flagging low confidence. Never refuses to suggest.
- **D-05:** Compact recommendation block format — council name, 1-2 sentence reasoning, then confirm/override prompt. Not a table, not prose.
- **D-06:** Two-option confirm flow: "Run [suggested council]" or "Pick a different council" (which shows all installed councils). One round-trip for the happy path.
- **D-07:** Router passes the user's original question through as-is to the dispatched council. No reformulation, no added context.
- **D-08:** Skill tool invocation — router uses the Skill tool to invoke the chosen council (e.g., `Skill(skill="council-code")`). Council runs in the same conversation, not as a subagent.
- **D-09:** Classify only installed councils — router does not reference or promise future councils.
- **D-10:** Skill name is `council-router`. Primary invocation via `/council-router`.
- **D-11:** `/council` is reassigned from council-code to council-router. `/council-code` remains the direct shortcut to the code council. `/council-strategy` remains the direct shortcut to the strategy council.
- **D-12:** Router coexists with direct council invocation — power users bypass the router via `/council-code` or `/council-strategy` directly.
- **D-13:** Explicit router triggers only — "which council should I use", "route this", "help me pick a council". Router does NOT intercept ambiguous triggers like "second opinion" or "stress test" that currently map to council-code.

### Claude's Discretion

- Exact wording of the classification prompt within the router SKILL.md
- Format details of the recommendation block (bold, emoji, spacing)
- How the "Pick a different council" list is presented (inline options vs numbered list)
- Error handling when Skill tool invocation fails

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| ROUT-01 | User can invoke a router skill that classifies their question and suggests the most appropriate council | Covered by: new `skills/council-router/SKILL.md` with classification protocol; Skill tool invocation pattern documented |
| ROUT-02 | Router always presents suggestion with reasoning and waits for user confirmation before dispatching (never auto-dispatch) | Covered by: two-option confirm flow (D-06); AskUserQuestion or inline prompt; explicit anti-pattern documentation |
| ROUT-03 | Each council SKILL.md has domain-specific trigger phrases in its description frontmatter for natural language detection | Covered by: gap analysis — `council-code` description frontmatter is missing trigger phrases (present only in body); must be added to frontmatter |
</phase_requirements>

---

## Summary

Phase 3 creates a single new skill (`council-router`) that classifies a user's question against the installed council roster and presents a suggestion with reasoning before dispatching. The router has no agents of its own — it is a pure orchestrator that reads council descriptions, reasons about fit, and hands off via `Skill(skill="...")` after user confirmation.

The implementation is entirely in Markdown. The primary deliverables are: (1) a new `skills/council-router/SKILL.md` orchestrator, (2) a one-line update to `council-code`'s description frontmatter to add trigger phrases (ROUT-03 gap), and (3) an update to `install.sh` to add `council-router` to the SKILLS array and reassign the `/council` trigger.

The classification mechanism is intentionally simple: the router's SKILL.md body contains the static list of installed councils with their descriptions, and the LLM uses its own reasoning to match the user's question against those descriptions. There is no scoring function, no weight system, no ML — the classification engine is the model reading natural language descriptions. This is the same pattern the LLM already uses to route `/council-code` vs `/council-strategy` when both are installed.

**Primary recommendation:** Build `council-router` as a pure SKILL.md orchestrator following the same frontmatter schema as `council-code` and `council-strategy`. Classification is inline reasoning, not a sub-agent spawn. Dispatch is `Skill(skill="council-code")` or `Skill(skill="council-strategy")` after explicit user confirmation.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Question classification | Router skill (inline LLM reasoning) | — | Classification is a single inference step, no subagent overhead justified |
| Suggestion presentation | Router skill (SKILL.md output) | — | Output is rendered directly in the conversation |
| User confirmation | Router skill (AskUserQuestion or inline prompt) | — | One round-trip, stays in same conversation |
| Council dispatch | Router skill → target council skill | — | `Skill(skill="...")` hands off execution; council takes over the conversation |
| Trigger phrase routing | Claude Code skill system (description frontmatter) | — | Claude Code reads `description` field for natural language routing |
| Installer registration | `install.sh` SKILLS array | — | Same batch mechanism used by all councils |

---

## Standard Stack

### Core

| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| SKILL.md orchestrator | N/A (Markdown) | Entry point and classification engine | All councils use this pattern [VERIFIED: codebase] |
| Skill tool invocation | Claude Code built-in | Dispatch to target council | Confirmed pattern in `gsd-manager` and `gsd-autonomous` skills [VERIFIED: codebase] |
| AskUserQuestion tool | Claude Code built-in | Present recommendation + await confirmation | Already used in `council-update` for interactive confirmation flow [VERIFIED: codebase] |

### Supporting

| Component | Version | Purpose | When to Use |
|-----------|---------|---------|-------------|
| `install.sh` SKILLS array | N/A (bash) | Register council-router for symlink/copy install | Same pattern as `council-code`, `council-strategy`, `council-update` [VERIFIED: codebase] |
| Description frontmatter trigger phrases | N/A (YAML string) | Natural language routing by Claude Code | Required for ROUT-03; already present in `council-strategy` description, missing from `council-code` description frontmatter [VERIFIED: codebase] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Inline LLM reasoning | Subagent classification spawn | Subagent is overkill — classification is one inference step, not a multi-file research task. Subagent would add latency and a context boundary with no benefit. |
| `Skill(skill="...")` dispatch | "Type `/council-code` to proceed" suggestion | Skill dispatch is a clean handoff in the same conversation. Text suggestion requires the user to re-type a command — worse UX, no benefit. |
| AskUserQuestion | Inline text prompt asking user to respond | Either works. AskUserQuestion is cleaner for explicit option selection (Run / Pick different). Claude's discretion per CONTEXT.md. |

**Installation:** No `npm install` required — this is a pure Markdown skill.

---

## Architecture Patterns

### System Architecture Diagram

```
User question
      │
      ▼
council-router SKILL.md
  ┌──────────────────────────────────────────────┐
  │  Step 1: Read static council list            │
  │  (council-code description + triggers)       │
  │  (council-strategy description + triggers)   │
  │                                              │
  │  Step 2: Classify question against           │
  │  council descriptions (inline LLM reasoning) │
  │                                              │
  │  Step 3: Present compact recommendation      │
  │  block with reasoning                        │
  └──────────────────────────────────────────────┘
      │
      ▼
  User confirms OR picks different council
      │
      ├── "Run [suggested]" ──────────────────────────► Skill(skill="council-code")
      │                                                        │
      └── "Pick different" → show council list                 ▼
                               User picks           council-code runs in same
                               │                     conversation (no context
                               └──────────────────► boundary — it's not a subagent)
                                        │
                                        └── OR ──► Skill(skill="council-strategy")
```

### Recommended Project Structure

```
skills/
└── council-router/
    └── SKILL.md            # New: router orchestrator (only file needed)

agents/                     # No new agent files — router has no advisors

install.sh                  # Modified: add council-router to SKILLS array
skills/council-code/
    SKILL.md                # Modified: add trigger phrases to description frontmatter
```

### Pattern 1: Router SKILL.md Frontmatter

**What:** The frontmatter schema for `council-router` must include `name`, `description`, `disable-model-invocation: true`, and `allowed-tools` listing `Skill` and `AskUserQuestion`.

**When to use:** All council SKILL.md orchestrators follow this pattern [VERIFIED: codebase].

```yaml
---
name: council-router
description: Smart council selector. Analyzes your question and suggests the most appropriate council (code, strategy) with reasoning, then dispatches after confirmation. Trigger phrases: which council, route this, help me pick a council, council-router, /council.
disable-model-invocation: true
allowed-tools:
  - AskUserQuestion
  - Skill
---
```

**Critical note on `/council` reassignment:** The `description` field must include `/council` and `council` as trigger phrases. This is the mechanism by which Claude Code routes `/council` invocations to the router instead of to `council-code`. Currently `council-code`'s description frontmatter does NOT include trigger phrases — the `/council` trigger is only in the body text. Since Claude Code routes based on skill descriptions/names, the reassignment is achieved by:
1. Adding `/council` trigger to `council-router`'s description frontmatter.
2. Removing `/council` trigger phrase from `council-code`'s description frontmatter (it's not there, only in body — body trigger phrases are behavioral guidance, not routing metadata).
3. The body of `council-code/SKILL.md` still says "Trigger phrases: `/council`..." — that line should be updated to `/council-code` only.

[ASSUMED: Claude Code uses the `description` frontmatter field for skill routing. The body trigger phrases section appears to be behavioral self-description for the skill, not parsed by the Claude Code runtime for routing. This assumption is based on observed pattern — council-strategy has trigger phrases in the description frontmatter and they work for natural language routing. Needs confirmation if the routing mechanism behaves differently.]

### Pattern 2: Skill Tool Invocation for Dispatch

**What:** `Skill(skill="council-code")` invokes the target council in the same conversation. The router hands off completely — the council's SKILL.md takes over execution.

**When to use:** After user confirms the router's suggestion. [VERIFIED: codebase — gsd-manager uses `Skill(skill="gsd-discuss-phase", args="...")` and `Skill(skill="gsd-verify-work")` for dispatch]

```
# After user confirms:
Skill(skill="council-code")

# The original user question is already in conversation context.
# Per D-07: do not reformulate or add context — the council reads the conversation directly.
```

**Note on args:** `gsd-manager` uses `args="{PHASE_NUM} {flags}"` for skills that take arguments. Council skills do not take structured args — they extract the question from conversation context. No `args` parameter needed for router dispatch.

### Pattern 3: Compact Recommendation Block (Claude's Discretion)

**What:** The output format for presenting a council suggestion. Per D-05: council name, 1-2 sentence reasoning, confirm/override prompt.

**When to use:** After classification, before dispatch.

```
**Suggested council: council-strategy**

Your question is about pricing and market positioning — that's a business strategy decision.
The strategy council runs 5 advisors (Devil's Advocate, Visionary, Pragmatist,
Customer Champion, Operator) optimized for exactly this domain.

→ Run council-strategy, or pick a different council?
  A) Run council-strategy
  B) Pick a different council
```

Low-confidence variant (D-04):

```
**Suggested council: council-code** _(low confidence — this could also fit council-strategy)_

Your question has both architectural and business tradeoffs. The code council addresses
the technical side best, but consider running council-strategy for the business impact.

→ Run council-code, or pick a different council?
  A) Run council-code
  B) Pick a different council
```

### Pattern 4: Classification Protocol (Inline Reasoning)

**What:** The router's classification logic. No subagent spawn — this is inline reasoning within the router skill's execution.

**When to use:** Step 1 of the router protocol.

The router SKILL.md body should contain:
1. A static list of installed councils with their names and full description text (duplicated from their SKILL.md description fields).
2. Instructions to read the user's question, compare against council descriptions, and determine the best fit.
3. Instructions for the confidence assessment (best fit / low confidence / no strong fit).

```markdown
## Installed Councils

**council-code** — Multi-perspective code decision council. Runs 5 expert advisors
(Contrarian, First Principles, Expansionist, Outsider, Executor) in parallel on a
code/architecture/engineering question...
Trigger phrases: architecture choices, library selection, refactor vs rewrite,
performance strategy, API design, pre-PR review, debugging hypotheses.

**council-strategy** — Multi-perspective strategy decision council. Runs 5 advisors
(Devil's Advocate, Visionary, Pragmatist, Customer Champion, Operator) in parallel
on a business or product decision...
Trigger phrases: pricing strategy, market entry, product roadmap, partnership
evaluation, competitive positioning, go-to-market, resource allocation.

## Classification Protocol

Read the user's question. Compare against the council descriptions and trigger phrases
above. Select the council whose domain coverage most closely matches the decision
the user is making.

If the question spans multiple domains, pick the council that covers the PRIMARY
decision type. Note the ambiguity in the recommendation block.

If no council is a clear fit, pick the closest match and flag low confidence.
```

### Anti-Patterns to Avoid

- **Auto-dispatch without confirmation:** ROUT-02 and D-06 are explicit — never skip the confirm step, even for obvious matches. The cost of running a wrong council (5 parallel agent runs, full token burn) is too high.
- **Reformulating the question:** D-07 forbids it. Pass the original question as-is. The council's SKILL.md handles context extraction.
- **Subagent for classification:** Classification is one inference step. Using Task tool would add latency and a context boundary with no benefit.
- **Capturing "second opinion" / "stress test" triggers:** D-13 is explicit — these stay with `council-code`. Router only intercepts explicit routing requests.
- **Referencing uninstalled councils:** D-09 says classify only installed councils. Do not mention design, research, or review councils that ship in later phases.
- **Hardcoding keyword matches:** D-01 prohibits this. Classification is LLM reasoning over natural language descriptions, not a lookup table.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Skill invocation | Custom bash or Task spawn | `Skill(skill="...")` tool | Built-in; runs council in same conversation context; no subagent overhead |
| User option selection | Free-text parsing of user response | AskUserQuestion with explicit options | Structured options prevent misparse; AskUserQuestion is the standard pattern (used in council-update) |
| Council registry | Dynamic file that councils register into | Static list in router SKILL.md body | D-02 explicitly chose static list; simpler, auditable, no install-time coordination |

**Key insight:** The LLM is the classification engine. The only "code" is the natural language description of each council inside the router SKILL.md. Any attempt to add explicit scoring, weight vectors, or decision trees adds complexity without improving accuracy — the model already understands the semantic difference between "architecture choice" and "pricing strategy."

---

## Runtime State Inventory

Phase 3 is a greenfield skill addition with one small modification to an existing skill body. No runtime state migration required.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None | — |
| Live service config | None — `~/.claude/skills/` symlinks are filesystem state, not service state | code edit (install.sh) |
| OS-registered state | None | — |
| Secrets/env vars | None | — |
| Build artifacts | `~/.claude/skills/council-code` symlink — no update needed for council-code body changes | none — symlink points to live file |

**The one behavioral state change:** `council-code` body currently says "Trigger phrases: `/council`..." (line 23). After phase 3, this line should read "Trigger phrases: `/council-code`..." to reflect that `/council` now routes to the router. This is a body text update in the existing file — no runtime migration, no symlink changes.

---

## Common Pitfalls

### Pitfall 1: Description Frontmatter vs Body Trigger Phrases

**What goes wrong:** Developer adds trigger phrases to the SKILL.md body (like council-code line 23) and expects Claude Code to route based on them. The routing does not change.

**Why it happens:** `council-code` has trigger phrases in its body under "When to use this skill." This is behavioral guidance for the running skill, NOT routing metadata. Claude Code routing appears to work from the `description` frontmatter field.

**How to avoid:** Add trigger phrases to the `description` YAML frontmatter field. The body's trigger phrase section can remain for human readability but does not control routing. [ASSUMED: routing from description frontmatter — see Assumptions Log]

**Warning signs:** `/council` still invokes council-code even after creating council-router.

### Pitfall 2: Forgetting to Update `council-code` Description Frontmatter (ROUT-03 Gap)

**What goes wrong:** `council-code`'s description frontmatter currently lacks explicit trigger phrases. It reads: "Multi-perspective code decision council. Runs 5 expert advisors..." — no "Trigger phrases:" suffix. ROUT-03 requires trigger phrases in description frontmatter for natural language detection.

**Why it happens:** council-code was built before the multi-council trigger phrase convention was established. council-strategy (built in Phase 2) already has the pattern.

**How to avoid:** Update `council-code` description frontmatter to append trigger phrases matching its domain. Remove `/council` from that list (it moves to council-router).

**Warning signs:** Router cannot classify code questions accurately because the council description it reads contains no trigger signals.

### Pitfall 3: install.sh Not Updated for `/council` Reassignment

**What goes wrong:** `install.sh` doesn't manage trigger phrase routing directly (that's done via the skill description frontmatter). But if `council-router` is not added to the SKILLS array, it won't be symlinked into `~/.claude/skills/` and won't be available at all.

**Why it happens:** Forgetting to update the SKILLS array in install.sh.

**How to avoid:** Add `council-router` to the `SKILLS=( ... )` array. This is the same one-word array append that was done for `council-strategy` in Phase 2.

**Warning signs:** `/council-router` invocation fails with "skill not found."

### Pitfall 4: Router Reads Stale Council Descriptions

**What goes wrong:** Router's SKILL.md body contains hardcoded council descriptions that drift out of sync when the council SKILL.md files are updated.

**Why it happens:** D-02 chose a static list. If a council's description changes (e.g., new trigger phrases added), the router's copy is not automatically updated.

**How to avoid:** The static list in the router SKILL.md should include the core domain summary and key trigger terms, not the full description verbatim. This reduces drift risk. Document in the router SKILL.md that the list must be updated when council descriptions change.

**Warning signs:** Router recommends the wrong council after council descriptions are updated.

### Pitfall 5: Skill Tool Requires Explicit `allowed-tools`

**What goes wrong:** Router SKILL.md doesn't declare `allowed-tools: [Skill, AskUserQuestion]` and the tools are unavailable at runtime.

**Why it happens:** Most council skills don't need `allowed-tools` because they spawn subagents via Task tool which is available by default. Skill-to-Skill invocation requires explicit declaration.

**How to avoid:** Add `allowed-tools` frontmatter to council-router SKILL.md. The gsd-manager skill demonstrates this pattern — it explicitly lists `Skill` in `allowed-tools`. [VERIFIED: codebase — gsd-manager SKILL.md lines 4-12]

**Warning signs:** `Skill` tool is unavailable when router tries to dispatch; runtime error on dispatch step.

---

## Code Examples

### council-router/SKILL.md Complete Structure

```yaml
---
name: council-router
description: Smart council selector. Analyzes your question and suggests the most appropriate council (code, strategy) with reasoning, then dispatches after your confirmation. Trigger phrases: which council, route this, help me pick a council, /council, /council-router.
disable-model-invocation: true
allowed-tools:
  - AskUserQuestion
  - Skill
---

# council-router

[Body: protocol for classification + recommendation + dispatch]
```

### Description Frontmatter Update for council-code (ROUT-03)

Current (line 3 of `skills/council-code/SKILL.md`):
```yaml
description: Multi-perspective code decision council. Runs 5 expert advisors (Contrarian, First Principles, Expansionist, Outsider, Executor) in parallel on a code/architecture/engineering question, then synthesizes a chairman verdict with agreements, clashes, blind spots, and a concrete next step.
```

Required (trigger phrases moved from body to frontmatter, `/council` removed):
```yaml
description: Multi-perspective code decision council. Runs 5 expert advisors (Contrarian, First Principles, Expansionist, Outsider, Executor) in parallel on a code/architecture/engineering question, then synthesizes a chairman verdict with agreements, clashes, blind spots, and a concrete next step. Trigger phrases: /council-code, architecture choices, library selection, refactor vs rewrite, performance strategy, API design, code review, debugging hypotheses, stress test this approach, what am I missing.
```

Note: `/council` is intentionally absent — that trigger moves to council-router per D-11.

### install.sh SKILLS Array Update

Current (line 132):
```bash
SKILLS=( council-code council-update council-strategy )
```

Required:
```bash
SKILLS=( council-code council-update council-strategy council-router )
```

### Skill Dispatch Pattern

```
# After user selects "Run council-code":
Skill(skill="council-code")

# After user selects "Run council-strategy":
Skill(skill="council-strategy")
```

No `args` parameter — council skills extract the question from conversation context directly.

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single council, `/council` triggers directly | Multi-council with router as smart entry point | Phase 3 (this phase) | `/council` becomes the smart default; power users use direct shortcuts |
| Trigger phrases in SKILL.md body only | Trigger phrases in description frontmatter (ROUT-03) | Phase 3 (this phase) | Claude Code can route natural language invocations to the correct council |

**Deprecated/outdated:**
- `/council` as direct shortcut for council-code: Reassigned to council-router per D-11. Direct access to code council moves to `/council-code`.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Claude Code routes skill invocations using the `description` frontmatter field for natural language matching; body text trigger phrases are behavioral guidance only, not routing metadata | Standard Stack, Pitfall 1, Pattern 1 | If body text also drives routing, the `/council` reassignment in D-11 may require removing `/council` from the council-code body as well — low additional effort, but worth verifying |
| A2 | `Skill(skill="council-code")` invocation in the router context passes the full conversation history to the invoked skill, so the council can read the user's original question without the router needing to re-state it | Pattern 2, D-07 | If Skill invocations do NOT pass conversation context, the router would need to include the user's question as an `args` parameter — a simple fix but changes the dispatch mechanism |
| A3 | The `allowed-tools` frontmatter key is required to enable `Skill` and `AskUserQuestion` tools in a skill execution context | Pitfall 5, Pattern 1 | If these tools are available by default without declaration, the `allowed-tools` key is optional. Adding it is harmless either way. |

---

## Open Questions

1. **`/council` reassignment mechanism**
   - What we know: `council-strategy` has trigger phrases in its description frontmatter and they work. `council-code` has trigger phrases only in its body.
   - What's unclear: Whether adding `/council` to council-router's description frontmatter alone is sufficient to reassign the trigger, or whether removing `/council` from council-code's body is also required.
   - Recommendation: Add `/council` to council-router description frontmatter AND update council-code body to say `/council-code` instead of `/council`. Belt-and-suspenders — both changes are low risk and ensure clean routing.

2. **`allowed-tools` requirement for Skill tool**
   - What we know: `gsd-manager` explicitly lists `Skill` in `allowed-tools`. Council skills (council-code, council-strategy) do NOT have `allowed-tools` because they use Task (which appears to be available by default).
   - What's unclear: Whether `allowed-tools` is strictly required for `Skill` tool access, or whether it's just `gsd-manager`'s convention.
   - Recommendation: Include `allowed-tools: [Skill, AskUserQuestion]` in council-router frontmatter. It's explicit, follows the observed pattern in gsd-manager, and costs nothing.

---

## Environment Availability

Step 2.6: SKIPPED — Phase 3 is purely Markdown file creation and text edits. No external dependencies, compiled build steps, or runtime services required.

---

## Validation Architecture

### Test Framework

This project has no automated test framework — it is a pure Markdown skill system. All validation is behavioral (human invocation testing).

| Property | Value |
|----------|-------|
| Framework | None — pure Markdown, no test runner |
| Config file | None |
| Quick run command | Manual: `/council-router "which council should I use for pricing?"` |
| Full suite command | Manual checklist (see Phase Requirements → Test Map) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| ROUT-01 | `/council-router` invocation returns council suggestion with reasoning | manual-smoke | N/A — skill invocation requires Claude Code session | ❌ manual only |
| ROUT-02 | Router presents suggestion and STOPS — no automatic council launch | manual-smoke | N/A — requires human observation of behavior | ❌ manual only |
| ROUT-03 | `council-code` and `council-strategy` description frontmatter contain trigger phrases | file-check | `grep "Trigger phrases" skills/council-code/SKILL.md` — verify in frontmatter, not just body | ✅ file exists |

**Justification for manual-only:** ROUT-01 and ROUT-02 test LLM behavior (classification quality, confirmation gating) that cannot be verified by static file inspection or a unit test. The verification gate is human UAT: invoke the router, observe the recommendation, confirm dispatch works.

### Sampling Rate

- **Per task commit:** `grep "Trigger phrases" skills/council-code/SKILL.md skills/council-strategy/SKILL.md` — verify description frontmatter contains trigger phrases
- **Per wave merge:** Manually invoke `/council-router` with a code question and a strategy question
- **Phase gate:** Full manual UAT checklist before `/gsd-verify-work`

### Wave 0 Gaps

None — no test infrastructure needed. This phase adds Markdown files only.

---

## Security Domain

This phase introduces no authentication, session state, external API calls, user input parsing, or data persistence. All inputs are natural language conversation text processed by the LLM. No ASVS categories apply.

Scope: Pure Markdown orchestration skill — no security surface.

---

## Sources

### Primary (HIGH confidence)
- `/Users/D052192/src/council-code/skills/council-code/SKILL.md` — Structural template for all council skills; verified frontmatter schema, trigger phrase patterns, Skill tool invocation documentation
- `/Users/D052192/src/council-code/skills/council-strategy/SKILL.md` — Verified description frontmatter trigger phrase pattern (ROUT-03 reference)
- `/Users/D052192/src/council-code/install.sh` — Verified SKILLS array pattern (lines 132-133)
- `/Users/D052192/.claude/skills/gsd-manager/SKILL.md` — Verified `Skill(skill="...")` invocation syntax and `allowed-tools: [Skill]` frontmatter pattern
- `/Users/D052192/src/council-code/.planning/phases/03-router/03-CONTEXT.md` — All locked decisions (D-01 through D-13)
- `/Users/D052192/src/council-code/.planning/phases/02-council-strategy/02-PATTERNS.md` — Established patterns from Phase 2 execution

### Secondary (MEDIUM confidence)
- `/Users/D052192/.claude/skills/gsd-autonomous/SKILL.md` — Additional Skill() invocation usage example
- `/Users/D052192/src/council-code/skills/council-update/SKILL.md` — AskUserQuestion pattern for confirmation flows

### Tertiary (LOW confidence)
- [A1] Routing from description frontmatter (not body) — inferred from observation, not from Claude Code source or official docs

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all components verified in codebase; no external libraries
- Architecture: HIGH — classification approach fully specified in CONTEXT.md; no ambiguous design choices
- Pitfalls: HIGH — most pitfalls derived from code inspection (existing files, install.sh, frontmatter gaps); one assumption flagged (A1)
- Trigger phrase routing mechanism: MEDIUM — behavior observed and consistent, source not confirmed

**Research date:** 2026-04-24
**Valid until:** Stable indefinitely (pure Markdown, no versioned dependencies)
