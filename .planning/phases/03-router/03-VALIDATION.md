---
phase: 3
slug: router
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-24
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual verification (no test framework — this phase creates Markdown skill files, not executable code) |
| **Config file** | none |
| **Quick run command** | `ls skills/council-router/SKILL.md && echo "PASS"` |
| **Full suite command** | `grep -q "council-router" install.sh && grep -q "description:" skills/council-router/SKILL.md && echo "FULL PASS"` |
| **Estimated runtime** | ~1 second |

---

## Sampling Rate

- **After every task commit:** Run quick run command
- **After every plan wave:** Run full suite command
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 1 second

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| TBD | TBD | TBD | ROUT-01 | — | N/A | file-check | `test -f skills/council-router/SKILL.md` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | ROUT-02 | — | N/A | grep-check | `grep -q "confirm" skills/council-router/SKILL.md` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | ROUT-03 | — | N/A | grep-check | `grep -q "trigger" skills/council-code/SKILL.md` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] No test framework needed — validation is file/content verification
- [ ] Existing `install.sh` and SKILL.md patterns provide structural validation

*Existing infrastructure covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Router suggests correct council for a code question | ROUT-01 | LLM reasoning quality cannot be unit tested | Invoke `/council-router` with "stress test this architecture" and verify it suggests council-code with reasoning |
| Router waits for confirmation before dispatch | ROUT-02 | Interactive flow requires human verification | Invoke router, verify it presents suggestion and waits — does NOT auto-dispatch |
| `/council` invokes router (not council-code directly) | ROUT-01 | Skill routing is runtime behavior | Type `/council` and verify council-router skill activates |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 1s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
