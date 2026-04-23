---
phase: 01-foundation
plan: "01"
subsystem: agents
tags: [rename, namespace, agent-files, skill-orchestrator]
dependency_graph:
  requires: []
  provides: [code-prefixed agent files, updated SKILL.md orchestrator]
  affects: [install.sh symlinks, CLAUDE.md agent listing]
tech_stack:
  added: []
  patterns: [code- namespace prefix for agent files, disable-model-invocation frontmatter]
key_files:
  created: []
  modified:
    - agents/code-contrarian.md
    - agents/code-first-principles.md
    - agents/code-expansionist.md
    - agents/code-outsider.md
    - agents/code-executor.md
    - skills/council-code/SKILL.md
decisions:
  - "Hard cutover to code- prefix with no compatibility shims (per D-01)"
  - "disable-model-invocation: true added to SKILL.md frontmatter (per FOUND-03/D-09)"
  - "name: council-code left unchanged to preserve /council and /council-code triggers (per FOUND-04)"
metrics:
  duration: "~5 minutes"
  completed: "2026-04-23"
  tasks_completed: 2
  tasks_total: 2
  files_modified: 6
requirements_satisfied: [FOUND-01, FOUND-03, FOUND-04]
---

# Phase 1 Plan 01: Agent Rename and SKILL.md Update Summary

**One-liner:** Hard cutover to code- namespace prefix on all 5 agent files plus disable-model-invocation frontmatter in SKILL.md orchestrator.

## What Was Done

Renamed all 5 agent files from bare names to code-prefixed names (e.g., `contrarian.md` -> `code-contrarian.md`) and updated the `name:` field in each file's YAML frontmatter to match. Updated `skills/council-code/SKILL.md` to add `disable-model-invocation: true` to its frontmatter and updated all 6 agent path references (1 body + 5 in References section) to use the new code- prefix.

## Tasks

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Rename 5 agent files with code- prefix | 50aa965 | agents/code-contrarian.md, agents/code-first-principles.md, agents/code-expansionist.md, agents/code-outsider.md, agents/code-executor.md |
| 2 | Update SKILL.md frontmatter and agent references | 86f4c0d | skills/council-code/SKILL.md |

## Verification Results

- `ls agents/code-*.md` returns exactly 5 files
- No bare-name agent files exist in agents/
- `grep "disable-model-invocation: true" skills/council-code/SKILL.md` matches
- `grep "name: council-code" skills/council-code/SKILL.md` matches (trigger preserved)
- `grep -c "agents/code-" skills/council-code/SKILL.md` returns 6

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None.

## Threat Flags

None — all changes are local Markdown file renames and edits at the repo level, no new network endpoints, auth paths, or trust boundaries introduced. T-01-02 (SKILL.md broken frontmatter) mitigated: frontmatter opens at line 1, closes at line 5, all required keys present and verified.

## Self-Check: PASSED

- agents/code-contrarian.md: FOUND
- agents/code-first-principles.md: FOUND
- agents/code-expansionist.md: FOUND
- agents/code-outsider.md: FOUND
- agents/code-executor.md: FOUND
- skills/council-code/SKILL.md: FOUND (disable-model-invocation: true confirmed)
- Commit 50aa965: FOUND
- Commit 86f4c0d: FOUND
