# Phase 2: Council Strategy - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-23
**Phase:** 02-council-strategy
**Areas discussed:** Advisor roster, Output contracts, Synthesis criteria, Trigger design

---

## Advisor Roster

| Option | Description | Selected |
|--------|-------------|----------|
| Business advisory board | Market Analyst, Risk Assessor, Operations Strategist, Growth Advisor, Financial Analyst. Mirrors a real boardroom advisory panel. | |
| Startup advisory dynamic | Devil's Advocate, Visionary, Pragmatist, Customer Champion, Operator. Closer to startup advisory dynamic. | ✓ |
| Reframed code personas | Keep same 5 thinking styles as code but reframe for strategy domain vocabulary. | |

**User's choice:** Startup advisory dynamic
**Notes:** Customer Champion is a strong differentiator — no code advisor thinks from the buyer's perspective.

| Option | Description | Selected |
|--------|-------------|----------|
| Fully independent names | Each strategy persona has its own name and mandate with no explicit link back to the code council. | ✓ |
| Acknowledged lineage | Strategy personas share conceptual lineage noted in docs but operate independently. | |
| Shared where lens fits | Keep some names (e.g., 'Contrarian') where the lens genuinely works across domains. | |

**User's choice:** Fully independent names
**Notes:** Clean separation — strategy personas stand on their own.

---

## Output Contracts

| Option | Description | Selected |
|--------|-------------|----------|
| Unique per advisor | Each advisor gets a unique, bespoke output template tuned to their lens. More work to author, stronger signal per advisor. | ✓ |
| Shared structure, different lens | All 5 advisors share a single output structure (Assessment, Risks, Opportunities, Recommendation) but each fills from their lens. | |
| Core + extensions | Shared core structure with optional advisor-specific sections. | |

**User's choice:** Unique per advisor
**Notes:** Matches the code council pattern where each persona has domain-specific output sections.

| Option | Description | Selected |
|--------|-------------|----------|
| Pure strategy vocabulary | Strategy-appropriate vocabulary throughout: viability, market fit, competitive position, ROI. No code/engineering terms. | ✓ |
| Shared where natural | Borrow some cross-cutting terms from code council where they apply (e.g., Confidence levels). | |
| Cross-council callouts | Explicitly flag when a strategy decision has technical implications, crossing into code territory. | |

**User's choice:** Pure strategy vocabulary
**Notes:** Clean domain separation.

---

## Synthesis Criteria

| Option | Description | Selected |
|--------|-------------|----------|
| Same structure, strategy language | Keep the same 6-section structure but replace code vocabulary with strategy vocabulary. Consistent UX across councils. | |
| Fully custom strategy axes | Custom synthesis: Strategic Question, Viability Assessment, Market Fit Analysis, Risk/Reward Matrix, Competitive Position, Go/No-Go/Pivot Verdict. | ✓ |
| Hybrid | Keep agreements/clashes/blind spots but replace recommendation with strategy-specific verdict section. | |

**User's choice:** Fully custom strategy axes
**Notes:** Strong signal that each council should feel like a native domain tool, not a reskin.

| Option | Description | Selected |
|--------|-------------|----------|
| Three-value verdict | Go, No-Go, or Pivot. Clear, decisive, no hedging. Conditions listed under verdict. | ✓ |
| Conditional paragraph | Recommendation paragraph with nuance — 'Go if X, pivot if Y, no-go if Z.' | |
| Scored with confidence | Go (8/10 confidence) with a confidence score. | |

**User's choice:** Three-value verdict
**Notes:** Investment committee style — the call must be clear.

---

## Trigger Design

| Option | Description | Selected |
|--------|-------------|----------|
| Slash command + trigger phrases | `/council-strategy` plus natural language: 'strategy council', 'should we pivot', 'pricing strategy', etc. | ✓ |
| Slash command only | Only `/council-strategy`. Router handles natural language later. | |
| Slash command + alias + triggers | `/council-strategy` and shorter `/strategy` alias plus natural language. | |

**User's choice:** Slash command + trigger phrases
**Notes:** Natural language triggers listed in SKILL.md description frontmatter for Claude Code detection.

| Option | Description | Selected |
|--------|-------------|----------|
| By name in natural language | 'get the Devil's Advocate view on X'. Each agent file's description enables matching. | ✓ |
| Sub-command syntax | `/council-strategy devils-advocate`. More explicit but heavier. | |
| Full council only | No standalone advisor invocation. | |

**User's choice:** By name in natural language
**Notes:** Same pattern as code council — agent `description` frontmatter does the heavy lifting.

| Option | Description | Selected |
|--------|-------------|----------|
| Non-overlapping triggers | Strategy triggers don't overlap with code council triggers. Clean boundaries. | ✓ |
| Allow overlap, context-dependent | Some overlap allowed. Claude Code picks based on context. | |

**User's choice:** Non-overlapping triggers
**Notes:** Clean boundaries until router (Phase 3) formalizes disambiguation.

---

## Claude's Discretion

- Exact wording of each advisor's mandate paragraph
- Specific sections within each advisor's output template
- Tool access per advisor (frontmatter `tools` field)
- SKILL.md guardrails section wording
- Follow-up offer wording after synthesis

## Deferred Ideas

None — discussion stayed within phase scope
