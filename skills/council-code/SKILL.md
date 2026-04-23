---
name: council-code
description: Multi-perspective code decision council. Runs 5 expert advisors (Contrarian, First Principles, Expansionist, Outsider, Executor) in parallel on a code/architecture/engineering question, then synthesizes a chairman verdict with agreements, clashes, blind spots, and a concrete next step.
disable-model-invocation: true
---

# council-code

Stress-test a code or engineering decision by spawning five independent advisors in parallel, each with a distinct lens, then producing a single synthesized verdict.

## When to use this skill

Invoke when the user asks for a "council," a "second opinion on code," to "stress-test" an architecture / design / PR plan, or when facing a high-stakes engineering decision where one perspective isn't enough:

- Architecture choices (monolith vs. services, sync vs. async, SQL vs. NoSQL)
- Library / framework selection
- Refactor vs. rewrite decisions
- Performance strategy choices
- API / data model design
- Debugging hypotheses when root cause is ambiguous
- Pre-PR self-review of significant changes

Trigger phrases: `/council`, `council`, "get a second opinion," "stress test this approach," "what am I missing," "have the council review."

## When NOT to use

- Simple factual code questions ("what does this function do") — just answer directly.
- Tiny mechanical changes (rename, add log, fix typo) — the council is overkill.
- The user already has a decision and just wants it implemented.

## The 5 Advisors

| Advisor | Job |
|---------|-----|
| **Contrarian** | Finds the fatal flaw |
| **First Principles Thinker** | Strips the problem to its core |
| **Expansionist** | Finds the upside being missed |
| **Outsider** | Imports a pattern from a distant domain |
| **Executor** | Answers "what do you do Monday morning?" |

Agent definitions live in `agents/` at the repo root (see `agents/code-contrarian.md`, etc.).

## Protocol

### Step 1 — Extract the decision

Before spawning anything, distill the user's question into:

1. **Decision prompt** — one sentence, no more. ("Should we split the `billing` service out of the monolith?")
2. **Relevant context** — the minimum files, constraints, requirements, or code the advisors need. Gather by reading/grepping, don't guess.
3. **Success criteria** — what "good" looks like for the decision.

If any of these three is unclear, ASK the user before proceeding. A council on a fuzzy question wastes 5 agent runs.

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

### Step 4 — Offer follow-up

End with: "Want me to (a) execute the Executor's first action, (b) dig deeper into one advisor's view, or (c) re-run the council with additional context?"

## Guardrails

- **Do not let advisors anchor on each other.** Spawn all 5 in one parallel batch. Never sequential — that contaminates the later advisors.
- **Do not summarize the advisors away.** The synthesis section names which advisor said what. The user should be able to see which lens produced which point.
- **Resist false consensus.** If 4 advisors agree and 1 dissents, the dissent often matters more than the agreement. Surface it explicitly.
- **The Executor always gets the last word on action.** The synthesis's "one thing to do first" must come from the Executor's output (or explicitly override with reasoning).
- **Cost awareness.** A full council is 5 subagent runs plus synthesis. Don't invoke on trivial questions.

## References

- `agents/code-contrarian.md` — Fatal flaw finder
- `agents/code-first-principles.md` — Primitives reducer
- `agents/code-expansionist.md` — Upside seeker
- `agents/code-outsider.md` — Distant-domain importer
- `agents/code-executor.md` — Monday-morning shipper
- `docs/personas.md` — Longer persona notes
- `docs/usage.md` — Example transcripts
