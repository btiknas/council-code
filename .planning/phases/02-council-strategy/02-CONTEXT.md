# Phase 2: Council Strategy - Context

**Gathered:** 2026-04-23
**Status:** Ready for planning

<domain>
## Phase Boundary

First new council proving the multi-council pattern end-to-end. Delivers 5 domain-native strategy advisors for business and product decisions (pricing, market, roadmap, partnerships), a strategy-specific SKILL.md orchestrator with custom synthesis, and individual advisor invocation. This phase validates the pattern that all subsequent councils (design, research, review) will follow.

</domain>

<decisions>
## Implementation Decisions

### Advisor Roster
- **D-01:** Startup advisory dynamic — 5 personas: Devil's Advocate, Visionary, Pragmatist, Customer Champion, Operator
- **D-02:** Fully independent names — no conceptual lineage to code council personas. Each strategy advisor stands on its own with strategy-native identity and mandate.
- **D-03:** Agent files named `strategy-devils-advocate.md`, `strategy-visionary.md`, `strategy-pragmatist.md`, `strategy-customer-champion.md`, `strategy-operator.md`

### Output Contracts
- **D-04:** Unique output template per advisor — each persona gets a bespoke structured output format tuned to its lens (same pattern as code council where Contrarian has "Fatal Flaw" and Executor has "Monday Morning" sections)
- **D-05:** Pure strategy vocabulary — output templates use domain-native terms (viability, market fit, competitive position, ROI, willingness to pay). No code/engineering terms. Clean domain separation.

### Synthesis Criteria
- **D-06:** Fully custom strategy synthesis axes — NOT the code council's agreements/clashes/blind spots structure. Strategy chairman uses: Strategic Question → Viability Assessment → Market Fit Analysis → Risk/Reward Matrix → Competitive Position → Go/No-Go/Pivot Verdict
- **D-07:** Three-value categorical verdict — Go, No-Go, or Pivot. Conditions can be listed under the verdict but the call itself is one of three values. No hedging.

### Trigger Design
- **D-08:** Primary invocation via `/council-strategy`. Natural language triggers in SKILL.md description: "strategy council", "evaluate this business decision", "should we pivot", "pricing strategy", "market analysis", "business strategy"
- **D-09:** Individual advisors invokable by name in natural language — "get the Devil's Advocate view on X", "what would the Customer Champion say about Y". Each agent file's `description` frontmatter enables Claude Code matching.
- **D-10:** Non-overlapping triggers with code council — "stress test" stays with code, "evaluate this strategy" goes to strategy. Clean boundaries until the router (Phase 3) formalizes disambiguation.

### Claude's Discretion
- Exact wording of each advisor's mandate paragraph
- Specific sections within each advisor's output template (the structural pattern is locked — unique per advisor, strategy vocabulary — but exact section names are implementation detail)
- Tool access per advisor (`tools` field in frontmatter) — likely same as code advisors (Read, Grep, Glob, WebSearch, WebFetch) but may vary
- SKILL.md guardrails section wording (follow code council pattern but adapt for strategy domain)
- Follow-up offer wording after synthesis

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing council-code (template to follow)
- `agents/code-contrarian.md` — Reference for agent file structure: frontmatter (name, description, tools), title, mandate, analysis steps, output format, rules
- `agents/code-executor.md` — Reference for action-oriented advisor pattern (Operator will follow similar "what to do next" lens)
- `skills/council-code/SKILL.md` — Reference for orchestrator structure: frontmatter, when-to-use, protocol (extract → spawn parallel → synthesize → offer follow-up), guardrails, references

### Infrastructure
- `install.sh` — Must be updated to include strategy agent files in PERSONAS array and strategy skill in SKILLS array
- `.claude-plugin/plugin.json` — Plugin manifest (may need version bump or description update)
- `hooks/patch-settings.js` — Shared settings patcher (no changes needed for new council, but used during install)

### Requirements
- `.planning/REQUIREMENTS.md` §Council: Strategy — STRT-01 through STRT-04

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `agents/code-*.md` — 5 existing agent files that serve as the structural template for all strategy agents. The frontmatter schema, section ordering, and output format contract pattern are proven and should be replicated.
- `skills/council-code/SKILL.md` — Orchestrator template. Strategy SKILL.md should follow the same protocol pattern: extract decision → spawn 5 in parallel → synthesize → offer follow-up.

### Established Patterns
- **Agent frontmatter:** `name`, `description`, `tools` fields in YAML frontmatter
- **Agent body:** Title → Mandate → "How you analyze" numbered steps → Output format (fenced code block) → Rules (bullet list)
- **Skill frontmatter:** `name`, `description`, `disable-model-invocation: true`
- **Parallel spawning:** Single message with 5 Agent tool calls, `subagent_type: general-purpose`
- **Naming:** `{council}-{persona}.md` for agents, `council-{domain}` for skill directories

### Integration Points
- `install.sh` PERSONAS array — new strategy agent files must be added
- `install.sh` SKILLS array — `council-strategy` skill directory must be added
- `~/.claude/agents/` — Where strategy agent files get symlinked
- `~/.claude/skills/council-strategy/` — Where skill directory gets symlinked

</code_context>

<specifics>
## Specific Ideas

- The 5 personas follow a startup advisory board dynamic — the kind of advisors a founder would want around a table. Devil's Advocate challenges, Visionary thinks long-term, Pragmatist anchors to reality, Customer Champion represents the buyer, Operator grounds everything in execution.
- Synthesis verdict is explicitly categorical (Go/No-Go/Pivot) — inspired by investment committee style decision-making where the call must be clear even if conditions are attached.
- Each advisor's output template should feel native to its domain the way a Contrarian's "Fatal Flaw" section feels native to code review — e.g., Customer Champion might have "Willingness to Pay" and "What Customers Will Actually Do vs What You Expect".

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-council-strategy*
*Context gathered: 2026-04-23*
