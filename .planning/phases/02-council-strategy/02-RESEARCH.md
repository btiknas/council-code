# Phase 2: Council Strategy - Research

**Researched:** 2026-04-23
**Domain:** Claude Code agent + skill authoring — strategy advisory personas
**Confidence:** HIGH

## Summary

Phase 2 is a pure content creation phase. No new technology is introduced, no new tooling is installed, no infrastructure changes are made. The task is: write 5 strategy advisor agent files, write a `council-strategy` SKILL.md, and update `install.sh` to include them. Every pattern needed already exists in the code council and can be replicated with domain substitution.

The code council agent files (`agents/code-*.md`) provide the exact structural template. The council-code SKILL.md provides the exact orchestrator template. The install.sh PERSONAS and SKILLS arrays are the only integration points. Phase 1 will have already established the `code-` prefix convention and extracted `patch-settings.js` — Phase 2 simply adds a parallel set of `strategy-` prefixed files.

The meaningful intellectual work in this phase is the persona design: writing mandates, analysis steps, and output templates that feel native to business strategy — not re-skinned code review. The five personas (Devil's Advocate, Visionary, Pragmatist, Customer Champion, Operator) follow a startup advisory board dynamic. Each needs a unique output format with strategy-native section names (viability, market fit, willingness to pay, ROI) that carry the same signal specificity as the code council's "Fatal Flaw" and "Monday Morning" sections.

**Primary recommendation:** Write the 5 agent files first, then SKILL.md, then update install.sh. Each agent file is ~50 lines and fully self-contained — they can be written in parallel and verified independently.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**D-01:** Startup advisory dynamic — 5 personas: Devil's Advocate, Visionary, Pragmatist, Customer Champion, Operator

**D-02:** Fully independent names — no conceptual lineage to code council personas. Each strategy advisor stands on its own with strategy-native identity and mandate.

**D-03:** Agent files named `strategy-devils-advocate.md`, `strategy-visionary.md`, `strategy-pragmatist.md`, `strategy-customer-champion.md`, `strategy-operator.md`

**D-04:** Unique output template per advisor — each persona gets a bespoke structured output format tuned to its lens (same pattern as code council where Contrarian has "Fatal Flaw" and Executor has "Monday Morning" sections)

**D-05:** Pure strategy vocabulary — output templates use domain-native terms (viability, market fit, competitive position, ROI, willingness to pay). No code/engineering terms. Clean domain separation.

**D-06:** Fully custom strategy synthesis axes — NOT the code council's agreements/clashes/blind spots structure. Strategy chairman uses: Strategic Question → Viability Assessment → Market Fit Analysis → Risk/Reward Matrix → Competitive Position → Go/No-Go/Pivot Verdict

**D-07:** Three-value categorical verdict — Go, No-Go, or Pivot. Conditions can be listed under the verdict but the call itself is one of three values. No hedging.

**D-08:** Primary invocation via `/council-strategy`. Natural language triggers in SKILL.md description: "strategy council", "evaluate this business decision", "should we pivot", "pricing strategy", "market analysis", "business strategy"

**D-09:** Individual advisors invokable by name in natural language — "get the Devil's Advocate view on X", "what would the Customer Champion say about Y". Each agent file's `description` frontmatter enables Claude Code matching.

**D-10:** Non-overlapping triggers with code council — "stress test" stays with code, "evaluate this strategy" goes to strategy. Clean boundaries until the router (Phase 3) formalizes disambiguation.

### Claude's Discretion

- Exact wording of each advisor's mandate paragraph
- Specific sections within each advisor's output template (the structural pattern is locked — unique per advisor, strategy vocabulary — but exact section names are implementation detail)
- Tool access per advisor (`tools` field in frontmatter) — likely same as code advisors (Read, Grep, Glob, WebSearch, WebFetch) but may vary
- SKILL.md guardrails section wording (follow code council pattern but adapt for strategy domain)
- Follow-up offer wording after synthesis

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope

</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| STRT-01 | 5 domain-native advisor personas for business/product decisions (not re-skinned code advisors) | All 5 persona mandates designed from strategy domain, not code domain. Output templates use strategy vocabulary throughout. Agent file structure verified from code-contrarian.md template. |
| STRT-02 | Each advisor has a unique output format contract appropriate to strategy domain | Unique output templates designed per persona — each has bespoke section names tuned to their lens. See Output Template Design section. |
| STRT-03 | Chairman synthesis uses strategy-specific success criteria (viability, market fit, risk/reward) | Custom synthesis structure documented: Strategic Question → Viability Assessment → Market Fit Analysis → Risk/Reward Matrix → Competitive Position → Go/No-Go/Pivot Verdict. Replaces the code council's agreements/clashes/blind spots structure. |
| STRT-04 | User can invoke individual strategy advisors without running full council | Verified mechanism: agent `description` frontmatter enables Claude Code name matching. Same mechanism that enables "get the Contrarian view" for code council. Each agent's description must contain the advisors's role name and natural language trigger phrases. |

</phase_requirements>

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Strategy advisor analysis | Agent files (`agents/strategy-*.md`) | None | Each advisor is a standalone subagent; logic lives in the agent file, not the orchestrator |
| Council orchestration (parallel spawn) | SKILL.md (`skills/council-strategy/SKILL.md`) | None | Skill owns: decision extraction, parallel Task calls, chairman synthesis, follow-up offer |
| Individual advisor invocation | Agent `description` frontmatter | Claude Code runtime | `description` field is what Claude Code uses to match natural language requests to agents |
| Installation to `~/.claude/` | `install.sh` PERSONAS + SKILLS arrays | None | Array-driven install pattern is the established integration point for all councils |
| Settings.json mutation | `hooks/patch-settings.js` (Phase 1) | install.sh (caller) | Phase 1 extracted this; Phase 2 does NOT call it — no new settings changes needed |

---

## Standard Stack

### Core

| Component | Version / Type | Purpose | Why Standard |
|-----------|---------------|---------|--------------|
| Agent `.md` frontmatter | Claude Code native | Agent metadata, tools, invocation description | Platform-native; established by Phase 1 code agents |
| SKILL.md frontmatter | Claude Code native | Skill invocation, trigger phrases, `disable-model-invocation` | Platform-native; established pattern from `skills/council-code/SKILL.md` |
| Bash arrays in install.sh | POSIX bash | Wire new agents/skills into the installer | Established by Phase 1; no new mechanism needed |

### No New Dependencies

Phase 2 introduces no new libraries, no new tooling, no new runtime dependencies. It is entirely new plain-text Markdown files and a targeted update to install.sh.

[VERIFIED: codebase inspection — all code council components are pure Markdown + shell]

### Alternatives Considered

None applicable — the file format and install mechanism are locked by the existing pattern.

---

## Architecture Patterns

### System Architecture Diagram

```
User: "/council-strategy" or "evaluate this pricing decision"
             │
             ▼
skills/council-strategy/SKILL.md  (orchestrator)
   │
   ├── Step 1: Extract decision prompt + context
   │
   ├── Step 2: Spawn 5 advisors IN PARALLEL (single message, 5 Task calls)
   │     ├── agents/strategy-devils-advocate.md  → challenge viability
   │     ├── agents/strategy-visionary.md         → long-term opportunity
   │     ├── agents/strategy-pragmatist.md        → reality check
   │     ├── agents/strategy-customer-champion.md → buyer perspective
   │     └── agents/strategy-operator.md          → execution path
   │
   ├── Step 3: Chairman synthesis
   │     └── Strategic Question → Viability → Market Fit → Risk/Reward →
   │         Competitive Position → Go/No-Go/Pivot
   │
   └── Step 4: Follow-up offer

User: "get the Customer Champion view on X"  (individual advisor)
             │
             ▼
agents/strategy-customer-champion.md  (direct agent invocation)
   └── Runs standalone; produces its own output without synthesis
```

### Recommended Project Structure (after Phase 2)

```
council-code/
├── agents/
│   ├── code-contrarian.md           # Phase 1 (complete)
│   ├── code-executor.md             # Phase 1 (complete)
│   ├── code-expansionist.md         # Phase 1 (complete)
│   ├── code-first-principles.md     # Phase 1 (complete)
│   ├── code-outsider.md             # Phase 1 (complete)
│   ├── strategy-devils-advocate.md  # NEW
│   ├── strategy-visionary.md        # NEW
│   ├── strategy-pragmatist.md       # NEW
│   ├── strategy-customer-champion.md # NEW
│   └── strategy-operator.md         # NEW
├── skills/
│   ├── council-code/SKILL.md        # Phase 1 (complete)
│   └── council-strategy/SKILL.md    # NEW
└── install.sh                       # Updated: PERSONAS + SKILLS arrays
```

### Pattern 1: Agent File Structure (replicate from code council)

**What:** Each agent file is a self-contained Claude Code agent definition with YAML frontmatter followed by instruction body.

**When to use:** Every advisor in every council.

**Template:**
```markdown
<!-- Source: /Users/D052192/src/council-code/agents/code-contrarian.md -->
---
name: strategy-<role>
description: <one-sentence job description with trigger phrases for natural language invocation>
tools: Read, Grep, Glob, WebSearch, WebFetch
---

# The <Role Name> (Strategy Focus)

You are the <Role> on a five-person strategy advisory council. Your one job: **<mandate verb phrase>**.

## Mandate

[2-3 sentences establishing the advisor's worldview and job to be done]

## How you analyze strategy questions

1. **[Step name].** [What to do, why it matters]
2. **[Step name].** [What to do, why it matters]
... (4-6 steps total)

## Output format

\`\`\`
## [Section 1 — advisor-specific name]
[What goes here]

## [Section 2]
[...]

## Confidence
[High / Medium / Low / Speculative — how grounded is the analysis in real data?]
\`\`\`

## Rules

- [Constraint 1 — ensures output quality and role separation]
- [Constraint 2]
- ...
```

[VERIFIED: /Users/D052192/src/council-code/agents/code-contrarian.md — exact structure confirmed]

### Pattern 2: SKILL.md Structure (replicate from council-code)

**What:** Orchestrator skill with `disable-model-invocation: true`, trigger phrase list, and 4-step protocol.

**When to use:** Every council orchestrator.

**Template:**
```yaml
---
name: council-strategy
description: Multi-perspective strategy decision council. Runs 5 expert advisors (Devil's Advocate, Visionary, Pragmatist, Customer Champion, Operator) in parallel on a business or product decision, then synthesizes a chairman verdict with viability assessment, market fit analysis, risk/reward matrix, competitive position, and a Go/No-Go/Pivot call.
disable-model-invocation: true
---
```

Trigger phrases for the `description` field (locked by D-08): "strategy council", "evaluate this business decision", "should we pivot", "pricing strategy", "market analysis", "business strategy"

[VERIFIED: /Users/D052192/src/council-code/skills/council-code/SKILL.md — frontmatter pattern confirmed]

### Pattern 3: install.sh Array Updates

**What:** Add strategy agents to PERSONAS array, add `council-strategy` to SKILLS array.

**When to use:** Once, as the final implementation step of this phase.

**Example:**
```bash
# Current (after Phase 1):
SKILLS=( council-code council-update )
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor )

# After Phase 2:
SKILLS=( council-code council-update council-strategy )
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor \
           strategy-devils-advocate strategy-visionary strategy-pragmatist strategy-customer-champion strategy-operator )
```

[VERIFIED: /Users/D052192/src/council-code/install.sh — PERSONAS and SKILLS array pattern confirmed at lines 132-133]

### Pattern 4: Parallel Task Spawning in SKILL.md

**What:** The orchestrator spawns all 5 advisors in a single message with 5 parallel Task tool calls to prevent anchoring.

**When to use:** Step 2 of every council SKILL.md protocol.

**Instruction pattern (from council-code SKILL.md):**
```
Use the Task tool to launch all 5 advisors in a single message with 5 parallel tool calls. Each gets the same brief:

Decision prompt: <one sentence>
Context: <relevant files, constraints, success criteria>
Your role: <see agents/<role>.md for full instructions>

Produce your analysis in the format specified by your role definition.
Do not read other advisors' output. Do not try to reach consensus.
Your job is to give the strongest possible version of your specific lens.
```

Use `subagent_type: general-purpose` for each. Give each a distinct `description` like "Devil's Advocate assessment of pricing strategy."

[VERIFIED: /Users/D052192/src/council-code/skills/council-code/SKILL.md — Step 2 protocol, lines 57-69]

### Anti-Patterns to Avoid

- **Re-skinning code personas:** Describing strategy advisors using code vocabulary ("find the bug in the strategy," "what's the technical risk") undermines the clean domain separation locked in D-05. Each advisor's mandate must derive from startup advisory / business strategy domain, not from software engineering.
- **Shared output template across all 5 strategy advisors:** D-04 locks unique-per-advisor output formats. A generic shared template (Assessment / Risks / Recommendation) loses the signal specificity that makes the code council valuable. Customer Champion must have "Willingness to Pay" — Visionary must have "10-Year Horizon." These sections cannot be collapsed.
- **Overlapping trigger phrases with code council:** D-10 prohibits overlap. Do not put "stress test" or "code review" in the strategy SKILL.md description. Conversely, do not put "market analysis" or "should we pivot" in the code council's description.
- **`disable-model-invocation: true` on agent files:** This frontmatter key belongs only on SKILL.md files. Agent files use `tools:` for capability restriction. Applying it to agent files has no documented effect. [VERIFIED: code council agents do not have this key]
- **Sequential advisor spawning:** If the SKILL.md spawns advisors one-at-a-time, later advisors read the context from earlier ones and anchor on it. The parallel spawn (all 5 in one message) is non-negotiable for council integrity.
- **Adding `council-strategy` to the uninstall LEGACY_PERSONAS array:** The legacy cleanup in `--uninstall` is only for the Phase 1 bare-name-to-code-prefixed rename migration. Strategy agents never had bare names, so no legacy cleanup is needed.

---

## Persona Design

This section documents the advisory board dynamics and output template design for each of the 5 strategy advisors. These are the inputs for authoring the agent files.

### The 5 Strategy Advisors

| Advisor | File | One-Line Job | Domain Lens |
|---------|------|--------------|-------------|
| Devil's Advocate | `strategy-devils-advocate.md` | Find why this strategy fails | Worst-case scenario planning, assumption challenging |
| Visionary | `strategy-visionary.md` | Find the 10x opportunity the proposal undersells | Long-term market positioning, trend extrapolation |
| Pragmatist | `strategy-pragmatist.md` | Anchor to what's achievable given real constraints | Resource reality, execution feasibility, short-term viability |
| Customer Champion | `strategy-customer-champion.md` | Represent the buyer's actual decision process | Willingness to pay, buyer behavior, value perception |
| Operator | `strategy-operator.md` | Turn the decision into a concrete execution plan | First 90 days, resources, milestones, blockers |

These roles are fully independent from the code council roster (D-02). They are not re-framings of Contrarian, Expansionist, etc. — they are a startup advisory board dynamic, chosen because: (a) they cover distinct failure modes of strategic decisions, (b) each has a unique domain-native vocabulary, (c) the combination catches the most common strategic blind spots (overestimating demand, underestimating execution cost, ignoring competitive response).

[ASSUMED — persona rationale based on design intent from CONTEXT.md; exact mandate wording is Claude's discretion]

### Output Template Design

Each advisor needs output sections that feel native to their domain lens. The code council's design principle: section names should be specific enough that you can't accidentally put them in the wrong report.

**Strategy Devil's Advocate** — inspired by investment due diligence and pre-mortems:
- `## Fatal Assumption` — the single belief the strategy depends on most, that might be wrong
- `## What Would Have to Be True` — conditions that must hold for this to succeed (make them explicit)
- `## The Bear Case` — what the strategy looks like if the 2-3 key assumptions are wrong
- `## Competitive Response` — how do rational competitors react, and does that invalidate the plan?
- `## The One Number to Track` — the leading indicator that would falsify the strategy early
- `## Confidence` — High / Medium / Low

**Strategy Visionary** — inspired by long-horizon strategy and venture thinking:
- `## The Bigger Market` — the opportunity the current framing undersells
- `## 10-Year Position` — if this works, what does the company look like in 10 years?
- `## Trend Tailwinds` — what macro forces accelerate this in ways the proposal doesn't claim credit for?
- `## The Adjacent Bet` — one adjacency this strategy unlocks that hasn't been named
- `## What This Could Become` — the minimum viable version vs. the full-potential version
- `## Confidence` — High / Medium / Low / Speculative

**Strategy Pragmatist** — inspired by operational planning and resource reality:
- `## Reality Check` — the gap between the plan's assumptions and the team's actual capacity
- `## Resource Requirements` — what this actually costs (time, money, headcount, attention)
- `## The 90-Day Version` — what can be validated or shipped in 90 days with current resources
- `## Inherited Constraints` — which constraints are real vs. perceived
- `## What to Cut` — the minimum viable version of this strategy that still tests the core bet
- `## Confidence` — High / Medium / Low

**Strategy Customer Champion** — inspired by customer development and pricing research:
- `## Willingness to Pay` — what customers will actually pay vs. what the strategy assumes
- `## What Customers Will Actually Do vs. What You Expect` — the behavior gap
- `## Who This Is Really For` — the actual buyer profile vs. the intended profile
- `## The Objection They Won't Say Out Loud` — the real reason customers hesitate
- `## Market Signal` — what the strongest evidence for customer desire actually is (not projections)
- `## Confidence` — High / Medium / Low

**Strategy Operator** — inspired by COO / general management execution:
- `## First Action` — the literal first step, with owner and deadline
- `## 90-Day Execution Plan` — 3-5 milestones, each observable and datable
- `## Resource Requirements` — specific: headcount, budget, tools, external dependencies
- `## Critical Path` — the one thing that blocks everything else
- `## Risk I'm Accepting` — known risks being taken to keep moving; explicit, not hidden
- `## Confidence` — High / Medium / Low

[ASSUMED — section names are Claude's discretion (D-04 discretion area); these are recommendations grounded in domain vocabulary]

### Chairman Synthesis Structure (D-06/D-07)

The strategy synthesis departs from the code council structure. The code council uses: Decision / Agreements / Clashes / Blind Spots / Recommendation / One Thing to Do First. The strategy council uses a different structure optimized for business decisions:

```
## Strategic Question
[The decision, restated in one sentence]

## Viability Assessment
[Can this strategy work given market, resources, and timing? Synthesized from all advisor inputs.]

## Market Fit Analysis
[Does this address a real customer need with real willingness to pay? Primarily from Customer Champion + Devil's Advocate.]

## Risk/Reward Matrix
[Top 3 risks ranked by likelihood × impact; top 3 rewards ranked by magnitude × probability. From all advisors.]

## Competitive Position
[Where does this land the company vs. competitors in 12-24 months? From Visionary + Devil's Advocate.]

## Verdict: [Go / No-Go / Pivot]
[One word. Then: if Go — what conditions; if No-Go — what would change it; if Pivot — what specifically to pivot to.]

## First Move
[The single concrete next action — owner, deadline, observable outcome. From Operator.]
```

[VERIFIED: D-06 and D-07 in CONTEXT.md — synthesis structure and three-value verdict are locked decisions]

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Agent discovery mechanism | Custom matching logic | `description` frontmatter field | Claude Code reads this field natively for natural language invocation; it's the only mechanism that works |
| Trigger phrase disambiguation | Custom routing logic in SKILL.md | Domain-specific trigger phrases in `description` field | Phase 3 builds the router; Phase 2 only needs clean trigger boundaries via natural language phrases |
| Output format validation | Schema validation or parsing logic | Freeform markdown in fenced code block (same as code council) | Advisors are LLMs producing text; format compliance is enforced by prompt instructions, not runtime validation |
| Installation orchestration | New installer script for strategy | Update existing `install.sh` PERSONAS and SKILLS arrays | The array-driven pattern is already proven and idempotent |

**Key insight:** This phase is entirely content creation. The infrastructure is already built. The only custom work is writing the 5 persona prompts and the SKILL.md — and every structural decision about how to write them is answered by the code council template.

---

## Common Pitfalls

### Pitfall 1: Code Vocabulary Leaking Into Strategy Output Templates
**What goes wrong:** Advisor output sections use engineering metaphors — "the fatal bug in this strategy," "the runtime risk," "the refactor path." The output feels like code review with a strategy skin.
**Why it happens:** Training data bias — LLMs default to code metaphors. The mandate paragraph must explicitly establish the domain vocabulary and the analysis steps must use strategy-native verbs (validate market, assess viability, estimate willingness to pay).
**How to avoid:** After drafting each advisor, read the output template sections: can any section name appear verbatim in a code review? If yes, rename it.
**Warning signs:** Output template contains words like "refactor," "technical debt," "fail silently," "edge case" without being in the context of a technical strategy decision.

### Pitfall 2: Synthesis Structure Reverts to Code Council Shape
**What goes wrong:** The strategy chairman synthesis uses "Where the council agrees" / "Where the council clashes" / "Blind spots" — the code council structure — instead of the D-06 custom axes.
**Why it happens:** SKILL.md for strategy is written by adapting the code council SKILL.md, and the synthesis section is not updated carefully.
**How to avoid:** The synthesis section is the highest-risk copy-paste target. Rewrite it from scratch using D-06's axes. Do NOT copy-paste from council-code SKILL.md Step 3.
**Warning signs:** Strategy synthesis output starts with "## Where the council agrees."

### Pitfall 3: Verdict Hedging Violates D-07
**What goes wrong:** The synthesis verdict says "Go with conditions, or Pivot if X, or No-Go if Y" — all three options presented as equally valid, no actual call made.
**Why it happens:** LLMs default to hedge language; synthesis prompts often invite nuance. D-07 is explicit: the call must be one of three values. Conditions can follow, but the verdict word comes first.
**How to avoid:** The synthesis format in SKILL.md must state: "The verdict is a single word: Go, No-Go, or Pivot. Do not hedge."
**Warning signs:** Synthesis output contains "Go/No-Go/Pivot depending on..."

### Pitfall 4: Individual Advisor Invocation Not Enabled
**What goes wrong:** "Get the Customer Champion view on X" fails to invoke the advisor because the `description` frontmatter is too generic or doesn't contain the advisor's name and role keywords.
**Why it happens:** `description` is written as a functional description rather than an invocation hint.
**How to avoid:** Each advisor `description` must contain: (a) the advisor's name as users would say it ("Customer Champion"), (b) the domain they cover ("business/product decisions"), (c) a natural language trigger phrase that distinguishes them ("buyer perspective," "willingness to pay").
**Warning signs:** "get the Customer Champion view" in Claude Code invokes a different agent or nothing.

### Pitfall 5: SKILL.md Description Triggers Overlap With Code Council
**What goes wrong:** Strategy SKILL.md is invoked when user asks for code council, or vice versa, because trigger phrases overlap.
**Why it happens:** Generic phrases like "second opinion," "what am I missing," "stress test this" are too broad. D-10 locks non-overlapping triggers.
**How to avoid:** Code council keeps: "stress test," "second opinion on code," "engineering decision." Strategy council gets: "evaluate this business decision," "should we pivot," "pricing strategy," "market analysis." Do not use overlapping phrases in both descriptions.
**Warning signs:** `/council-code` is invoked when user types "evaluate this pricing strategy."

### Pitfall 6: `skills/council-strategy/` Directory Not Created
**What goes wrong:** `install.sh` SKILLS array includes `council-strategy` but the `skills/council-strategy/` directory does not exist, causing `install_link` to fail silently (or create a broken symlink to a non-existent source).
**Why it happens:** Forgetting to create the `skills/council-strategy/` directory alongside the SKILL.md file.
**How to avoid:** The file path for the strategy SKILL.md is `skills/council-strategy/SKILL.md`. The directory must be created as part of authoring the file.
**Warning signs:** `ls ~/.claude/skills/` shows a broken `council-strategy` symlink.

---

## Code Examples

Verified patterns from codebase inspection:

### Agent File Frontmatter Pattern
```yaml
# Source: /Users/D052192/src/council-code/agents/code-contrarian.md lines 1-5
---
name: code-contrarian
description: Devil's advocate for code decisions. Finds the fatal flaw, challenges consensus, surfaces hidden failure modes in proposed architectures, libraries, APIs, refactors, or algorithms.
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

For strategy agents, the pattern maps to:
```yaml
---
name: strategy-customer-champion
description: Customer and buyer advocate on the strategy council. Surfaces what customers will actually do vs. what the business expects — willingness to pay, real objections, buyer behavior. Invoke for "customer champion view," "buyer perspective," "willingness to pay analysis."
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

### SKILL.md Frontmatter Pattern
```yaml
# Source: /Users/D052192/src/council-code/skills/council-code/SKILL.md lines 1-5
---
name: council-code
description: Multi-perspective code decision council. [...]
disable-model-invocation: true
---
```

For strategy:
```yaml
---
name: council-strategy
description: Multi-perspective strategy decision council. Runs 5 advisors (Devil's Advocate, Visionary, Pragmatist, Customer Champion, Operator) in parallel on a business or product decision, then synthesizes a chairman verdict with viability assessment, market fit analysis, risk/reward matrix, competitive position, and a Go/No-Go/Pivot call. Trigger phrases: strategy council, evaluate this business decision, should we pivot, pricing strategy, market analysis, business strategy.
disable-model-invocation: true
---
```

### install.sh PERSONAS and SKILLS Array Updates
```bash
# Source: /Users/D052192/src/council-code/install.sh line 132-133

# Current (after Phase 1):
SKILLS=( council-code council-update )
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor )

# After Phase 2 — append strategy entries:
SKILLS=( council-code council-update council-strategy )
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor \
           strategy-devils-advocate strategy-visionary strategy-pragmatist strategy-customer-champion strategy-operator )
```

Note: no `.md` suffix in array entries. The install loop appends `.md`. [VERIFIED: install.sh line 166]

### Strategy Chairman Synthesis Section (from D-06/D-07)
```markdown
## Strategic Question
[The decision, restated in one sentence]

## Viability Assessment
[Can this strategy work? Synthesized answer with supporting evidence from advisors.]

## Market Fit Analysis
[Does real customer demand + willingness to pay exist? Name which advisor(s) surfaced this.]

## Risk/Reward Matrix
**Top Risks:** (ranked likelihood × impact)
- [risk 1]
- [risk 2]
- [risk 3]

**Top Rewards:** (ranked magnitude × probability)
- [reward 1]
- [reward 2]

## Competitive Position
[Where does this land the company vs. competitors in 12-24 months?]

## Verdict: Go / No-Go / Pivot
[One word first. Then: conditions (Go), what changes it (No-Go), or what to pivot to (Pivot).]

## First Move
[Concrete next action with owner, deadline, and observable outcome]
```

---

## State of the Art

| Aspect | Code Council Pattern | Strategy Council Pattern | Notes |
|--------|---------------------|--------------------------|-------|
| Synthesis axes | Agreements / Clashes / Blind Spots / Recommendation / First Action | Strategic Question / Viability / Market Fit / Risk-Reward / Competitive Position / Verdict | D-06: fully custom |
| Verdict format | Recommendation paragraph | Go / No-Go / Pivot + conditions | D-07: categorical |
| Persona names | Domain-generic (Contrarian, Executor) | Domain-specific (Customer Champion, Operator) | D-02: independent names |
| Output sections | Code-native (Fatal Flaw, Monday Morning) | Strategy-native (Willingness to Pay, 10-Year Position) | D-05: pure domain vocab |
| Trigger phrases | "stress test," "second opinion on code" | "evaluate this business decision," "should we pivot" | D-10: non-overlapping |

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Strategy agent `description` frontmatter enables Claude Code to match "get the Customer Champion view" to `strategy-customer-champion.md` via the same mechanism as code agents | Architecture Patterns / Pitfall 4 | If name matching is more fragile than assumed, individual advisor invocation (STRT-04) may fail. Mitigation: test individual invocation by name after implementation. |
| A2 | `tools: Read, Grep, Glob, WebSearch, WebFetch` is the right tool set for all 5 strategy advisors | Standard Stack | If strategy advisors need tools the code advisors don't (e.g., Bash for the Operator), the `tools` field needs adjustment. This is Claude's discretion per CONTEXT.md. |
| A3 | Phase 1 will be fully complete (including install.sh PERSONAS and SKILLS arrays using `code-` prefix) before Phase 2 implementation begins | Architecture Patterns | Phase 2 appends to install.sh arrays that Phase 1 establishes. If Phase 1 is incomplete, the starting state for the array update is different. Mitigation: verify Phase 1 completion before Phase 2 starts. |
| A4 | Output template section names are implementation detail (Claude's discretion) — the names in this research document are design recommendations, not locked specs | Persona Design | If the user has strong opinions on specific section names, they should be surfaced before authoring begins. |

**No assumptions involve external libraries, APIs, or platform features that might be stale.**

---

## Open Questions

1. **Does the Operator advisor need `Bash` tool access?**
   - What we know: The code Executor has `tools: Read, Grep, Glob, Bash` (without WebSearch/WebFetch) because it focuses on concrete action in the repo. The strategy Operator is analogous but operates in a business context, not a codebase.
   - What's unclear: Does the Operator need Bash to run commands (e.g., look up financial data, read business docs), or is `Read, Grep, Glob, WebSearch, WebFetch` the right set for researching market context?
   - Recommendation: Give the Operator `Read, Grep, Glob, WebSearch, WebFetch` (same as other strategy advisors) since strategy decisions aren't codebase operations. This is Claude's discretion per CONTEXT.md.

2. **Should strategy SKILL.md include a "When NOT to use" section?**
   - What we know: The code council SKILL.md has a "When NOT to use" section with three conditions (simple factual questions, tiny mechanical changes, user already decided).
   - What's unclear: What are the equivalent "too small for strategy council" conditions?
   - Recommendation: Include analogous guardrails — e.g., "Don't invoke for simple factual questions about a market" and "Don't invoke when the user has already made the decision and just needs help executing." This is wording at Claude's discretion.

---

## Environment Availability

Step 2.6: SKIPPED — Phase 2 is purely Markdown content creation + an in-place text edit to install.sh. No external tools, services, or runtimes are required beyond what Phase 1 already established (Node.js, Bash). Phase 2 does not invoke install.sh as part of implementation; it only edits the source file.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | None — no test runner configured (same as Phase 1) |
| Config file | None |
| Quick run command | `bash install.sh --help` (smoke — verifies script parses) |
| Full suite command | Manual behavioral verification (see below) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| STRT-01 | 5 strategy agent files exist with strategy-native vocabulary | smoke | `ls agents/strategy-*.md \| wc -l` → should output 5 | Wave 0 |
| STRT-01 | No code/engineering terms in strategy agent mandates | manual | Read each agent file; verify no "bug," "refactor," "runtime" in mandate body | Wave 0 |
| STRT-02 | Each advisor has a unique output format section structure | manual | Read each agent file; compare output format sections — none should be identical | Wave 0 |
| STRT-03 | Strategy SKILL.md synthesis uses D-06 axes (Viability, Market Fit, etc.) | smoke | `grep 'Viability Assessment' skills/council-strategy/SKILL.md` | Wave 0 |
| STRT-03 | Synthesis verdict is Go/No-Go/Pivot (D-07) | smoke | `grep 'Go / No-Go / Pivot' skills/council-strategy/SKILL.md` | Wave 0 |
| STRT-04 | Individual advisor invocation via natural language | manual | Restart Claude Code, type "get the Customer Champion view on X," verify correct agent loads | Wave 0 |
| STRT-04 | All 5 advisors invokable individually | manual | Test each advisor name in natural language | Wave 0 |

### Sampling Rate

- **Per task commit:** `bash install.sh --help` (script parses without error)
- **Per wave merge:** `ls agents/strategy-*.md` + `grep 'disable-model-invocation' skills/council-strategy/SKILL.md`
- **Phase gate:** All 4 requirements verified before `/gsd-verify-work`

### Wave 0 Gaps

- [ ] `skills/council-strategy/` directory — must be created; `SKILL.md` lives here
- [ ] 5 `agents/strategy-*.md` files — all new; no existing file to edit
- [ ] Manual test: restart Claude Code, invoke each advisor by name, confirm correct agent loads

*(No test framework install needed — pure Markdown + shell verification)*

---

## Security Domain

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V5 Input Validation | No | No user input parsed; Markdown files only |
| V6 Cryptography | No | No cryptographic operations |
| V2 Authentication | No | No auth layer |

Phase 2 creates Markdown files that are read by Claude Code's agent runtime. No security surface area is introduced. The only install.sh change (array append) uses the existing `install_link` / `install_copy` helpers which are already reviewed.

---

## Sources

### Primary (HIGH confidence)

- `/Users/D052192/src/council-code/agents/code-contrarian.md` — agent file structure template [VERIFIED: full read]
- `/Users/D052192/src/council-code/agents/code-executor.md` — action-oriented advisor pattern [VERIFIED: full read]
- `/Users/D052192/src/council-code/agents/code-first-principles.md` — analysis steps structure [VERIFIED: full read]
- `/Users/D052192/src/council-code/agents/code-expansionist.md` — opportunity lens pattern [VERIFIED: full read]
- `/Users/D052192/src/council-code/agents/code-outsider.md` — output format fenced-block pattern [VERIFIED: full read]
- `/Users/D052192/src/council-code/skills/council-code/SKILL.md` — orchestrator structure, synthesis template, guardrails, parallel spawn protocol [VERIFIED: full read]
- `/Users/D052192/src/council-code/install.sh` — PERSONAS and SKILLS array pattern, install_link/install_copy functions [VERIFIED: full read]
- `/Users/D052192/src/council-code/.planning/phases/02-council-strategy/02-CONTEXT.md` — all locked decisions D-01 through D-10 [VERIFIED: full read]
- `/Users/D052192/src/council-code/.planning/REQUIREMENTS.md` — STRT-01 through STRT-04 [VERIFIED: full read]
- `/Users/D052192/src/council-code/docs/personas.md` — persona design philosophy, "why these five" rationale [VERIFIED: full read]

### Secondary (MEDIUM confidence)

- `/Users/D052192/src/council-code/.planning/phases/02-council-strategy/02-DISCUSSION-LOG.md` — alternatives considered during discussion, confirming decision rationale [VERIFIED: full read]
- `/Users/D052192/src/council-code/.planning/phases/01-foundation/01-RESEARCH.md` — Phase 1 patterns and infrastructure state post-Phase 1 [VERIFIED: full read]

### Tertiary (N/A)

No web searches required. All claims sourced from codebase inspection. The domain (Claude Code agent authoring) is entirely internal to this repo.

---

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — no new technology; all patterns verified from existing code council files
- Architecture: HIGH — all source files read; agent/skill/installer integration points fully mapped
- Persona design: HIGH (structure) / ASSUMED (exact wording) — structure is locked by template; section names are Claude's discretion
- Pitfalls: HIGH — derived from direct analysis of the code council pattern and the D-05/D-06/D-07 decisions

**Research date:** 2026-04-23
**Valid until:** Stable — pure internal content authoring with no external dependencies; research does not expire
