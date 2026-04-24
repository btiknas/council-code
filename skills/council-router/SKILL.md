---
name: council-router
description: Smart council selector. Analyzes your question and suggests the most appropriate council (code, strategy) with reasoning, then dispatches after your confirmation. Trigger phrases: which council, route this, help me pick a council, /council, /council-router.
disable-model-invocation: true
allowed-tools:
  - AskUserQuestion
  - Skill
---

# council-router

Smart entry point for the council system. Analyzes your question, suggests the best-fit council, and dispatches after you confirm.

## When to use this skill

Invoke when the user doesn't know which council to use and wants a recommendation:

- "Which council should I use for this?"
- "Route this question"
- "Help me pick a council"
- `/council` (smart entry point — suggests the right council)
- `/council-router` (direct invocation)

## When NOT to use

- User already knows which council they want — they should use `/council-code` or `/council-strategy` directly.
- Ambiguous triggers like "second opinion," "stress test this," "what am I missing" — these belong to `/council-code`, not the router.
- Simple questions that don't need a council at all — just answer directly.

## Installed Councils

**council-code** — Multi-perspective code decision council. Runs 5 expert advisors (Contrarian, First Principles, Expansionist, Outsider, Executor) in parallel on a code/architecture/engineering question, then synthesizes a chairman verdict with agreements, clashes, blind spots, and a concrete next step.
Trigger phrases: architecture choices, library selection, refactor vs rewrite, performance strategy, API design, code review, debugging hypotheses, stress test this approach, what am I missing.

**council-strategy** — Multi-perspective strategy decision council. Runs 5 advisors (Devil's Advocate, Visionary, Pragmatist, Customer Champion, Operator) in parallel on a business or product decision, then synthesizes a chairman verdict with viability assessment, market fit analysis, risk/reward matrix, competitive position, and a Go/No-Go/Pivot call.
Trigger phrases: pricing strategy, market entry, product roadmap, partnership evaluation, competitive positioning, go-to-market, resource allocation, evaluate this business decision, should we pivot.

## Protocol

### Step 1 — Classify the question

Read the user's question. Compare it against the council descriptions and trigger phrases listed in "Installed Councils" above. Select the council whose domain coverage most closely matches the decision the user is making.

**Classification rules:**
- If the question is about code, architecture, engineering, libraries, APIs, refactoring, performance, or debugging — suggest **council-code**.
- If the question is about business strategy, pricing, market entry, product roadmap, partnerships, competitive positioning, or go-to-market — suggest **council-strategy**.
- If the question spans multiple domains, pick the council that covers the PRIMARY decision type. Note the ambiguity in the recommendation.
- If no council is a clear fit, pick the closest match and flag low confidence. Never refuse to suggest.

Do NOT spawn a subagent for classification. This is a single inference step — read the question, reason about fit, select a council.

### Step 2 — Present the recommendation

Present a compact recommendation block:

**Standard confidence:**
```
**Suggested council: [council-name]**

[1-2 sentence reasoning: what the question is about and why this council fits]

-> Run [council-name], or pick a different council?
  A) Run [council-name]
  B) Pick a different council
```

**Low confidence (ambiguous fit):**
```
**Suggested council: [council-name]** _(low confidence — this could also fit [other-council])_

[1-2 sentence reasoning explaining the ambiguity]

-> Run [council-name], or pick a different council?
  A) Run [council-name]
  B) Pick a different council
```

Use `AskUserQuestion` to present the A/B options and wait for the user's response. Do NOT proceed to Step 3 until the user has confirmed.

CRITICAL: Never auto-dispatch. Always present the recommendation and wait. The cost of running the wrong council (5 parallel agent runs) is too high to skip confirmation.

### Step 3 — Dispatch

**If user selects A (Run suggested council):**

Invoke the suggested council using the Skill tool:

```
Skill(skill="council-code")
```
or
```
Skill(skill="council-strategy")
```

Do NOT pass `args`. The user's original question is already in the conversation context. Per D-07: do not reformulate, restate, or add context — the council's own SKILL.md handles context extraction from the conversation.

**If user selects B (Pick a different council):**

Show the full list of installed councils:
```
Available councils:
1. council-code — Code, architecture, and engineering decisions
2. council-strategy — Business, product, and strategy decisions

Which council would you like to run?
```

Use `AskUserQuestion` to let the user pick. Then dispatch via `Skill(skill="...")` as above.

## Guardrails

- **Never auto-dispatch without confirmation.** Always present the recommendation and wait for the user to confirm. Even for obvious matches — the confirm step is mandatory (ROUT-02).
- **Never reformulate the question.** Pass the user's original question as-is to the council. The council's SKILL.md handles context extraction (D-07).
- **Never reference uninstalled councils.** Only suggest councils in the "Installed Councils" list. Do not mention future councils (design, research, review) that have not shipped yet (D-09).
- **Never use a subagent for classification.** Classification is one inference step — inline reasoning, not a Task spawn. No subagent overhead for a routing decision (D-01).
- **Never refuse to suggest.** If no council is a clear fit, pick the closest match and flag low confidence. The user can always override (D-04).
- **Do not intercept ambiguous triggers.** "Second opinion," "stress test this," "what am I missing" — these belong to council-code. The router only activates on explicit routing requests (D-13).
