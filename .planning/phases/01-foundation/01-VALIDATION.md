---
phase: 1
slug: foundation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-23
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | bash + manual verification (shell script project, no test framework) |
| **Config file** | none — shell-based validation |
| **Quick run command** | `bash -n install.sh && node --check hooks/patch-settings.js` |
| **Full suite command** | `bash -n install.sh && node --check hooks/patch-settings.js && ls agents/code-*.md` |
| **Estimated runtime** | ~2 seconds |

---

## Sampling Rate

- **After every task commit:** Run `bash -n install.sh && node --check hooks/patch-settings.js`
- **After every plan wave:** Run full suite command
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 2 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 1-01-01 | 01 | 1 | FOUND-01 | — | N/A | file-check | `ls agents/code-contrarian.md agents/code-executor.md agents/code-expansionist.md agents/code-first-principles.md agents/code-outsider.md` | ❌ W0 | ⬜ pending |
| 1-01-02 | 01 | 1 | FOUND-01 | — | N/A | file-check | `test ! -f agents/contrarian.md && test ! -f agents/executor.md` | ✅ | ⬜ pending |
| 1-02-01 | 02 | 1 | FOUND-02 | — | N/A | syntax | `node --check hooks/patch-settings.js` | ❌ W0 | ⬜ pending |
| 1-02-02 | 02 | 1 | FOUND-02 | — | N/A | grep | `grep -q "patch-settings.js" install.sh` | ✅ | ⬜ pending |
| 1-03-01 | 03 | 1 | FOUND-03 | — | N/A | grep | `grep -q "disable-model-invocation: true" skills/council-code/SKILL.md` | ✅ | ⬜ pending |
| 1-04-01 | 04 | 2 | FOUND-04 | — | N/A | grep | `grep -q "code-contrarian" skills/council-code/SKILL.md` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Agent files renamed from bare to code-prefixed names
- [ ] `hooks/patch-settings.js` created as standalone CLI tool
- [ ] SKILL.md updated with new agent references and frontmatter

*Existing infrastructure covers basic validation — no test framework install needed.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| `/council-code` trigger works | FOUND-04 | Requires live Claude Code runtime | Invoke `/council-code` in Claude Code, verify 5 advisors spawn |
| `/council` trigger works | FOUND-04 | Requires live Claude Code runtime | Invoke `/council` in Claude Code, verify same behavior as `/council-code` |
| install.sh re-run cleans old symlinks | FOUND-01 | Requires `~/.claude/agents/` state | Run `./install.sh`, verify old bare-name files removed from `~/.claude/agents/` |
| `--uninstall` removes both old and new | FOUND-01 | Requires `~/.claude/agents/` state | Run `./install.sh --uninstall`, verify both naming schemes removed |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 2s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
