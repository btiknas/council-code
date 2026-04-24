---
phase: 03-router
plan: 01
subsystem: skills/routing
tags: [router, skill-orchestrator, trigger-phrases, council-code, council-router]
dependency_graph:
  requires: []
  provides:
    - skills/council-router/SKILL.md
    - skills/council-code/SKILL.md (trigger phrases in description frontmatter)
  affects:
    - /council trigger reassigned from council-code to council-router (D-11)
    - Natural language routing for code and strategy councils (ROUT-03)
tech_stack:
  added: []
  patterns:
    - Skill tool chaining (council-router -> council-code/council-strategy via Skill(skill="..."))
    - AskUserQuestion confirm gate before dispatch
    - Static council registry in router SKILL.md body (D-02)
    - Trigger phrases in description frontmatter for Claude Code routing (ROUT-03 pattern)
key_files:
  created:
    - skills/council-router/SKILL.md
  modified:
    - skills/council-code/SKILL.md
decisions:
  - "D-11: /council trigger reassigned from council-code to council-router; /council-code is the direct shortcut"
  - "D-02: Static council list in router SKILL.md updated manually when new councils ship"
  - "D-07: Router passes original question as-is to dispatched council; no reformulation"
  - "ROUT-02: Router always presents suggestion with confirmation gate; never auto-dispatches"
metrics:
  duration: "2m 8s"
  completed: "2026-04-24T08:20:39Z"
  tasks_completed: 2
  tasks_total: 2
  files_created: 1
  files_modified: 1
requirements:
  - ROUT-01
  - ROUT-02
  - ROUT-03
---

# Phase 3 Plan 01: Router Skill and Trigger Phrase Update Summary

**One-liner:** Council-router orchestrator with inline LLM classification, AskUserQuestion confirm gate, and Skill-tool dispatch; /council trigger reassigned from council-code to council-router.

## What Was Built

### Task 1 — Add trigger phrases to council-code description frontmatter (commit 4011f9a)

Updated `skills/council-code/SKILL.md` with two changes:

1. **Description frontmatter** (line 3): Appended `Trigger phrases: /council-code, code council, architecture choices, library selection, refactor vs rewrite, performance strategy, API design, code review, debugging hypotheses, stress test this approach, what am I missing.` to the end of the description value. `/council` is intentionally absent — that trigger moves to council-router per D-11.

2. **Body trigger line** (line 23): Changed `/council` and `council` to `/council-code` and `council-code` respectively. This is belt-and-suspenders — the body trigger phrases are behavioral guidance, not routing metadata, but they should be consistent with the frontmatter after the reassignment.

Files modified: `skills/council-code/SKILL.md`

### Task 2 — Create council-router SKILL.md orchestrator (commit 96a5009)

Created `skills/council-router/` directory and `skills/council-router/SKILL.md` (118 lines).

**Frontmatter:**
- `name: council-router`
- `description` includes "Smart council selector" and `Trigger phrases: which council, route this, help me pick a council, /council, /council-router`
- `disable-model-invocation: true`
- `allowed-tools: [AskUserQuestion, Skill]` — explicit declaration required for Skill-to-Skill invocation (Pitfall 5)

**Body structure:**
- `## When to use this skill` — explicit routing triggers only (/council, /council-router, "which council", "route this")
- `## When NOT to use` — "second opinion", "stress test" explicitly excluded (D-13)
- `## Installed Councils` — static list of council-code and council-strategy only (D-09)
- `## Protocol` with 3 steps: classify (inline LLM reasoning), suggest (AskUserQuestion A/B confirm), dispatch (Skill tool)
- `## Guardrails` — 6 bullets covering all non-negotiable constraints

Files created: `skills/council-router/SKILL.md`

## Verification Results

| Check | Result |
|-------|--------|
| `grep "Trigger phrases:" skills/council-code/SKILL.md` returns 2 lines | PASS |
| `/council-code` in council-code description frontmatter | PASS |
| No bare `/council` in council-code (0 matches) | PASS |
| council-router SKILL.md exists, 118 lines (>= 80) | PASS |
| No uninstalled council references in council-router | PASS |
| `allowed-tools` with `AskUserQuestion` and `Skill` | PASS |
| `/council` trigger in council-router description | PASS |
| `Skill(skill="council-code")` and `Skill(skill="council-strategy")` dispatch examples | PASS |
| No `args` in Skill dispatch | PASS |
| 6 guardrail bullets (>= 5) | PASS |

## Deviations from Plan

None — plan executed exactly as written. Both tasks followed the specified structure, patterns, and constraints from 03-RESEARCH.md and 03-CONTEXT.md.

## Known Stubs

None — both files are fully functional SKILL.md orchestrators. council-router's static council list is complete for the currently installed councils (council-code, council-strategy). The list requires manual update when new councils ship in later phases (D-02).

## Threat Flags

None — this plan adds Markdown skill files only. No new network endpoints, auth paths, file access patterns, or schema changes at trust boundaries.

## Requirements Coverage

| Req ID | Description | Status |
|--------|-------------|--------|
| ROUT-01 | User can invoke council-router skill that classifies their question and suggests the most appropriate council | Covered by skills/council-router/SKILL.md with 3-step protocol |
| ROUT-02 | Router always presents suggestion with reasoning and waits for user confirmation before dispatching | Covered by AskUserQuestion confirm gate in Step 2; "Never auto-dispatch" guardrail |
| ROUT-03 | Each council SKILL.md has domain-specific trigger phrases in its description frontmatter | Covered by council-code description frontmatter update + council-strategy already had it |

## Self-Check: PASSED

- `skills/council-code/SKILL.md` exists and modified: FOUND
- `skills/council-router/SKILL.md` exists: FOUND
- Task 1 commit `4011f9a`: FOUND
- Task 2 commit `96a5009`: FOUND
