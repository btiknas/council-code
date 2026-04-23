---
status: partial
phase: 01-foundation
source: [01-VERIFICATION.md]
started: 2026-04-23T21:00:00Z
updated: 2026-04-23T21:00:00Z
---

## Current Test

[awaiting human testing]

## Tests

### 1. End-to-end install cycle
expected: Run `./install.sh` — 5 code-*.md symlinks appear in `~/.claude/agents/`, settings.json patched
result: [pending]

### 2. Trigger phrase resolution
expected: Type `/council-code` or `/council` in new Claude Code session — council triggers identically to before rename
result: [pending]

### 3. Dual-name uninstall from pre-rename state
expected: `./install.sh --uninstall` removes both bare-name and code-prefixed files from `~/.claude/agents/`
result: [pending]

## Summary

total: 3
passed: 0
issues: 0
pending: 3
skipped: 0
blocked: 0

## Gaps
