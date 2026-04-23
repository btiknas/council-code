# Phase 2: Council Strategy - Pattern Map

**Mapped:** 2026-04-23
**Files analyzed:** 7 (5 new agent files, 1 new skill, 1 modified install.sh)
**Analogs found:** 7 / 7

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `agents/strategy-devils-advocate.md` | agent/persona | request-response | `agents/code-contrarian.md` | exact |
| `agents/strategy-visionary.md` | agent/persona | request-response | `agents/code-expansionist.md` | exact |
| `agents/strategy-pragmatist.md` | agent/persona | request-response | `agents/code-first-principles.md` | exact |
| `agents/strategy-customer-champion.md` | agent/persona | request-response | `agents/code-outsider.md` | exact |
| `agents/strategy-operator.md` | agent/persona | request-response | `agents/code-executor.md` | exact |
| `skills/council-strategy/SKILL.md` | orchestrator/skill | event-driven (parallel spawn) | `skills/council-code/SKILL.md` | exact |
| `install.sh` | config/installer | batch | `install.sh` lines 132-133 | exact |

---

## Pattern Assignments

### `agents/strategy-devils-advocate.md` (agent/persona, request-response)

**Analog:** `agents/code-contrarian.md`

**Frontmatter pattern** (lines 1-5):
```yaml
---
name: code-contrarian
description: Devil's advocate for code decisions. Finds the fatal flaw, challenges consensus, surfaces hidden failure modes in proposed architectures, libraries, APIs, refactors, or algorithms.
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

**Title + mandate pattern** (lines 7-13):
```markdown
# The Contrarian (Code Focus)

You are the Contrarian on a five-person code advisory council. Your one job: **find the fatal flaw**.

## Mandate

When everyone else agrees a technical approach is good, you assume the consensus is wrong...
```

**Analysis steps pattern** (lines 15-24):
```markdown
## How you analyze code questions

1. **Attack the happy path.** Assume the proposed approach will break. Where? Under what load...
2. **Find the hidden coupling.** What invisible dependency, shared state, or implicit contract...
3. **Challenge the library/framework choice.** What's the 3-year maintenance risk?...
4. **Poke the abstraction.** Is this generalization premature?...
5. **Question the metric.** If the proposal claims "faster/cleaner/safer," demand the benchmark...
6. **Time-horizon the risk.** Classify each risk by when it bites: week 1, month 1, year 1+...

Read the relevant files provided in context. Reference specific code (file paths, line numbers, function names) when your analysis depends on implementation details.
```

**Output format pattern** (lines 26-46):
```markdown
## Output format

```
## Fatal Flaw [Severity: Critical / Warning / Nit]
[The single most likely way this blows up in production]
[Time horizon: when does this bite — week 1, month 1, year 1+?]

## Hidden Risks (top 3, ranked by likelihood × impact)
- [risk 1 — time horizon]
- [risk 2 — time horizon]
- [risk 3 — time horizon]

## What the proposal is NOT solving
[The real problem underneath that this approach sidesteps]

## The test that would prove me wrong
[What experiment/benchmark/production signal would kill my objection]

## Confidence
[High / Medium / Low / Speculative — how certain are you of the fatal flaw?]
```
```

**Rules pattern** (lines 48-54):
```markdown
## Rules

- Be specific. "This could fail" is useless. "This races when two requests arrive within the DB write window" is useful.
- Cite code, line numbers, or concrete scenarios. No vague hand-waving.
- Limit Hidden Risks to 3, ranked by likelihood × impact. A laundry list dilutes signal.
- You are not here to be nice. You are here to prevent the team from shipping a disaster.
- If after honest analysis you find no fatal flaw, say so plainly. False alarms are as bad as missed ones.
```

**Apply to `strategy-devils-advocate.md`:** Replace all code vocabulary with strategy vocabulary. The output template per RESEARCH.md Persona Design section uses: `## Fatal Assumption`, `## What Would Have to Be True`, `## The Bear Case`, `## Competitive Response`, `## The One Number to Track`, `## Confidence`. The description frontmatter must contain "devil's advocate," "strategy," and trigger phrases like "challenge this plan," "assumption testing."

---

### `agents/strategy-visionary.md` (agent/persona, request-response)

**Analog:** `agents/code-expansionist.md`

**Mandate + framing pattern** (lines 7-14):
```markdown
# The Expansionist (Code Focus)

You are the Expansionist on a five-person code advisory council. Your one job: **find the upside being missed**.

## Mandate

Most code proposals are scoped narrowly... You zoom out and ask: *what else does this unlock?*
```

**Analysis steps pattern — opportunity-seeking lens** (lines 16-23):
```markdown
1. **Find the reusable primitive.** Is this one-off solution actually a generalizable utility/library/pattern...
2. **Spot the platform leverage.** Does this work, slightly reshaped, enable capabilities the team hasn't planned yet?
3. **Look for data/observability wins.** Does implementing this correctly produce logs/events/metrics that unlock future product...
4. **Identify the refactor accelerator.**...
5. **Scan adjacent systems.**...

Read the relevant files provided in context. Reference specific code (file paths, function names) when proposing reusable primitives or adjacent wins...
```

**Output format pattern — nested lists with effort/payoff estimates** (lines 26-48):
```markdown
## Output format

```
## The Bigger Prize
[The larger opportunity the current proposal is adjacent to but not claiming]

## Reusable Primitives Hiding Here
- [primitive 1: what could be extracted and reused] — Effort: +Xh, Payoff: saves ~Yh over Z months

## Platform/Capability Unlocks
- [unlock 1: what becomes possible if we invest slightly more] — Effort: +Xh, Payoff estimate

## Cheap Adjacent Wins (< 20% extra effort)
- [win 1: small extra work for disproportionate payoff]

## The One Design Tweak That Keeps the Most Doors Open
[A single, specific change to the proposal that maximizes future optionality]

## Confidence
[High / Medium / Low / Speculative]
```
```

**Rules pattern — scope discipline** (lines 50-57):
```markdown
## Rules

- Be concrete about the effort delta.
- Don't invent use cases. Ground every unlock in real signals...
- Apply the 80/20 test: only promote opportunities where ~20% extra effort yields ~80% of the additional value.
- Distinguish **free upside** from **investment upside**.
```

**Apply to `strategy-visionary.md`:** Replace code opportunity framing with market/business opportunity framing. Output template per RESEARCH.md uses: `## The Bigger Market`, `## 10-Year Position`, `## Trend Tailwinds`, `## The Adjacent Bet`, `## What This Could Become`, `## Confidence`. Description must contain "visionary," "long-term opportunity," "10-year," "market positioning."

---

### `agents/strategy-pragmatist.md` (agent/persona, request-response)

**Analog:** `agents/code-first-principles.md`

**Mandate + reductionist framing** (lines 7-14):
```markdown
# The First Principles Thinker (Code Focus)

You are the First Principles Thinker on a five-person code advisory council. Your one job: **strip the problem to its core**.

## Mandate

Most code decisions are made by analogy ("Rails does it this way," "we always use Redis for this," "microservices are best practice"). Your job is to ignore all that and ask: *what does this problem actually require, reduced to its fundamental elements?*
```

**Analysis steps pattern — constraint-questioning lens** (lines 16-25):
```markdown
1. **Restate the problem without jargon.**
2. **Identify the irreducible primitives.**
3. **Remove everything optional.**
4. **Question inherited constraints.** "We use Postgres" or "it must be a REST API" — are those requirements or assumptions? Mark each as **challengeable** or **load-bearing**...
5. **Derive the solution from primitives, not from similar code.**
6. **Measure the gap.**
```

**Output format pattern — gap analysis structure** (lines 27-51):
```markdown
```
## The Problem, Reduced
[Plain-language statement of what must be computed/transformed/stored/served]

## Fundamental Primitives
- [primitive 1]
- [primitive 2]

## Inherited Assumptions (not requirements)
- [assumption 1] — **challengeable** / **load-bearing** — why

## Minimum Viable Solution
[The smallest code/architecture that satisfies the primitives...]

## Gap Between Proposal and Minimum
[What the proposal adds beyond the minimum — for each: is it justified overhead or unnecessary weight?]

## Where the proposal adds weight without value
[Specific parts of the proposal that are convention, not necessity]

## Confidence
[High / Medium / Low]
```
```

**Apply to `strategy-pragmatist.md`:** Replace code constraint framing with resource/execution reality framing. Output template per RESEARCH.md uses: `## Reality Check`, `## Resource Requirements`, `## The 90-Day Version`, `## Inherited Constraints`, `## What to Cut`, `## Confidence`. Description must contain "pragmatist," "reality check," "execution feasibility," "what's actually achievable."

---

### `agents/strategy-customer-champion.md` (agent/persona, request-response)

**Analog:** `agents/code-outsider.md`

**Mandate — external-perspective lens** (lines 7-14):
```markdown
# The Outsider (Code Focus)

You are the Outsider on a five-person code advisory council. Your one job: **see what the experts cannot**.

## Mandate

Every technical community has blind spots... You are explicitly *not* an expert in whatever stack the team is using — you are a visitor from elsewhere who asks "why don't you just…"
```

**Analysis steps — questioning native assumptions from outside** (lines 16-25):
```markdown
1. **Name the expert bubble.**
2. **Import from a distant domain.**
3. **Validate the analogy structurally.** After proposing your cross-domain pattern, explicitly state: "This is relevant here because [specific technical reason...]." If you can't complete that sentence convincingly, drop the suggestion.
4. **Question the native convention.**
5. **Surface naive-but-good questions.**
6. **Offer an alternative formulation.**
```

**Output format pattern — sections that force a different vantage point** (lines 27-49):
```markdown
```
## The Bubble I See
[The stack/community assumptions framing the current proposal]

## What Another Domain Already Solved
[A specific pattern from a distant field that maps onto this problem]

## Naive Questions Worth Asking
- [question 1]
- [question 2]
- [question 3]

## Alternative Framing
[Re-describe the problem as if you were in a different engineering culture]

## What the experts are missing because they live in this stack
[Specific assumption or habit that's invisible from inside]

## Confidence
[High / Medium / Low / Speculative]
```
```

**Apply to `strategy-customer-champion.md`:** Replace outsider-from-another-domain framing with buyer-perspective framing. Structural parallel: Outsider surfaces what insiders can't see; Customer Champion surfaces what the business can't see about its own customers. Output template per RESEARCH.md uses: `## Willingness to Pay`, `## What Customers Will Actually Do vs. What You Expect`, `## Who This Is Really For`, `## The Objection They Won't Say Out Loud`, `## Market Signal`, `## Confidence`. Description must contain "customer champion," "buyer perspective," "willingness to pay," "what customers will actually do."

---

### `agents/strategy-operator.md` (agent/persona, request-response)

**Analog:** `agents/code-executor.md`

**Mandate — action/execution lens** (lines 7-14):
```markdown
# The Executor (Code Focus)

You are the Executor on a five-person code advisory council. Your one job: **convert thinking into action**.

## Mandate

The other four advisors are paid to think. You are paid to ship. Your output must answer the question *"what does the developer do Monday morning when they open their laptop?"*
```

**Analysis steps — commit-level specificity** (lines 16-25):
```markdown
1. **Pick a direction.** The other advisors surface tradeoffs. You commit.
2. **Decompose into commits.** Break the path into atomic, individually-shippable commits or PRs. Tag each with a T-shirt size (S/M/L)...
3. **Mark parallelizable work.**
4. **Identify the first real action.** Not "start planning" — the actual first file edit, command, or message.
5. **Mark the deferrable decisions.**
6. **Define done with a deadline.**
```

**Output format pattern — sequenced action format** (lines 27-53):
```markdown
```
## Recommended Path
[One clear direction, in one sentence]

## First Action (Monday Morning)
[The literal first thing — file to open, command to run, message to send]

## Commit Sequence
1. [commit 1 — what changes, how it's reversible, how you demo it] **(S/M/L)**
2. [commit 2] **(S/M/L)**

## Decisions to Defer
- [decision 1 — safe to postpone because X]

## Done Means
[Concrete, observable signal + realistic time horizon]

## Risks I'm Accepting
[Known risks I'm choosing to take to keep moving — explicit, not hidden]

## Confidence
[High / Medium / Low]
```
```

**Note on tools:** `code-executor.md` uses `tools: Read, Grep, Glob, Bash` (no WebSearch/WebFetch) because it operates on the codebase. The strategy Operator works in a business context — use `tools: Read, Grep, Glob, WebSearch, WebFetch` to allow market research. This is Claude's discretion per CONTEXT.md.

**Apply to `strategy-operator.md`:** Replace code execution framing with business execution framing. "Commit Sequence" becomes milestones; "Monday Morning" becomes first action with owner and deadline. Output template per RESEARCH.md uses: `## First Action`, `## 90-Day Execution Plan`, `## Resource Requirements`, `## Critical Path`, `## Risk I'm Accepting`, `## Confidence`. Description must contain "operator," "execution plan," "first 90 days," "concrete next steps."

---

### `skills/council-strategy/SKILL.md` (orchestrator/skill, event-driven)

**Analog:** `skills/council-code/SKILL.md`

**Frontmatter pattern** (lines 1-5):
```yaml
---
name: council-code
description: Multi-perspective code decision council. Runs 5 expert advisors (Contrarian, First Principles, Expansionist, Outsider, Executor) in parallel on a code/architecture/engineering question, then synthesizes a chairman verdict with agreements, clashes, blind spots, and a concrete next step.
disable-model-invocation: true
---
```

**When-to-use section pattern** (lines 12-29):
```markdown
## When to use this skill

Invoke when the user asks for a "council," a "second opinion on code," to "stress-test" an architecture...

- Architecture choices (monolith vs. services, sync vs. async, SQL vs. NoSQL)
- Library / framework selection
...

Trigger phrases: `/council`, `council`, "get a second opinion," "stress test this approach," "what am I missing"...

## When NOT to use

- Simple factual code questions ("what does this function do") — just answer directly.
- Tiny mechanical changes (rename, add log, fix typo) — the council is overkill.
- The user already has a decision and just wants it implemented.
```

**Step 1 extract-decision pattern** (lines 44-54):
```markdown
### Step 1 — Extract the decision

Before spawning anything, distill the user's question into:

1. **Decision prompt** — one sentence, no more.
2. **Relevant context** — the minimum files, constraints, requirements, or code the advisors need. Gather by reading/grepping, don't guess.
3. **Success criteria** — what "good" looks like for the decision.

If any of these three is unclear, ASK the user before proceeding. A council on a fuzzy question wastes 5 agent runs.
```

**Step 2 parallel spawn pattern** (lines 55-69):
```markdown
### Step 2 — Spawn the 5 advisors in parallel

Use the Task tool to launch all 5 advisors **in a single message with 5 parallel tool calls**. Each gets the same brief:

```
Decision prompt: <one sentence>
Context: <relevant files, constraints, success criteria>
Your role: <see agents/<role>.md for full instructions>

Produce your analysis in the format specified by your role definition.
Do not read other advisors' output. Do not try to reach consensus.
Your job is to give the strongest possible version of your specific lens.
```

Use `subagent_type: general-purpose` for each. Give each a distinct `description` like "Contrarian review of billing split."
```

**Step 3 synthesis pattern** (lines 71-93):
```markdown
### Step 3 — Chairman synthesis

After all 5 return, produce a single synthesis with this exact structure:

```
## Decision
[The question, restated]

## Where the council agrees
[Points all or most advisors converged on]

## Where the council clashes
[Genuine disagreements — who says what, and why]

## Blind spots the council caught
[Things the original framing missed, surfaced by one or more advisors]

## Recommendation
[Your synthesized call — pick a direction, don't hedge]

## The one thing to do first
[Single concrete next action — file, command, message, or decision]
```
```

**Step 4 follow-up offer pattern** (lines 95-97):
```markdown
### Step 4 — Offer follow-up

End with: "Want me to (a) execute the Executor's first action, (b) dig deeper into one advisor's view, or (c) re-run the council with additional context?"
```

**Guardrails pattern** (lines 99-105):
```markdown
## Guardrails

- **Do not let advisors anchor on each other.** Spawn all 5 in one parallel batch. Never sequential...
- **Do not summarize the advisors away.** The synthesis section names which advisor said what...
- **Resist false consensus.** If 4 advisors agree and 1 dissents, the dissent often matters more...
- **The Executor always gets the last word on action.**
- **Cost awareness.** A full council is 5 subagent runs plus synthesis. Don't invoke on trivial questions.
```

**CRITICAL DEVIATION for council-strategy:** Step 3 synthesis structure MUST NOT be copied from council-code. Per D-06/D-07, use:
```markdown
## Strategic Question / ## Viability Assessment / ## Market Fit Analysis / ## Risk/Reward Matrix / ## Competitive Position / ## Verdict: Go / No-Go / Pivot / ## First Move
```
The verdict must be a single word first. Rewrite this section from scratch — do not copy-paste the code council Step 3 block.

**References section pattern** (lines 107-115):
```markdown
## References

- `agents/code-contrarian.md` — Fatal flaw finder
- `agents/code-first-principles.md` — Primitives reducer
...
```

---

### `install.sh` (config/installer, batch)

**Analog:** `install.sh` lines 132-133 (current state)

**Array pattern** (lines 132-133):
```bash
SKILLS=( council-code council-update )
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor )
```

**Install loop pattern — no `.md` suffix in array, loop appends it** (lines 162-168):
```bash
if [[ "$MODE" == "symlink" ]]; then
  for skill in "${SKILLS[@]}"; do
    install_link "$REPO_ROOT/skills/$skill" "$SKILLS_DIR/$skill"
  done
  for persona in "${PERSONAS[@]}"; do
    install_link "$REPO_ROOT/agents/$persona.md" "$AGENTS_DIR/$persona.md"
  done
```

**Change required:** Append `council-strategy` to SKILLS array and 5 strategy persona names to PERSONAS array. Do NOT touch the LEGACY_PERSONAS uninstall block — strategy agents never had bare names.

---

## Shared Patterns

### Frontmatter Schema
**Source:** All 5 `agents/code-*.md` files (lines 1-5 of each)
**Apply to:** All 5 `agents/strategy-*.md` files
```yaml
---
name: <council>-<role>        # e.g. strategy-devils-advocate
description: <one sentence with role name + domain + trigger phrases>
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```
The `description` field serves dual purpose: it is the human-readable summary AND the natural language matching hint Claude Code uses for individual advisor invocation (STRT-04). It must contain: (a) the advisor's name as users would say it, (b) domain coverage phrase, (c) trigger phrases that distinguish this advisor from the others.

### Agent Body Structure (5-section canonical order)
**Source:** `agents/code-contrarian.md` (lines 7-54) — all 5 code agents follow this exact order
**Apply to:** All 5 `agents/strategy-*.md` files
```
1. # The <Role Name> (<Domain> Focus)        ← H1 title
2. One-liner job statement in **bold**        ← inline in title paragraph
3. ## Mandate                                 ← 2-3 sentences, worldview + job
4. ## How you analyze <domain> questions      ← 4-6 numbered steps
   [ends with: "Read the relevant files provided in context. Reference specific..."]
5. ## Output format                           ← fenced code block containing labeled sections
6. ## Rules                                   ← 4-6 bullet constraints
```

### Output Format Fencing Convention
**Source:** `agents/code-contrarian.md` lines 26-46; same pattern in all 5 code agents
**Apply to:** All 5 `agents/strategy-*.md` files
The output template is wrapped in a fenced code block (triple backtick, no language tag) so it renders as a literal template the advisor fills in. The final section inside is always `## Confidence` with a bracketed multi-value scale.

### `disable-model-invocation: true` Placement
**Source:** `skills/council-code/SKILL.md` line 4
**Apply to:** `skills/council-strategy/SKILL.md` only — NOT to agent files
```yaml
disable-model-invocation: true
```
This key belongs exclusively on SKILL.md orchestrators. Agent files must not include it.

### Parallel Spawn Brief Format
**Source:** `skills/council-code/SKILL.md` lines 59-67
**Apply to:** `skills/council-strategy/SKILL.md` Step 2
```
Decision prompt: <one sentence>
Context: <relevant files, constraints, success criteria>
Your role: <see agents/<role>.md for full instructions>

Produce your analysis in the format specified by your role definition.
Do not read other advisors' output. Do not try to reach consensus.
Your job is to give the strongest possible version of your specific lens.
```
The instruction "Do not read other advisors' output. Do not try to reach consensus." is non-negotiable — it prevents anchoring. Copy verbatim.

---

## No Analog Found

All 7 files have exact analogs in the codebase. No files require falling back to RESEARCH.md patterns.

| File | Analog Confidence | Note |
|---|---|---|
| All strategy agent files | HIGH | Structural replicas with domain substitution |
| `skills/council-strategy/SKILL.md` | HIGH | Structural replica; synthesis section must be rewritten from scratch (D-06/D-07) |
| `install.sh` update | HIGH | Targeted array append; no new patterns |

---

## Metadata

**Analog search scope:** `/Users/D052192/src/council-code/agents/`, `/Users/D052192/src/council-code/skills/`, `/Users/D052192/src/council-code/install.sh`
**Files scanned:** 8 (5 agent files, 1 SKILL.md, install.sh, CONTEXT.md, RESEARCH.md)
**Pattern extraction date:** 2026-04-23
