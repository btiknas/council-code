---
status: testing
phase: 01-foundation
source: [01-01-SUMMARY.md, 01-02-SUMMARY.md, 01-03-SUMMARY.md]
started: 2026-04-23T20:15:00Z
updated: 2026-04-23T20:16:00Z
---

## Current Test

number: 6
name: End-to-end install cycle
expected: |
  Run `./install.sh` — 5 code-*.md symlinks appear in `~/.claude/agents/`, settings.json patched with statusLine and SessionStart hook. Run `./install.sh --uninstall` — all symlinks removed, settings.json restored.
awaiting: user response

## Tests

### 1. Agent files use code- prefix
expected: `ls agents/code-*.md` returns exactly 5 files. No bare-name agent files exist in agents/.
result: pass

### 2. SKILL.md orchestrator references updated agents
expected: SKILL.md frontmatter contains `disable-model-invocation: true` and `name: council-code`. All agent path references use code- prefix (6 total).
result: pass

### 3. patch-settings.js standalone operation
expected: No-args prints usage and exits non-zero. Syntax valid. Only Node.js stdlib (fs, path).
result: pass

### 4. install.sh integrates code-prefix and patcher
expected: PERSONAS array code-prefixed. HOOKS includes patch-settings.js. No heredocs. 2 patcher calls.
result: pass

### 5. Dual-name uninstall cleanup
expected: LEGACY_PERSONAS array with bare names and cleanup loop during uninstall.
result: pass

### 6. End-to-end install cycle
expected: Run `./install.sh` — 5 code-*.md symlinks appear in `~/.claude/agents/`, settings.json patched. Run `./install.sh --uninstall` — all removed, settings.json restored.
result: [pending]

## Summary

total: 6
passed: 5
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps
