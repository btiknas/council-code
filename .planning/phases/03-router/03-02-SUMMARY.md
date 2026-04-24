---
phase: 03-router
plan: 02
subsystem: install
tags: [install, skills, council-router, routing]
dependency_graph:
  requires:
    - 03-01 (skills/council-router/SKILL.md must exist to be symlinked)
  provides:
    - install.sh updated to symlink council-router on install
  affects:
    - ~/.claude/skills/council-router symlink created by ./install.sh
    - /council invocation path fully operational after reinstall
tech_stack:
  added: []
  patterns:
    - SKILLS array entry causes install/uninstall loop to handle new skill automatically
key_files:
  created: []
  modified:
    - install.sh
decisions:
  - "D-11: Success message updated to mention /council as smart entry point (in addition to /council-code)"
metrics:
  duration: "< 5m"
  completed: "2026-04-24"
  tasks_completed: 1
  tasks_total: 2
  files_created: 0
  files_modified: 1
requirements:
  - ROUT-01
  - ROUT-02
status: checkpoint-pending
---

# Phase 3 Plan 02: Install.sh Update and End-to-End Verification Summary

**One-liner:** install.sh SKILLS array updated with council-router entry; end-to-end routing verification pending human checkpoint.

## What Was Built

### Task 1 — Add council-router to install.sh SKILLS array (commit 98060e2)

Two changes to `install.sh`:

1. **Line 132 — SKILLS array:** Added `council-router` as 4th entry:
   ```bash
   SKILLS=( council-code council-update council-strategy council-router )
   ```

2. **Line 188 — Success message:** Updated to reflect `/council` as the smart entry point per D-11:
   ```bash
   ok "done. Restart Claude Code, then try: /council or /council-code"
   ```

No other changes: PERSONAS array (10 entries), HOOKS array (4 entries), and LEGACY_PERSONAS array are all unchanged. The existing install and uninstall loops iterate over SKILLS automatically, so the new entry is handled by both without further modification.

Files modified: `install.sh`

### Task 2 — End-to-end verification (checkpoint pending)

Human verification required. See checkpoint details below.

## Verification Results (Task 1)

| Check | Result |
|-------|--------|
| `bash -n install.sh` exits 0 | PASS |
| `grep "SKILLS=" install.sh` contains "council-router" | PASS |
| SKILLS array has exactly 4 entries | PASS |
| PERSONAS array unchanged (10 entries) | PASS |
| HOOKS array unchanged (4 entries) | PASS |
| `bash install.sh --help` exits 0 | PASS |
| Success message mentions `/council or /council-code` | PASS |
| No unexpected file deletions in commit | PASS |

## Checkpoint: Task 2 — End-to-End Verification

**Status:** PENDING — awaiting human verification

**What was built across Phase 3:**
1. `skills/council-router/SKILL.md` — new router orchestrator (Plan 01, commit 96a5009)
2. `skills/council-code/SKILL.md` — updated with trigger phrases in description frontmatter (Plan 01, commit 4011f9a)
3. `install.sh` — updated with council-router in SKILLS array (Plan 02, Task 1, commit 98060e2)

**Verification steps:**

**Step 1:** Re-install to pick up the new skill:
```bash
cd /Users/D052192/src/council-code
./install.sh
```
Verify output shows "linked ~/.claude/skills/council-router".

**Step 2:** Restart Claude Code to load the new skill definitions.

**Step 3:** Test `/council-router` direct invocation — expect router presents suggestion with reasoning and A/B confirm gate.

**Step 4:** Test `/council` reassignment (D-11) — expect router invoked (not council-code directly).

**Step 5:** Confirm dispatch — select option A, expect council launches in the same conversation.

**Step 6:** Test direct shortcuts still work — `/council-code Should I refactor this module?` should go directly to council-code.

**Resume signal:** Type "approved" if all 6 steps pass, or describe which step(s) failed.

## Deviations from Plan

None — plan executed exactly as written. One SKILLS entry and one message string changed.

## Known Stubs

None — install.sh is fully functional. The council-router skill directory exists (created in Plan 01) and will be symlinked by the updated installer.

## Threat Flags

None — this plan modifies only the SKILLS array in install.sh. No new network endpoints, auth paths, file access patterns, or schema changes at trust boundaries. Threat register entries T-03-05 and T-03-06 are both accepted (no mitigation required).

## Self-Check: PASSED

- `install.sh` modified with council-router in SKILLS: CONFIRMED
- Task 1 commit `98060e2`: CONFIRMED
- Task 2 checkpoint: PENDING (human verification required)
