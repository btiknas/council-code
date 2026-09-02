---
name: council-strategy
description: Multi-perspective strategy decision council. Runs 5 advisors (Devil's Advocate, Visionary, Pragmatist, Customer Champion, Operator) in parallel on a business or product decision, then synthesizes a chairman verdict with viability assessment, market fit analysis, risk/reward matrix, competitive position, and a Go/No-Go/Pivot call. Trigger phrases: strategy council, evaluate this business decision, should we pivot, pricing strategy, market analysis, business strategy.
disable-model-invocation: true
---

# council-strategy

Stress-test a business or product decision by spawning five independent strategy advisors in parallel, each with a distinct lens, then producing a single synthesized verdict with a Go/No-Go/Pivot call.

## When to use this skill

Invoke when the user asks to evaluate a business decision, pricing strategy, market entry, product roadmap pivot, partnership evaluation, or competitive positioning question:

- Pricing and monetization decisions
- Market entry or expansion strategies
- Product roadmap prioritization
- Partnership or acquisition evaluation
- Competitive positioning choices
- Go-to-market strategy
- Resource allocation across initiatives

Trigger phrases: `/council-strategy`, "strategy council", "evaluate this business decision", "should we pivot", "pricing strategy", "market analysis", "business strategy"

## When NOT to use

- Simple factual market questions ("what's the market size for X") — just answer directly.
- Tiny operational decisions (meeting scheduling, minor budget reallocation) — the council is overkill.
- The user already has a decision and just needs help executing it — point them to the Operator advisor directly.

## The 5 Advisors

| Advisor | Job |
|---------|-----|
| **Devil's Advocate** | Finds why this strategy fails |
| **Visionary** | Finds the 10x opportunity the proposal undersells |
| **Pragmatist** | Anchors to what's achievable given real constraints |
| **Customer Champion** | Represents the buyer's actual decision process |
| **Operator** | Turns the decision into a concrete execution plan |

Agent definitions: `agents/strategy-devils-advocate.md`, `agents/strategy-visionary.md`, `agents/strategy-pragmatist.md`, `agents/strategy-customer-champion.md`, `agents/strategy-operator.md`

## Protocol

### Step 1 — Extract the decision

Before spawning anything, distill the user's question into:

1. **Decision prompt** — one sentence, no more. ("Should we launch a freemium tier at half our current price point?")
2. **Relevant context** — the minimum market data, financial projections, competitive landscape, or business constraints the advisors need. Gather by reading/grepping, don't guess.
3. **Success criteria** — what "good" looks like for the decision (revenue target, market share, timeline).

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

Use `subagent_type: general-purpose` for each. Give each a distinct `description` like "Devil's Advocate assessment of pricing strategy."

### Step 3 — Chairman synthesis

After all 5 return, produce a single synthesis with this exact structure:

```
## Strategic Question
[The decision, restated in one sentence]

## Viability Assessment
[Can this strategy work given market, resources, and timing? Synthesize from all advisor inputs. Name which advisor(s) surfaced key evidence.]

## Market Fit Analysis
[Does this address a real customer need with real willingness to pay? Primarily from Customer Champion + Devil's Advocate inputs.]

## Risk/Reward Matrix
**Top Risks:** (ranked likelihood × impact)
- [risk 1]
- [risk 2]
- [risk 3]

**Top Rewards:** (ranked magnitude × probability)
- [reward 1]
- [reward 2]

## Competitive Position
[Where does this land the company vs. competitors in 12-24 months? From Visionary + Devil's Advocate inputs.]

## Verdict: [Go / No-Go / Pivot]
[One word first. Then: if Go — conditions that must hold; if No-Go — what would change it; if Pivot — what specifically to pivot to.]

## First Move
[Concrete next action with owner, deadline, and observable outcome. From Operator's output.]
```

**CRITICAL:** The verdict is a single word: Go, No-Go, or Pivot. Write the word first, then conditions. Do not hedge. Do not present multiple verdicts as options.

### Step 4 — Offer follow-up

End with: "Want me to (a) start executing the Operator's first action, (b) dig deeper into one advisor's view, or (c) re-run the council with additional context?"

## Guardrails

- **Do not let advisors anchor on each other.** Spawn all 5 in one parallel batch. Never sequential — that contaminates the later advisors.
- **Do not summarize the advisors away.** The synthesis section names which advisor said what. The user should be able to see which lens produced which point.
- **Resist false consensus.** If 4 advisors agree and 1 dissents, the dissent often matters more than the agreement. Surface it explicitly.
- **The Operator always gets the last word on action.** The synthesis's "First Move" must come from the Operator's output (or explicitly override with reasoning).
- **The verdict is categorical.** Go, No-Go, or Pivot. Not "Go if X but No-Go if Y." Pick one and state conditions afterward.
- **Cost awareness.** A full council is 5 subagent runs plus synthesis. Don't invoke for simple market questions.

## References

- `agents/strategy-devils-advocate.md` — Assumption challenger
- `agents/strategy-visionary.md` — Long-horizon opportunity finder
- `agents/strategy-pragmatist.md` — Resource reality checker
- `agents/strategy-customer-champion.md` — Buyer perspective advocate
- `agents/strategy-operator.md` — Execution planner
