---
phase: 2
slug: council-strategy
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-23
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual verification (no test framework — this is a content/config phase) |
| **Config file** | none |
| **Quick run command** | `ls agents/strategy-*.md skills/council-strategy/SKILL.md` |
| **Full suite command** | `bash -c 'for f in agents/strategy-*.md; do head -3 "$f" | grep -q "^---" && echo "✓ $f" || echo "✗ $f"; done && test -f skills/council-strategy/SKILL.md && echo "✓ SKILL.md"'` |
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
| 02-01-01 | 01 | 1 | STRT-01 | — | N/A | file-check | `test -f agents/strategy-devils-advocate.md` | ❌ W0 | ⬜ pending |
| 02-01-02 | 01 | 1 | STRT-01 | — | N/A | file-check | `test -f agents/strategy-visionary.md` | ❌ W0 | ⬜ pending |
| 02-01-03 | 01 | 1 | STRT-01 | — | N/A | file-check | `test -f agents/strategy-pragmatist.md` | ❌ W0 | ⬜ pending |
| 02-01-04 | 01 | 1 | STRT-01 | — | N/A | file-check | `test -f agents/strategy-customer-champion.md` | ❌ W0 | ⬜ pending |
| 02-01-05 | 01 | 1 | STRT-01 | — | N/A | file-check | `test -f agents/strategy-operator.md` | ❌ W0 | ⬜ pending |
| 02-02-01 | 02 | 1 | STRT-02, STRT-03 | — | N/A | content-check | `grep -q "strategy-specific" skills/council-strategy/SKILL.md` | ❌ W0 | ⬜ pending |
| 02-03-01 | 03 | 2 | STRT-04 | — | N/A | content-check | `grep -c "strategy-" install.sh` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- *Existing infrastructure covers all phase requirements — no test framework needed for content/config phase.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Strategy vocabulary in advisor output | STRT-02 | Requires reading generated analysis text | Invoke `/council-strategy` with a business decision, verify each advisor uses strategy terms (viability, market fit, ROI) not code terms |
| Chairman Go/No-Go/Pivot verdict | STRT-03 | Requires running synthesis and reading output | Run full council, verify synthesis contains exactly one of: Go, No-Go, Pivot |
| Individual advisor invocation | STRT-04 | Requires natural language interaction | Say "get the Devil's Advocate view on X", verify only that advisor responds |

*All structural/file behaviors have automated verification above.*

---

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 1s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
