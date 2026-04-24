---
phase: 02-council-strategy
plan: "01"
subsystem: agents
tags: [strategy, personas, advisory-council, agent-files]
dependency_graph:
  requires: []
  provides:
    - strategy-devils-advocate agent (STRT-01, STRT-02, STRT-04)
    - strategy-visionary agent (STRT-01, STRT-02, STRT-04)
    - strategy-pragmatist agent (STRT-01, STRT-02, STRT-04)
    - strategy-customer-champion agent (STRT-01, STRT-02, STRT-04)
    - strategy-operator agent (STRT-01, STRT-02, STRT-04)
  affects:
    - agents/ directory (adds 5 new strategy-prefixed agent files)
    - 02-02-PLAN.md (SKILL.md will reference these agent files)
    - 02-03-PLAN.md (install.sh will wire these into PERSONAS array)
tech_stack:
  added: []
  patterns:
    - Claude Code agent file pattern (name/description/tools frontmatter + 6-section body)
    - Strategy-native output template per advisor (unique bespoke sections, strategy vocabulary)
    - Individual advisor invocation via description frontmatter natural language matching
key_files:
  created:
    - agents/strategy-devils-advocate.md
    - agents/strategy-visionary.md
    - agents/strategy-pragmatist.md
    - agents/strategy-customer-champion.md
    - agents/strategy-operator.md
  modified: []
decisions:
  - "All 5 strategy advisors use tools: Read, Grep, Glob, WebSearch, WebFetch — not Bash. Strategy decisions require market research access, not codebase execution."
  - "Output templates use strategy-native section names that cannot be confused with code review sections: Fatal Assumption vs Fatal Flaw, Willingness to Pay vs Hidden Risks, 90-Day Execution Plan vs Commit Sequence."
  - "Description frontmatter for each advisor contains role name + domain + trigger phrases enabling Claude Code natural language matching for individual invocation (STRT-04)."
metrics:
  duration_minutes: 12
  completed_date: "2026-04-24"
  tasks_completed: 2
  tasks_total: 2
  files_created: 5
  files_modified: 0
---

# Phase 2 Plan 01: Strategy Advisor Agent Files Summary

5 strategy advisory council agent files with domain-native personas, unique bespoke output templates, and individually-invokable description frontmatter — forming the startup advisory board roster for business/product decisions.

## What Was Built

Five new agent files in `agents/` following the exact structural template of the code council advisors (6-section canonical order: frontmatter, H1+one-liner, Mandate, How you analyze, Output format, Rules) with strategy domain content substituted throughout.

### Agent Roster

| File | Role | One-Liner Job | Unique Output Sections |
|------|------|---------------|----------------------|
| `strategy-devils-advocate.md` | Assumption challenger | find why this strategy fails | Fatal Assumption, What Would Have to Be True, The Bear Case, Competitive Response, The One Number to Track |
| `strategy-visionary.md` | Long-horizon strategist | find the 10x opportunity the proposal undersells | The Bigger Market, 10-Year Position, Trend Tailwinds, The Adjacent Bet, What This Could Become |
| `strategy-pragmatist.md` | Resource realist | anchor this to what's actually achievable | Reality Check, Resource Requirements, The 90-Day Version, Inherited Constraints, What to Cut |
| `strategy-customer-champion.md` | Buyer advocate | represent the buyer's actual decision process | Willingness to Pay, What Customers Will Actually Do vs. What You Expect, Who This Is Really For, The Objection They Won't Say Out Loud, Market Signal |
| `strategy-operator.md` | Execution planner | turn this decision into a concrete execution plan | First Action, 90-Day Execution Plan, Resource Requirements, Critical Path, Risk I'm Accepting |

### Requirements Delivered

- **STRT-01**: 5 domain-native strategy advisors with business vocabulary — no code/engineering terms in mandate or output sections
- **STRT-02**: Unique output format per advisor — no two advisors share the same section names (except `## Confidence`)
- **STRT-04**: Each agent's `description` frontmatter contains role name + natural language trigger phrases enabling individual invocation ("get the Customer Champion view," "devil's advocate on this plan")

## Commits

| Task | Commit | Files |
|------|--------|-------|
| Task 1: Devil's Advocate, Visionary, Pragmatist | 617e422 | agents/strategy-devils-advocate.md, agents/strategy-visionary.md, agents/strategy-pragmatist.md |
| Task 2: Customer Champion, Operator | 59d1419 | agents/strategy-customer-champion.md, agents/strategy-operator.md |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed "codebase" from Pragmatist Rules section**
- **Found during:** Task 1 post-write verification
- **Issue:** Verification grep for code vocabulary (`codebase`) matched a rule that said "not an operations manager for the codebase" — the word appeared in a prohibition statement, not as actual code vocabulary
- **Fix:** Rephrased the rule to "not an engineering manager" to avoid ambiguity in future vocabulary checks
- **Files modified:** agents/strategy-pragmatist.md
- **Commit:** included in 617e422

No other deviations — plan executed as written.

## Known Stubs

None. Agent files are complete content artifacts, not placeholder stubs. All output templates have fully-specified section names and descriptions.

## Threat Flags

None. Per the plan's threat model:
- Agent `description` fields are used for natural language matching only, not authentication
- Agent files contain prompt instructions only, no secrets or PII

## Self-Check: PASSED

Files verified to exist:
- agents/strategy-devils-advocate.md: FOUND
- agents/strategy-visionary.md: FOUND
- agents/strategy-pragmatist.md: FOUND
- agents/strategy-customer-champion.md: FOUND
- agents/strategy-operator.md: FOUND

Commits verified:
- 617e422: FOUND (feat(02-01): add Devil's Advocate, Visionary, and Pragmatist strategy agents)
- 59d1419: FOUND (feat(02-01): add Customer Champion and Operator strategy agents)

Acceptance criteria verified:
- All 5 files have `name: strategy-*` in frontmatter
- All 5 files have `tools: Read, Grep, Glob, WebSearch, WebFetch`
- All 5 files have `## Mandate`, `## How you analyze strategy questions`, `## Output format`, `## Rules`
- All output templates end with `## Confidence`
- No `disable-model-invocation` in any agent file
- No code vocabulary (bug, refactor, technical debt, runtime, edge case, codebase, lint, test suite) in mandate or output sections
- Each file's `description` contains advisor name + domain + trigger phrases for individual invocation
- Trigger phrases do not overlap with code council (no "stress test," "code review," "second opinion on code")
